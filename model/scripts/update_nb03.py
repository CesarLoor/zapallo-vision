import json
from pathlib import Path

nb_path = Path(r"c:\Users\csar_\Desktop\prototipo_zapallo\model\notebooks\03_entrenamiento_yolov11.ipynb")
nb = json.loads(nb_path.read_text(encoding="utf-8"))

# Modify Cell 5
cell5_src = "".join(nb["cells"][5]["source"])
cell5_src = cell5_src.replace("epochs    = 10", "epochs    = 50")
cell5_src = cell5_src.replace("name      = 'zapallo_yolov11n_v1'", "name      = 'zapallo_yolov11n_v2',\n    exist_ok  = False")
cell5_src = cell5_src.replace("imgsz     = 224,", "imgsz     = 224,\n    patience  = 15,\n    dropout   = 0.2,")
nb["cells"][5]["source"] = [line + ("\n" if not line.endswith("\n") else "") for line in cell5_src.split("\n") if line]

# Modify other cells to use v2
for i in [6, 7, 8]:
    src = "".join(nb["cells"][i]["source"])
    src = src.replace("'zapallo_yolov11n_v1'", "'zapallo_yolov11n_v2'")
    nb["cells"][i]["source"] = [line + ("\n" if not line.endswith("\n") else "") for line in src.split("\n") if line]

nb_path.write_text(json.dumps(nb, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
print("Updated NB03 successfully.")
