from django import template
from django.conf import settings

register = template.Library()

LANGUAGE_CODES = {code for code, _ in settings.LANGUAGES}


@register.filter
def strip_language_prefix(value):
    """`/ru/cart/?x=1` -> `/cart/?x=1` — til almashtirishda `next` uchun."""
    if not value:
        return value
    path, sep, query = value.partition('?')
    raw = path.strip('/')
    parts = raw.split('/', 1)
    if parts and parts[0] in LANGUAGE_CODES:
        rest = parts[1] if len(parts) > 1 else ''
        path = '/' + rest
        if value.startswith('/') and rest and value.split('?', 1)[0].endswith('/'):
            path += '/'
    return path + (sep + query if sep else '')
