# Configuração Global do OpenCode + Phi-4 Mini

Este guia mostra **exatamente** como fazer o OpenCode (terminal, TUI e web) usar o phi4-mini local em qualquer pasta.

---

## Passo 1 — Garantir que o modelo está rodando

```powershell
# Verifique se está rodando
docker model ps
```

Se o modelo **não estiver** na lista, inicie:

```powershell
docker model run "huggingface.co/unsloth/phi-4-mini-instruct-gguf:Q4_K_M" --detach
```

Aguarde 30 segundos e verifique novamente:

```powershell
docker model ps
```

Deve aparecer:
```
MODEL NAME                                     BACKEND    MODE        UNTIL
huggingface.co/unsloth/phi-4-mini-instruct-gguf:Q4_K_M  llama.cpp  completion  X minutes from now
```

---

## Passo 2 — Criar/Atualizar os arquivos de configuração global

O OpenCode precisa dos arquivos em **DOIS locais diferentes** para funcionar em todos os modos (terminal, TUI, web):

### Localização 1: `%APPDATA%\opencode\` (para terminal e TUI)

```powershell
@'
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "docker-model-runner": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Docker Model Runner",
      "options": {
        "baseURL": "http://localhost:12434/engines/llama.cpp/v1",
        "apiKey": "docker-model-runner"
      },
      "models": {
        "hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M": {
          "name": "Phi-4 Mini Instruct (Local - GPU)",
          "limit": {
            "context": 16384,
            "output": 4096
          }
        }
      }
    }
  },
  "model": "docker-model-runner/hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M"
}
'@ | Set-Content -Path "$env:APPDATA\opencode\opencode.json" -Force
```

### Localização 2: `~/.config/opencode/` (para web interface) — ⚠️ OBRIGATÓRIO PARA A WEB

Esta é a localização **CRÍTICA** para o `opencode web` funcionar:

```powershell
# Criar a pasta
New-Item -ItemType Directory -Path "$env:USERPROFILE\.config\opencode\" -Force | Out-Null

# Copiar ou criar o arquivo de configuração
@'
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "docker-model-runner": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Docker Model Runner",
      "options": {
        "baseURL": "http://localhost:12434/engines/llama.cpp/v1",
        "apiKey": "docker-model-runner"
      },
      "models": {
        "hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M": {
          "name": "Phi-4 Mini Instruct (Local - GPU)",
          "limit": {
            "context": 16384,
            "output": 4096
          }
        }
      }
    }
  },
  "model": "docker-model-runner/hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M"
}
'@ | Set-Content -Path "$env:USERPROFILE\.config\opencode\opencode.json" -Force
```

Isso cria os arquivos em:
- `C:\Users\<seu-usuario>\AppData\Roaming\opencode\opencode.json` (Localização 1)
- `C:\Users\<seu-usuario>\.config\opencode\opencode.json` (Localização 2) ← **ESSENCIAL PARA WEB**

> **⚠️ CRÍTICO:** Sem o arquivo em `~/.config/opencode/`, o `opencode web` **NÃO reconhecerá** o provider `docker-model-runner` e o modelo phi4-mini não aparecerá na interface web. **Ambas as localizações são necessárias.**

---

## Passo 3 — Verificar se o arquivo foi criado corretamente

```powershell
# Listar o arquivo
Get-ChildItem "$env:APPDATA\opencode\opencode.json"

# Ver o conteúdo
Get-Content "$env:APPDATA\opencode\opencode.json" | ConvertFrom-Json | ConvertTo-Json -Depth 10
```

