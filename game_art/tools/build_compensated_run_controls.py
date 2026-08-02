"""Compense la réponse géométrique mesurée du générateur dans les guides source."""

from __future__ import annotations

import argparse
import json
import math
from pathlib import Path

import cv2
import numpy as np


def remap_control(image: np.ndarray, dx: float, upper_scale: float, anchor_y: float) -> np.ndarray:
    height, width = image.shape[:2]
    grid_x, grid_y = np.meshgrid(
        np.arange(width, dtype=np.float32), np.arange(height, dtype=np.float32)
    )
    map_x = grid_x - np.float32(dx)
    map_y = grid_y.copy()
    upper = grid_y < anchor_y
    map_y[upper] = anchor_y + (grid_y[upper] - anchor_y) / np.float32(upper_scale)
    return cv2.remap(
        image,
        map_x,
        map_y,
        interpolation=cv2.INTER_LINEAR,
        borderMode=cv2.BORDER_CONSTANT,
        borderValue=(0, 0, 0, 0),
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--pose-dir", required=True)
    parser.add_argument("--silhouette-dir", required=True)
    parser.add_argument("--metrics-dir", required=True)
    parser.add_argument("--output-pose-dir", required=True)
    parser.add_argument("--output-silhouette-dir", required=True)
    parser.add_argument("--frames", type=int, default=17)
    parser.add_argument("--gain-x", type=float, default=1.0)
    parser.add_argument("--gain-height", type=float, default=1.0)
    args = parser.parse_args()

    pose_dir = Path(args.pose_dir).resolve()
    silhouette_dir = Path(args.silhouette_dir).resolve()
    metrics_dir = Path(args.metrics_dir).resolve()
    output_pose_dir = Path(args.output_pose_dir).resolve()
    output_silhouette_dir = Path(args.output_silhouette_dir).resolve()
    output_pose_dir.mkdir(parents=True, exist_ok=True)
    output_silhouette_dir.mkdir(parents=True, exist_ok=True)

    measurements = []
    for frame in range(1, args.frames + 1):
        data = json.loads((metrics_dir / f"frame_{frame:03d}.json").read_text())
        body = data["body"]
        pelvis_x = (body[8][0] + body[11][0]) * 0.5
        pelvis_y = (body[8][1] + body[11][1]) * 0.5
        head_pelvis = pelvis_y - body[0][1]
        measurements.append((pelvis_x, head_pelvis))

    cycle = measurements[:16]
    target_x = float(np.median([value[0] for value in cycle]))
    target_height = float(np.median([value[1] for value in cycle]))
    report = {
        "target_pelvis_x_normalized": target_x,
        "target_head_pelvis_normalized": target_height,
        "gain_x": args.gain_x,
        "gain_height": args.gain_height,
        "frames": [],
    }

    first_correction = None
    for frame in range(1, args.frames + 1):
        pose_path = pose_dir / f"frame_{frame:04d}.png"
        silhouette_path = silhouette_dir / f"frame_{frame:04d}.png"
        pose = cv2.imread(str(pose_path), cv2.IMREAD_UNCHANGED)
        silhouette = cv2.imread(str(silhouette_path), cv2.IMREAD_UNCHANGED)
        if pose is None or silhouette is None:
            raise RuntimeError(f"guide introuvable pour l'image {frame}")

        if frame == args.frames and args.frames == 17:
            dx_normalized, height_scale = first_correction
        else:
            pelvis_x, head_pelvis = measurements[frame - 1]
            dx_normalized = (target_x - pelvis_x) * args.gain_x
            raw_scale = target_height / max(1e-6, head_pelvis)
            height_scale = 1.0 + (raw_scale - 1.0) * args.gain_height
            if frame == 1:
                first_correction = (dx_normalized, height_scale)

        phase = ((frame - 1) % 16) / 16.0
        bob = 0.14 * (1.0 - math.cos(4.0 * math.pi * (phase - 0.125))) * 0.5
        anchor_y_normalized = (3.325 - bob) / 6.45
        dx = dx_normalized * pose.shape[1]
        anchor_y = anchor_y_normalized * pose.shape[0]

        corrected_pose = remap_control(pose, dx, height_scale, anchor_y)
        corrected_silhouette = remap_control(silhouette, dx, height_scale, anchor_y)
        cv2.imwrite(str(output_pose_dir / pose_path.name), corrected_pose)
        cv2.imwrite(str(output_silhouette_dir / silhouette_path.name), corrected_silhouette)
        report["frames"].append(
            {
                "frame": frame,
                "dx_source_px": dx,
                "upper_body_scale": height_scale,
                "anchor_y_source_px": anchor_y,
            }
        )

    (output_pose_dir.parent / "compensation_report.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )


if __name__ == "__main__":
    main()
