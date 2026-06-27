"""
Sync game_art -> game
  game_art/assets/  ->  game/assets/sprites/
  game_art/data/animations.json  ->  game/data/animations.json
"""
import shutil
from pathlib import Path

ROOT = Path(__file__).parent
SRC_SPRITES = ROOT / "game_art" / "assets"
DST_SPRITES = ROOT / "game" / "assets" / "sprites"
SRC_ANIM    = ROOT / "game_art" / "data" / "animations.json"
DST_ANIM    = ROOT / "game" / "data" / "animations.json"

def sync():
    if SRC_SPRITES.exists():
        if DST_SPRITES.exists():
            shutil.rmtree(DST_SPRITES)
        shutil.copytree(SRC_SPRITES, DST_SPRITES)
        print(f"[sync] {SRC_SPRITES} -> {DST_SPRITES}")

    if SRC_ANIM.exists():
        shutil.copy2(SRC_ANIM, DST_ANIM)
        print(f"[sync] {SRC_ANIM} -> {DST_ANIM}")

if __name__ == "__main__":
    sync()
