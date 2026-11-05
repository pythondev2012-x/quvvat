"""Tarjima katalogini (.po) yaratadi va .mo ga kompilyatsiya qiladi.

msgfmt talab qilinmaydi — GNU MO formatini Python'da yozamiz.

Foydalanish:
    ./.venv/Scripts/python.exe -X utf8 scripts/build_translations.py
"""

import struct
import sys
from pathlib import Path

from translations import TRANSLATIONS

BASE_DIR = Path(__file__).resolve().parent.parent
LOCALE_DIR = BASE_DIR / 'locale'


def escape_po(value):
    return value.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')


def metadata(lang):
    return (
        'Project-Id-Version: Quvvat 1.0\n'
        'Report-Msgid-Bugs-To: \n'
        'POT-Creation-Date: 2026-01-01 00:00+0500\n'
        'PO-Revision-Date: 2026-01-01 00:00+0500\n'
        'Last-Translator: Quvvat <dev@quvvat.uz>\n'
        f'Language-Team: {lang}\n'
        f'Language: {lang}\n'
        'MIME-Version: 1.0\n'
        'Content-Type: text/plain; charset=UTF-8\n'
        'Content-Transfer-Encoding: 8bit\n'
        'Plural-Forms: nplurals=1; plural=0;\n'
    )


def write_po(path, lang, messages):
    header = metadata(lang)
    lines = ['msgid ""', 'msgstr ""']
    lines.extend(f'"{escape_po(line)}\\n"' for line in header.splitlines())
    lines.append('')
    for msgid in sorted(messages):
        msgstr = messages[msgid]
        lines.append(f'msgid "{escape_po(msgid)}"')
        lines.append(f'msgstr "{escape_po(msgstr)}"')
        lines.append('')
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text('\n'.join(lines), encoding='utf-8')


def write_mo(path, lang, messages):
    messages = {'': metadata(lang), **messages}
    items = sorted(messages.items())
    keys = [k.encode('utf-8') for k, _ in items]
    values = [v.encode('utf-8') for _, v in items]

    # Barcha satrlar uchun bitta katta buffer yig'amiz.
    offsets = []
    chunks = []
    cursor = 0
    for text in keys + values:
        offsets.append((cursor, len(text)))
        chunks.append(text + b'\x00')
        cursor += len(text) + 1

    key_offsets = offsets[:len(keys)]
    value_offsets = offsets[len(keys):]

    header_size = 7 * 4
    key_table_start = header_size
    value_table_start = key_table_start + len(keys) * 8
    strings_start = value_table_start + len(values) * 8

    key_table = b''.join(
        struct.pack('<II', ln, strings_start + off) for off, ln in key_offsets
    )
    value_table = b''.join(
        struct.pack('<II', ln, strings_start + off) for off, ln in value_offsets
    )

    header = struct.pack(
        '<7I',
        0x950412DE,              # magic
        0,                       # revision
        len(keys),               # number of strings
        key_table_start,
        value_table_start,
        0,                       # hash table size
        strings_start + cursor,  # hash table offset (unused)
    )

    payload = b''.join(chunks)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(header + key_table + value_table + payload)


def main():
    for lang, messages in TRANSLATIONS.items():
        po_path = LOCALE_DIR / lang / 'LC_MESSAGES' / 'django.po'
        mo_path = LOCALE_DIR / lang / 'LC_MESSAGES' / 'django.mo'
        write_po(po_path, lang, messages)
        write_mo(mo_path, lang, messages)
        print(f'{lang}: {len(messages)} ta satr -> {mo_path.relative_to(BASE_DIR)}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
