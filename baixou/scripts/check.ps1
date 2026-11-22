$ErrorActionPreference = 'Stop'
$env:FLUTTER_SUPPRESS_ANALYTICS = 'true'
$env:DART_SUPPRESS_ANALYTICS = 'true'

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw 'Flutter não encontrado no PATH.'
}

Push-Location (Join-Path $PSScriptRoot '..')
try {
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw 'Falha no flutter pub get.' }

    flutter analyze
    if ($LASTEXITCODE -ne 0) { throw 'Falha no flutter analyze.' }

    flutter test
    if ($LASTEXITCODE -ne 0) { throw 'Falha no flutter test.' }
}
finally {
    Pop-Location
}
