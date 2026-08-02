"""Extrait les reperes DWPose d'une reference pour un cycle MimicMotion."""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

import numpy as np
from PIL import Image


def fit_reference(path: Path, width: int, height: int) -> np.ndarray:
    source_rgba = Image.open(path).convert("RGBA")
    matte = Image.new("RGBA", source_rgba.size, (128, 128, 128, 255))
    matte.alpha_composite(source_rgba)
    source = matte.convert("RGB")
    source.thumbnail((width, height), Image.Resampling.LANCZOS)
    canvas = Image.new("RGB", (width, height), (128, 128, 128))
    canvas.paste(source, ((width - source.width) // 2, (height - source.height) // 2))
    return np.asarray(canvas)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--mimic-root", default=r"D:\AI\MimicMotion")
    source_group = parser.add_mutually_exclusive_group(required=True)
    source_group.add_argument("--reference")
    source_group.add_argument("--reference-dir")
    parser.add_argument("--output")
    parser.add_argument("--output-dir")
    parser.add_argument("--width", type=int, default=448)
    parser.add_argument("--height", type=int, default=640)
    args = parser.parse_args()

    mimic_root = Path(args.mimic_root).resolve()
    sys.path.insert(0, str(mimic_root))
    os.chdir(mimic_root)
    from mimicmotion.dwpose.dwpose_detector import dwpose_detector

    if args.reference:
        if not args.output:
            parser.error("--output est requis avec --reference")
        jobs = [(Path(args.reference).resolve(), Path(args.output).resolve())]
    else:
        if not args.output_dir:
            parser.error("--output-dir est requis avec --reference-dir")
        reference_dir = Path(args.reference_dir).resolve()
        output_dir = Path(args.output_dir).resolve()
        paths = sorted(
            path
            for path in reference_dir.iterdir()
            if path.suffix.lower() in {".png", ".jpg", ".jpeg"}
            and not path.stem.startswith("montage")
            and not path.stem.startswith("contact")
        )
        jobs = [(path, output_dir / f"{path.stem}.json") for path in paths]
        if not jobs:
            raise RuntimeError(f"aucune image PNG ou JPEG dans {reference_dir}")

    for reference, output in jobs:
        pose = dwpose_detector(fit_reference(reference, args.width, args.height))
        bodies = pose["bodies"]
        if len(bodies["subset"]) != 1:
            raise RuntimeError(f"{reference.name}: une personne attendue, {len(bodies['subset'])} detectee(s)")
        report = {
            "canvas": [args.width, args.height],
            "body": bodies["candidate"].reshape(-1, 18, 2)[0].tolist(),
            "body_scores": bodies["score"][0].tolist(),
            "face": pose["faces"][0].tolist(),
            "face_scores": pose["faces_score"][0].tolist(),
            "hands": pose["hands"].tolist(),
            "hand_scores": pose["hands_score"].tolist(),
        }
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(json.dumps(report, indent=2), encoding="utf-8")
        print(json.dumps({
            "frame": reference.name,
            "body_points": sum(score >= 0.3 for score in report["body_scores"]),
            "face_points": sum(score >= 0.3 for score in report["face_scores"]),
            "hand_points": [sum(score >= 0.3 for score in hand) for hand in report["hand_scores"]],
        }))


if __name__ == "__main__":
    main()
