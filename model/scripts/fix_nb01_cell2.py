"""
ZapalloAI — Corrige la celda 2 del notebook 01 añadiendo 'from pathlib import Path'.
Ejecutar desde la raíz del repo:
    python model/scripts/fix_nb01_cell2.py
"""
import json
import sys
import io
from pathlib import Path

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

ROOT = Path(__file__).resolve().parents[2]
NB_PATH = ROOT / "model" / "notebooks" / "01_exploracion_datos.ipynb"

assert NB_PATH.exists(), f"Notebook no encontrado: {NB_PATH}"

print(f"Leyendo: {NB_PATH}")
with open(NB_PATH, "r", encoding="utf-8") as f:
    nb = json.load(f)

cells = nb["cells"]

# Celda 2 (índice 2) es la de "Conteo de imágenes" que usa Path sin importarlo
cell2 = cells[2]
src = "".join(cell2.get("source", []))

if "from pathlib import Path" in src:
    print("  [INFO] La celda 2 ya tiene 'from pathlib import Path'. Sin cambios.")
else:
    # Añadir import al inicio del source
    first_comment_line = cell2["source"][0]  # El comment # ── 2. ...
    cell2["source"] = [
        first_comment_line,
        "from pathlib import Path\n",
        "import pandas as pd\n",
    ] + [
        line for line in cell2["source"][1:]
        if line.strip() not in ("import pandas as pd", "import pandas as pd\n")
    ]
    print("  [OK] Anadido 'from pathlib import Path' a la celda 2")

with open(NB_PATH, "w", encoding="utf-8") as f:
    json.dump(nb, f, ensure_ascii=False, indent=1)

print(f"[OK] Notebook 01 guardado: {NB_PATH}")
