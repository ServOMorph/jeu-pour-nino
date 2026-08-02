import json
from pathlib import Path

import cv2


ROOT = Path(r"D:\ServOMorph\Jeu pour Nino")
BASE = ROOT / "game_art/assets/generated_raw/player/run_video_v1"
SOURCE = BASE / "sd15_controlnet_candidate_17_noslide_base"
CONTROL = BASE / "run_realistic_control_5cycles81.mp4"
CONFIG = BASE / "wangp_run_candidate_37_realistic_control.json"
OUTPUT = BASE / "wangp_candidate_37_realistic_control"
REFERENCE = BASE / "reference_white.png"


def build_control() -> None:
    first = cv2.imread(str(SOURCE / "frame_001.png"), cv2.IMREAD_COLOR)
    if first is None:
        raise RuntimeError("guide source introuvable")
    height, width = first.shape[:2]
    writer = cv2.VideoWriter(
        str(CONTROL), cv2.VideoWriter_fourcc(*"mp4v"), 30.0, (width, height)
    )
    if not writer.isOpened():
        raise RuntimeError("impossible de créer la vidéo de contrôle")
    try:
        for index in range(81):
            frame_no = index % 16 + 1
            frame = cv2.imread(str(SOURCE / f"frame_{frame_no:03d}.png"), cv2.IMREAD_COLOR)
            if frame is None:
                raise RuntimeError(f"guide {frame_no} introuvable")
            writer.write(frame)
    finally:
        writer.release()


def build_config() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    task = {
        "settings_version": 2.66,
        "model_type": "animate",
        "prompt": (
            "A single dark fantasy male swordsman in strict right-facing side profile performs an exact repeated "
            "sixteen-pose sprinting run-in-place cycle. Preserve exactly the validated reference character: same "
            "face, black hair, short beard, black layered leather armor, compact dark torn cape, brown belts, gloves, "
            "boots, and exactly one sheathed longsword on his back. Follow the supplied realistic human motion exactly. "
            "Fixed orthographic side camera and fixed framing. Lock the pelvis root to one screen coordinate. Keep a "
            "rigid torso, constant head-to-pelvis distance and constant body scale. Clear alternating contacts, push-off, "
            "airborne phases, high recovery knee, bent elbows and opposite arm drive. Plain white background."
        ),
        "negative_prompt": (
            "multiple people, duplicate body, duplicate limbs, extra arms, extra legs, extra sword, missing sword, "
            "drawn sword, sword in hand, detached cape, cape covering hips, costume change, face change, front view, "
            "back view, camera motion, zoom, pan, crop, cut off feet, cut off head, background motion, text, watermark, "
            "blur, flicker, morphing, walking, marching, standing still, sliding feet, horizontal body drift, scale change, "
            "torso stretch"
        ),
        "image_mode": 0,
        "image_prompt_type": "",
        "video_prompt_type": "PVBKI",
        "image_refs": [str(REFERENCE)],
        "video_guide": str(CONTROL),
        "remove_background_images_ref": 0,
        "resolution": "512x736",
        "video_length": 81,
        "force_fps": "control",
        "num_inference_steps": 20,
        "seed": 813157,
        "guidance_phases": 1,
        "guidance_scale": 1.0,
        "flow_shift": 5.0,
        "sample_solver": "unipc",
        "repeat_generation": 1,
        "sliding_window_size": 81,
        "sliding_window_overlap": 1,
        "temporal_upsampling": "",
        "spatial_upsampling": "",
        "film_grain_intensity": 0,
        "activated_loras": [],
        "loras_multipliers": "",
        "override_profile": 5,
        "override_attention": "sdpa",
        "output_filename": "run_wan22_candidate_37_realistic_control",
    }
    CONFIG.write_text(json.dumps(task, indent=2), encoding="utf-8")


if __name__ == "__main__":
    build_control()
    build_config()
    print(CONTROL)
    print(CONFIG)
