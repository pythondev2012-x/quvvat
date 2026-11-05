"""API so'rovlarida Accept-Language sarlavhasini hisobga oluvchi middleware.

`i18n_patterns(prefix_default_language=False)` ishlatilganda Django
`LocaleMiddleware` prefikssiz URL'larda (masalan `/api/...`) tilni har doim
`LANGUAGE_CODE` ga majburan o'rnatadi. Shu sababli API uchun tilni
`Accept-Language` sarlavhasidan alohida aniqlaymiz.
"""

from django.utils import translation
from django.utils.translation import get_supported_language_variant


class ApiAcceptLanguageMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if request.path.startswith('/api/'):
            header = request.headers.get('Accept-Language', '')
            for chunk in header.split(','):
                candidate = chunk.split(';', 1)[0].strip().lower()
                if not candidate or candidate == '*':
                    continue
                try:
                    language = get_supported_language_variant(candidate)
                except LookupError:
                    continue
                translation.activate(language)
                request.LANGUAGE_CODE = language
                break

        return self.get_response(request)
