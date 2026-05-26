"""
ZapalloAI — Reescribe las celdas 8 y 9 del notebook 03 y añade la celda 10.
Ejecutar desde la raíz del repo:
    python model/scripts/rewrite_nb03_cells.py
"""
import json
import os
import sys
import io
from pathlib import Path

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

# ── Detectar raíz del repo ──────────────────────────────────────────────────
ROOT = Path(__file__).resolve().parents[2]
NB_PATH = ROOT / "model" / "notebooks" / "03_entrenamiento_yolov11.ipynb"

assert NB_PATH.exists(), f"Notebook no encontrado: {NB_PATH}"

# ── Fuente de las celdas nuevas ─────────────────────────────────────────────

CELL_8_SOURCE = [
    "# ── CELDA 8: Exportar a TFLite (manual: ONNX → TFLite) ──────────────────\n",
    "# NO usa model.export(format='tflite') de Ultralytics porque falla con\n",
    "# onnx2tf en Windows. Usa el flujo manual: ONNX → onnx2tf → TFLite int8.\n",
    "\n",
    "import os, shutil, sys\n",
    "from pathlib import Path\n",
    "\n",
    "# ── Redefinir rutas (por si el kernel se reinició) ────────────────────────\n",
    "ROOT = Path(os.path.abspath('')).resolve()\n",
    "for _ in range(6):\n",
    "    if (ROOT / 'model').exists() and (ROOT / 'zapallo_app').exists():\n",
    "        break\n",
    "    ROOT = ROOT.parent\n",
    "\n",
    "PROJECT_DIR = ROOT / 'model' / 'runs' / 'classify'\n",
    "EXPORT_DIR  = ROOT / 'model' / 'exports'\n",
    "EXPORT_DIR.mkdir(parents=True, exist_ok=True)\n",
    "\n",
    "BEST_PT   = PROJECT_DIR / 'zapallo_yolov11n_v1' / 'weights' / 'best.pt'\n",
    "BEST_ONNX = PROJECT_DIR / 'zapallo_yolov11n_v1' / 'weights' / 'best.onnx'\n",
    "\n",
    "assert BEST_PT.exists(), (\n",
    "    f'Modelo no encontrado: {BEST_PT}\\n'\n",
    "    'Ejecuta primero el entrenamiento (Celda 5).'\n",
    ")\n",
    "\n",
    "# ── Paso 1: Exportar a ONNX (si no existe) ───────────────────────────────\n",
    "if not BEST_ONNX.exists():\n",
    "    print('Exportando PyTorch → ONNX...')\n",
    "    from ultralytics import YOLO\n",
    "    model = YOLO(str(BEST_PT))\n",
    "    model.export(format='onnx', imgsz=224, simplify=True)\n",
    "    print(f'  ONNX creado: {BEST_ONNX} ({BEST_ONNX.stat().st_size/1024**2:.2f} MB)')\n",
    "else:\n",
    "    print(f'ONNX ya existe: {BEST_ONNX.name} ({BEST_ONNX.stat().st_size/1024**2:.2f} MB)')\n",
    "\n",
    "# ── Paso 2: Verificar que onnx2tf está disponible ─────────────────────────\n",
    "try:\n",
    "    import onnx2tf\n",
    "    print(f'onnx2tf version: {onnx2tf.__version__} ✅')\n",
    "except ImportError:\n",
    "    print('ERROR: onnx2tf no está instalado.')\n",
    "    print('Ejecuta: pip install \"onnx2tf>=1.26.3,<1.29.0\"')\n",
    "    raise\n",
    "\n",
    "# ── Paso 3: Convertir ONNX → TFLite int8 ────────────────────────────────\n",
    "print('\\nConvirtiendo ONNX → TFLite int8...')\n",
    "print('Esto puede tardar 2-5 minutos...\\n')\n",
    "\n",
    "ONNX2TF_OUT = BEST_ONNX.parent / 'best_saved_model'\n",
    "\n",
    "try:\n",
    "    onnx2tf.convert(\n",
    "        input_onnx_file_path=str(BEST_ONNX),\n",
    "        output_folder_path=str(ONNX2TF_OUT),\n",
    "        copy_onnx_input_output_names_to_tflite=True,\n",
    "        non_verbose=True,\n",
    "        output_integer_quantized_tflite=True,\n",
    "        quant_type='per-channel',\n",
    "    )\n",
    "    print('Conversión onnx2tf completada ✅')\n",
    "except Exception as e:\n",
    "    print(f'⚠️ onnx2tf.convert() falló: {e}')\n",
    "    print('Intentando método alternativo via TFLiteConverter...')\n",
    "    import tensorflow as tf\n",
    "    try:\n",
    "        converter = tf.lite.TFLiteConverter.from_saved_model(str(ONNX2TF_OUT))\n",
    "        converter.optimizations = [tf.lite.Optimize.DEFAULT]\n",
    "        converter.target_spec.supported_types = [tf.int8]\n",
    "        tflite_model = converter.convert()\n",
    "        fallback_path = ONNX2TF_OUT / 'fallback_int8.tflite'\n",
    "        with open(fallback_path, 'wb') as f:\n",
    "            f.write(tflite_model)\n",
    "        print(f'Fallback exitoso: {fallback_path}')\n",
    "    except Exception as e2:\n",
    "        print(f'ERROR en fallback: {e2}')\n",
    "        raise RuntimeError(\n",
    "            'No se pudo exportar a TFLite.\\n'\n",
    "            'Verifica las dependencias con: pip install \"onnx2tf>=1.26.3,<1.29.0\" '\n",
    "            '\"tensorflow>=2.17.0,<2.20.0\" ai-edge-litert'\n",
    "        )\n",
    "\n",
    "# ── Paso 4: Buscar y copiar el .tflite generado ──────────────────────────\n",
    "tflite_files = list(ONNX2TF_OUT.rglob('*_integer_quant.tflite'))\n",
    "if not tflite_files:\n",
    "    tflite_files = list(ONNX2TF_OUT.rglob('*.tflite'))\n",
    "\n",
    "if not tflite_files:\n",
    "    raise FileNotFoundError(\n",
    "        f'No se encontró ningún .tflite en {ONNX2TF_OUT}\\n'\n",
    "        'La conversión puede haber fallado silenciosamente.'\n",
    "    )\n",
    "\n",
    "src_tflite = tflite_files[0]\n",
    "dst_tflite = EXPORT_DIR / 'best_int8.tflite'\n",
    "shutil.copy2(str(src_tflite), str(dst_tflite))\n",
    "\n",
    "size_mb = dst_tflite.stat().st_size / 1024**2\n",
    "print(f'\\n{\"=\"*50}')\n",
    "print(f'  TFLite int8 exportado exitosamente!')\n",
    "print(f'  Archivo : {dst_tflite}')\n",
    "print(f'  Tamaño  : {size_mb:.2f} MB')\n",
    "print(f'{\"=\"*50}')\n",
    "\n",
    "if size_mb > 5:\n",
    "    print('⚠️ ADVERTENCIA: El archivo es mayor a 5 MB. Verifica que sea correcto.')\n",
]

