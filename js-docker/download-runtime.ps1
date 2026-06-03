# Baixa o Apache Tomcat para a pasta local (necessario uma vez).
# Depois disso o build Docker nao precisa de internet.

$ErrorActionPreference = "Stop"
$tomcatDir = Join-Path $PSScriptRoot "resources\runtime"
$tomcatVer = "9.0.85"
$tomcatTar = Join-Path $tomcatDir "apache-tomcat-$tomcatVer.tar.gz"
$tomcatHome = Join-Path $tomcatDir "apache-tomcat-$tomcatVer"
$url = "https://archive.apache.org/dist/tomcat/tomcat-9/v$tomcatVer/bin/apache-tomcat-$tomcatVer.tar.gz"

New-Item -ItemType Directory -Force -Path $tomcatDir | Out-Null

if (Test-Path $tomcatHome) {
    Write-Host "Tomcat ja existe em $tomcatHome"
    exit 0
}

if (-not (Test-Path $tomcatTar)) {
    Write-Host "A transferir Tomcat $tomcatVer..."
    curl.exe -L $url -o $tomcatTar
}

Write-Host "A extrair Tomcat..."
tar -xzf $tomcatTar -C $tomcatDir
Write-Host "Concluido: $tomcatHome"
