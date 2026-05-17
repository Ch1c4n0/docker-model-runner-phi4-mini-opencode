<div align="center">

<img src="https://www.docker.com/wp-content/uploads/2022/03/vertical-logo-monochromatic.png" height="80" alt="Docker Logo" />
&nbsp;&nbsp;&nbsp;&nbsp;
<img src="https://opencode.ai/favicon.ico" height="80" alt="OpenCode Logo" />

# Docker Model Runner + Phi-4 Mini + OpenCode

[![Docker](https://img.shields.io/badge/Docker_Model_Runner-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docs.docker.com/desktop/features/model-runner/)
[![OpenCode](https://img.shields.io/badge/OpenCode-000000?style=for-the-badge&logo=openai&logoColor=white)](https://opencode.ai)
[![HuggingFace](https://img.shields.io/badge/Phi--4_Mini_GGUF-FFD21E?style=for-the-badge&logo=huggingface&logoColor=black)](https://huggingface.co/unsloth/Phi-4-mini-instruct-GGUF)
[![NVIDIA](https://img.shields.io/badge/RTX_3050_6GB-76B900?style=for-the-badge&logo=nvidia&logoColor=white)](https://www.nvidia.com)

---

🌐 **Language / Idioma:**&nbsp;&nbsp;
<a href="#-english"><img src="https://img.shields.io/badge/🇺🇸_English-0052CC?style=flat-square" /></a>
&nbsp;
<a href="#-português"><img src="https://img.shields.io/badge/🇧🇷_Português-009C3B?style=flat-square" /></a>

</div>

---

## 🇺🇸 English

### Overview

This setup allows you to run **Phi-4 Mini Instruct** fully locally using **Docker Model Runner** (built into Docker Desktop), then connect it to **OpenCode** (terminal AI assistant) or **Continue.dev** (VSCode AI chat).

> **Hardware:** Optimized for NVIDIA RTX 3050 6GB VRAM. Phi-4 Mini uses ~2.5GB VRAM and runs GPU-accelerated.

> **📁 About the config folder:**
> The files in this repository (`opencode.json`, `setup.ps1`, etc.) are stored at `D:\Docker Model Runner\phi4\` — but **you can place this folder anywhere you want** on your machine (e.g. `C:\projects\phi4-local\` or `~/dev/phi4\`).
> The only requirement is that you run `opencode` from inside the same folder where `opencode.json` is located.

---

### Prerequisites

| Tool | Version | Link |
|---|---|---|
| Docker Desktop | 4.40+ | [download](https://www.docker.com/products/docker-desktop/) |
| OpenCode | latest | `npm install -g opencode-ai` |
| Node.js | 18+ | [download](https://nodejs.org) |
| Continue.dev (VSCode) | latest | VSCode Marketplace |

---

### Step 1 — Enable Docker Model Runner

Open **Docker Desktop** and go to:

```
Settings → Features in development → Enable Docker Model Runner ✓
Settings → Features in development → Enable GPU-backed inference ✓
```

Click **Apply & restart**.

Verify it's working:

```powershell
docker model ls
```

---

### Step 2 — Pull the Phi-4 Mini Model

```powershell
docker model pull "hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M"
```

> Download size: ~2.5 GB. Wait for completion before proceeding.

Confirm the download:

```powershell
docker model ls
```

---

### Step 3 — Start the Model

```powershell
docker model run "hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M" --detach
```

Check it's running:

```powershell
docker model ps
```

---

### Step 4 — Test the API

```powershell
.\test-api.ps1
```

Or manually:

```powershell
$body = '{"model":"hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M","messages":[{"role":"user","content":"Hello!"}]}'
Invoke-RestMethod -Uri "http://localhost:12434/engines/llama.cpp/v1/chat/completions" `
  -Method POST -Body $body -ContentType "application/json"
```

---

### Step 5A — Use with OpenCode (terminal)

Install OpenCode:

```powershell
npm install -g opencode-ai
```

The `opencode.json` in this folder is already configured. Run OpenCode from this directory:

```powershell
cd "D:\Docker Model Runner\phi4"
opencode
```

> **Important:** The `opencode.json` must use `npm` and `options.baseURL` — not `api` and `base`. Correct format:

```json
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
          "limit": { "context": 16384, "output": 4096 }
        }
      }
    }
  },
  "model": "docker-model-runner/hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M"
}
```

---

### Step 5B — Global Config for Terminal, TUI, and Web (⚠️ REQUIRED for web interface)

To use OpenCode globally (terminal, TUI, and web interface), copy the configuration to **BOTH** locations. **Without the second location, the web interface will NOT work.**

#### 1 — Copy config to AppData (for terminal and TUI)

```powershell
New-Item -ItemType Directory -Force "$env:APPDATA\opencode"
Copy-Item "D:\Docker Model Runner\phi4\opencode.json" "$env:APPDATA\opencode\opencode.json"
```

#### 2 — ⚠️ Copy config to .config (REQUIRED for web interface to work)

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.config\opencode"
Copy-Item "D:\Docker Model Runner\phi4\opencode.json" "$env:USERPROFILE\.config\opencode\opencode.json"
```

This creates the folder at `C:\Users\<your-username>\.config\opencode\opencode.json` (where `<your-username>` is your Windows username).

> ⚠️ **CRITICAL:** The web interface requires the config in `~/.config/opencode/` to recognize custom providers. **Without this file, `opencode web` will NOT show the phi4-mini model.** Both locations are necessary — one for terminal/TUI, one for web.

#### 3 — Verify both locations have the config

```powershell
# Check AppData (terminal/TUI)
Get-ChildItem "$env:APPDATA\opencode\opencode.json"

# Check .config (web interface) — THIS IS CRITICAL
Get-ChildItem "$env:USERPROFILE\.config\opencode\opencode.json"

# View your username
whoami
```

Both files should exist with the same content. The `.config` folder will be in your user's home directory (e.g., `C:\Users\<your-username>\.config\opencode\`).

#### 4 — Test all three interfaces

```powershell
# Terminal mode
opencode run "Hello"

# Interactive TUI
opencode

# Web interface (must have Step 5B.2 completed)
opencode web --port 3000
```

All three should now recognize the **Phi-4 Mini Instruct (Local - GPU)** model.

> **If `opencode web` doesn't show the model:**
> 1. Verify that `C:\Users\<your-username>\.config\opencode\opencode.json` exists
> 2. Open the web interface and go to **Settings → Configure**
> 3. If the model still doesn't appear, run the copy command from Step 5B.2 again
> 4. Restart the browser and clear cache (or open an incognito window)

---

### Step 5C — OpenCode Commands Reference

#### Starting OpenCode

```powershell
opencode                              # start TUI in current folder
opencode "C:\my-project"             # start in a specific folder
opencode -m docker-model-runner/hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M  # force a specific model
opencode -c                          # continue the last session
opencode -s <sessionID>              # continue a specific session
opencode --fork -c                   # fork the last session (keeps original intact)
opencode web                         # open web interface in browser
```

#### Running without opening the TUI

```powershell
# Ask a question and get the answer directly in the terminal
opencode run "explain what this project does"
opencode run "list all TypeScript files that export a default function"
opencode run "fix the lint errors in src/index.ts"

# Continue last session non-interactively
opencode run -c "now add unit tests for the changes you made"
```

#### Inside the TUI — Keyboard Shortcuts

| Key | Action |
|---|---|
| `Tab` | Switch between **Build** (edits files) and **Plan** (read-only analysis) agents |
| `@` | Fuzzy-search and attach a file from the project to the prompt |
| `Ctrl+C` | Cancel current operation |
| `Ctrl+D` | Exit OpenCode |

#### Inside the TUI — Slash Commands

| Command | Description | Example |
|---|---|---|
| `/init` | Analyse the project and create a `AGENTS.md` summary | `/init` |
| `/undo` | Revert the last change made by the agent | `/undo` |
| `/redo` | Restore a change that was undone | `/redo` |
| `/share` | Generate a shareable link for the current conversation | `/share` |
| `/connect` | Configure API keys for providers | `/connect` |

#### Inside the TUI — @ References

```
@filename.ts        attach a specific file to the prompt
@general            invoke the general subagent for complex multi-step tasks
```

**Examples:**
```
Read @src/app.ts and explain what the main function does
Refactor @utils/helpers.ts to use async/await instead of callbacks
Compare @old-config.json and @new-config.json and show the differences
```

#### Managing Models

```powershell
opencode models                         # list all available models
opencode models docker-model-runner     # list models for a specific provider
opencode models --verbose               # show models with cost and metadata
opencode models --refresh               # refresh model list from remote
```

#### Managing Sessions

```powershell
opencode session list                   # list all past sessions
opencode session delete <sessionID>     # delete a specific session
opencode export                         # export last session as JSON
opencode export <sessionID>             # export a specific session
opencode import session.json            # import a session from file
opencode stats                          # show token usage and cost statistics
```

#### Managing MCP Servers

```powershell
opencode mcp list                       # list MCP servers and their status
opencode mcp add                        # add a new MCP server interactively
opencode mcp debug filesystem           # debug the filesystem MCP connection
```

#### Other Useful Commands

```powershell
opencode upgrade                        # upgrade to the latest version
opencode pr 42                          # checkout GitHub PR #42 and start OpenCode on it
opencode providers                      # manage provider credentials
opencode plugin <npm-package>           # install an OpenCode plugin
opencode stats                          # token usage and cost report
```

#### Real Usage Examples

```
# Understand a codebase
"Explain the architecture of this project. What are the main modules?"

# Work with specific files (using @)
"Look at @src/api/routes.ts and add input validation to all POST endpoints"

# Debugging
"The function processBatch in @workers/batch.ts is throwing a TypeError. Find and fix it"

# Refactoring
"Refactor @components/Dashboard.tsx to use React hooks instead of class components"

# Writing tests
"Write unit tests for all exported functions in @lib/parser.ts using Jest"

# Documentation
"Generate JSDoc comments for all public functions in @src/utils.ts"

# Cross-file tasks (use @general for complex searches)
"@general Find all places in the codebase where we call the deprecated sendEmail() function and replace them with sendEmailV2()"
```

> **Note about phi4-mini and file access:** phi4-mini has limited tool-calling capability. For file operations, prefer using `@filename` to attach files directly to your prompt rather than asking the model to "read" files on its own.

---

### Step 5D — Use with Continue.dev (VSCode Chat)

**Install the extension:**
```
Ctrl+Shift+X → search "Continue" → Install
```

**Edit config** at `C:\Users\<you>\.continue\config.yaml`:

```yaml
models:
  - name: Phi-4 Mini (Local)
    provider: openai
    model: hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M
    apiBase: http://localhost:12434/engines/llama.cpp/v1
    apiKey: docker-model-runner

tabAutocompleteModel:
  name: Phi-4 Mini Autocomplete
  provider: openai
  model: hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M
  apiBase: http://localhost:12434/engines/llama.cpp/v1
  apiKey: docker-model-runner
```

Open VSCode chat: `Ctrl+L`

---

### Verify GPU Usage

Run this in a second terminal while asking something in OpenCode or Continue:

```powershell
while ($true) { Clear-Host; nvidia-smi; Start-Sleep 2 }
```

Expected when model is active:

| Metric | Idle | Running |
|---|---|---|
| GPU-Util | ~0% | 80–100% |
| Memory-Usage | ~1 GB | ~3–4 GB |
| Power | ~7W | 40–70W |

---

### Useful Commands

```powershell
docker model ls                                                          # list downloaded models
docker model ps                                                          # list running models
docker model stop "hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M"      # stop the model
docker model run  "hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M" --detach  # start the model
docker model rm   "hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M"      # remove (free ~2.5 GB)
```

---

### Troubleshooting

| Error | Fix |
|---|---|
| `docker model` not recognized | Enable Docker Model Runner in Docker Desktop settings and restart |
| Port 12434 not responding | Run `docker model run ... --detach` |
| OpenCode `ConfigInvalidError` | Use `npm` + `options.baseURL` in `opencode.json`, not `api` + `base` |
| Model `ai/phi4-mini` not found | Correct name is `hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M` |
| Very slow responses | GPU inference may not be active — check Docker Desktop GPU settings |
| **`opencode web` doesn't show the model** | ⚠️ **The file must be in `~/.config/opencode/`**. Run this: `Copy-Item "$env:APPDATA\opencode\opencode.json" "$env:USERPROFILE\.config\opencode\opencode.json"` |
| Model visible in terminal but not in web | Copy config to `~/.config/opencode/`, clear browser cache, restart browser |
| Web interface shows error/blank | Open incognito/private window and check **Settings → Configure** for the model |

---
---

## 🇧🇷 Português

### Visão Geral

Esta configuração permite rodar o **Phi-4 Mini Instruct** completamente local usando o **Docker Model Runner** (integrado ao Docker Desktop), e conectá-lo ao **OpenCode** (assistente de IA no terminal) ou ao **Continue.dev** (chat de IA no VSCode).

> **Hardware:** Otimizado para NVIDIA RTX 3050 6GB de VRAM. O Phi-4 Mini usa ~2.5GB de VRAM e roda com aceleração GPU.

> **📁 Sobre a pasta de configuração:**
> Os arquivos deste repositório (`opencode.json`, `setup.ps1`, etc.) estão em `D:\Docker Model Runner\phi4\` — mas **você pode colocar esta pasta em qualquer lugar** da sua máquina (ex: `C:\projetos\phi4-local\` ou `D:\meus-configs\phi4\`).
> O único requisito é executar o `opencode` de dentro da mesma pasta onde está o `opencode.json`.

---

### Pré-requisitos

| Ferramenta | Versão | Link |
|---|---|---|
| Docker Desktop | 4.40+ | [download](https://www.docker.com/products/docker-desktop/) |
| OpenCode | latest | `npm install -g opencode-ai` |
| Node.js | 18+ | [download](https://nodejs.org) |
| Continue.dev (VSCode) | latest | VSCode Marketplace |

---

### Passo 1 — Habilitar o Docker Model Runner

Abra o **Docker Desktop** e vá em:

```
Settings → Features in development → Enable Docker Model Runner ✓
Settings → Features in development → Enable GPU-backed inference ✓
```

Clique em **Apply & restart**.

Verifique se está funcionando:

```powershell
docker model ls
```

---

### Passo 2 — Baixar o modelo Phi-4 Mini

```powershell
docker model pull "hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M"
```

> Tamanho do download: ~2.5 GB. Aguarde a conclusão antes de continuar.

Confirme o download:

```powershell
docker model ls
```

---

### Passo 3 — Iniciar o modelo

```powershell
docker model run "hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M" --detach
```

Verifique se está rodando:

```powershell
docker model ps
```

---

### Passo 4 — Testar a API

```powershell
.\test-api.ps1
```

Ou manualmente:

```powershell
$body = '{"model":"hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M","messages":[{"role":"user","content":"Ola!"}]}'
Invoke-RestMethod -Uri "http://localhost:12434/engines/llama.cpp/v1/chat/completions" `
  -Method POST -Body $body -ContentType "application/json"
```

---

### Passo 5A — Usar com OpenCode (terminal)

Instalar o OpenCode:

```powershell
npm install -g opencode-ai
```

O arquivo `opencode.json` desta pasta já está configurado. Execute o OpenCode dentro desta pasta:

```powershell
cd "D:\Docker Model Runner\phi4"
opencode
```

> **Importante:** O `opencode.json` deve usar `npm` e `options.baseURL` — e não `api` e `base`. Formato correto:

```json
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
          "limit": { "context": 16384, "output": 4096 }
        }
      }
    }
  },
  "model": "docker-model-runner/hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M"
}
```

---

### Passo 5B — Config Global + Web Interface + Acesso a Arquivos do Computador (MCP)

Por padrão, o OpenCode só enxerga os arquivos da pasta onde foi iniciado. Para torná-lo **global** (usável em qualquer pasta), habilitar a **interface web**, e dar acesso aos **arquivos do seu computador**, faça as seguintes etapas:

#### 1 — Copiar o config para o local global (terminal e TUI)

```powershell
New-Item -ItemType Directory -Force "$env:APPDATA\opencode"
Copy-Item "D:\Docker Model Runner\phi4\opencode.json" "$env:APPDATA\opencode\opencode.json"
```

Após isso, você pode rodar `opencode` de **qualquer pasta de projeto** — ele sempre usará o modelo phi4-mini.

#### 2 — ⚠️ Copiar config para `~/.config/opencode/` (OBRIGATÓRIO para web)

**Sem este passo, `opencode web` NÃO funcionará.**

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.config\opencode"
Copy-Item "D:\Docker Model Runner\phi4\opencode.json" "$env:USERPROFILE\.config\opencode\opencode.json"
```

#### 3 — Adicionar o servidor MCP de Filesystem

O servidor **MCP Filesystem** dá ao OpenCode acesso de leitura e escrita a caminhos específicos do seu computador. Edite `%APPDATA%\opencode\opencode.json` e adicione o bloco `mcp`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": { ... },
  "model": "docker-model-runner/hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M",
  "mcp": {
    "filesystem": {
      "type": "local",
      "command": [
        "npx",
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "C:\\Users\\SeuUsuario",
        "D:\\"
      ]
    }
  }
}
```

**O que cada linha do `command` significa:**

| Linha | Significado |
|---|---|
| `"npx"` | Executa o pacote sem precisar instalar globalmente |
| `"-y"` | Confirma automaticamente o download na primeira execução (sem prompt) |
| `"@modelcontextprotocol/server-filesystem"` | O servidor MCP que expõe o sistema de arquivos ao OpenCode |
| `"C:\\Users\\SeuUsuario"` | Primeira raiz permitida — OpenCode pode ler/escrever tudo dentro deste caminho |
| `"D:\\"` | Segunda raiz permitida — drive D: inteiro acessível |

> Adicione quantos caminhos precisar. Cada entrada após o nome do pacote vira uma raiz permitida.
> Para permitir o drive C: inteiro, adicione `"C:\\"`. Para restringir a um projeto, use `"C:\\projetos\\meuapp"`.

O pacote é baixado automaticamente pelo `npx` na primeira execução — sem instalação manual necessária.

#### 4 — Testar todas as três interfaces

```powershell
# Terminal direto
opencode run "Olá, qual é sua versão?"

# TUI interativo
cd "C:\seu-projeto"
opencode

# Interface web (requer Passo 5B.2)
opencode web --port 3000
```

Todas as três devem reconhecer o modelo **Phi-4 Mini Instruct (Local - GPU)**.

> **Se `opencode web` não mostra o modelo:**
> 1. Verifique que `C:\Users\<seu-usuario>\.config\opencode\opencode.json` existe
> 2. Abra a interface web e vá em **Settings → Configure**
> 3. Se o modelo ainda não aparecer, rode novamente o comando de cópia do Passo 5B.2
> 4. Reinicie o navegador e limpe o cache (ou abra uma janela incógnita)

---

### Passo 5C — Referência de Comandos do OpenCode

#### Iniciando o OpenCode

```powershell
opencode                              # abre o TUI na pasta atual
opencode "C:\meu-projeto"            # abre em uma pasta específica
opencode -m docker-model-runner/hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M  # força um modelo específico
opencode -c                          # continua a última sessão
opencode -s <sessionID>              # continua uma sessão específica
opencode --fork -c                   # cria um fork da última sessão (mantém o original)
opencode web                         # abre a interface web no navegador
```

#### Rodar sem abrir o TUI

```powershell
# Faz uma pergunta e recebe a resposta direto no terminal
opencode run "explique o que este projeto faz"
opencode run "liste todos os arquivos TypeScript que exportam uma função default"
opencode run "corrija os erros de lint em src/index.ts"

# Continua a última sessão de forma não-interativa
opencode run -c "agora adicione testes unitários para as mudanças que você fez"
```

#### Dentro do TUI — Atalhos de Teclado

| Tecla | Ação |
|---|---|
| `Tab` | Alterna entre o agente **Build** (edita arquivos) e **Plan** (somente análise) |
| `@` | Busca e anexa um arquivo do projeto ao prompt |
| `Ctrl+C` | Cancela a operação atual |
| `Ctrl+D` | Sai do OpenCode |

#### Dentro do TUI — Comandos de Barra

| Comando | Descrição | Exemplo |
|---|---|---|
| `/init` | Analisa o projeto e cria um resumo `AGENTS.md` | `/init` |
| `/undo` | Reverte a última alteração feita pelo agente | `/undo` |
| `/redo` | Restaura uma alteração desfeita | `/redo` |
| `/share` | Gera um link compartilhável da conversa atual | `/share` |
| `/connect` | Configura chaves de API para provedores | `/connect` |

#### Dentro do TUI — Referências com @

```
@nomedoarquivo.ts   anexa um arquivo específico ao prompt
@general            invoca o subagente geral para tarefas complexas em múltiplos passos
```

**Exemplos:**
```
Leia @src/app.ts e explique o que a função principal faz
Refatore @utils/helpers.ts para usar async/await em vez de callbacks
Compare @config-antigo.json e @config-novo.json e mostre as diferenças
```

#### Gerenciar Modelos

```powershell
opencode models                         # listar todos os modelos disponíveis
opencode models docker-model-runner     # listar modelos de um provider específico
opencode models --verbose               # mostrar modelos com custo e metadados
opencode models --refresh               # atualizar lista de modelos do servidor
```

#### Gerenciar Sessões

```powershell
opencode session list                   # listar todas as sessões anteriores
opencode session delete <sessionID>     # deletar uma sessão específica
opencode export                         # exportar última sessão como JSON
opencode export <sessionID>             # exportar uma sessão específica
opencode import sessao.json             # importar uma sessão de um arquivo
opencode stats                          # ver estatísticas de tokens e custo
```

#### Gerenciar Servidores MCP

```powershell
opencode mcp list                       # listar servidores MCP e seu status
opencode mcp add                        # adicionar um novo servidor MCP
opencode mcp debug filesystem           # depurar a conexão MCP do filesystem
```

#### Outros Comandos Úteis

```powershell
opencode upgrade                        # atualizar para a versão mais recente
opencode pr 42                          # fazer checkout do PR #42 do GitHub e abrir o OpenCode
opencode providers                      # gerenciar credenciais de provedores
opencode plugin <pacote-npm>            # instalar um plugin do OpenCode
opencode stats                          # relatório de uso de tokens e custo
```

#### Exemplos Reais de Uso

```
# Entender um projeto
"Explique a arquitetura deste projeto. Quais são os módulos principais?"

# Trabalhar com arquivos específicos (usando @)
"Olhe em @src/api/routes.ts e adicione validação de entrada em todos os endpoints POST"

# Depurar erros
"A função processBatch em @workers/batch.ts está lançando um TypeError. Encontre e corrija"

# Refatoração
"Refatore @components/Dashboard.tsx para usar React Hooks em vez de class components"

# Escrever testes
"Escreva testes unitários para todas as funções exportadas em @lib/parser.ts usando Jest"

# Documentação
"Gere comentários JSDoc para todas as funções públicas em @src/utils.ts"

# Tarefas entre múltiplos arquivos (use @general para buscas complexas)
"@general Encontre todos os lugares no projeto onde chamamos a função sendEmail() depreciada e substitua por sendEmailV2()"
```

> **Nota sobre o phi4-mini e acesso a arquivos:** O phi4-mini tem capacidade limitada de uso de ferramentas. Para operações com arquivos, prefira usar `@nomedoarquivo` para anexar os arquivos diretamente ao prompt em vez de pedir ao modelo para "ler" arquivos por conta própria.

---

### Passo 5D — Usar com Continue.dev (chat no VSCode)

**Instalar a extensão:**
```
Ctrl+Shift+X → buscar "Continue" → Instalar
```

**Editar o config** em `C:\Users\<usuario>\.continue\config.yaml`:

```yaml
models:
  - name: Phi-4 Mini (Local)
    provider: openai
    model: hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M
    apiBase: http://localhost:12434/engines/llama.cpp/v1
    apiKey: docker-model-runner

tabAutocompleteModel:
  name: Phi-4 Mini Autocomplete
  provider: openai
  model: hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M
  apiBase: http://localhost:12434/engines/llama.cpp/v1
  apiKey: docker-model-runner
```

Abrir o chat no VSCode: `Ctrl+L`

---

### Verificar uso da GPU

Execute em um segundo terminal enquanto usa o OpenCode ou Continue:

```powershell
while ($true) { Clear-Host; nvidia-smi; Start-Sleep 2 }
```

O que esperar com o modelo ativo:

| Metrica | Idle | Rodando |
|---|---|---|
| GPU-Util | ~0% | 80–100% |
| Memory-Usage | ~1 GB | ~3–4 GB |
| Consumo | ~7W | 40–70W |

---

### Comandos Uteis

```powershell
docker model ls                                                          # listar modelos baixados
docker model ps                                                          # listar modelos em execucao
docker model stop "hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M"      # parar o modelo
docker model run  "hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M" --detach  # iniciar o modelo
docker model rm   "hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M"      # remover (libera ~2.5 GB)
```

---

### Solucao de Problemas

| Erro | Solucao |
|---|---|
| `docker model` nao reconhecido | Habilite o Docker Model Runner nas configuracoes do Docker Desktop e reinicie |
| Porta 12434 nao responde | Execute `docker model run ... --detach` |
| OpenCode `ConfigInvalidError` | Use `npm` + `options.baseURL` no `opencode.json`, nao `api` + `base` |
| Modelo `ai/phi4-mini` nao encontrado | O nome correto e `hf.co/unsloth/Phi-4-mini-instruct-GGUF:Q4_K_M` |
| Respostas muito lentas | A GPU pode nao estar ativa — verifique as configuracoes de GPU no Docker Desktop |
| **`opencode web` nao mostra o modelo** | ⚠️ **Crie o arquivo em `~/.config/opencode/`**. Execute: `Copy-Item "$env:APPDATA\opencode\opencode.json" "$env:USERPROFILE\.config\opencode\opencode.json"` |
| Modelo visivel no terminal mas nao na web | Copie o config para `~/.config/opencode/`, limpe o cache do navegador, reinicie |
| Interface web branca/erro | Abra uma janela incógnita e verifique **Settings → Configure** para ver o modelo |

---

<div align="center">

Made with ❤️ for local AI development

</div>
