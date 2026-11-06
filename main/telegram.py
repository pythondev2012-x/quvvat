"""Telegram orqali yangi buyurtma haqida xabar yuborish.

Muhim: Telegram bilan bog'liq xatolar buyurtmani rasmiylashtirish jarayonini
to'xtatmasligi kerak. Shu sababli barcha xatolar logga yoziladi va `False`
qaytariladi.
"""

import logging
import os
from html import escape
from urllib.parse import quote

import requests
from django.utils import timezone

BOT_TOKEN = os.getenv('TELEGRAM_BOT_TOKEN', '')
CHAT_ID = os.getenv('TELEGRAM_CHAT_ID', '')

logger = logging.getLogger(__name__)

_API_URL = "https://api.telegram.org/bot{token}/{method}"
_TIMEOUT = 6
_PLACEHOLDER_PREFIX = "PASTE_"


def is_configured():
    """Token va chat ID haqiqiy qiymatlar bilan to'ldirilganini tekshiradi."""
    return bool(
        BOT_TOKEN
        and CHAT_ID
        and not str(BOT_TOKEN).startswith(_PLACEHOLDER_PREFIX)
        and not str(CHAT_ID).startswith(_PLACEHOLDER_PREFIX)
    )


def _money(value):
    try:
        number = int(value or 0)
    except (TypeError, ValueError):
        number = 0
    return f"{number:,}".replace(",", " ")


def _send(method, payload):
    """Telegram API ga so'rov yuboradi. Hech qachon exception ko'tarmaydi."""
    if not is_configured():
        logger.info("Telegram sozlanmagan, xabar yuborilmadi (%s).", method)
        return False

    try:
        response = requests.post(
            _API_URL.format(token=BOT_TOKEN, method=method),
            json=payload,
            timeout=_TIMEOUT,
        )
        data = response.json()
        if response.status_code != 200 or not data.get("ok"):
            logger.warning(
                "Telegram %s xatosi: status=%s, javob=%s",
                method,
                response.status_code,
                data.get("description", data),
            )
            return False
        return True
    except Exception as exc:  # noqa: BLE001 - buyurtma oqimini buzmaslik uchun
        logger.warning("Telegram %s so'rovida xato: %s", method, exc)
        return False


def _full_name(cart):
    user = cart.user
    name = " ".join(part for part in (user.first_name, user.last_name) if part).strip()
    return name or user.username


def _location_links(cart, latitude=None, longitude=None):
    """Manzil/koordinatalar uchun xarita havolalarini qaytaradi."""
    links = []
    if latitude is not None and longitude is not None:
        links.append(
            '<a href="https://yandex.com/maps/?pt={lon},{lat}&z=17&l=map">'
            "Yandex xaritada</a>".format(lat=latitude, lon=longitude)
        )
        links.append(
            '<a href="https://maps.google.com/?q={lat},{lon}">'
            "Google xaritada</a>".format(lat=latitude, lon=longitude)
        )
    elif getattr(cart.user, "address", ""):
        query = quote(str(cart.user.address))
        links.append(
            '<a href="https://yandex.com/maps/?text={q}">Yandex xaritada</a>'.format(q=query)
        )
        links.append(
            '<a href="https://maps.google.com/?q={q}">Google xaritada</a>'.format(q=query)
        )
    return links


def format_order_message(cart, cart_products, latitude=None, longitude=None):
    """Buyurtma ma'lumotlaridan ixcham HTML Telegram xabarini yasaydi."""
    user = cart.user
    items = list(cart_products)
    total = cart.cart_total_price
    savings = cart.discount_total_price

    phone = escape(str(user.phone)) if user.phone else "—"
    phone_text = (
        f'<a href="tel:{phone}">{phone}</a>' if user.phone else "—"
    )
    email = escape(str(user.email)) if user.email else "—"
    address = escape(str(user.address)) if user.address else "ko'rsatilmagan"

    links = _location_links(cart, latitude, longitude)
    if links:
        address = f"{address} — {' · '.join(links)}"

    if items:
        products = "; ".join(
            "{name} × {count} — {total} so'm".format(
                name=escape(str(item.product.name if item.product else "O'chirilgan mahsulot")),
                count=item.count,
                total=_money(item.total_price),
            )
            for item in items
        )
    else:
        products = "Mahsulotlar topilmadi"

    lines = [
        "🚀 <b>Yangi buyurtma!</b>",
        "",
        f"👤 <b>Ism:</b> {escape(_full_name(cart))}",
        f"📍 <b>Manzil:</b> {address}",
        f"📞 <b>Tel:</b> {phone_text}",
        f"📧 <b>Email:</b> {email}",
        f"📝 <b>Xabar:</b> {products}",
        "",
        f"🧾 <b>Kod:</b> {escape(str(cart.code))} · {timezone.localtime(cart.date):%d.%m.%Y %H:%M}",
        f"💰 <b>Jami:</b> {_money(total)} so'm"
        + (f" · <b>Tejash:</b> {_money(savings)} so'm" if savings else ""),
    ]

    return "\n".join(lines)


def send_order_notification(cart, cart_products, latitude=None, longitude=None):
    """Yangi buyurtma haqida Telegramga xabar (va iloji bo'lsa lokatsiya) yuboradi."""
    if not is_configured():
        logger.info("Telegram token/chat ID hali kiritilmagan — xabar o'tkazib yuborildi.")
        return False

    try:
        text = format_order_message(cart, cart_products, latitude, longitude)
    except Exception as exc:  # noqa: BLE001 - buyurtma oqimini buzmaslik uchun
        logger.warning("Telegram xabarini yasashda xato: %s", exc)
        return False

    sent = _send(
        "sendMessage",
        {
            "chat_id": CHAT_ID,
            "text": text,
            "parse_mode": "HTML",
            "disable_web_page_preview": True,
        },
    )

    if latitude is not None and longitude is not None:
        try:
            lat, lon = float(latitude), float(longitude)
        except (TypeError, ValueError):
            logger.warning("Noto'g'ri koordinatalar: %r, %r", latitude, longitude)
        else:
            _send(
                "sendLocation",
                {
                    "chat_id": CHAT_ID,
                    "latitude": lat,
                    "longitude": lon,
                },
            )

    return sent
