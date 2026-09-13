"""Stabilise automatiquement un lot de frames generees.

Le script ne cree aucune pose et ne modifie jamais une sheet runtime. Il extrait
un sujet depuis un alpha ou un fond vert, normalise le lot dans des cases fixes,
aligne le bas de chaque frame sur une ligne de sol et produit un rapport de
controle. Il est reserve aux candidats de player/run : toute integration reste
soumise a une validation visuelle et en jeu.

Usage:
  python game_art/tools/stabilize_generated_animation.py ^
    --input-dir game_art/assets/generated_raw/player/run_frames_v2_alpha ^
    --output-dir game_art/assets/generated_raw/player/run_stabilized_v1/frames ^
    --sheet-out game_art/assets/generated_raw/player/run_stabilized_v1/sheet.png ^
    --report-out game_art/assets/generated_raw/player/run_stabilized_v1/report.json
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from statistics import median

import cv2
import numpy as np
from PIL import Image


def alpha_mask(image: Image.Image, chroma_green: bool) -> np.ndarray:
    rgba = np.asarray(image.convert("RGBA"))
    alpha = rgba[:, :, 3]
    if not chroma_green:
        return alpha
    hsv = cv2.cvtColor(rgba[:, :, :3], cv2.COLOR_RGB2HSV)
    green = cv2.inRange(hsv, np.array((40, 80, 60)), np.array((90, 255, 255)))
    return np.where(green > 0, 0, alpha).astype(np.uint8)


def subject_bbox(mask: np.ndarray) -> tuple[int, int, int, int]:
    binary = (mask > 16).astype(np.uint8)
    count, labels, stats, _ = cv2.connectedComponentsWithStats(binary, 8)
    if count <= 1:
        raise ValueError("sujet introuvable")
    area_index = 1 + int(np.argmax(stats[1:, cv2.CC_STAT_AREA]))
    component = (labels == area_index).astype(np.uint8)
    # Retient les fragments de cape/epee proches du corps principal.
    kernel = np.ones((5, 5), np.uint8)
    component = cv2.morphologyEx(component, cv2.MORPH_CLOSE, kernel)
    ys, xs = np.where(component > 0)
    if xs.size == 0:
        raise ValueError("sujet vide")
    return int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1


def load_frame(path: Path, chroma_green: bool) -> dict:
    image = Image.open(path).convert("RGBA")
    mask = alpha_mask(image, chroma_green)
    bbox = subject_bbox(mask)
    x0, y0, x1, y1 = bbox
    rgba = np.asarray(image).copy()
    rgba[:, :, 3] = mask
    rgba[rgba[:, :, 3] == 0, :3] = 0
    subject = Image.fromarray(rgba, "RGBA").crop(bbox)
    return {
        "path": path,
        "source": image,
        "subject": subject,
        "bbox": bbox,
        "width": x1 - x0,
        "height": y1 - y0,
    }


def resize_and_place(frame: dict, target: tuple[int, int], scale: float, ground_y: int) -> tuple[Image.Image, dict]:
    target_w, target_h = target
    width = max(1, round(frame["width"] * scale))
    height = max(1, round(frame["height"] * scale))
    if width > target_w - 4 or height > target_h - 2:
        raise ValueError("sujet trop grand apres normalisation")
    subject = frame["subject"].resize((width, height), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", target, (0, 0, 0, 0))
    x = round((target_w - width) / 2)
    y = ground_y - height + 1
    canvas.alpha_composite(subject, (x, y))
    bbox = canvas.getchannel("A").getbbox()
    assert bbox is not None
    return canvas, {
        "source": frame["path"].name,
        "source_bbox": frame["bbox"],
        "source_size": [frame["width"], frame["height"]],
        "scale": scale,
        "output_bbox": list(bbox),
        "output_bottom": bbox[3] - 1,
        "offset": [x, y],
    }


def make_sheet(frames: list[Image.Image], size: tuple[int, int]) -> Image.Image:
    width, height = size
    sheet = Image.new("RGBA", (width * len(frames), height), (0, 0, 0, 0))
    for index, frame in enumerate(frames):
        sheet.alpha_composite(frame, (index * width, 0))
    return sheet


def parse_size(text: str) -> tuple[int, int]:
    width, height = text.lower().split("x", 1)
    return int(width), int(height)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input-dir", required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--sheet-out", required=True)
    parser.add_argument("--report-out", required=True)
    parser.add_argument("--frame-size", default="104x150")
    parser.add_argument("--expected-count", type=int, default=16)
    parser.add_argument("--chroma-green", action="store_true")
    args = parser.parse_args()

    target = parse_size(args.frame_size)
    paths = sorted(Path(args.input_dir).glob("*.png"))
    if len(paths) != args.expected_count:
        raise SystemExit(f"erreur : {args.expected_count} frames attendues, {len(paths)} trouvees")

    frames = [load_frame(path, args.chroma_green) for path in paths]
    # Une echelle uniforme pour le lot entier : aucune frame n'est mise a l'echelle seule.
    median_height = median(frame["height"] for frame in frames)
    scale = min((target[1] - 2) / max(frame["height"] for frame in frames), (target[0] - 4) / max(frame["width"] for frame in frames))
    ground_y = target[1] - 1
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    rendered: list[Image.Image] = []
    reports: list[dict] = []
    for index, frame in enumerate(frames):
        image, report = resize_and_place(frame, target, scale, ground_y)
        output = output_dir / f"frame_{index:02d}.png"
        image.save(output)
        report["output"] = output.name
        rendered.append(image)
        reports.append(report)

    sheet = make_sheet(rendered, target)
    sheet_path = Path(args.sheet_out)
    sheet_path.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(sheet_path)
    bottoms = [frame["output_bottom"] for frame in reports]
    report = {
        "verdict": "A_VALIDER_VISUELLEMENT",
        "integration_runtime_autorisee": False,
        "input_dir": str(args.input_dir),
        "sheet_out": str(sheet_path),
        "frame_size": list(target),
        "frame_count": len(rendered),
        "chroma_green": args.chroma_green,
        "uniform_scale": scale,
        "source_median_height": median_height,
        "ground_y": ground_y,
        "ground_span": max(bottoms) - min(bottoms),
        "checks": {
            "alpha_sheet": sheet.mode == "RGBA",
            "grid_exacte": sheet.size == (target[0] * len(rendered), target[1]),
            "appuis_alignes": max(bottoms) - min(bottoms) == 0,
            "poses_et_boucle": "NON_MESUREES_REQUIERT_VALIDATION_VISUELLE",
        },
        "frames": reports,
    }
    Path(args.report_out).write_text(json.dumps(report, indent=2), encoding="utf-8")
    print(json.dumps(report["checks"], indent=2))
    print(f"sheet: {sheet_path}")
    print(f"report: {args.report_out}")


if __name__ == "__main__":
    main()
