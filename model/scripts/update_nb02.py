import json
from pathlib import Path

nb_path = Path(r"c:\Users\csar_\Desktop\prototipo_zapallo\model\notebooks\02_preprocesamiento.ipynb")
nb = json.loads(nb_path.read_text(encoding="utf-8"))

# Modify Cell 7
cell7_src = "".join(nb["cells"][7]["source"])
cell7_src = cell7_src.replace(
    "TARGET = max(train_ns)",
    "train_ns = [len(list((OUTPUT_DIR / 'train' / cls).glob('*.jpg'))) + len(list((OUTPUT_DIR / 'train' / cls).glob('*.png'))) for cls in CLASSES]\nTARGET = max(train_ns)"
)
nb["cells"][7]["source"] = [line + ("\n" if not line.endswith("\n") else "") for line in cell7_src.split("\n") if line]

nb_path.write_text(json.dumps(nb, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
print("Updated NB02 successfully.")
