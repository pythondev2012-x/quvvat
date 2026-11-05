# Loyihani PowerShell orqali ishga tushirish.
# Ishlatish:  .\scripts\start.ps1
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

# PostgreSQL (5432) ishlab turganini ta'minlaymiz.
& (Join-Path $PSScriptRoot "postgres_start.bat") | Out-Host

& (Join-Path $root ".venv\Scripts\python.exe") manage.py runserver
