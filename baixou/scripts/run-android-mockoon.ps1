$ErrorActionPreference = 'Stop'

if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
    throw 'ADB não encontrado. Instale/configure o Android SDK Platform Tools.'
}

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw 'Flutter não encontrado no PATH.'
}

$devices = @(adb devices | Select-Object -Skip 1 | Where-Object { $_ -match "\tdevice$" })
if ($devices.Count -eq 0) {
    throw 'Nenhum celular autorizado. Ative a Depuração USB, conecte o cabo e aceite a autorização no aparelho.'
}

if ($devices.Count -gt 1) {
    throw 'Há mais de um dispositivo Android. Desconecte os extras ou execute flutter run -d <id> manualmente.'
}

$deviceId = ($devices[0] -split "\t")[0]

adb -s $deviceId reverse tcp:3001 tcp:3001
if ($LASTEXITCODE -ne 0) {
    throw 'Não foi possível criar o redirecionamento ADB para a porta 3001.'
}

Write-Host "Dispositivo: $deviceId"
Write-Host 'Mockoon esperado em http://localhost:3001/api'
flutter run -d $deviceId `
    --dart-define=API_BASE_URL=http://127.0.0.1:3001/api `
    --dart-define=DEMO_AUTH_CODE=1234
