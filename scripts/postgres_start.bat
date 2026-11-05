@echo off
setlocal
set "PGBIN=%USERPROFILE%\pgsql\bin"
set "PGDATA=%USERPROFILE%\pgdata-quvvat"

"%PGBIN%\pg_ctl.exe" -D "%PGDATA%" status >nul 2>&1
if %errorlevel%==0 (
    echo PostgreSQL allaqachon ishlayapti.
    exit /b 0
)

"%PGBIN%\pg_ctl.exe" -D "%PGDATA%" -l "%PGDATA%\server.log" -o "-p 5432" start
