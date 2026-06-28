#!/usr/bin/env python3
import csv
import json
from pathlib import Path

ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"}


def read_config(root: Path) -> dict:
    config_path = root / "data" / "config_album.json"
    with config_path.open("r", encoding="utf-8") as f:
        return json.load(f)


def list_images(folder: Path):
    if not folder.exists():
        return []
    files = []
    for p in folder.iterdir():
        if p.is_file() and p.suffix.lower() in ALLOWED_EXTENSIONS:
            files.append(p)
    files.sort(key=lambda p: p.name.lower())
    return files


def build_rows(config: dict, image_files):
    expected_total = int(config.get("total_players_expected", 15))
    missing_known = list(config.get("known_missing_players", []))

    rows = []
    next_id = 1

    for img in image_files:
        player_id = f"J{next_id:02d}"
        rows.append(
            {
                "id": player_id,
                "nombre": f"PENDIENTE_NOMBRE_{next_id:02d}",
                "archivo": img.name,
                "ruta_imagen": str(img),
                "tipo": "jugador",
                "rareza": "C",
                "estado": "lista_foto",
                "nota": "Renombrar jugador en este registro",
            }
        )
        next_id += 1

    while next_id <= expected_total:
        player_id = f"J{next_id:02d}"
        placeholder_name = (
            missing_known.pop(0)
            if missing_known
            else f"PENDIENTE_FOTO_{next_id:02d}"
        )
        rows.append(
            {
                "id": player_id,
                "nombre": placeholder_name,
                "archivo": "",
                "ruta_imagen": "",
                "tipo": "jugador",
                "rareza": "C",
                "estado": "falta_foto",
                "nota": "Esperando foto",
            }
        )
        next_id += 1

    return rows


def write_csv(csv_path: Path, rows):
    csv_path.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = [
        "id",
        "nombre",
        "archivo",
        "ruta_imagen",
        "tipo",
        "rareza",
        "estado",
        "nota",
    ]
    with csv_path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def main():
    root = Path(__file__).resolve().parents[1]
    config = read_config(root)

    photos_dir = Path(config["players_photos_dir"])
    image_files = list_images(photos_dir)

    rows = build_rows(config, image_files)
    out_csv = root / "data" / "laminas_jugadores.csv"
    write_csv(out_csv, rows)

    print("Catalogo generado:", out_csv)
    print("Fotos detectadas:", len(image_files))
    print("Jugadores esperados:", config.get("total_players_expected", 15))


if __name__ == "__main__":
    main()
