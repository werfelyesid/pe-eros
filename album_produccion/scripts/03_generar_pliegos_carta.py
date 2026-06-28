#!/usr/bin/env python3
from pathlib import Path
from PIL import Image, ImageDraw

DPI = 300
PAGE_W, PAGE_H = 2550, 3300
CARD_W, CARD_H = 591, 827
MARGIN_X, MARGIN_Y = 120, 120
GAP_X, GAP_Y = 40, 40
COLS, ROWS = 3, 3


def chunk(items, size):
    for i in range(0, len(items), size):
        yield items[i:i + size]


def main():
    root = Path(__file__).resolve().parents[1]
    stickers_dir = root / "output" / "stickers"
    out_dir = root / "output" / "sheets"
    out_dir.mkdir(parents=True, exist_ok=True)

    sticker_files = sorted(stickers_dir.glob("*.png"))
    if not sticker_files:
        print("No hay laminas en", stickers_dir)
        return

    per_sheet = COLS * ROWS
    total_sheets = 0

    for idx, group in enumerate(chunk(sticker_files, per_sheet), start=1):
        page = Image.new("RGB", (PAGE_W, PAGE_H), (255, 255, 255))
        draw = ImageDraw.Draw(page)

        for j, sticker_path in enumerate(group):
            row = j // COLS
            col = j % COLS
            x = MARGIN_X + col * (CARD_W + GAP_X)
            y = MARGIN_Y + row * (CARD_H + GAP_Y)

            sticker = Image.open(sticker_path).convert("RGB")
            if sticker.size != (CARD_W, CARD_H):
                sticker = sticker.resize((CARD_W, CARD_H), Image.Resampling.LANCZOS)

            page.paste(sticker, (x, y))

            # marcas de corte basicas
            draw.rectangle((x, y, x + CARD_W, y + CARD_H), outline=(0, 0, 0), width=1)

        out_file = out_dir / f"pliego_carta_{idx:03d}.png"
        page.save(out_file, format="PNG", dpi=(DPI, DPI))
        total_sheets += 1

    print("Pliegos generados:", total_sheets)
    print("Salida:", out_dir)


if __name__ == "__main__":
    main()
