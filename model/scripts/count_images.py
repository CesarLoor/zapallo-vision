import sys
sys.stdout.reconfigure(encoding='utf-8')
from pathlib import Path

d = Path(r'c:\Users\csar_\Desktop\prototipo_zapallo\model\data\processed')
for s in ['train', 'val', 'test']:
    for c in sorted((d / s).iterdir()):
        if c.is_dir():
            n = len([f for f in c.iterdir() if f.is_file()])
            print(f'{s}/{c.name}: {n}')
