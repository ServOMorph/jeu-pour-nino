"""Normalise un lot de frames detourees dans des cases runtime fixes.

Usage :
  python game_art/tools/normalize_animation_frames.py ^
    --input-dir game_art/assets/generated_raw/player/run_frames_alpha ^
    --output-dir game_art/assets/generated_raw/player/run_frames_norm ^
    --sheet-out game_art/assets/generated_raw/player/player_run_sheet_candidate.png ^
    --frame-size 87x150

Le script :
1. charge des PNG avec alpha
2. mesure la bbox utile de chaque frame
3. calcule une echelle commune basee sur la mediane du lot
4. applique si besoin une correction individuelle minimale pour rester dans la case
5. aligne toutes les frames sur une meme ligne de sol
6. ecrit les frames normalisees, la strip finale et un rapport JSON
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from statistics import median

from PIL import Image


def parse_size(text: str) -> tuple[int, int]:
    w, h = text.lower().split("x", 1)
    return int(w), int(h)


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    bbox = image.getchannel("A").getbbox()
    if bbox is None:
        raise ValueError("image entierement transparente")
    return bbox


def load_frame(path: Path) -> dict:
    image = Image.open(path).convert("RGBA")
    x0, y0, x1, y1 = alpha_bbox(image)
    return {
        "path": path,
        "image": image,
        "bbox": [x0, y0, x1, y1],
        "width": x1 - x0,
        "height": y1 - y0,
        "bottom": y1 - 1,
    }


def compute_base_scale(
    frames: list[dict],
    max_content_w: int,
    max_content_h: int,
) -> tuple[float, list[float]]:
    fit_scales = [
        min(max_content_w / frame["width"], max_content_h / frame["height"])
        for frame in frames
    ]
    base = median(fit_scales)
    return base, fit_scales


def normalize_frame(
    frame: dict,
    target_w: int,
    target_h: int,
    base_scale: float,
    max_content_w: int,
    max_content_h: int,
    ground_y: int,
    center_x: float,
) -> tuple[Image.Image, dict]:
    x0, y0, x1, y1 = frame["bbox"]
    cropped = frame["image"].crop((x0, y0, x1, y1))
    fit_scale = min(max_content_w / frame["width"], max_content_h / frame["height"])
    applied_scale = min(base_scale, fit_scale)
    scaled_w = max(1, round(frame["width"] * applied_scale))
    scaled_h = max(1, round(frame["height"] * applied_scale))
    scaled = cropped.resize((scaled_w, scaled_h), Image.LANCZOS)

    canvas = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 0))
    off_x = round(center_x - scaled_w / 2)
    off_y = ground_y - scaled_h + 1
    off_x = max(0, min(target_w - scaled_w, off_x))
    off_y = max(0, min(target_h - scaled_h, off_y))
    canvas.alpha_composite(scaled, (off_x, off_y))

    norm_bbox = alpha_bbox(canvas)
    nx0, ny0, nx1, ny1 = norm_bbox
    report = {
        "source": frame["path"].name,
        "source_bbox": frame["bbox"],
        "source_width": frame["width"],
        "source_height": frame["height"],
        "fit_scale": fit_scale,
        "applied_scale": applied_scale,
        "scale_delta_vs_base": applied_scale - base_scale,
        "normalized_bbox": [nx0, ny0, nx1, ny1],
        "normalized_width": nx1 - nx0,
        "normalized_height": ny1 - ny0,
        "normalized_bottom": ny1 - 1,
        "offset_x": off_x,
        "offset_y": off_y,
    }
    return canvas, report


def build_sheet(frames: list[Image.Image], frame_w: int, frame_h: int) -> Image.Image:
    sheet = Image.new("RGBA", (frame_w * len(frames), frame_h), (0, 0, 0, 0))
    for index, frame in enumerate(frames):
        sheet.alpha_composite(frame, (index * frame_w, 0))
    return sheet


def summarize(report_frames: list[dict], base_scale: float) -> dict:
    widths = [frame["normalized_width"] for frame in report_frames]
    heights = [frame["normalized_height"] for frame in report_frames]
    bottoms = [frame["normalized_bottom"] for frame in report_frames]
    scale_deltas = [abs(frame["scale_delta_vs_base"]) for frame in report_frames]
    return {
        "base_scale": base_scale,
        "normalized_width_min": min(widths),
        "normalized_width_max": max(widths),
        "normalized_height_min": min(heights),
        "normalized_height_max": max(heights),
        "normalized_bottom_min": min(bottoms),
        "normalized_bottom_max": max(bottoms),
        "max_scale_delta_vs_base": max(scale_deltas),
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input-dir", required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--sheet-out", required=True)
    parser.add_argument("--frame-size", required=True)
    parser.add_argument("--top-pad", type=int, default=0)
    parser.add_argument("--bottom-pad", type=int, default=0)
    parser.add_argument("--side-pad", type=int, default=2)
    parser.add_argument("--report-out")
    args = parser.parse_args()

    frame_w, frame_h = parse_size(args.frame_size)
    input_dir = Path(args.input_dir)
    output_dir = Path(args.output_dir)
    sheet_out = Path(args.sheet_out)
    report_out = Path(args.report_out) if args.report_out else sheet_out.with_suffix(".json")

    output_dir.mkdir(parents=True, exist_ok=True)
    sheet_out.parent.mkdir(parents=True, exist_ok=True)

    source_paths = sorted(input_dir.glob("*.png"))
    if not source_paths:
        raise SystemExit("erreur : aucune frame trouvee")

    frames = [load_frame(path) for path in source_paths]
    max_content_w = frame_w - 2 * args.side_pad
    max_content_h = frame_h - args.top_pad - args.bottom_pad
    if max_content_w <= 0 or max_content_h <= 0:
        raise SystemExit("erreur : padding incompatible avec la taille cible")

    base_scale, fit_scales = compute_base_scale(frames, max_content_w, max_content_h)
    ground_y = frame_h - 1 - args.bottom_pad
    center_x = frame_w / 2.0

    normalized_images = []
    report_frames = []
    for frame in frames:
        normalized, report = normalize_frame(
            frame,
            frame_w,
            frame_h,
            base_scale,
            max_content_w,
            max_content_h,
            ground_y,
            center_x,
        )
        out_path = output_dir / frame["path"].name
        normalized.save(out_path)
        report["output"] = out_path.name
        normalized_images.append(normalized)
        report_frames.append(report)

    sheet = build_sheet(normalized_images, frame_w, frame_h)
    sheet.save(sheet_out)

    report = {
        "input_dir": str(input_dir),
        "output_dir": str(output_dir),
        "sheet_out": str(sheet_out),
        "frame_size": [frame_w, frame_h],
        "top_pad": args.top_pad,
        "bottom_pad": args.bottom_pad,
        "side_pad": args.side_pad,
        "fit_scales": fit_scales,
        "summary": summarize(report_frames, base_scale),
        "frames": report_frames,
    }
    report_out.write_text(json.dumps(report, indent=2), encoding="utf-8")

    summary = report["summary"]
    print("sheet      :", sheet_out)
    print("report     :", report_out)
    print("base_scale :", f"{summary['base_scale']:.6f}")
    print(
        "width_span :",
        summary["normalized_width_max"] - summary["normalized_width_min"],
    )
    print(
        "height_span:",
        summary["normalized_height_max"] - summary["normalized_height_min"],
    )
    print(
        "ground_span:",
        summary["normalized_bottom_max"] - summary["normalized_bottom_min"],
    )
    print("max_delta  :", f"{summary['max_scale_delta_vs_base']:.6f}")


if __name__ == "__main__":
    main()
