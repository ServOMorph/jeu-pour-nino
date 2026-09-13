import os
import sys
from pathlib import Path

SF3D_ROOT = Path(r"D:\tools\stable-fast-3d")
CUDA_TOOLKIT = Path(r"D:\NVIDIA\CUDA\v12.8\toolkit")

for module_path in reversed(
    [SF3D_ROOT, SF3D_ROOT / "uv_unwrapper_src", SF3D_ROOT / "texture_baker_src"]
):
    sys.path.insert(0, str(module_path))

os.environ["PATH"] = f"{CUDA_TOOLKIT / 'bin'};{os.environ['PATH']}"
if hasattr(os, "add_dll_directory"):
    os.add_dll_directory(str(CUDA_TOOLKIT / "bin"))

import torch
from PIL import Image

from sf3d.system import SF3D
from sf3d.utils import resize_foreground


INPUT = Path(r"D:\ServOMorph\Jeu pour Nino\game_art\assets\concept\player_adventurer_front_v1.png")
MODEL = Path(r"D:\ai-cache\huggingface\hub\models--stabilityai--stable-fast-3d\snapshots\f0c9a8ffd62cb1bbc8a7a53c9f87a0be1b6be778")
OUTPUT = Path(r"D:\ServOMorph\Jeu pour Nino\game_art\models\sf3d_player_v1")


def remove_flat_background(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    for y in range(rgba.height):
        for x in range(rgba.width):
            red, green, blue, alpha = pixels[x, y]
            if max(red, green, blue) - min(red, green, blue) < 18 and red > 115:
                pixels[x, y] = (red, green, blue, 0)
    return rgba


OUTPUT.mkdir(parents=True, exist_ok=True)
image = resize_foreground(remove_flat_background(Image.open(INPUT)), 0.85)
image.save(OUTPUT / "input.png")

device = "cuda" if torch.cuda.is_available() else "cpu"
model = SF3D.from_pretrained(str(MODEL), config_name="config.yaml", weight_name="model.safetensors")
model.to(device)
model.eval()

with torch.no_grad(), torch.autocast(device_type=device, dtype=torch.bfloat16) if device == "cuda" else torch.no_grad():
    mesh, _ = model.run_image([image], bake_resolution=512, remesh="none", vertex_count=-1)

mesh.export(OUTPUT / "player_adventurer_sf3d_v1.glb", include_normals=True)
print("SF3D_OK", OUTPUT / "player_adventurer_sf3d_v1.glb")
