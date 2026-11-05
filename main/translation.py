"""Mahsulot va kategoriya matnlarini avtomatik tarjima qilish.

Tarjima Google'ning ochiq ``translate_a/single`` endpoint'i orqali amalga
oshiriladi. Tarmoq xatosi yoki endpoint javob bermasa, saqlash jarayoni
buzilmaydi: tarjima maydoni bo'sh qoladi va sayt o'zbekcha matnni ko'rsatadi.
"""

import logging

import requests
from django.utils.translation import get_language

logger = logging.getLogger(__name__)

TRANSLATE_URL = 'https://translate.googleapis.com/translate_a/single'
SUPPORTED_LANGUAGES = ('ru', 'en')
REQUEST_TIMEOUT = (2.0, 8.0)
MAX_CHUNK_LENGTH = 4500


def localized_field(obj, field):
    """Joriy til uchun tarjimani, bo'lmasa asl (o'zbekcha) qiymatni qaytaradi."""
    language = (get_language() or '').split('-')[0]
    if language in SUPPORTED_LANGUAGES:
        translated = getattr(obj, f'{field}_{language}', '') or ''
        if translated.strip():
            return translated
    return getattr(obj, field, '') or ''


def _split_text(text, limit=MAX_CHUNK_LENGTH):
    """Uzun matnni endpoint uchun bo'laklarga ajratadi."""
    text = text.strip()
    if len(text) <= limit:
        return [text]

    chunks = []
    current = ''
    for part in text.splitlines(keepends=True):
        if len(current) + len(part) > limit and current:
            chunks.append(current)
            current = ''
        while len(part) > limit:
            chunks.append(part[:limit])
            part = part[limit:]
        current += part
    if current.strip():
        chunks.append(current)
    return chunks or [text]


def translate_text(text, target_language):
    """Matnni ``target_language`` ga tarjima qiladi.

    Muvaffaqiyatsizlikda ``None`` qaytaradi va logga yozadi. Hech qachon
    xatoni tashqariga chiqarmaydi, chunki bu funksiya model saqlash
    signalidan chaqiriladi.
    """
    if not text or not text.strip():
        return ''

    translated_parts = []
    try:
        for chunk in _split_text(text):
            response = requests.post(
                TRANSLATE_URL,
                data={
                    'client': 'gtx',
                    'sl': 'auto',
                    'tl': target_language,
                    'dt': 't',
                    'q': chunk,
                },
                timeout=REQUEST_TIMEOUT,
                headers={'User-Agent': 'Quvvat/1.0'},
            )
            response.raise_for_status()
            data = response.json()
            segments = data[0] if data and isinstance(data, list) else []
            translated = ''.join(
                segment[0]
                for segment in segments
                if segment and isinstance(segment, list) and segment[0]
            )
            if translated.strip():
                translated_parts.append(translated)
    except Exception as exc:  # noqa: BLE001 - tarjima saqlashni to'xtatmasligi kerak
        logger.warning(
            "Tarjima amalga oshmadi (%s -> %s): %s",
            text[:60],
            target_language,
            exc,
        )
        return None

    if not translated_parts:
        logger.warning(
            "Tarjima bo'sh javob qaytardi (%s -> %s).",
            text[:60],
            target_language,
        )
        return None
    return '\n'.join(part.strip() for part in translated_parts).strip()


def _translate_instance(obj, fields, force=False):
    """Obyektning bo'sh tarjima maydonlarini to'ldiradi.

    ``force=True`` bo'lsa mavjud tarjimalar ham qayta yoziladi.
    """
    updates = {}
    failed = False
    for language in SUPPORTED_LANGUAGES:
        if failed:
            break
        for field in fields:
            translated_field = f'{field}_{language}'
            if not force and (getattr(obj, translated_field, '') or '').strip():
                continue

            source = getattr(obj, field, '') or ''
            if not source.strip():
                continue

            translated = translate_text(source, language)
            if translated is None:
                # Endpoint ishlamayapti — qolgan maydonlarni urinib o'tirmaymiz.
                failed = True
                break
            if translated:
                updates[translated_field] = translated

    if updates:
        type(obj).objects.filter(pk=obj.pk).update(**updates)
        for field, value in updates.items():
            setattr(obj, field, value)
    return updates


def translate_category(category, force=False):
    return _translate_instance(category, ('name',), force=force)


def translate_product(product, force=False):
    return _translate_instance(product, ('name', 'description'), force=force)
