"""Model saqlanganda tarjimalarni avtomatik to'ldiruvchi signallar."""

import logging

from django.conf import settings
from django.db.models.signals import post_save
from django.dispatch import receiver

from .models import Category, Product
from .translation import translate_category, translate_product

logger = logging.getLogger(__name__)

PRODUCT_TRANSLATION_FIELDS = {
    'name_ru',
    'name_en',
    'description_ru',
    'description_en',
}
CATEGORY_TRANSLATION_FIELDS = {'name_ru', 'name_en'}


def _should_translate(update_fields, translation_fields):
    if not getattr(settings, 'AUTO_TRANSLATE', True):
        return False
    # Faqat tarjima maydonlari saqlanayotgan bo'lsa, qayta tarjima kerak emas.
    if update_fields and set(update_fields).issubset(translation_fields):
        return False
    return True


@receiver(post_save, sender=Product)
def translate_product_on_save(sender, instance, created, raw=False, update_fields=None, **kwargs):
    if raw or not _should_translate(update_fields, PRODUCT_TRANSLATION_FIELDS):
        return
    try:
        translate_product(instance)
    except Exception:  # noqa: BLE001 - mahsulot saqlanishi buzilmasligi kerak
        logger.exception("Mahsulot %s tarjimasida xato.", instance.pk)


@receiver(post_save, sender=Category)
def translate_category_on_save(sender, instance, created, raw=False, update_fields=None, **kwargs):
    if raw or not _should_translate(update_fields, CATEGORY_TRANSLATION_FIELDS):
        return
    try:
        translate_category(instance)
    except Exception:  # noqa: BLE001 - kategoriya saqlanishi buzilmasligi kerak
        logger.exception("Kategoriya %s tarjimasida xato.", instance.pk)
