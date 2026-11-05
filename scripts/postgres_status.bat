@echo off
setlocal
set "PGBIN=%USERPROFILE%\pgsql\bin"
set "PGDATA=%USERPROFILE%\pgdata-quvvat"

"%PGBIN%\pg_ctl.exe" -D "%PGDATA%" status
