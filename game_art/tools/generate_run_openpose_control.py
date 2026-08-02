"""Genere une video OpenPose exacte pour un cycle de course lateral."""

from __future__ import annotations

import argparse
import math
import sys
from pathlib import Path

import cv2
import numpy as np


def smoothstep(value: float) -> float:
    return value * value * (3.0 - 2.0 * value)


def interpolate_cycle(keys: tuple[tuple[float, float, float], ...], phase: float) -> tuple[float, float]:
    for (p0, x0, z0), (p1, x1, z1) in zip(keys, keys[1:]):
        if phase <= p1:
            t = smoothstep((phase - p0) / (p1 - p0))
            return x0 + (x1 - x0) * t, z0 + (z1 - z0) * t
    return keys[-1][1], keys[-1][2]


def leg_points(hip: np.ndarray, phase: float, near: bool) -> tuple[np.ndarray, np.ndarray]:
    foot_keys = (
        (0.0, 1.05, 0.43),
        (0.125, 0.55, 0.72),
        (0.25, -0.35, 1.02),
        (0.375, -0.82, 1.38),
        (0.5, -0.48, 1.58),
        (0.625, 0.08, 1.46),
        (0.75, 0.7, 1.18),
        (0.875, 1.02, 0.72),
        (1.0, 1.05, 0.43),
    )
    foot_x, foot_z = interpolate_cycle(foot_keys, phase)
    foot = np.array((hip[0] + foot_x, foot_z), dtype=np.float64)
    direction = foot - hip
    distance = max(0.001, float(np.linalg.norm(direction)))
    thigh_length = 1.48 if near else 1.44
    half = min(distance * 0.5, thigh_length - 0.001)
    bend = math.sqrt(max(0.0, thigh_length * thigh_length - half * half))
    perpendicular = np.array((-direction[1], direction[0]), dtype=np.float64) / distance
    knee = (hip + foot) * 0.5 + perpendicular * bend
    return knee, foot


def arm_points(shoulder: np.ndarray, phase: float) -> tuple[np.ndarray, np.ndarray]:
    elbow_keys = (
        (0.0, 0.68, -0.44),
        (0.25, 0.0, -0.82),
        (0.5, -0.68, -0.44),
        (0.75, 0.0, -0.82),
        (1.0, 0.68, -0.44),
    )
    wrist_keys = (
        (0.0, 1.02, -0.05),
        (0.25, 0.48, -0.6),
        (0.5, -0.28, -0.86),
        (0.75, -0.48, -0.6),
        (1.0, 1.02, -0.05),
    )
    elbow_x, elbow_z = interpolate_cycle(elbow_keys, phase)
    wrist_x, wrist_z = interpolate_cycle(wrist_keys, phase)
    return (
        shoulder + np.array((elbow_x, elbow_z)),
        shoulder + np.array((wrist_x, wrist_z)),
    )


def project(point: np.ndarray, width: int, height: int) -> np.ndarray:
    ortho_height = 6.45
    ortho_width = ortho_height * width / height
    x = (point[0] + ortho_width * 0.5) / ortho_width
    y = (3.1 + ortho_height * 0.5 - point[1]) / ortho_height
    return np.array((x, y), dtype=np.float64)


