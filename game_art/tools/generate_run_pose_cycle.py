"""Genere un cycle de course OpenPose deterministe pour MimicMotion."""

from __future__ import annotations

import argparse
import colorsys
import hashlib
import json
import math
from pathlib import Path

import cv2
import numpy as np


LIMBS = [
    (1, 2), (1, 5), (2, 3), (3, 4), (5, 6), (6, 7),
    (1, 8), (8, 9), (9, 10), (1, 11), (11, 12), (12, 13),
    (1, 0), (0, 14), (14, 16), (0, 15), (15, 17),
]

COLORS = [
    (255, 0, 0), (255, 85, 0), (255, 170, 0), (255, 255, 0),
    (170, 255, 0), (85, 255, 0), (0, 255, 0), (0, 255, 85),
    (0, 255, 170), (0, 255, 255), (0, 170, 255), (0, 85, 255),
    (0, 0, 255), (85, 0, 255), (170, 0, 255), (255, 0, 255),
    (255, 0, 170), (255, 0, 85),
]

HAND_EDGES = [
    (0, 1), (1, 2), (2, 3), (3, 4),
    (0, 5), (5, 6), (6, 7), (7, 8),
    (0, 9), (9, 10), (10, 11), (11, 12),
    (0, 13), (13, 14), (14, 15), (15, 16),
    (0, 17), (17, 18), (18, 19), (19, 20),
]


def leg(hip: np.ndarray, phase: float, side: float) -> tuple[np.ndarray, np.ndarray]:
    angle = 2.0 * math.pi * phase
    foot = np.array([
        hip[0] + 0.145 * math.cos(angle),
        0.925 - 0.075 * max(0.0, -math.sin(angle)),
    ])
    midpoint = (hip + foot) * 0.5
    bend = 0.052 + 0.018 * max(0.0, -math.sin(angle))
    knee = midpoint + np.array([bend * side, -0.018])
    return knee, foot


def arm(shoulder: np.ndarray, phase: float) -> tuple[np.ndarray, np.ndarray]:
    swing = math.cos(2.0 * math.pi * phase)
    elbow = shoulder + np.array([0.075 * swing, 0.145])
    wrist = elbow + np.array([0.062 * swing, 0.13])
    return elbow, wrist


def pose_for_frame(index: int, frame_count: int) -> np.ndarray:
    phase = index / frame_count
    bob = 0.006 * (1.0 - math.cos(4.0 * math.pi * phase)) * 0.5
    points = np.zeros((18, 2), dtype=np.float32)

    neck = np.array([0.515, 0.275 + bob])
    nose = np.array([0.555, 0.19 + bob])
    right_shoulder = neck + np.array([-0.012, 0.018])
    left_shoulder = neck + np.array([0.012, 0.018])
    right_hip = np.array([0.49, 0.555 + bob])
    left_hip = np.array([0.51, 0.555 + bob])

    right_knee, right_ankle = leg(right_hip, phase, 1.0)
    left_knee, left_ankle = leg(left_hip, (phase + 0.5) % 1.0, -1.0)
    right_elbow, right_wrist = arm(right_shoulder, (phase + 0.5) % 1.0)
    left_elbow, left_wrist = arm(left_shoulder, phase)

    points[0] = nose
    points[1] = neck
    points[2] = right_shoulder
    points[3] = right_elbow
    points[4] = right_wrist
    points[5] = left_shoulder
    points[6] = left_elbow
    points[7] = left_wrist
    points[8] = right_hip
    points[9] = right_knee
    points[10] = right_ankle
    points[11] = left_hip
    points[12] = left_knee
    points[13] = left_ankle
    points[14] = nose + np.array([0.008, -0.012])
    points[15] = nose + np.array([-0.008, -0.012])
    points[16] = nose + np.array([-0.022, 0.004])
    points[17] = nose + np.array([-0.032, 0.008])
    return points


