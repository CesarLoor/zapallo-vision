"""Print full source of specific cells in NB02."""
import json, sys
from pathlib import Path
sys.stdout.reconfigure(encoding='utf-8')

nb_path = Path(r"c:\Users\csar_\Desktop\prototipo_zapallo\model\notebooks\02_preprocesamiento.ipynb")
nb = json.loads(nb_path.read_text(encoding="utf-8"))

for i in [2, 4, 5, 7]:
    cell = nb["cells"][i]
    src = "".join(cell["source"])
    print(f"\n{'='*70}")
    print(f"CELL {i}: {cell['cell_type']}")
    print(f"{'='*70}")
    print(src)
