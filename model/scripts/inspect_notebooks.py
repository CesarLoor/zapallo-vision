"""Inspect all notebooks and print cell summaries."""
import json, sys
from pathlib import Path
sys.stdout.reconfigure(encoding='utf-8')

NB_DIR = Path(r"c:\Users\csar_\Desktop\prototipo_zapallo\model\notebooks")

for nb_path in sorted(NB_DIR.glob("*.ipynb")):
    print(f"\n{'='*60}")
    print(f"NOTEBOOK: {nb_path.name}")
    print(f"{'='*60}")
    nb = json.loads(nb_path.read_text(encoding="utf-8"))
    for i, cell in enumerate(nb["cells"]):
        ct = cell["cell_type"]
        src = "".join(cell["source"])
        first_line = src.strip().split("\n")[0][:120] if src.strip() else "(empty)"
        line_count = len(src.split("\n"))
        print(f"  Cell {i:2d} [{ct:8s}] ({line_count:3d} lines) | {first_line}")
