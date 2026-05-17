<div align="center">

<img src="https://www.docker.com/wp-content/uploads/2022/03/vertical-logo-monochromatic.png" height="80" alt="Docker Logo" />
&nbsp;&nbsp;&nbsp;&nbsp;
<img src="https://opencode.ai/favicon.ico" height="80" alt="OpenCode Logo" />

# Docker Model Runner + Phi-4 Mini + OpenCode

## Global Configuration Guide

🌐 **Language / Idioma:**&nbsp;&nbsp;
<a href="#-english"><img src="https://img.shields.io/badge/🇺🇸_English-0052CC?style=flat-square" /></a>
&nbsp;
<a href="#-português"><img src="https://img.shields.io/badge/🇧🇷_Português-009C3B?style=flat-square" /></a>

</div>

---

## 🇺🇸 English

### Overview

This guide shows **exactly** how to make OpenCode (terminal, TUI, and web) use phi4-mini locally from **any folder on your machine**.

> **Key Point:** After this setup, you can run `opencode` from any project folder and it will automatically use the local phi4-mini model.

---

### Step 1 — Verify the Model is Running

```powershell
# Check if the model is running
docker model ps
```

If the model is **NOT** in the list, start it:

```powershell
docker model run "hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M" --detach
```

Wait 30 seconds and verify again:

```powershell
docker model ps
```

You should see:
```
MODEL NAME                                     BACKEND    MODE        UNTIL
hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M  llama.cpp  completion  X minutes from now
```

---

### Step 2 — Create/Update Global Configuration Files

OpenCode needs files in **TWO DIFFERENT LOCATIONS** to work in all modes (terminal, TUI, web):

#### Location 1: `%APPDATA%\opencode\` (for terminal and TUI)

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

#### Location 2: `~/.config/opencode/` (REQUIRED for web interface) ⚠️

**Without this location, `opencode web` will NOT work.**

```powershell
# Create the folder
New-Item -ItemType Directory -Path "$env:USERPROFILE\.config\opencode\" -Force | Out-Null

# Create or copy the configuration file
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

This creates the files in:
- `C:\Users\<your-username>\AppData\Roaming\opencode\opencode.json` (Location 1)
- `C:\Users\<your-username>\.config\opencode\opencode.json` (Location 2) ← **CRITICAL FOR WEB**

> ⚠️ **CRITICAL:** Both locations are necessary — Location 1 for terminal/TUI, Location 2 for web interface. Without Location 2, the web interface will NOT recognize the `docker-model-runner` provider.

---

### Step 3 — Verify Configuration Files Were Created Correctly

```powershell
# Check Location 1 (AppData)
Get-ChildItem "$env:APPDATA\opencode\opencode.json"

# View the content
Get-Content "$env:APPDATA\opencode\opencode.json" | ConvertFrom-Json | ConvertTo-Json -Depth 10

