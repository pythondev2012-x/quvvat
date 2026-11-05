# Loyihani PowerShell orqali ishga tushirish.
# Ishlatish:  .\scripts\start.ps1
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

# PostgreSQL (5432) ishlab turganini ta'minlaymiz.
& (Join-Path $PSScriptRoot "postgres_start.bat") | Out-Host

$port = 8000
$lanIp = (
    Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object {
        $_.IPAddress -notlike "127.*" -and
        $_.IPAddress -notlike "169.254.*" -and
        $_.PrefixOrigin -ne "WellKnown"
    } |
    Select-Object -First 1 -ExpandProperty IPAddress
)

Write-Host ""
Write-Host "Sayt:    http://127.0.0.1:$port/"
if ($lanIp) {
    Write-Host "Telefon: http://${lanIp}:$port/api"
    Write-Host "Ilova sozlamalarida API manzilini shunday kiriting."
} else {
    Write-Host "Telefon uchun kompyuterning lokal IP manzilini ishlating."
}
Write-Host ""

# 0.0.0.0 — telefonga ulanadigan qilib tinglaymiz.
& (Join-Path $root ".venv\Scripts\python.exe") manage.py runserver "0.0.0.0:$port"
