"""Pipeline reference image_gen -> sprite pixel art a taille exacte.

Usage :
  python game_art/tools/ref_to_sprite.py INPUT OUTPUT --size 14x14 [options]

Etapes (mode average, defaut) :
  1. binarisation alpha (aucun pixel semi-transparent en sortie)
  2. recadrage sur le contenu opaque
  3. reduction par moyenne d'aire (BOX) a la taille cible
  4. boost saturation/contraste pour compenser l'ecrasement des accents
  5. quantisation dure de la palette (median cut, N couleurs)
  6. nettoyage : pixels orphelins retires, trous internes rebouches
  7. audit + preview agrandie + planche contact vs reference

Le mode vote (couleur dominante par cellule) est conserve pour les sources
deja proches du rendu pixel art a gros blocs nets.

Options :
  --size WxH            taille finale du sprite (obligatoire)
  --colors N            couleurs max de la palette (defaut 8)
  --pad N               marge transparente dans le canevas final (defaut 0)
  --alpha-threshold N   seuil de binarisation alpha 0-255 (defaut 128)
  --mode average|vote   strategie de reduction (defaut average)
  --sat F               boost saturation avant quantisation (defaut 1.4)
  --contrast F          boost contraste avant quantisation (defaut 1.2)
  --coverage F          mode vote : couverture opaque min par cellule (defaut 0.5)
  --preview N           facteur d'agrandissement de la preview (defaut 8)
  --compare PATH        image existante a inclure dans la planche contact
  --no-clean            desactive le nettoyage orphelins/trous
"""

import argparse
import os
import sys
from collections import Counter

from PIL import Image, ImageDraw, ImageEnhance


def parse_size(text):
    w, h = text.lower().split("x")
    return int(w), int(h)


def binarize_alpha(im, threshold):
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            px[x, y] = (r, g, b, 255) if a >= threshold else (0, 0, 0, 0)
    return im


def crop_to_content(im):
    bbox = im.getbbox()
    if bbox is None:
        sys.exit("erreur : image entierement transparente apres binarisation alpha")
    return im.crop(bbox)


def build_palette(im, n_colors):
    opaque = [(r, g, b) for r, g, b, a in im.getdata() if a == 255]
    strip = Image.new("RGB", (len(opaque), 1))
    strip.putdata(opaque)
    quantized = strip.quantize(colors=n_colors, method=Image.MEDIANCUT, dither=Image.Dither.NONE)
    pal = quantized.getpalette()
    used = sorted(set(quantized.getdata()))
    return [(pal[i * 3], pal[i * 3 + 1], pal[i * 3 + 2]) for i in used]


def nearest(color, palette):
    r, g, b = color
    best, best_d = palette[0], 1 << 30
    for p in palette:
        d = (p[0] - r) ** 2 + (p[1] - g) ** 2 + (p[2] - b) ** 2
        if d < best_d:
            best, best_d = p, d
    return best


def fit_rect(src_w, src_h, target_w, target_h, pad):
    inner_w, inner_h = target_w - 2 * pad, target_h - 2 * pad
    if inner_w <= 0 or inner_h <= 0:
        sys.exit("erreur : padding trop grand pour la taille cible")
    scale = min(inner_w / src_w, inner_h / src_h)
    used_w = max(1, round(src_w * scale))
    used_h = max(1, round(src_h * scale))
    off_x = pad + (inner_w - used_w) // 2
    off_y = pad + (inner_h - used_h)
    return used_w, used_h, off_x, off_y


def reduce_average(src, target_w, target_h, pad, n_colors, sat, contrast):
    used_w, used_h, off_x, off_y = fit_rect(src.width, src.height, target_w, target_h, pad)
    small = src.resize((used_w, used_h), Image.BOX)
    small = binarize_alpha(small, 128)
    rgb = ImageEnhance.Color(small.convert("RGB")).enhance(sat)
    rgb = ImageEnhance.Contrast(rgb).enhance(contrast)
    small = Image.merge("RGBA", (*rgb.split(), small.split()[3]))
    palette = build_palette(small, n_colors)
    px = small.load()
    for y in range(used_h):
        for x in range(used_w):
            r, g, b, a = px[x, y]
            if a == 255:
                px[x, y] = nearest((r, g, b), palette) + (255,)
    out = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 0))
    out.alpha_composite(small, (off_x, off_y))
    return out


def reduce_vote(src, target_w, target_h, pad, n_colors, coverage):
    used_w, used_h, off_x, off_y = fit_rect(src.width, src.height, target_w, target_h, pad)
    palette = build_palette(src, n_colors)
    cells = [[Counter() for _ in range(target_w)] for _ in range(target_h)]
    totals = [[0] * target_w for _ in range(target_h)]
    px = src.load()
    cache = {}
    for sy in range(src.height):
        ty = off_y + min(used_h - 1, int(sy * used_h / src.height))
        for sx in range(src.width):
            tx = off_x + min(used_w - 1, int(sx * used_w / src.width))
            totals[ty][tx] += 1
            r, g, b, a = px[sx, sy]
            if a == 255:
                key = (r, g, b)
                q = cache.get(key)
                if q is None:
                    q = nearest(key, palette)
                    cache[key] = q
                cells[ty][tx][q] += 1
    out = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 0))
    opx = out.load()
    for ty in range(target_h):
        for tx in range(target_w):
            total = totals[ty][tx]
            counter = cells[ty][tx]
            if total and sum(counter.values()) / total >= coverage:
                opx[tx, ty] = counter.most_common(1)[0][0] + (255,)
    return out


