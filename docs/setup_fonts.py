"""
Descarga la fuente Outfit desde Google Fonts y la coloca en los assets de la app.
Ejecutar desde la raíz del proyecto: python docs/setup_fonts.py
"""
import urllib.request
import zipfile
import os
import shutil
from pathlib import Path

FONTS_URL = "https://fonts.google.com/download?family=Outfit"
FONTS_DIR = Path("zapallo_app/assets/fonts")

NEEDED_WEIGHTS = {
    "Outfit-Regular.ttf":  "Regular",
    "Outfit-Medium.ttf":   "Medium",
    "Outfit-SemiBold.ttf": "SemiBold",
    "Outfit-Bold.ttf":     "Bold",
}

def download_outfit():
    print("📥 Descargando fuente Outfit desde Google Fonts...")
    
    zip_path = Path("outfit_fonts.zip")
    try:
        headers = {"User-Agent": "Mozilla/5.0"}
        req = urllib.request.Request(FONTS_URL, headers=headers)
        with urllib.request.urlopen(req) as response:
            with open(zip_path, "wb") as f:
                f.write(response.read())
        print("   ✅ ZIP descargado")
    except Exception as e:
        print(f"   ❌ Error descargando: {e}")
        print("\n🔧 Descarga manual:")
        print("   1. Ir a: https://fonts.google.com/specimen/Outfit")
        print("   2. Clic en 'Download family'")
        print(f"   3. Extraer y copiar los .ttf a: {FONTS_DIR.absolute()}")
        return False

    # Extraer
    extract_dir = Path("outfit_tmp")
    with zipfile.ZipFile(zip_path, 'r') as z:
        z.extractall(extract_dir)
    
    # Buscar los archivos .ttf necesarios
    FONTS_DIR.mkdir(parents=True, exist_ok=True)
    copied = 0
    for ttf_file in extract_dir.rglob("*.ttf"):
        if ttf_file.name in NEEDED_WEIGHTS:
            dest = FONTS_DIR / ttf_file.name
            shutil.copy2(ttf_file, dest)
            print(f"   📁 {ttf_file.name} → {dest}")
            copied += 1
    
    # Limpiar temporales
    zip_path.unlink(missing_ok=True)
    shutil.rmtree(extract_dir, ignore_errors=True)
    
    if copied == len(NEEDED_WEIGHTS):
        print(f"\n✅ {copied} fuentes instaladas correctamente en {FONTS_DIR}")
        return True
    else:
        print(f"\n⚠️ Solo se copiaron {copied}/{len(NEEDED_WEIGHTS)} fuentes")
        print("   Copia manualmente los archivos faltantes.")
        return False

if __name__ == "__main__":
    success = download_outfit()
    if success:
        print("\n🚀 Listo. Ejecuta 'flutter run' para ver la fuente Outfit en la app.")
