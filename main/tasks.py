import logging

import redis
from celery import shared_task
from django.conf import settings

from .models import Cart, CartProduct
from .telegram import send_order_notification

logger = logging.getLogger(__name__)


@shared_task
def send_order_notification_task(cart_id, item_ids, latitude=None, longitude=None):
    """Celery worker ichida Telegram xabarini yuboradi."""
    cart = Cart.objects.select_related('user').filter(pk=cart_id).first()
    if cart is None:
        logger.warning("Telegram vazifasi: cart %s topilmadi.", cart_id)
        return False

    items = list(
        CartProduct.objects.filter(pk__in=item_ids).select_related('product')
    )
    return send_order_notification(
        cart,
        items,
        latitude=latitude,
        longitude=longitude,
    )


def broker_available(timeout=1.0):
    """Redis broker tezda javob berishini tekshiradi.

    `retry=None` muhim: aks holda redis-py ulanishni qayta urinib,
    broker o'chiq bo'lganda so'rovni uzoq vaqt osib qo'yadi.
    """
    if getattr(settings, 'CELERY_TASK_ALWAYS_EAGER', False):
        return True

    url = getattr(settings, 'CELERY_BROKER_URL', '') or ''
    if not url.startswith(('redis://', 'rediss://')):
        return True

    client = None
    try:
        client = redis.Redis.from_url(
            url,
            retry=None,
            socket_connect_timeout=timeout,
            socket_timeout=timeout,
        )
        return bool(client.ping())
    except Exception:  # noqa: BLE001 - broker yo'qligi normal holat
        logger.warning("Redis broker mavjud emas, Telegram sinxron yuboriladi.")
        return False
    finally:
        if client is not None:
            try:
                client.close()
            except Exception:  # noqa: BLE001
                pass


def send_notification_now(cart_id, item_ids, latitude=None, longitude=None):
    """Telegram xabarini joriy jarayonda yuboradi."""
    cart = Cart.objects.select_related('user').filter(pk=cart_id).first()
    if cart is None:
        logger.warning("Telegram uchun cart %s topilmadi.", cart_id)
        return False
    items = CartProduct.objects.filter(pk__in=item_ids).select_related('product')
    return send_order_notification(
        cart,
        items,
        latitude=latitude,
        longitude=longitude,
    )


def queue_order_notification(cart_id, item_ids, latitude=None, longitude=None):
    """Celeryga vazifa qo'shadi; broker ishlamasa sinxron yuborishga qaytadi."""
    item_ids = list(item_ids)

    if broker_available():
        try:
            send_order_notification_task.delay(
                cart_id, item_ids, latitude, longitude
            )
            return True
        except Exception:  # noqa: BLE001 - buyurtma oqimini buzmaslik uchun
            logger.exception(
                "Celeryga vazifa qo'shilmadi. Telegram sinxron yuboriladi."
            )

    return send_notification_now(
        cart_id, item_ids, latitude=latitude, longitude=longitude
    )