def neighbors8(x, y, w, h):
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            if dx or dy:
                nx, ny = x + dx, y + dy
                if 0 <= nx < w and 0 <= ny < h:
                    yield nx, ny


def clean(im):
    px = im.load()
    w, h = im.size
    removed = filled = 0
    for x in range(w):
        for y in range(h):
            n_opaque = sum(1 for nx, ny in neighbors8(x, y, w, h) if px[nx, ny][3] == 255)
            if px[x, y][3] == 255 and n_opaque <= 1:
                px[x, y] = (0, 0, 0, 0)
                removed += 1
            elif px[x, y][3] == 0 and n_opaque >= 7:
                votes = Counter(px[nx, ny][:3] for nx, ny in neighbors8(x, y, w, h)
                                if px[nx, ny][3] == 255)
                px[x, y] = votes.most_common(1)[0][0] + (255,)
                filled += 1
    return removed, filled


def audit(im):
    data = list(im.getdata())
    opaque = [c[:3] for c in data if c[3] == 255]
    semi = sum(1 for c in data if 0 < c[3] < 255)
    return {
        "taille": im.size,
        "couleurs": len(set(opaque)),
        "pixels_opaques": len(opaque),
        "semi_transparents": semi,
    }


def upscale(im, factor):
    return im.resize((im.width * factor, im.height * factor), Image.NEAREST)


def contact_sheet(raw, result, compare, path):
    row_h = 224
    panels = []
    labels = []
    thumb = raw.copy()
    thumb.thumbnail((row_h, row_h), Image.LANCZOS)
    panels.append(thumb)
    labels.append("reference")
    factor = max(1, row_h // result.height)
    panels.append(upscale(result, factor))
    labels.append("resultat x%d" % factor)
    if compare is not None:
        cf = max(1, row_h // compare.height)
        panels.append(upscale(compare, cf))
        labels.append("existant x%d" % cf)
    gap, label_h = 16, 20
    width = sum(p.width for p in panels) + gap * (len(panels) + 1)
    height = row_h + label_h + 2 * gap
    sheet = Image.new("RGBA", (width, height), (24, 24, 28, 255))
    draw = ImageDraw.Draw(sheet)
    x = gap
    for panel, label in zip(panels, labels):
        sheet.alpha_composite(panel, (x, gap + row_h - panel.height))
        draw.text((x, gap + row_h + 4), label, fill=(220, 220, 220, 255))
        x += panel.width + gap
    sheet.save(path)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input")
    parser.add_argument("output")
    parser.add_argument("--size", required=True)
    parser.add_argument("--colors", type=int, default=8)
    parser.add_argument("--pad", type=int, default=0)
    parser.add_argument("--alpha-threshold", type=int, default=128)
    parser.add_argument("--mode", choices=["average", "vote"], default="average")
    parser.add_argument("--sat", type=float, default=1.4)
    parser.add_argument("--contrast", type=float, default=1.2)
    parser.add_argument("--coverage", type=float, default=0.5)
    parser.add_argument("--preview", type=int, default=8)
    parser.add_argument("--compare")
    parser.add_argument("--no-clean", action="store_true")
    args = parser.parse_args()

    target_w, target_h = parse_size(args.size)
    raw = Image.open(args.input).convert("RGBA")
    src = crop_to_content(binarize_alpha(raw.copy(), args.alpha_threshold))
    if args.mode == "average":
        result = reduce_average(src, target_w, target_h, args.pad,
                                args.colors, args.sat, args.contrast)
    else:
        result = reduce_vote(src, target_w, target_h, args.pad,
                             args.colors, args.coverage)
    removed = filled = 0
    if not args.no_clean:
        removed, filled = clean(result)
    result.save(args.output)

    base, _ = os.path.splitext(args.output)
    preview_path = base + "_preview_x%d.png" % args.preview
    upscale(result, args.preview).save(preview_path)
    contact_path = base + "_contact.png"
    compare = Image.open(args.compare).convert("RGBA") if args.compare else None
    contact_sheet(raw, result, compare, contact_path)

    report = audit(result)
    print("sprite      :", args.output)
    print("taille      : %dx%d" % report["taille"])
    print("couleurs    :", report["couleurs"])
    print("opaques     :", report["pixels_opaques"])
    print("semi-transp :", report["semi_transparents"])
    print("nettoyage   : %d orphelins retires, %d trous rebouches" % (removed, filled))
    print("preview     :", preview_path)
    print("contact     :", contact_path)


if __name__ == "__main__":
    main()