Deve aparecer:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "docker-model-runner": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Docker Model Runner",
      "options": {
        "baseURL": "http://localhost:12434/v1",
        "apiKey": "docker-model-runner"
      },
      ...
    }
  },
  "model": "docker-model-runner/huggingface.co/unsloth/phi-4-mini-instruct-gguf:Q4_K_M"
}
```

---

## Passo 4 — Testar a API manualmente

Isso confirma que o endpoint está correto:

```powershell
$body = @{
    model = "huggingface.co/unsloth/phi-4-mini-instruct-gguf:Q4_K_M"
    messages = @(@{ role = "user"; content = "Say hello" })
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:12434/v1/chat/completions" `
  -Method POST -Body $body -ContentType "application/json"
```

Deve retornar uma resposta com `choices`, `usage`, `model`, etc.

---

## Passo 5 — Limpar cache do OpenCode

Isso remove cache que possa estar conflitando:

```powershell
# Remover cache mantendo o config
Remove-Item -Recurse -Force "$env:APPDATA\opencode\*" -Exclude "opencode.json" -ErrorAction SilentlyContinue
```

---

## Passo 6 — Usar o OpenCode

### No Terminal (modo direto)

```powershell
cd "C:\qualquer\pasta"
opencode run "Olá, qual é sua versão?"
```

### No Terminal (modo interativo)

```powershell
cd "C:\qualquer\pasta"
opencode
```

Dentro do TUI, o phi4-mini estará disponível.

### Na Web — ⚠️ IMPORTANTE: Configuração Obrigatória

> **ATENÇÃO:** Para o `opencode web` funcionar com o modelo local, você **DEVE** copiar os arquivos de configuração para `~/.config/opencode/`. Sem isso, o modelo não aparecerá na interface web.

**Passo 1: Copiar os arquivos para `~/.config/opencode/`**

```powershell
# Criar a pasta se não existir
New-Item -ItemType Directory -Path "$env:USERPROFILE\.config\opencode\" -Force | Out-Null

# Copiar o arquivo de configuração
Copy-Item "$env:APPDATA\opencode\opencode.json" -Destination "$env:USERPROFILE\.config\opencode\opencode.json" -Force
```

**Passo 2: Executar o OpenCode Web**

```powershell
opencode web --port 3000
```

Abre `http://localhost:3000` no navegador com o phi4-mini como modelo padrão.

> **Verificação:** Após abrir a interface web, acesse **Settings → Configure** e verifique se o modelo `Phi-4 Mini Instruct (Local - GPU)` aparece na lista. Se não aparecer, repita o Passo 1 (cópia de arquivos).

---

## Checklist de Troubleshooting

Se não funcionar, verifique **nesta ordem**:

- [ ] `docker model ps` mostra o modelo rodando?
  - **Não?** → `docker model run "huggingface.co/unsloth/phi-4-mini-instruct-gguf:Q4_K_M" --detach`

- [ ] `Get-Content "$env:APPDATA\opencode\opencode.json"` mostra JSON válido?
  - **Não?** → Rode o comando do Passo 2 novamente

- [ ] A API responde? `Invoke-RestMethod -Uri "http://localhost:12434/engines/llama.cpp/v1/chat/completions" ...`
  - **Não?** → O Docker Model Runner pode não estar ativo. Reinicie o Docker Desktop.

- [ ] O OpenCode vê o modelo no terminal? `opencode models | grep -i phi4`
  - **Não?** → Rode o comando do Passo 5 (limpar cache) e tente novamente

- [ ] ❌ **ANTES DE USAR `opencode web`, certifique-se de ter feito o Passo 2 — Localização 2!**
  - Verifique se o arquivo existe: `Get-ChildItem "$env:USERPROFILE\.config\opencode\opencode.json"`
  - **Arquivo não existe?** → Rode a segunda parte do Passo 2 (criar `~/.config/opencode/`)

- [ ] `opencode web --port 3000` ainda não mostra o modelo?
  - Verifique se o arquivo em `~/.config/opencode/opencode.json` existe e tem conteúdo válido
  - Feche o navegador completamente e abra de novo
  - Tente em uma aba anônima/privada
  - Vá em **Settings → Configure** e confirme que o modelo aparece
  - Se não aparecer, copie novamente o arquivo de `%APPDATA%\opencode\` para `~/.config\opencode\`

---

## Localização dos Arquivos

| O quê | Onde |
|---|---|
| Config global | `C:\Users\<usuario>\AppData\Roaming\opencode\opencode.json` |
| Config local (D:\Docker Model Runner\phi4) | `D:\Docker Model Runner\phi4\opencode.json` |
| Cache | `C:\Users\<usuario>\AppData\Roaming\opencode\` (tudo exceto o JSON) |
| Sessions | `C:\Users\<usuario>\AppData\Roaming\opencode\sessions\` |

---

## Resumo Rápido

Se você quer **só um comando** para rodar tudo:

```powershell
# 1. Certifique-se que o modelo está rodando
docker model run "hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M" --detach

# 2. Crie o config em %APPDATA%\opencode\ (copie-cole tudo de uma vez)
@'
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "docker-model-runner": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Docker Model Runner",
      "options": {
        "baseURL": "http://localhost:12434/engines/llama.cpp/v1",
        "apiKey": "docker-model-runner"
      },
      "models": {
        "hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M": {
          "name": "Phi-4 Mini Instruct (Local - GPU)",
          "limit": {
            "context": 16384,
            "output": 4096
          }
        }
      }
    }
  },
  "model": "docker-model-runner/hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M"
}
'@ | Set-Content -Path "$env:APPDATA\opencode\opencode.json" -Force

# 3. Crie o config em ~/.config/opencode/ (ESSENCIAL PARA WEB)
New-Item -ItemType Directory -Path "$env:USERPROFILE\.config\opencode\" -Force | Out-Null

@'
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "docker-model-runner": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Docker Model Runner",
      "options": {
        "baseURL": "http://localhost:12434/engines/llama.cpp/v1",
        "apiKey": "docker-model-runner"
      },
      "models": {
        "hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M": {
          "name": "Phi-4 Mini Instruct (Local - GPU)",
          "limit": {
            "context": 16384,
            "output": 4096
          }
        }
      }
    }
  },
  "model": "docker-model-runner/hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M"
}
'@ | Set-Content -Path "$env:USERPROFILE\.config\opencode\opencode.json" -Force

# 4. Teste no terminal
opencode run "Olá!"

# 5. Abra a interface web
opencode web --port 3000
```

Pronto! O phi4-mini estará disponível globalmente em terminal, TUI e web.
