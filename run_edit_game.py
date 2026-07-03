import ctypes
import subprocess
import sys
import time
from ctypes import wintypes
from pathlib import Path

GODOT = Path(r"D:\tmp\godot45\Godot_v4.5-stable_win64.exe")
ROOT = Path(__file__).parent
GAME = ROOT / "game"
EDITEUR = ROOT / "game_art"

GAME_TITLE = "CoreDive Challenge"
EDITEUR_TITLE = "SpriteEditor"

if not GODOT.exists():
    sys.exit(f"Godot introuvable : {GODOT}")

sys.path.insert(0, str(ROOT))
from sync import sync

user32 = ctypes.windll.user32

def work_area():
    rect = wintypes.RECT()
    ctypes.windll.user32.SystemParametersInfoW(0x0030, 0, ctypes.byref(rect), 0)
    return rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top

def find_window(title_substr):
    result = []
    EnumProc = ctypes.WINFUNCTYPE(ctypes.c_bool, wintypes.HWND, wintypes.LPARAM)

    def callback(hwnd, _):
        if not user32.IsWindowVisible(hwnd):
            return True
        length = user32.GetWindowTextLengthW(hwnd)
        if length == 0:
            return True
        buf = ctypes.create_unicode_buffer(length + 1)
        user32.GetWindowTextW(hwnd, buf, length + 1)
        if title_substr in buf.value:
            result.append(hwnd)
            return False
        return True

    user32.EnumWindows(EnumProc(callback), 0)
    return result[0] if result else None

def wait_window(title_substr, timeout=20.0):
    deadline = time.time() + timeout
    while time.time() < deadline:
        hwnd = find_window(title_substr)
        if hwnd:
            return hwnd
        time.sleep(0.3)
    return None

def place(hwnd, x, y, w, h):
    user32.ShowWindow(hwnd, 9)  # SW_RESTORE
    user32.MoveWindow(hwnd, x, y, w, h, True)

sync()

subprocess.Popen([str(GODOT), "--path", str(GAME)])
subprocess.Popen([str(GODOT), "--path", str(EDITEUR)])

hwnd_game = wait_window(GAME_TITLE)
hwnd_edit = wait_window(EDITEUR_TITLE)

wx, wy, ww, wh = work_area()
half = ww // 2

if hwnd_game:
    place(hwnd_game, wx, wy, half, wh)
else:
    print(f"Fenetre '{GAME_TITLE}' introuvable")

if hwnd_edit:
    place(hwnd_edit, wx + half, wy, ww - half, wh)
else:
    print(f"Fenetre '{EDITEUR_TITLE}' introuvable")