def render_pose(
    points: np.ndarray,
    width: int,
    height: int,
    reference_details: dict | None,
) -> np.ndarray:
    canvas = np.zeros((height, width, 3), dtype=np.uint8)
    thickness = max(2, round(min(width, height) / 120))
    radius = max(3, round(min(width, height) / 90))
    pixels = np.column_stack((points[:, 0] * width, points[:, 1] * height)).round().astype(int)
    for limb_index, (start, end) in enumerate(LIMBS):
        cv2.line(canvas, tuple(pixels[start]), tuple(pixels[end]), COLORS[limb_index], thickness)
    for point_index, point in enumerate(pixels):
        cv2.circle(canvas, tuple(point), radius, COLORS[point_index], -1)

    if reference_details is not None:
        ref_body = np.asarray(reference_details["body"], dtype=np.float32)
        face = np.asarray(reference_details["face"], dtype=np.float32)
        face_scores = np.asarray(reference_details["face_scores"], dtype=np.float32)
        face = face + (points[0] - ref_body[0])
        for point, score in zip(face, face_scores):
            if score >= 0.3:
                pixel = (round(point[0] * width), round(point[1] * height))
                cv2.circle(canvas, pixel, max(1, radius // 2), (255, 255, 255), -1)

        hands = np.asarray(reference_details["hands"], dtype=np.float32)
        hand_scores = np.asarray(reference_details["hand_scores"], dtype=np.float32)
        available_wrists = [4, 7]
        assigned_wrists: set[int] = set()
        for hand, scores in zip(hands, hand_scores):
            distances = [
                np.linalg.norm(hand[0] - ref_body[index]) if index not in assigned_wrists else float("inf")
                for index in available_wrists
            ]
            wrist_index = available_wrists[int(np.argmin(distances))]
            assigned_wrists.add(wrist_index)
            moved = hand + (points[wrist_index] - hand[0])
            hand_pixels = np.column_stack((moved[:, 0] * width, moved[:, 1] * height)).round().astype(int)
            for edge_index, (start, end) in enumerate(HAND_EDGES):
                if scores[start] < 0.3 or scores[end] < 0.3:
                    continue
                rgb = colorsys.hsv_to_rgb(edge_index / len(HAND_EDGES), 1.0, 1.0)
                color = tuple(round(channel * 255) for channel in rgb)
                cv2.line(canvas, tuple(hand_pixels[start]), tuple(hand_pixels[end]), color, max(1, thickness // 2))
            for point_index, point in enumerate(hand_pixels):
                if scores[point_index] >= 0.3:
                    cv2.circle(canvas, tuple(point), max(1, radius // 2), (0, 0, 255), -1)
    return canvas


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--width", type=int, default=448)
    parser.add_argument("--height", type=int, default=640)
    parser.add_argument("--frames", type=int, default=16)
    parser.add_argument("--fps", type=int, default=16)
    parser.add_argument("--reference-pose-json")
    args = parser.parse_args()

    output_dir = Path(args.output_dir)
    frame_dir = output_dir / "control_frames"
    frame_dir.mkdir(parents=True, exist_ok=True)
    video_path = output_dir / "run_pose_control.mp4"
    reference_details = None
    if args.reference_pose_json:
        reference_details = json.loads(Path(args.reference_pose_json).read_text(encoding="utf-8"))

    writer = cv2.VideoWriter(
        str(video_path),
        cv2.VideoWriter_fourcc(*"mp4v"),
        args.fps,
        (args.width, args.height),
    )
    if not writer.isOpened():
        raise RuntimeError("impossible d'ouvrir l'encodeur MP4")

    report_frames = []
    for index in range(args.frames):
        points = pose_for_frame(index, args.frames)
        frame = render_pose(points, args.width, args.height, reference_details)
        frame_path = frame_dir / f"pose_{index:02d}.png"
        cv2.imwrite(str(frame_path), frame)
        writer.write(frame)
        report_frames.append({
            "index": index,
            "phase": index / args.frames,
            "pelvis_x": float((points[8, 0] + points[11, 0]) * 0.5),
            "head_pelvis_distance": float((points[8:12:3, 1].mean()) - points[0, 1]),
            "support_foot_y": float(max(points[10, 1], points[13, 1])),
        })
    writer.release()

    pelvis_values = [frame["pelvis_x"] for frame in report_frames]
    head_values = [frame["head_pelvis_distance"] for frame in report_frames]
    foot_values = [frame["support_foot_y"] for frame in report_frames]
    report = {
        "version": 1,
        "frame_count": args.frames,
        "fps": args.fps,
        "canvas": [args.width, args.height],
        "cycle_sampling": "phase=i/frame_count; frame 16 equals implicit frame 0",
        "metrics": {
            "pelvis_horizontal_drift_px": (max(pelvis_values) - min(pelvis_values)) * args.width,
            "head_pelvis_variation_percent": (max(head_values) - min(head_values)) * 100.0,
            "support_foot_vertical_drift_px": (max(foot_values) - min(foot_values)) * args.height,
        },
        "video": video_path.name,
        "video_sha256": sha256(video_path),
        "reference_pose_json": args.reference_pose_json,
        "frames": report_frames,
    }
    (output_dir / "pose_cycle_report.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    print(json.dumps(report["metrics"], indent=2))


if __name__ == "__main__":
    main()