# Check Location 2 (.config)
Get-ChildItem "$env:USERPROFILE\.config\opencode\opencode.json"
```

Both files should exist with the same content.

---

### Step 4 — Test the API Manually

This confirms the endpoint is working correctly:

```powershell
$body = @{
    model = "hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M"
    messages = @(@{ role = "user"; content = "Say hello" })
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:12434/engines/llama.cpp/v1/chat/completions" `
  -Method POST -Body $body -ContentType "application/json"
```

Should return a response with `choices`, `usage`, `model`, etc.

---

### Step 5 — Clear OpenCode Cache

This removes cached data that might conflict:

```powershell
# Remove cache while keeping the config
Remove-Item -Recurse -Force "$env:APPDATA\opencode\*" -Exclude "opencode.json" -ErrorAction SilentlyContinue
```

---

### Step 6 — Use OpenCode

#### Terminal (direct mode)

```powershell
cd "C:\any\project"
opencode run "What is your version?"
```

#### Terminal (interactive mode)

```powershell
cd "C:\any\project"
opencode
```

The TUI will open with phi4-mini available.

#### Web Interface ⚠️ (requires Step 2 — Location 2)

```powershell
opencode web --port 3000
```

Opens `http://localhost:3000` in the browser with phi4-mini as the default model.

> **If the model doesn't appear in the web interface:**
> 1. Verify that `C:\Users\<your-username>\.config\opencode\opencode.json` exists
> 2. Go to **Settings → Configure** to check if the model appears
> 3. If not, run the copy command from Step 2 again
> 4. Restart the browser and clear cache (or use incognito window)

---

### Troubleshooting Checklist

Check in **this order** if something doesn't work:

- [ ] Does `docker model ps` show the model running?
  - **No?** → `docker model run "hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M" --detach`

- [ ] Does `Get-Content "$env:APPDATA\opencode\opencode.json"` show valid JSON?
  - **No?** → Run the command from Step 2 again

- [ ] Does the API respond? `Invoke-RestMethod -Uri "http://localhost:12434/engines/llama.cpp/v1/chat/completions" ...`
  - **No?** → Docker Model Runner may not be active. Restart Docker Desktop.

- [ ] Does OpenCode see the model? `opencode models | grep -i phi4`
  - **No?** → Run Step 5 (clear cache) and try again

- [ ] **Does `opencode web` show the model?** ⚠️
  - File exists? `Get-ChildItem "$env:USERPROFILE\.config\opencode\opencode.json"`
  - **No?** → Run Step 2 — Location 2 again
  - Open **Settings → Configure** in the web interface
  - Try in incognito/private mode
  - Clear browser cache

---

### File Locations

| What | Where |
|---|---|
| Global config (Terminal/TUI) | `C:\Users\<username>\AppData\Roaming\opencode\opencode.json` |
| Global config (Web) — ⚠️ CRITICAL | `C:\Users\<username>\.config\opencode\opencode.json` |
| Cache | `C:\Users\<username>\AppData\Roaming\opencode\` (everything except JSON) |
| Sessions | `C:\Users\<username>\AppData\Roaming\opencode\sessions\` |

---

### Quick Summary

If you want **just one command sequence** to set everything up:

```powershell
# 1. Make sure the model is running
docker model run "hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M" --detach

# 2. Create config in %APPDATA%\opencode\ (copy-paste all at once)
New-Item -ItemType Directory -Path "$env:APPDATA\opencode\" -Force | Out-Null

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

# 3. Create config in ~/.config/opencode/ (REQUIRED FOR WEB)
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

# 4. Test in terminal
opencode run "Hello!"

# 5. Open web interface
opencode web --port 3000
```

Done! phi4-mini will now be available globally in terminal, TUI, and web.

---

## 🇧🇷 Português

### Visão Geral

Este guia mostra **exatamente** como fazer o OpenCode (terminal, TUI e web) usar o phi4-mini local em **qualquer pasta do seu computador**.

> **Ponto-chave:** Depois desta configuração, você pode executar `opencode` em qualquer pasta de projeto e ele usará automaticamente o modelo phi4-mini local.

---

### Passo 1 — Garantir que o Modelo está Rodando

```powershell
# Verifique se está rodando
docker model ps
```

Se o modelo **não estiver** na lista, inicie:

```powershell
docker model run "hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M" --detach
```

Aguarde 30 segundos e verifique novamente:

```powershell
docker model ps
```

Deve aparecer:
```
MODEL NAME                                     BACKEND    MODE        UNTIL
hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M  llama.cpp  completion  X minutes from now
```

---

### Passo 2 — Criar/Atualizar os Arquivos de Configuração Global

O OpenCode precisa dos arquivos em **DOIS LOCAIS DIFERENTES** para funcionar em todos os modos (terminal, TUI, web):

#### Localização 1: `%APPDATA%\opencode\` (para terminal e TUI)

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

#### Localização 2: `~/.config/opencode/` (OBRIGATÓRIA para web) ⚠️

**Sem esta localização, `opencode web` NÃO funcionará.**

```powershell
# Criar a pasta
New-Item -ItemType Directory -Path "$env:USERPROFILE\.config\opencode\" -Force | Out-Null

# Criar ou copiar o arquivo de configuração
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
- `C:\Users\<seu-usuario>\.config\opencode\opencode.json` (Localização 2) ← **CRÍTICA PARA WEB**

> ⚠️ **CRÍTICO:** Ambas as localizações são necessárias — Localização 1 para terminal/TUI, Localização 2 para interface web. Sem a Localização 2, a interface web NÃO reconhecerá o provider `docker-model-runner`.

---

### Passo 3 — Verificar se os Arquivos foram Criados Corretamente

```powershell
# Verificar Localização 1 (AppData)
Get-ChildItem "$env:APPDATA\opencode\opencode.json"

# Ver o conteúdo
Get-Content "$env:APPDATA\opencode\opencode.json" | ConvertFrom-Json | ConvertTo-Json -Depth 10

# Verificar Localização 2 (.config)
Get-ChildItem "$env:USERPROFILE\.config\opencode\opencode.json"
```

Ambos os arquivos devem existir com o mesmo conteúdo.

---

### Passo 4 — Testar a API Manualmente

Isso confirma que o endpoint está funcionando corretamente:

```powershell
$body = @{
    model = "hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M"
    messages = @(@{ role = "user"; content = "Diga olá" })
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:12434/engines/llama.cpp/v1/chat/completions" `
  -Method POST -Body $body -ContentType "application/json"
```

Deve retornar uma resposta com `choices`, `usage`, `model`, etc.

---

### Passo 5 — Limpar Cache do OpenCode

Isso remove dados em cache que possam estar conflitando:

```powershell
# Remover cache mantendo o arquivo de config
Remove-Item -Recurse -Force "$env:APPDATA\opencode\*" -Exclude "opencode.json" -ErrorAction SilentlyContinue
```

---

### Passo 6 — Usar o OpenCode

#### Terminal (modo direto)

```powershell
cd "C:\qualquer\projeto"
opencode run "Qual é sua versão?"
```

#### Terminal (modo interativo)

```powershell
cd "C:\qualquer\projeto"
opencode
```

O TUI será aberto com phi4-mini disponível.

#### Interface Web ⚠️ (requer Passo 2 — Localização 2)

```powershell
opencode web --port 3000
```

Abre `http://localhost:3000` no navegador com phi4-mini como modelo padrão.

> **Se o modelo não aparecer na interface web:**
> 1. Verifique que `C:\Users\<seu-usuario>\.config\opencode\opencode.json` existe
> 2. Vá em **Settings → Configure** para verificar se o modelo aparece
> 3. Se não aparecer, rode novamente o comando de cópia do Passo 2
> 4. Reinicie o navegador e limpe o cache (ou abra uma janela incógnita)

---

### Checklist de Resolução de Problemas

Verifique **nesta ordem** se algo não funcionar:

- [ ] `docker model ps` mostra o modelo rodando?
  - **Não?** → `docker model run "hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M" --detach`

- [ ] `Get-Content "$env:APPDATA\opencode\opencode.json"` mostra JSON válido?
  - **Não?** → Execute novamente o comando do Passo 2

- [ ] A API responde? `Invoke-RestMethod -Uri "http://localhost:12434/engines/llama.cpp/v1/chat/completions" ...`
  - **Não?** → O Docker Model Runner pode não estar ativo. Reinicie o Docker Desktop.

- [ ] O OpenCode vê o modelo? `opencode models | grep -i phi4`
  - **Não?** → Execute o Passo 5 (limpar cache) e tente novamente

- [ ] **O `opencode web` mostra o modelo?** ⚠️
  - Arquivo existe? `Get-ChildItem "$env:USERPROFILE\.config\opencode\opencode.json"`
  - **Não?** → Execute novamente o Passo 2 — Localização 2
  - Abra **Settings → Configure** na interface web
  - Tente em modo incógnito/privado
  - Limpe o cache do navegador

---

### Localização dos Arquivos

| O quê | Onde |
|---|---|
| Config global (Terminal/TUI) | `C:\Users\<usuario>\AppData\Roaming\opencode\opencode.json` |
| Config global (Web) — ⚠️ CRÍTICA | `C:\Users\<usuario>\.config\opencode\opencode.json` |
| Cache | `C:\Users\<usuario>\AppData\Roaming\opencode\` (tudo exceto JSON) |
| Sessões | `C:\Users\<usuario>\AppData\Roaming\opencode\sessions\` |

---

### Resumo Rápido

Se você quer **só uma sequência de comandos** para configurar tudo:

```powershell
# 1. Certifique-se que o modelo está rodando
docker model run "hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M" --detach

# 2. Crie o config em %APPDATA%\opencode\ (copie-cole tudo de uma vez)
New-Item -ItemType Directory -Path "$env:APPDATA\opencode\" -Force | Out-Null

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

# 3. Crie o config em ~/.config/opencode/ (OBRIGATÓRIO PARA WEB)
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

---

