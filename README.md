# Branch: windows/glazewm-yasb

Esta branch contém configurações personalizadas para Windows, focando em um ambiente de gerenciamento de janelas e customização de interface.

### O que está incluído

Este repositório contém configurações para:

#### 🪟 **GlazeWM** - Gerenciador de Janelas Tiling
- Gerenciador de janelas em mosaico para Windows
- Configuração localizada em `.glzr/glazewm/config.yaml`
- Proporciona uma experiência similar ao i3/bspwm no Windows

#### 📊 **YASB** (Yet Another Status Bar)
- Barra de status personalizável para Windows
- Arquivos de configuração em `.config/yasb/`:
  - `config.yaml` - Configuração principal da barra
  - `styles.css` - Estilos visuais customizados

#### ⚡ **PowerShell**
- Perfil customizado do PowerShell
- Arquivo: `profile powershell`
- Recursos:
  - Configuração UTF-8
  - Integração com Starship prompt
  - Fastfetch com ASCII arts aleatórias na inicialização

#### 🚀 **Starship**
- Prompt cross-shell minimalista e rápido
- Configurações em `.config/`:
  - `starship.toml`
  - `starship-config.toml`

#### 🎨 **Fastfetch**
- Ferramenta de informações do sistema (alternativa ao neofetch)
- Configuração em `.config/fastfetch/`:
  - `config.jsonc` - Configuração principal
  - `ascii-arts/` - Coleção de ASCII arts personalizadas (ascii1.txt - ascii4.txt)

### 📋 Lista Completa de Dotfiles

```
.
├── .config/
│   ├── fastfetch/
│   │   ├── ascii-arts/
│   │   │   ├── ascii1.txt
│   │   │   ├── ascii2.txt
│   │   │   ├── ascii3.txt
│   │   │   └── ascii4.txt
│   │   └── config.jsonc
│   ├── yasb/
│   │   ├── config.yaml
│   │   └── styles.css
│   ├── starship.toml
│   └── starship-config.toml
├── .glzr/
│   └── glazewm/
│       └── config.yaml
├── profile powershell
└── README.md
```

## 🔧 Como Instalar

### Pré-requisitos

Antes de instalar os dotfiles, você precisa ter os seguintes programas instalados:

1. **GlazeWM** - [Instalação](https://github.com/glzr-io/glazewm)
2. **YASB** - [Instalação](https://github.com/amnweb/yasb)
3. **Starship** - [Instalação](https://starship.rs/guide/#🚀-installation)
4. **Fastfetch** - [Instalação](https://github.com/fastfetch-cli/fastfetch)
5. **PowerShell 7+** (recomendado)

### Instalação dos Dotfiles

#### Método 1: Clone e Copie Manualmente

```powershell
# Clone o repositório
git clone -b windows/glazewm-yasb https://github.com/fabvarisco/my-dotfiles.git
cd my-dotfiles

# Copie os arquivos para os locais apropriados

# PowerShell Profile
# Descubra o caminho do seu perfil
echo $PROFILE
# Copie o conteúdo de 'profile powershell' para o arquivo indicado

# Fastfetch
Copy-Item -Recurse .config/fastfetch/* $env:USERPROFILE/.config/fastfetch/

# Starship
Copy-Item .config/starship*.toml $env:USERPROFILE/.config/

# GlazeWM
Copy-Item -Recurse .glzr/* $env:USERPROFILE/.glzr/

# YASB
Copy-Item -Recurse .config/yasb/* $env:USERPROFILE/.config/yasb/
```

#### Método 2: Usando Symlinks (Recomendado)

```powershell
# Clone o repositório
git clone -b windows/glazewm-yasb https://github.com/fabvarisco/my-dotfiles.git
cd my-dotfiles

# Crie symlinks (execute como Administrador)
# PowerShell Profile
New-Item -ItemType SymbolicLink -Path $PROFILE -Target "$PWD/profile powershell" -Force

# Fastfetch
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE/.config/fastfetch" -Target "$PWD/.config/fastfetch" -Force

# Starship
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE/.config/starship.toml" -Target "$PWD/.config/starship.toml" -Force

# GlazeWM
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE/.glzr" -Target "$PWD/.glzr" -Force

# YASB
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE/.config/yasb" -Target "$PWD/.config/yasb" -Force
```

### 🎯 Personalização

Após a instalação, você pode personalizar:

- **ASCII Arts**: Adicione seus próprios arquivos `.txt` em `.config/fastfetch/ascii-arts/`
- **Cores da Barra**: Edite `.config/yasb/styles.css`
- **Atalhos do GlazeWM**: Modifique `.glzr/glazewm/config.yaml`
- **Prompt**: Ajuste `.config/starship.toml` conforme suas preferências

### 🔄 Atualização

Para atualizar suas configurações:

```powershell
cd my-dotfiles
git pull origin windows/glazewm-yasb
```

Se você usou symlinks, as mudanças serão aplicadas automaticamente. Caso contrário, copie os arquivos novamente.

---

**Nota**: Ajuste os caminhos conforme necessário para o seu sistema.
