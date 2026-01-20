# Branch: windows/glazewm-yasb

This branch contains custom configurations for Windows, focusing on a window management environment and interface customization.

### What's Included

This repository contains configurations for:

#### 🪟 **GlazeWM** - Tiling Window Manager
- Tiling window manager for Windows
- Configuration located at `.glzr/glazewm/config.yaml`
- Provides an i3/bspwm-like experience on Windows

#### 📊 **YASB** (Yet Another Status Bar)
- Customizable status bar for Windows
- Configuration files in `.config/yasb/`:
  - `config.yaml` - Main bar configuration
  - `styles.css` - Custom visual styles

#### ⚡ **PowerShell**
- Custom PowerShell profile
- File: `profile powershell`
- Features:
  - UTF-8 configuration
  - Starship prompt integration
  - Fastfetch with random ASCII arts on startup

#### 🚀 **Starship**
- Minimal and fast cross-shell prompt
- Configurations in `.config/`:
  - `starship.toml`
  - `starship-config.toml`

#### 🎨 **Fastfetch**
- System information tool (neofetch alternative)
- Configuration in `.config/fastfetch/`:
  - `config.jsonc` - Main configuration
  - `ascii-arts/` - Collection of custom ASCII arts (ascii1.txt - ascii4.txt)

### 📋 Complete Dotfiles List

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

## 🔧 How to Install

### Prerequisites

Before installing the dotfiles, you need to have the following programs installed:

1. **GlazeWM** - [Installation](https://github.com/glzr-io/glazewm)
2. **YASB** - [Installation](https://github.com/amnweb/yasb)
3. **Starship** - [Installation](https://starship.rs/guide/#🚀-installation)
4. **Fastfetch** - [Installation](https://github.com/fastfetch-cli/fastfetch)
5. **PowerShell 7+** (recommended)

### Installing the Dotfiles

#### Method 1: Clone and Copy Manually

```powershell
# Clone the repository
git clone -b windows/glazewm-yasb https://github.com/fabvarisco/my-dotfiles.git
cd my-dotfiles

# Copy files to appropriate locations

# PowerShell Profile
# Find your profile path
echo $PROFILE
# Copy the content of 'profile powershell' to the indicated file

# Fastfetch
Copy-Item -Recurse .config/fastfetch/* $env:USERPROFILE/.config/fastfetch/

# Starship
Copy-Item .config/starship*.toml $env:USERPROFILE/.config/

# GlazeWM
Copy-Item -Recurse .glzr/* $env:USERPROFILE/.glzr/

# YASB
Copy-Item -Recurse .config/yasb/* $env:USERPROFILE/.config/yasb/
```

#### Method 2: Using Symlinks (Recommended)

```powershell
# Clone the repository
git clone -b windows/glazewm-yasb https://github.com/fabvarisco/my-dotfiles.git
cd my-dotfiles

# Create symlinks (run as Administrator)
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

### 🎯 Customization

After installation, you can customize:

- **ASCII Arts**: Add your own `.txt` files to `.config/fastfetch/ascii-arts/`
- **Bar Colors**: Edit `.config/yasb/styles.css`
- **GlazeWM Keybindings**: Modify `.glzr/glazewm/config.yaml`
- **Prompt**: Adjust `.config/starship.toml` to your preferences

### 🔄 Updating

To update your configurations:

```powershell
cd my-dotfiles
git pull origin windows/glazewm-yasb
```

If you used symlinks, changes will be applied automatically. Otherwise, copy the files again.

---

**Note**: Adjust paths as needed for your system.