# Quvvat

Quvvat — santexnika mahsulotlari uchun Django onlayn do‘kon va REST API.
Sayt uch tilda (`uz`, `ru`, `en`) ishlaydi, mahsulot va kategoriya nomlari
bazada saqlanadi va avtomatik tarjima qilinadi.

## Imkoniyatlar

- Katalog, mahsulot sahifasi, qidiruv va bannerlar
- Savat, saqlanganlar (wishlist) va buyurtma rasmiylashtirish
- Ro‘yxatdan o‘tish, kirish, profil
- Django admin panel (django-unfold)
- REST API va Swagger/ReDoc hujjati
- Telegram’ga yangi buyurtma haqida xabar
- `uz` / `ru` / `en` interfeys va DB kontenti tarjimasi
- PostgreSQL ma’lumotlar bazasi

## Texnologiyalar

- Python 3.12+, Django 5.2
- Django REST Framework, drf-yasg, django-filter
- PostgreSQL 14+ (`psycopg`)
- Celery + Redis (fon vazifalari)
- django-unfold (admin)
- Google Translate API (DB kontenti tarjimasi)

## Tez boshlash (Windows / PowerShell)

### 1. Virtual muhit va kutubxonalar

```powershell
cd C:\Users\Thebe\OneDrive\Desktop\Quvvat
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
```

### 2. Sozlamalar

```powershell
Copy-Item .env.example .env
Copy-Item tokens.example.py tokens.py
```

- `.env` ichida `DB_PASSWORD` va `SECRET_KEY` ni to‘ldiring.
- `tokens.py` ichida `BOT_TOKEN` va `CHAT_ID` ni yozing.

`.env` va `tokens.py` GitHub’ga yuklanmaydi.

### 3. PostgreSQL

Baza va foydalanuvchi yarating:

```sql
CREATE USER quvvat WITH PASSWORD 'kuchli-parol';
CREATE DATABASE quvvat OWNER quvvat ENCODING 'UTF8';
```

Batafsil: [`POSTGRES.md`](POSTGRES.md).

### 4. Migratsiya va ishga tushirish

```powershell
.\.venv\Scripts\python.exe manage.py migrate
.\scripts\start.ps1
```

Brauzer: <http://127.0.0.1:8000/>

## Foydali skriptlar

| Skript | Vazifasi |
| --- | --- |
| `scripts\start.ps1` | PostgreSQL’ni tekshirib, Django serverini ishga tushiradi |
| `scripts\psql.ps1` | `.env` dagi parol bilan bazaga ulanadi |
| `scripts\postgres_start.bat` | Lokal PostgreSQL’ni ishga tushiradi |
| `scripts\postgres_stop.bat` | Lokal PostgreSQL’ni to‘xtatadi |
| `scripts\postgres_status.bat` | PostgreSQL holatini ko‘rsatadi |
| `scripts\build_translations.py` | `.po` fayllardan `.mo` yasaydi |

## API

Asosiy manzil: `/api/`

| Metod | Manzil | Vazifasi |
| --- | --- | --- |
| GET | `/api/` | API haqida ma’lumot |
| GET | `/api/categories/` | Kategoriyalar |
| GET | `/api/categories/<id>/` | Kategoriya tafsiloti |
| GET | `/api/products/` | Mahsulotlar (`?q=`, `?category=`) |
| GET | `/api/products/<code>/` | Mahsulot tafsiloti |
| GET | `/api/banners/` | Bannerlar |
| POST | `/api/auth/register/` | Ro‘yxatdan o‘tish |
| POST | `/api/auth/login/` | Token olish |
| POST | `/api/auth/logout/` | Chiqish |
| GET | `/api/auth/me/` | Profil |
| GET/POST/DELETE | `/api/wishlist/` | Saqlanganlar |
| GET | `/api/cart/` | Savat |
| POST/PATCH/DELETE | `/api/cart/items/` | Savat elementlari |
| GET | `/api/orders/` | Buyurtmalar |
| POST | `/api/orders/checkout/` | Buyurtma berish |
| GET | `/api/orders/<code>/` | Buyurtma tafsiloti |

Hujjatlar:

- Swagger: <http://127.0.0.1:8000/swagger/>
- ReDoc: <http://127.0.0.1:8000/redoc/>

## Tillar va tarjima

- `uz` — asosiy til (prefikssiz)
- `ru` — `/ru/...`
- `en` — `/en/...`

Interfeys matnlari `locale/` dagi `.po` fayllarda. DB kontenti
(`name_ru`, `name_en`, `description_ru`, `description_en`) saqlanayotganda
avtomatik tarjima qilinadi. Tarjima xatosi saqlashni to‘xtatmaydi.

## Telegram

Buyurtma yaratilganda Telegram’ga xabar yuboriladi. `tokens.py` dagi
qiymatlar `PASTE_` bilan boshlansa, yuborish o‘tkazib yuboriladi.
Telegram xatosi buyurtmani buzmaydi.

## Loyiha tuzilishi

```text
config/        Django sozlamalari va URL'lar
main/          modellar, view'lar, API, admin, tarjima, signallar
templates/     HTML shablonlar
static/        CSS, JS, rasmlar
locale/        uz/ru/en tarjimalari
media/         yuklangan rasmlar (media/users/ git'ga kirmaydi)
scripts/       ishga tushirish va PostgreSQL skriptlari
```

## Mobil ilova

`mobile/` — Flutter ilova (Android va iOS). Batafsil: [`mobile/README.md`](mobile/README.md).

```powershell
cd mobile
flutter pub get
flutter run
```

API manzili ilova sozlamalarida o‘zgartiriladi:

- Emulyator: `http://10.0.2.2:8000/api`
- Telefon: `http://<kompyuter-IP>:8000/api`

Telefon uchun backend `0.0.0.0:8000` da tinglashi kerak — `scripts\start.ps1`
buni avtomatik qiladi va lokal IP manzilni ko'rsatadi.

iOS build uchun Mac kerak: [`mobile/IOS_BUILD.md`](mobile/IOS_BUILD.md).
