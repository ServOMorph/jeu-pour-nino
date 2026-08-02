"""Lance MimicMotion en local sur un cycle de poses deja preprocesses."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import sys
import time
from pathlib import Path

import cv2
import numpy as np
import torch
from PIL import Image


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def fit_reference(
    path: Path,
    width: int,
    height: int,
    background: tuple[int, int, int],
    background_mode: str,
) -> Image.Image:
    source_rgba = Image.open(path).convert("RGBA")
    source_rgba.thumbnail((width, height), Image.Resampling.LANCZOS)
    if background_mode == "studio":
        rows = np.linspace(175, 112, height, dtype=np.uint8)[:, None]
        studio = np.repeat(rows, width, axis=1)
        studio[int(height * 0.78):] = np.linspace(
            105, 78, height - int(height * 0.78), dtype=np.uint8
        )[:, None]
        rgb = np.stack((studio, studio, studio), axis=2)
        canvas = Image.fromarray(rgb, "RGB").convert("RGBA")
    else:
        canvas = Image.new("RGBA", (width, height), (*background, 255))
    canvas.alpha_composite(
        source_rgba,
        ((width - source_rgba.width) // 2, (height - source_rgba.height) // 2),
    )
    return canvas.convert("RGB")


def load_pose(path: Path, width: int, height: int) -> np.ndarray:
    frame = cv2.imread(str(path), cv2.IMREAD_COLOR)
    if frame is None:
        raise ValueError(f"pose illisible: {path}")
    if frame.shape[:2] != (height, width):
        frame = cv2.resize(frame, (width, height), interpolation=cv2.INTER_NEAREST)
    return cv2.cvtColor(frame, cv2.COLOR_BGR2RGB).transpose(2, 0, 1)


def write_outputs(frames: torch.Tensor, output_dir: Path, fps: int) -> Path:
    output_dir.mkdir(parents=True, exist_ok=True)
    video_path = output_dir / "player_run_mimicmotion_probe.mp4"
    height, width = frames.shape[-2:]
    writer = cv2.VideoWriter(
        str(video_path), cv2.VideoWriter_fourcc(*"mp4v"), fps, (width, height)
    )
    if not writer.isOpened():
        raise RuntimeError("impossible d'ouvrir l'encodeur MP4")
    for index, frame in enumerate(frames):
        rgb = frame.permute(1, 2, 0).numpy()
        Image.fromarray(rgb).save(output_dir / f"frame_{index:02d}.png")
        writer.write(cv2.cvtColor(rgb, cv2.COLOR_RGB2BGR))
    writer.release()
    return video_path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--mimic-root", default=r"D:\AI\MimicMotion")
    parser.add_argument("--reference", required=True)
    parser.add_argument("--reference-pose")
    parser.add_argument("--control-dir")
    parser.add_argument("--control-video")
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--width", type=int, default=448)
    parser.add_argument("--height", type=int, default=640)
    parser.add_argument("--fps", type=int, default=16)
    parser.add_argument("--steps", type=int, default=15)
    parser.add_argument("--seed", type=int, default=20260801)
    parser.add_argument("--background", default="128,128,128")
    parser.add_argument("--background-mode", choices=("solid", "studio"), default="solid")
    args = parser.parse_args()

    mimic_root = Path(args.mimic_root).resolve()
    reference_path = Path(args.reference).resolve()
    reference_pose_path = Path(args.reference_pose).resolve() if args.reference_pose else None
    control_dir = Path(args.control_dir).resolve() if args.control_dir else None
    control_video = Path(args.control_video).resolve() if args.control_video else None
    output_dir = Path(args.output_dir).resolve()
    sys.path.insert(0, str(mimic_root))
    os.chdir(mimic_root)
    from mimicmotion.utils.loader import create_pipeline

    background = tuple(int(value) for value in args.background.split(","))
    if len(background) != 3 or any(value < 0 or value > 255 for value in background):
        raise ValueError("--background attend R,G,B avec des valeurs 0..255")
    reference = fit_reference(
        reference_path, args.width, args.height, background, args.background_mode
    )
    control_paths: list[Path] = []
    if control_video is not None:
        from mimicmotion.dwpose.preprocess import get_image_pose, get_video_pose
        reference_array = np.asarray(reference)
        image_pose = get_image_pose(reference_array)
        video_poses = get_video_pose(str(control_video), reference_array, sample_stride=1)
        if len(video_poses) < 16:
            raise ValueError(f"16 poses requises, {len(video_poses)} trouvees dans la video")
        pose_arrays = [image_pose, *list(video_poses[:16])]
    else:
        if reference_pose_path is None or control_dir is None:
            raise ValueError("fournir --control-video ou le couple --reference-pose/--control-dir")
        control_paths = sorted(control_dir.glob("pose_*.png"))
        if len(control_paths) != 16:
            raise ValueError(f"16 poses requises, {len(control_paths)} trouvees")
        pose_arrays = [load_pose(reference_pose_path, args.width, args.height)]
        pose_arrays.extend(load_pose(path, args.width, args.height) for path in control_paths)
    pose_pixels = torch.from_numpy(np.stack(pose_arrays)).to(torch.float16) / 127.5 - 1.0

    class Config:
        base_model_path = str(mimic_root / "models" / "stable-video-diffusion-img2vid-xt-1-1")
        ckpt_path = str(mimic_root / "models" / "MimicMotion_1-1.pth")

    if not torch.cuda.is_available():
        raise RuntimeError("CUDA indisponible")
    torch.backends.cuda.matmul.allow_tf32 = True
    torch.set_default_dtype(torch.float16)
    device = torch.device("cuda")
    started = time.perf_counter()
    pipeline = create_pipeline(Config, device)

    generator = torch.Generator(device=device).manual_seed(args.seed)
    result = pipeline(
        [reference],
        image_pose=pose_pixels,
        num_frames=pose_pixels.size(0),
        tile_size=16,
        tile_overlap=6,
        height=args.height,
        width=args.width,
        fps=args.fps,
        noise_aug_strength=0.0,
        num_inference_steps=args.steps,
        generator=generator,
        min_guidance_scale=2.0,
        max_guidance_scale=2.0,
        decode_chunk_size=1,
        output_type="pt",
        device=device,
    ).frames.cpu()
    frames = (result[0, 1:] * 255.0).clamp(0, 255).to(torch.uint8)
    video_path = write_outputs(frames, output_dir, args.fps)
    report = {
        "backend": "Tencent/MimicMotion 1.1 local",
        "base_model": "weights/stable-video-diffusion-img2vid-xt-1-1",
        "reference": str(reference_path),
        "reference_sha256": sha256(reference_path),
        "control_frames": [str(path) for path in control_paths],
        "control_video": str(control_video) if control_video else None,
        "frame_count": int(frames.shape[0]),
        "canvas": [args.width, args.height],
        "fps": args.fps,
        "steps": args.steps,
        "seed": args.seed,
        "guidance_scale": 2.0,
        "decode_chunk_size": 1,
        "elapsed_seconds": time.perf_counter() - started,
        "video": str(video_path),
        "video_sha256": sha256(video_path),
    }
    (output_dir / "generation_report.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
