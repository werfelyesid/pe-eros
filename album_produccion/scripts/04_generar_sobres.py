#!/usr/bin/env python3
import argparse
import csv
import json
import random
from collections import Counter
from pathlib import Path


def read_config(root: Path) -> dict:
    with (root / "data" / "config_album.json").open("r", encoding="utf-8") as f:
        return json.load(f)


def read_catalog(path: Path):
    with path.open("r", encoding="utf-8", newline="") as f:
        rows = list(csv.DictReader(f))
    return [r for r in rows if r.get("tipo", "").lower() == "jugador"]


def normalize_rare(player_name: str, rareza: str, forced_rare_player: str):
    if player_name.strip().lower() == forced_rare_player.strip().lower():
        return "R"
    r = (rareza or "C").upper()
    if r not in {"C", "R", "E"}:
        return "C"
    return r


def weighted_choice(pool, weights_map):
    weights = [weights_map.get(item["rareza"], 0.0) for item in pool]
    total = sum(weights)
    if total <= 0:
        return random.choice(pool)
    pick = random.uniform(0, total)
    acc = 0.0
    for item, w in zip(pool, weights):
        acc += w
        if pick <= acc:
            return item
    return pool[-1]


def generate_packs(cards, num_packs, cards_per_pack, weights_map):
    packs = []
    for p in range(1, num_packs + 1):
        pack_cards = []
        used_ids = set()
        guard = 0
        while len(pack_cards) < cards_per_pack and guard < 200:
            guard += 1
            candidate = weighted_choice(cards, weights_map)
            cid = candidate["id"]
            if cid in used_ids:
                continue
            used_ids.add(cid)
            pack_cards.append(candidate)
        packs.append(pack_cards)
    return packs


def save_pack_report(packs, out_csv: Path):
    out_csv.parent.mkdir(parents=True, exist_ok=True)
    with out_csv.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=["pack_id", "slot", "id", "nombre", "rareza"],
        )
        writer.writeheader()
        for i, pack in enumerate(packs, start=1):
            for slot, card in enumerate(pack, start=1):
                writer.writerow(
                    {
                        "pack_id": f"S{i:04d}",
                        "slot": slot,
                        "id": card["id"],
                        "nombre": card["nombre"],
                        "rareza": card["rareza"],
                    }
                )


def save_summary(packs, price_pesitos, out_txt: Path):
    out_txt.parent.mkdir(parents=True, exist_ok=True)
    rarity_counter = Counter()
    for pack in packs:
        for card in pack:
            rarity_counter[card["rareza"]] += 1

    gross = len(packs) * price_pesitos

    lines = [
        "Resumen de lote de sobres",
        f"Total sobres: {len(packs)}",
        f"Laminas por sobre: {len(packs[0]) if packs else 0}",
        f"Precio por sobre: {price_pesitos} pesitos",
        f"Ingreso bruto potencial: {gross} pesitos",
        "Distribucion de rarezas en el lote:",
        f"- C: {rarity_counter.get('C', 0)}",
        f"- R: {rarity_counter.get('R', 0)}",
        f"- E: {rarity_counter.get('E', 0)}",
    ]

    out_txt.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main():
    parser = argparse.ArgumentParser(description="Generar lote de sobres")
    parser.add_argument("--num-packs", type=int, default=100, help="Cantidad de sobres")
    args = parser.parse_args()

    root = Path(__file__).resolve().parents[1]
    config = read_config(root)
    rows = read_catalog(root / "data" / "laminas_jugadores.csv")

    forced_rare_player = config.get("forced_rare_player", "")
    weights = config.get("rarity_weights", {"C": 0.75, "R": 0.20, "E": 0.05})
    cards_per_pack = int(config.get("pack", {}).get("cards_per_pack", 3))
    price_pesitos = int(config.get("pack", {}).get("price_pesitos", 1000))

    cards = []
    for r in rows:
        normalized = dict(r)
        normalized["rareza"] = normalize_rare(r.get("nombre", ""), r.get("rareza", "C"), forced_rare_player)
        cards.append(normalized)

    packs = generate_packs(cards, args.num_packs, cards_per_pack, weights)

    out_dir = root / "output" / "packs"
    save_pack_report(packs, out_dir / "lote_sobres.csv")
    save_summary(packs, price_pesitos, out_dir / "resumen_lote.txt")

    print("Sobres generados:", len(packs))
    print("Salida:", out_dir)


if __name__ == "__main__":
    main()