CELL_9_SOURCE = [
    "# ── CELDA 9: Generar labels.txt ──────────────────────────────────────────\n",
    "import os\n",
    "from pathlib import Path\n",
    "\n",
    "# ── Redefinir rutas (por si el kernel se reinició) ────────────────────────\n",
    "ROOT = Path(os.path.abspath('')).resolve()\n",
    "for _ in range(6):\n",
    "    if (ROOT / 'model').exists() and (ROOT / 'zapallo_app').exists():\n",
    "        break\n",
    "    ROOT = ROOT.parent\n",
    "\n",
    "EXPORT_DIR = ROOT / 'model' / 'exports'\n",
    "EXPORT_DIR.mkdir(parents=True, exist_ok=True)\n",
    "\n",
    "CLASSES = ['healthy', 'downy_mildew', 'leaf_curl', 'mosaic_virus', 'red_beetle']\n",
    "\n",
    "# Generar labels.txt\n",
    "lbl_path = EXPORT_DIR / 'labels.txt'\n",
    "lbl_path.write_text('\\n'.join(CLASSES), encoding='utf-8')\n",
    "\n",
    "print('labels.txt generado:')\n",
    "for i, label in enumerate(CLASSES):\n",
    "    print(f'  {i}: {label}')\n",
    "\n",
    "# Verificar\n",
    "content = lbl_path.read_text(encoding='utf-8').strip().split('\\n')\n",
    "assert len(content) == 5, f'ERROR: labels.txt tiene {len(content)} líneas, esperadas 5'\n",
    "assert content == CLASSES, f'ERROR: contenido no coincide con CLASSES'\n",
    "print(f'\\n✅ Verificado: {lbl_path} ({len(content)} clases)')\n",
]

