$ErrorActionPreference = 'Stop'

$baseUrl = 'http://localhost:3001/api'
$health = Invoke-RestMethod -Uri "$baseUrl/health" -Method Get
if ($health.data.status -ne 'ok') {
    throw 'O Mockoon respondeu, mas o health check não retornou status ok.'
}

$loginBody = @{
    email = 'gabriel@baixou.app'
    password = '12345678'
} | ConvertTo-Json

$login = Invoke-RestMethod `
    -Uri "$baseUrl/auth/login" `
    -Method Post `
    -ContentType 'application/json' `
    -Body $loginBody

if (-not $login.token) {
    throw 'O login mock não retornou token.'
}

$headers = @{ Authorization = "Bearer $($login.token)" }
$products = Invoke-RestMethod -Uri "$baseUrl/products" -Headers $headers -Method Get

Write-Host 'Mockoon validado com sucesso.'
Write-Host "Usuário: $($login.data.email)"
Write-Host "Produtos: $(@($products.data).Count)"
