"""Templatelardagi tarjima qilinadigan matnlarni yig'adi.

Foydalanish:
    ./.venv/Scripts/python.exe scripts/extract_i18n_strings.py
"""

import re
import sys
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
TEMPLATES_DIR = BASE_DIR / 'templates' / 'front'

TRANS_RE = re.compile(
    r'{%\s*trans\s+(?:"((?:[^"\\]|\\.)*)"|\'((?:[^\'\\]|\\.)*)\')\s*%}'
)
BLOCK_RE = re.compile(
    r'{%\s*blocktrans(?:\s+[^%]*)?%}(.*?){%\s*endblocktrans\s*%}', re.S
)


def collect():
    strings = set()
    for path in sorted(TEMPLATES_DIR.glob('*.html')):
        text = path.read_text(encoding='utf-8')
        for match in TRANS_RE.finditer(text):
            value = match.group(1) if match.group(1) is not None else match.group(2)
            strings.add(value)
        for match in BLOCK_RE.finditer(text):
            value = re.sub(r'{%\s*plural\s*%}', '', match.group(1)).strip()
            strings.add(value)
    return strings


if __name__ == '__main__':
    items = collect()
    for item in sorted(items):
        print(repr(item))
    print(f'TOTAL {len(items)}', file=sys.stderr)
