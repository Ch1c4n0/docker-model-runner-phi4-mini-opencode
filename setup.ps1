# Setup: Docker Model Runner + Phi-4 Mini Instruct (unsloth GGUF) + OpenCode
# Requer Docker Desktop com Model Runner e GPU habilitados

$MODEL = "hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M"
#$MODEL = "docker.io/smollm2:latest"

Write-Host "=== Docker Model Runner - Phi-4 Mini Instruct Setup ===" -ForegroundColor Cyan
Write-Host "Modelo: $MODEL" -ForegroundColor Gray

# Verifica se Docker esta disponivel
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker nao encontrado. Instale o Docker Desktop primeiro."
    exit 1
}

# Verifica se Docker Model Runner esta disponivel
docker model ls 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Error "Docker Model Runner nao esta disponivel. Habilite em Docker Desktop > Settings > Features in development > Docker Model Runner"
    exit 1
}

# Para qualquer modelo em execucao
Write-Host "`n[1/3] Parando modelos em execucao..." -ForegroundColor Yellow
$running = docker model ps --format "{{.Name}}" 2>$null
if ($running) {
    $running | ForEach-Object { docker model stop $_ }
    Write-Host "Modelos parados." -ForegroundColor Gray
} else {
    Write-Host "Nenhum modelo em execucao." -ForegroundColor Gray
}

# Baixa o modelo
Write-Host "`n[2/3] Baixando $MODEL (~2.5GB)..." -ForegroundColor Yellow
docker model pull $MODEL

if ($LASTEXITCODE -ne 0) {
    Write-Error "Falha ao baixar o modelo. Verifique sua conexao e tente novamente."
    exit 1
}

# Inicia o modelo
Write-Host "`n[3/3] Iniciando modelo com GPU..." -ForegroundColor Yellow
docker model run $MODEL --detach

if ($LASTEXITCODE -ne 0) {
    Write-Error "Falha ao iniciar o modelo."
    exit 1
}

Write-Host "`n=== Configuracao concluida! ===" -ForegroundColor Green
Write-Host "Endpoint : http://localhost:12434/engines/llama.cpp/v1" -ForegroundColor White
Write-Host "Modelo   : $MODEL" -ForegroundColor White
Write-Host "VRAM     : ~2.5GB (RTX 3050 6GB)" -ForegroundColor White
Write-Host "`nAbrindo OpenCode..." -ForegroundColor Cyan
#opencode