CELL_10_SOURCE = [
    "# ── CELDA 10: Verificación final de artefactos ───────────────────────────\n",
    "import os\n",
    "from pathlib import Path\n",
    "\n",
    "# ── Redefinir rutas ───────────────────────────────────────────────────────\n",
    "ROOT = Path(os.path.abspath('')).resolve()\n",
    "for _ in range(6):\n",
    "    if (ROOT / 'model').exists() and (ROOT / 'zapallo_app').exists():\n",
    "        break\n",
    "    ROOT = ROOT.parent\n",
    "\n",
    "EXPORT_DIR = ROOT / 'model' / 'exports'\n",
    "CLASSES    = ['healthy', 'downy_mildew', 'leaf_curl', 'mosaic_virus', 'red_beetle']\n",
    "\n",
    "print('=' * 55)\n",
    "print('  ZapalloAI — Verificación de Artefactos para Flutter')\n",
    "print('=' * 55)\n",
    "\n",
    "all_ok = True\n",
    "\n",
    "# 1. Verificar best_int8.tflite\n",
    "tflite_path = EXPORT_DIR / 'best_int8.tflite'\n",
    "if tflite_path.exists():\n",
    "    size_mb = tflite_path.stat().st_size / 1024**2\n",
    "    status = '✅' if size_mb < 5 else '⚠️ (>5MB)'\n",
    "    print(f'  {status} best_int8.tflite  : {size_mb:.2f} MB')\n",
    "else:\n",
    "    print('  ❌ best_int8.tflite  : NO ENCONTRADO → Ejecuta Celda 8')\n",
    "    all_ok = False\n",
    "\n",
    "# 2. Verificar labels.txt\n",
    "lbl_path = EXPORT_DIR / 'labels.txt'\n",
    "if lbl_path.exists():\n",
    "    content = lbl_path.read_text(encoding='utf-8').strip().split('\\n')\n",
    "    if content == CLASSES:\n",
    "        print(f'  ✅ labels.txt        : {len(content)} clases correctas')\n",
    "    else:\n",
    "        print(f'  ⚠️ labels.txt        : contenido inesperado: {content}')\n",
    "        all_ok = False\n",
    "else:\n",
    "    print('  ❌ labels.txt        : NO ENCONTRADO → Ejecuta Celda 9')\n",
    "    all_ok = False\n",
    "\n",
    "# 3. Verificar confusion_matrix.png\n",
    "cm_path = EXPORT_DIR / 'confusion_matrix.png'\n",
    "if cm_path.exists():\n",
    "    cm_kb = cm_path.stat().st_size / 1024\n",
    "    print(f'  ✅ confusion_matrix  : {cm_kb:.1f} KB')\n",
    "else:\n",
    "    print('  ❌ confusion_matrix  : NO ENCONTRADO → Ejecuta Celda 7')\n",
    "    all_ok = False\n",
    "\n",
    "print()\n",
    "if all_ok:\n",
    "    print('🎉 ¡TODO LISTO! Artefactos listos para integrar en Flutter.')\n",
    "    print()\n",
    "    print('Copiar a la app Flutter:')\n",
    "    print(f'  {EXPORT_DIR / \"best_int8.tflite\"}')\n",
    "    print(f'    → zapallo_app/assets/models/best_int8.tflite')\n",
    "    print(f'  {EXPORT_DIR / \"labels.txt\"}')\n",
    "    print(f'    → zapallo_app/assets/models/labels.txt')\n",
    "else:\n",
    "    print('⚠️ Faltan artefactos. Revisa los errores arriba.')\n",
]


def make_code_cell(source_lines: list, cell_id: str) -> dict:
    return {
        "cell_type": "code",
        "execution_count": None,
        "id": cell_id,
        "metadata": {},
        "outputs": [],
        "source": source_lines,
    }


def main():
    print(f"Leyendo: {NB_PATH}")
    with open(NB_PATH, "r", encoding="utf-8") as f:
        nb = json.load(f)

    cells = nb["cells"]
    print(f"  Total de celdas: {len(cells)}")

    # Reemplazar celda 8
    cells[8] = make_code_cell(CELL_8_SOURCE, "celda_8_export_tflite")
    print("  [OK] Celda 8 reescrita (Exportar TFLite)")

    # Reemplazar celda 9
    cells[9] = make_code_cell(CELL_9_SOURCE, "celda_9_labels")
    print("  [OK] Celda 9 reescrita (Generar labels.txt)")

    # Insertar/reemplazar celda 10 (verificación)
    # Si ya existe una celda 10 (markdown "Resumen"), insertar antes de ella
    # Si el notebook tiene exactamente 12 celdas (0-11), reemplazar la celda 11 (vacía)
    cell_10_new = make_code_cell(CELL_10_SOURCE, "celda_10_verificacion")

    if len(cells) >= 11:
        # Celda 10 actual es markdown "Resumen" → insertar antes de ella
        cells.insert(10, cell_10_new)
        print("  [OK] Celda 10 insertada (Verificacion final)")
    else:
        cells.append(cell_10_new)
        print("  [OK] Celda 10 anadida al final (Verificacion final)")

    # Guardar el notebook modificado
    with open(NB_PATH, "w", encoding="utf-8") as f:
        json.dump(nb, f, ensure_ascii=False, indent=1)

    print(f"\n[OK] Notebook guardado: {NB_PATH}")
    print(f"   Total de celdas ahora: {len(nb['cells'])}")


if __name__ == "__main__":
    main()
