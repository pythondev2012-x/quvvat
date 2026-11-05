# Loyiha bazasiga psql orqali ulanish.
# Ishlatish:  .\scripts\psql.ps1
# SQL buyrug'i bilan:  .\scripts\psql.ps1 -c "select count(*) from main_product;"
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $root ".env"

if (-not (Test-Path $envFile)) {
    Write-Error ".env topilmadi: $envFile"
    exit 1
}

$cfg = @{}
Get-Content $envFile | ForEach-Object {
    if ($_ -match '^\s*([^#=]+)=(.*)$') {
        $cfg[$matches[1].Trim()] = $matches[2].Trim()
    }
}

$psql = Join-Path $env:USERPROFILE "pgsql\bin\psql.exe"
if (-not (Test-Path $psql)) {
    Write-Error "psql.exe topilmadi: $psql"
    exit 1
}

$env:PGPASSWORD = $cfg["DB_PASSWORD"]
& $psql -h $cfg["DB_HOST"] -p $cfg["DB_PORT"] -U $cfg["DB_USER"] -d $cfg["DB_NAME"] @args
