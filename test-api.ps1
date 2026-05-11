# Testa a API do Docker Model Runner com Phi-4 Mini Instruct

$MODEL    = "hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M"
$endpoint = "http://localhost:12434/engines/llama.cpp/v1/chat/completions"

$body = @{
    model    = $MODEL
    messages = @(
        @{ role = "user"; content = "Responda em uma frase: o que e Docker Model Runner?" }
    )
    max_tokens = 200
} | ConvertTo-Json -Depth 5

Write-Host "Testando API com $MODEL..." -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri $endpoint -Method POST -Body $body -ContentType "application/json"
    Write-Host "`nResposta:" -ForegroundColor Green
    Write-Host $response.choices[0].message.content
    Write-Host "`nTokens utilizados: $($response.usage.total_tokens)" -ForegroundColor Gray
} catch {
    Write-Error "Falha na chamada a API: $_"
    Write-Host "`nVerifique se o modelo esta rodando:" -ForegroundColor Yellow
    Write-Host "  docker model ps" -ForegroundColor White
    Write-Host "Para iniciar:" -ForegroundColor Yellow
    Write-Host "  docker model run '$MODEL' --detach" -ForegroundColor White
}
