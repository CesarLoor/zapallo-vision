"""
Cuenta imágenes en el dataset procesado.

Uso:
    python model/scripts/count_images.py [--path model/data/processed]
"""

from __future__ import annotations

import argparse
from pathlib import Path


def count_images(data_dir: Path) -> None:
    if not data_dir.exists():
        print(f"ERROR: No encontrado: {data_dir}")
        return

    total = 0
    for split in sorted(data_dir.iterdir()):
        if not split.is_dir():
            continue
        for cls in sorted(split.iterdir()):
            if not cls.is_dir():
                continue
            n = len([f for f in cls.iterdir() if f.is_file()])
            total += n
            print(f"{split.name}/{cls.name}: {n}")
    print(f"\nTotal: {total:,}")


def main():
    parser = argparse.ArgumentParser(description="Contar imágenes del dataset")
    parser.add_argument("--path", type=str, default="model/data/processed",
                        help="Ruta al dataset procesado")
    args = parser.parse_args()
    count_images(Path(args.path))


if __name__ == "__main__":
    main()
