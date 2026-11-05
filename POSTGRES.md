# PostgreSQL

Sayt SQLite o‘rniga PostgreSQL 17.6 da ishlaydi.

## Lokal baza

- PostgreSQL: `C:\Users\Thebe\pgsql`
- Ma’lumotlar papkasi: `C:\Users\Thebe\pgdata-quvvat`
- Baza nomi: `quvvat`
- Foydalanuvchi: `quvvat`
- Port: `5432`
- Parol va boshqa sozlamalar: loyihadagi `.env` faylida
- PostgreSQL superuser (`postgres`) paroli: `C:\Users\Thebe\pgdata-quvvat\ADMIN_PASSWORD.txt`

`.env` faylini hech kimga yubormang va GitHub’ga qo‘shmang.
`quvvat` roli test bazasini yaratishi uchun `CREATEDB` huquqiga ega.

## Ishga tushirish

PowerShell orqali (tavsiya etiladi):

```powershell
cd C:\Users\Thebe\OneDrive\Desktop\Quvvat
.\scripts\start.ps1
```

Brauzerda: <http://127.0.0.1:8000/>

Agar PowerShell skriptni bloklasa:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start.ps1
```

Yoki PostgreSQL’ni alohida ishga tushirib, Django’ni qo‘lda yuritish:

```powershell
.\scripts\postgres_start.bat
.\.venv\Scripts\python.exe manage.py runserver
```

To‘xtatish:

```bat
scripts\postgres_stop.bat
```

Holatni tekshirish:

```bat
scripts\postgres_status.bat
```

Lokal PostgreSQL Windows’ga kirganda avtomatik ishga tushadi
(`Startup` papkasidagi `quvvat-postgres.vbs` orqali).

## Django

```bat
.venv\Scripts\python.exe manage.py migrate
.venv\Scripts\python.exe manage.py runserver
```

## Bazani psql orqali ochish

PowerShell’da loyiha bazasiga ulanish:

```powershell
cd C:\Users\Thebe\OneDrive\Desktop\Quvvat
.\scripts\psql.ps1
```

Bitta SQL buyrug‘ini bajarish:

```powershell
.\scripts\psql.ps1 -c "select count(*) from main_product;"
```

`psql.ps1` parolni `.env` faylidan o‘zi oladi, qo‘lda kiritish shart emas.

## Muhim: ikkinchi PostgreSQL (18.6, port 5433)

Kompyuterda yana bitta PostgreSQL 18.6 Windows service sifatida `5433`
portida ishlashi mumkin. U **loyiha bazasi emas**. Loyiha `5432` portidagi
PostgreSQL 17.6 va `quvvat` bazasidan foydalanadi.

Agar 18.6 ga ham ulanish kerak bo‘lsa:

```powershell
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h 127.0.0.1 -p 5433 -U postgres -d postgres
```

Parol — PostgreSQL 18.6 o‘rnatilayotganda kiritilgan `postgres` paroli.
Loyihani 18.6 ga ko‘chirish kerak bo‘lsa, avval baza/foydalanuvchi yaratib,
`.env` dagi `DB_PORT` ni `5433` ga o‘zgartirish va `migrate` qilish kerak.

## Zaxira nusxa

Ma’lumotlar bazasini zaxiralash (`.env` dagi parolni `PGPASSWORD` ga qo‘ying):

```bat
set PGPASSWORD=parol
C:\Users\Thebe\pgsql\bin\pg_dump.exe -h 127.0.0.1 -p 5432 -U quvvat -Fc -f backups\quvvat.dump quvvat
```

Tiklash:

```bat
set PGPASSWORD=parol
C:\Users\Thebe\pgsql\bin\pg_restore.exe -h 127.0.0.1 -p 5432 -U quvvat -d quvvat --clean --if-exists backups\quvvat.dump
```

Django orqali faqat ma’lumotlarni JSON’ga chiqarish:

```bat
.venv\Scripts\python.exe manage.py dumpdata main authtoken.token --natural-foreign --natural-primary --indent 2 -o backups\data.json
```

## Serverga chiqarishda

1. Serverda PostgreSQL 14+ o‘rnating.
2. Baza va foydalanuvchi yarating:
   ```sql
   CREATE USER quvvat WITH PASSWORD 'kuchli-parol';
   CREATE DATABASE quvvat OWNER quvvat ENCODING 'UTF8';
   ```
3. `.env.example` dan `.env` yasab, serverdagi qiymatlarni yozing.
4. `pip install -r requirements.txt`
5. `python manage.py migrate`
6. Eski ma’lumotlarni ko‘chirish kerak bo‘lsa:
   ```bat
   python manage.py loaddata backups\data.json
   ```
7. `python manage.py collectstatic`

PostgreSQL serverga tashqi internetdan ochiq bo‘lmasin; Django va baza
odatda bitta serverda yoki xususiy tarmoqda ishlaydi.

## Eski SQLite

SQLite bazasi o‘chirilmagan: `db.sqlite3` va `backups/` papkasidagi nusxa
zaxira sifatida saqlanadi. Sayt endi ularni ishlatmaydi.
