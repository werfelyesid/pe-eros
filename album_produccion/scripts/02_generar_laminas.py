#!/usr/bin/env python3
import csv
import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageOps

DPI = 300
STICKER_WIDTH_CM = 5.0
STICKER_HEIGHT_CM = 7.0
STICKER_W = int((STICKER_WIDTH_CM / 2.54) * DPI)
STICKER_H = int((STICKER_HEIGHT_CM / 2.54) * DPI)


def read_config(root: Path) -> dict:
    with (root / "data" / "config_album.json").open("r", encoding="utf-8") as f:
        return json.load(f)


def read_catalog(csv_path: Path):
    with csv_path.open("r", encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))


def load_font(size: int):
    try:
        return ImageFont.truetype("DejaVuSans-Bold.ttf", size)
    except OSError:
        return ImageFont.load_default()


def fit_photo(image: Image.Image, width: int, height: int) -> Image.Image:
    return ImageOps.fit(image.convert("RGB"), (width, height), method=Image.Resampling.LANCZOS)


def draw_rare_badge(draw: ImageDraw.ImageDraw, rareza: str, forced_name: str, player_name: str):
    is_rare = (rareza or "C").upper() == "R" or player_name.strip().lower() == forced_name.strip().lower()
    if not is_rare:
        return

    badge_w, badge_h = 150, 56
    x1, y1 = STICKER_W - badge_w - 16, 16
    x2, y2 = STICKER_W - 16, 16 + badge_h
    draw.rounded_rectangle((x1, y1, x2, y2), radius=12, fill=(180, 18, 32), outline=(255, 255, 255), width=2)
    font = load_font(24)
    draw.text((x1 + 22, y1 + 14), "RARA", fill=(255, 255, 255), font=font)


def make_sticker(row: dict, forced_rare_player: str) -> Image.Image:
    base = Image.new("RGB", (STICKER_W, STICKER_H), (240, 240, 240))
    draw = ImageDraw.Draw(base)

    top_h = 52
    bottom_h = 92

    draw.rectangle((0, 0, STICKER_W, top_h), fill=(16, 76, 142))
    draw.rectangle((0, STICKER_H - bottom_h, STICKER_W, STICKER_H), fill=(26, 26, 26))

    image_path = row.get("ruta_imagen", "").strip()
    photo_top = top_h + 8
    photo_bottom = STICKER_H - bottom_h - 8

    if image_path and Path(image_path).exists():
        photo = Image.open(image_path)
        fitted = fit_photo(photo, STICKER_W - 16, photo_bottom - photo_top)
        base.paste(fitted, (8, photo_top))
    else:
        draw.rectangle((8, photo_top, STICKER_W - 8, photo_bottom), fill=(200, 200, 200))
        missing_font = load_font(24)
        draw.text((20, photo_top + 20), "FOTO PENDIENTE", fill=(90, 90, 90), font=missing_font)

    title_font = load_font(22)
    name_font = load_font(24)

    player_id = row.get("id", "SIN_ID")
    player_name = row.get("nombre", "SIN_NOMBRE")

    draw.text((14, 14), player_id, fill=(255, 255, 255), font=title_font)
    draw_rare_badge(draw, row.get("rareza", "C"), forced_rare_player, player_name)

    draw.text((14, STICKER_H - bottom_h + 14), player_name[:30], fill=(255, 255, 255), font=name_font)

    return base


def main():
    root = Path(__file__).resolve().parents[1]
    config = read_config(root)
    forced_rare_player = config.get("forced_rare_player", "")

    catalog = read_catalog(root / "data" / "laminas_jugadores.csv")
    out_dir = root / "output" / "stickers"
    out_dir.mkdir(parents=True, exist_ok=True)

    generated = 0
    for row in catalog:
        if row.get("tipo", "").strip().lower() != "jugador":
            continue
        img = make_sticker(row, forced_rare_player)
        out_path = out_dir / f"{row.get('id', 'SIN_ID')}.png"
        img.save(out_path, format="PNG", dpi=(DPI, DPI))
        generated += 1

    print("Laminas generadas:", generated)
    print("Salida:", out_dir)


if __name__ == "__main__":
    main()
