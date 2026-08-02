import json
from pathlib import Path

from PIL import Image


ROOT = Path(r"D:\ServOMorph\Jeu pour Nino")
BASE = ROOT / "game_art/assets/generated_raw/player/run_video_v1"
GUIDES = BASE / "unirig_run_candidate_35_cloth_pose/frames"
REFERENCE = BASE / "reference_white.png"
OUTPUT = BASE / "wangp_flux2_img2img_candidate_36_probe"
CONFIG = BASE / "wangp_flux2_img2img_candidate_36_probe.json"
MASK = OUTPUT / "mask_white.png"


PROMPT = (
    "Recreate the single dark fantasy swordsman from the reference image in the exact full-body running pose "
    "and exact framing of the control image. Preserve the reference face, black hair, beard, black layered "
    "leather armor and compact torn cape. Keep the pelvis at the control image position. His hands are empty. "
    "Exactly one longsword is fully sheathed vertically on his back; no blade is visible. Strict right-facing "
    "side profile, pure white background."
)

NEGATIVE = (
    "sword in hand, drawn sword, visible blade, two swords, duplicate sword, missing sword, multiple people, "
    "duplicate limbs, stretched cape, wing, front view, cropped, text, blur"
)


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    Image.new("L", (520, 750), 255).save(MASK)

    tasks = []
    for frame in (1, 9):
        for strength in (0.25, 0.5, 0.75):
            task = {
                "settings_version": 2.66,
                "model_type": "flux2_klein_4b",
                "prompt": PROMPT,
                "negative_prompt": NEGATIVE,
                "image_mode": 1,
                "image_prompt_type": "S",
                "image_refs": [str(REFERENCE)],
                "video_prompt_type": "VAGKI",
                "image_guide": str(GUIDES / f"frame_{frame:04d}.png"),
                "image_mask": str(MASK),
                "remove_background_images_ref": 0,
                "resolution": "512x736",
                "num_inference_steps": 4,
                "denoising_strength": strength,
                "masking_strength": 1.0,
                "model_mode": 0,
                "seed": 813156,
                "embedded_guidance_scale": 1,
                "batch_size": 1,
                "repeat_generation": 1,
                "activated_loras": [],
                "loras_multipliers": "",
                "override_profile": 5,
                "override_attention": "sdpa",
                "output_filename": f"run_flux2_i2i_f{frame:02d}_d{int(strength * 100):02d}",
            }
            tasks.append(task)

    CONFIG.write_text(json.dumps(tasks, indent=2), encoding="utf-8")
    print(CONFIG)


if __name__ == "__main__":
    main()