def build_pose(phase: float, width: int, height: int) -> tuple[np.ndarray, np.ndarray]:
    bob = 0.14 * (1.0 - math.cos(4.0 * math.pi * (phase - 0.125))) * 0.5
    head = np.array((0.22, 5.22 + bob))
    neck = np.array((0.12, 4.67 + bob))
    right_shoulder = np.array((0.08, 4.5 + bob))
    left_shoulder = np.array((0.16, 4.5 + bob))
    right_hip = np.array((-0.08, 3.0 + bob))
    left_hip = np.array((0.08, 3.0 + bob))

    right_knee, right_ankle = leg_points(right_hip, phase, False)
    left_knee, left_ankle = leg_points(left_hip, (phase + 0.5) % 1.0, True)
    right_elbow, right_wrist = arm_points(right_shoulder, (phase + 0.5) % 1.0)
    left_elbow, left_wrist = arm_points(left_shoulder, phase)

    nose = head + np.array((0.36, 0.015))
    right_eye = head + np.array((0.24, 0.1))
    left_eye = head + np.array((0.19, 0.1))
    right_ear = head + np.array((-0.05, 0.07))
    left_ear = head + np.array((-0.1, 0.07))
    points = (
        nose,
        neck,
        right_shoulder,
        right_elbow,
        right_wrist,
        left_shoulder,
        left_elbow,
        left_wrist,
        right_hip,
        right_knee,
        right_ankle,
        left_hip,
        left_knee,
        left_ankle,
        right_eye,
        left_eye,
        right_ear,
        left_ear,
    )
    candidate = np.stack([project(point, width, height) for point in points])

    face = []
    face_center = project(head + np.array((0.08, 0.02)), width, height)
    for index in range(68):
        angle = 2.0 * math.pi * index / 68.0
        face.append(face_center + np.array((0.038 * math.cos(angle), 0.052 * math.sin(angle))))
    return candidate, np.asarray(face)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--wan-root", default=r"D:\AI\WanGP")
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--width", type=int, default=448)
    parser.add_argument("--height", type=int, default=640)
    parser.add_argument("--cycle-frames", type=int, default=16)
    parser.add_argument("--cycle-count", type=int, default=5)
    parser.add_argument("--include-loop-frame", action="store_true")
    parser.add_argument("--face-reference")
    parser.add_argument("--face-crop", default="460,60,700,300")
    parser.add_argument("--face-size", type=int, default=96)
    args = parser.parse_args()

    sys.path.insert(0, str(Path(args.wan_root).resolve()))
    from preprocessing.dwpose.util import draw_bodypose, draw_facepose

    output_dir = Path(args.output_dir).resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    face_rgb = None
    face_alpha = None
    if args.face_reference:
        source = cv2.imread(str(Path(args.face_reference).resolve()), cv2.IMREAD_COLOR)
        if source is None:
            raise RuntimeError(f"reference faciale illisible: {args.face_reference}")
        x0, y0, x1, y1 = (int(value) for value in args.face_crop.split(","))
        crop = source[y0:y1, x0:x1, ::-1]
        face_rgb = cv2.resize(crop, (args.face_size, args.face_size), interpolation=cv2.INTER_LANCZOS4)
        whiteness = np.min(face_rgb.astype(np.float32), axis=2)
        face_alpha = np.clip((250.0 - whiteness) / 24.0, 0.0, 1.0)[..., None]
    frame_count = args.cycle_frames * args.cycle_count + (1 if args.include_loop_frame else 0)
    subset = np.arange(18, dtype=np.float64)[None, :]
    for index in range(frame_count):
        phase = (index / float(args.cycle_frames)) % 1.0
        candidate, face = build_pose(phase, args.width, args.height)
        canvas = np.zeros((args.height, args.width, 3), dtype=np.uint8)
        canvas = draw_bodypose(canvas, candidate, subset)
        canvas = draw_facepose(canvas, face[None, :, :])
        if face_rgb is not None and face_alpha is not None:
            head_center = candidate[0] - np.array((0.36 / (6.45 * args.width / args.height), 0.015 / 6.45))
            center_x = int(round(head_center[0] * args.width))
            center_y = int(round(head_center[1] * args.height))
            left = center_x - args.face_size // 2
            top = center_y - args.face_size // 2
            right = left + args.face_size
            bottom = top + args.face_size
            if left < 0 or top < 0 or right > args.width or bottom > args.height:
                raise RuntimeError("visage hors cadre")
            region = canvas[top:bottom, left:right].astype(np.float32)
            canvas[top:bottom, left:right] = np.clip(
                region * (1.0 - face_alpha) + face_rgb.astype(np.float32) * face_alpha,
                0,
                255,
            ).astype(np.uint8)
        path = output_dir / f"frame_{index + 1:04d}.png"
        if not cv2.imwrite(str(path), canvas[:, :, ::-1]):
            raise RuntimeError(f"echec d'ecriture: {path}")

    print(f"{frame_count} cartes OpenPose generees dans {output_dir}")


if __name__ == "__main__":
    main()
