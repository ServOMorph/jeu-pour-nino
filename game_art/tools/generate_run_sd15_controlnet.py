"""Génère un cycle de course local avec SD 1.5, Multi-ControlNet et IP-Adapter."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import cv2
import numpy as np
import torch
from diffusers import (
    ControlNetModel,
    DPMSolverMultistepScheduler,
    StableDiffusionControlNetPipeline,
)
from PIL import Image, ImageFilter


def load_pose(path: Path, size: tuple[int, int]) -> Image.Image:
    return Image.open(path).convert("RGB").resize(size, Image.Resampling.LANCZOS)


def load_silhouette_edges(path: Path, size: tuple[int, int]) -> Image.Image:
    rgba = Image.open(path).convert("RGBA")
    alpha = rgba.getchannel("A").filter(ImageFilter.GaussianBlur(radius=1.2))
    alpha = alpha.resize(size, Image.Resampling.LANCZOS)
    values = np.asarray(alpha)
    edges = cv2.Canny(values, 64, 160)
    edges = cv2.dilate(edges, np.ones((2, 2), dtype=np.uint8), iterations=1)
    return Image.fromarray(np.repeat(edges[:, :, None], 3, axis=2), mode="RGB")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--reference", required=True)
    parser.add_argument("--pose-dir", required=True)
    parser.add_argument("--silhouette-dir", required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--start-frame", type=int, default=1)
    parser.add_argument("--frame-count", type=int, default=1)
    parser.add_argument("--width", type=int, default=512)
    parser.add_argument("--height", type=int, default=736)
    parser.add_argument("--steps", type=int, default=24)
    parser.add_argument("--seed", type=int, default=813156)
    parser.add_argument("--openpose-scale", type=float, default=1.25)
    parser.add_argument("--silhouette-scale", type=float, default=0.8)
    parser.add_argument("--ip-scale", type=float, default=0.8)
    args = parser.parse_args()

    reference = Image.open(args.reference).convert("RGB")
    pose_dir = Path(args.pose_dir).resolve()
    silhouette_dir = Path(args.silhouette_dir).resolve()
    output_dir = Path(args.output_dir).resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    size = (args.width, args.height)

    dtype = torch.float16
    openpose = ControlNetModel.from_pretrained(
        "lllyasviel/control_v11p_sd15_openpose",
        torch_dtype=dtype,
        variant="fp16",
        use_safetensors=True,
    )
    canny = ControlNetModel.from_pretrained(
        "lllyasviel/control_v11p_sd15_canny",
        torch_dtype=dtype,
        variant="fp16",
        use_safetensors=True,
    )
    pipe = StableDiffusionControlNetPipeline.from_pretrained(
        "stable-diffusion-v1-5/stable-diffusion-v1-5",
        controlnet=[openpose, canny],
        torch_dtype=dtype,
        variant="fp16",
        use_safetensors=True,
        safety_checker=None,
        requires_safety_checker=False,
    )
    pipe.scheduler = DPMSolverMultistepScheduler.from_config(
        pipe.scheduler.config,
        algorithm_type="dpmsolver++",
        use_karras_sigmas=True,
    )
    pipe.load_ip_adapter(
        "h94/IP-Adapter",
        subfolder="models",
        weight_name="ip-adapter-plus_sd15.safetensors",
    )
    pipe.set_ip_adapter_scale(args.ip_scale)
    pipe.enable_model_cpu_offload()
    pipe.enable_vae_slicing()
    torch.backends.cuda.matmul.allow_tf32 = True

    prompt = (
        "masterpiece game sprite, single dark fantasy male, exact right-facing side "
        "profile, full body sprinting in place, reference identity costume and equipment "
        "unchanged, black hair, beard, black leather armor, torn cape behind the body, "
        "one sheathed longsword on the back, white background, "
        "fixed orthographic camera, sharp detail"
    )
    negative = (
        "two swords, duplicate sword, second sword hilt, missing sword, multiple people, "
        "duplicate limbs, extra arms, extra legs, three-quarter face, front view, back "
        "view, cropped, walking, standing, mannequin, low poly, text, blur, deformation"
    )

    report = {
        "model": "stable-diffusion-v1-5/stable-diffusion-v1-5",
        "controlnets": [
            "lllyasviel/control_v11p_sd15_openpose",
            "lllyasviel/control_v11p_sd15_canny",
        ],
        "ip_adapter": "h94/IP-Adapter/models/ip-adapter-plus_sd15.safetensors",
        "seed": args.seed,
        "steps": args.steps,
        "size": [args.width, args.height],
        "frames": [],
    }

    for frame in range(args.start_frame, args.start_frame + args.frame_count):
        pose_path = pose_dir / f"frame_{frame:04d}.png"
        silhouette_path = silhouette_dir / f"frame_{frame:04d}.png"
        pose = load_pose(pose_path, size)
        edges = load_silhouette_edges(silhouette_path, size)
        generator = torch.Generator(device="cpu").manual_seed(args.seed)
        image = pipe(
            prompt=prompt,
            negative_prompt=negative,
            image=[pose, edges],
            ip_adapter_image=reference,
            width=args.width,
            height=args.height,
            num_inference_steps=args.steps,
            guidance_scale=7.0,
            controlnet_conditioning_scale=[args.openpose_scale, args.silhouette_scale],
            control_guidance_start=[0.0, 0.0],
            control_guidance_end=[1.0, 0.9],
            generator=generator,
        ).images[0]
        output = output_dir / f"frame_{frame:03d}.png"
        image.save(output)
        edges.save(output_dir / f"control_edges_{frame:03d}.png")
        report["frames"].append({"frame": frame, "output": output.name})
        print(json.dumps(report["frames"][-1]))

    (output_dir / "generation_report.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )


if __name__ == "__main__":
    main()
