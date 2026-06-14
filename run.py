import subprocess
import sys
from pathlib import Path

GODOT = Path(r"D:\tmp\godot45\Godot_v4.5-stable_win64.exe")
GAME  = Path(__file__).parent / "game"

if not GODOT.exists():
    sys.exit(f"Godot introuvable : {GODOT}")

subprocess.run([str(GODOT), "--path", str(GAME)])
