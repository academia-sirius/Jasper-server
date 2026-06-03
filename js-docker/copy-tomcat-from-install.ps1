# Copia o Tomcat da instalacao Windows (.exe) para a pasta local do Docker.
# Executar ANTES de: docker compose build --pull=false

$ErrorActionPreference = "Stop"
$dest = Join-Path $PSScriptRoot "resources\runtime\apache-tomcat-9.0.85"

if (Test-Path (Join-Path $dest "bin\catalina.sh")) {
    Write-Host "Tomcat ja existe em $dest"
    exit 0
}

$candidates = @(
    "C:\Program Files\TIBCO\jasperreports-server*\apache-tomcat*",
    "C:\Program Files\TIBCO\JasperReports Server*\apache-tomcat*",
    "C:\TIBCO\jasperreports-server*\apache-tomcat*",
    "C:\Jaspersoft\jasperreports-server*\apache-tomcat*",
    "C:\Program Files\Jaspersoft\jasperreports-server*\apache-tomcat*"
)

$source = $null
foreach ($pattern in $candidates) {
    $found = Get-ChildItem -Path $pattern -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) { $source = $found.FullName; break }
}

if (-not $source) {
    Write-Host "Tomcat nao encontrado na instalacao Windows."
    Write-Host "Copia manualmente a pasta apache-tomcat para:"
    Write-Host "  $dest"
    Write-Host ""
    Write-Host "Ou, com internet, executa: .\download-runtime.ps1"
    exit 1
}

Write-Host "A copiar Tomcat de: $source"
New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
Copy-Item -Path $source -Destination $dest -Recurse -Force
Write-Host "Concluido: $dest"
