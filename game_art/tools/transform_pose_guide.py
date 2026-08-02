"""Transforme une image de contrôle, sans modifier une image d'animation finale."""

from __future__ import annotations

import argparse
from pathlib import Path

import cv2
import numpy as np


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--dx", type=float, default=0.0)
    parser.add_argument("--upper-scale", type=float, default=1.0)
    parser.add_argument("--anchor-y", type=float, required=True)
    args = parser.parse_args()

    source = cv2.imread(str(Path(args.input).resolve()), cv2.IMREAD_COLOR)
    if source is None:
        raise RuntimeError("image de contrôle introuvable")
    height, width = source.shape[:2]
    grid_x, grid_y = np.meshgrid(
        np.arange(width, dtype=np.float32), np.arange(height, dtype=np.float32)
    )
    map_x = grid_x - np.float32(args.dx)
    map_y = grid_y.copy()
    upper = grid_y < args.anchor_y
    map_y[upper] = args.anchor_y + (grid_y[upper] - args.anchor_y) / np.float32(args.upper_scale)
    transformed = cv2.remap(
        source,
        map_x,
        map_y,
        interpolation=cv2.INTER_LINEAR,
        borderMode=cv2.BORDER_CONSTANT,
        borderValue=(255, 255, 255),
    )
    output = Path(args.output).resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    if not cv2.imwrite(str(output), transformed):
        raise RuntimeError("échec d'écriture du guide transformé")


if __name__ == "__main__":
    main()
