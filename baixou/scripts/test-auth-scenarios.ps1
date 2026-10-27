$ErrorActionPreference = 'Stop'
$baseUrl = 'http://localhost:3001/api'
$headers = @{ 'Content-Type' = 'application/json' }

function Invoke-ExpectedStatus {
    param(
        [string]$Path,
        [hashtable]$Body,
        [int]$ExpectedStatus
    )

    try {
        $response = Invoke-WebRequest `
            -Uri "$baseUrl/$Path" `
            -Method Post `
            -Headers $headers `
            -UseBasicParsing `
            -Body ($Body | ConvertTo-Json)
        $status = [int]$response.StatusCode
    }
    catch {
        if ($_.Exception.Response) {
            $status = [int]$_.Exception.Response.StatusCode
        }
        else {
            throw "Falha ao chamar $Path`: $($_.Exception.Message)"
        }
    }

    if ($status -ne $ExpectedStatus) {
        throw "$Path retornou $status; esperado $ExpectedStatus. Reinicie o ambiente no Mockoon."
    }

    Write-Host "OK $ExpectedStatus POST /api/$Path"
}

$email = 'gabriel@baixou.app'

Invoke-ExpectedStatus -Path 'auth/activate' `
    -Body @{ email = $email; code = '1234' } -ExpectedStatus 200
Invoke-ExpectedStatus -Path 'auth/activate' `
    -Body @{ email = $email; code = '4321' } -ExpectedStatus 422

Invoke-ExpectedStatus -Path 'auth/forgot-password' `
    -Body @{ email = $email } -ExpectedStatus 200
Invoke-ExpectedStatus -Path 'auth/verify-reset-code' `
    -Body @{ email = $email; code = '1234' } -ExpectedStatus 200
Invoke-ExpectedStatus -Path 'auth/verify-reset-code' `
    -Body @{ email = $email; code = '4321' } -ExpectedStatus 422

Invoke-ExpectedStatus -Path 'auth/reset-password' `
    -Body @{
        reset_token = 'mock-reset-token'
        password = 'NovaSenha123'
        password_confirmation = 'NovaSenha123'
    } -ExpectedStatus 200

Write-Host 'Cenários de primeiro acesso e recuperação validados.'
