# GizmoTickler's Dotfiles

My personal dotfiles managed with [Chezmoi](https://www.chezmoi.io/), featuring Fish shell, Starship prompt, and productivity tools.

## ✨ Features

- **Fish Shell** - Modern shell with better defaults, auto-suggestions, and syntax highlighting
- **Starship Prompt** - Fast, customizable prompt with Git and Kubernetes context
- **Chezmoi** - Secure, cross-platform dotfiles management with templating
- **1Password CLI Integration** - Complete secret management for environment variables, Git config, and SSH keys
- **Kubernetes Tools** - kubectl, k9s, helm, talos, and more with context switching
- **Modern CLI Tools** - bat, eza, fd, ripgrep, fzf, zoxide
- **Development Tools** - Neovim with LSP support, atuin, git tooling
- **Security First** - 1Password SSH agent integration, automatic key management, secure credential storage

## 📋 Prerequisites

Before applying these dotfiles, you need to set up 1Password CLI integration, as all secrets and personal information are managed through 1Password.

### Required: 1Password Account & Desktop App

1. **1Password Account**: You need an active 1Password subscription:
   - Individual ($3/month) or Family ($5/month) plan minimum
   - Sign up at [1password.com](https://1password.com) if you don't have an account

2. **Install 1Password Desktop App**:
   ```bash
   # Install via Homebrew (recommended)
   brew install --cask 1password
   
   # Or download from Mac App Store / 1Password website
   ```

3. **Sign in to 1Password Desktop App**:
   - Open 1Password app
   - Sign in with your account credentials
   - Enable Touch ID/Face ID for convenience
   - **Important**: Keep the desktop app running (it manages CLI authentication)

### Required: 1Password CLI Setup

4. **Install 1Password CLI**:
   ```bash
   brew install 1password-cli
   ```

5. **Enable 1Password CLI integration**:
   - Open 1Password app → Settings → Developer
   - Enable "Connect with 1Password CLI"
   - This allows CLI to authenticate through the desktop app (no separate signin needed)

6. **Verify CLI integration**:
   ```bash
   op whoami
   # Should show your account info without requiring signin
   ```

### Required: Create Vault Items

7. **Create required vault items** in your 1Password:

   **Item: "Git Config"** (in Private vault)
   - Field: `name` → Your full name (e.g., "John Doe")
   - Field: `email` → Your Git email address

   **Item: "Atuin Config"** (in Private vault) 
   - Field: `sync_address` → Your Atuin server URL

   **Item: "Google Cloud Config"** (in Private vault)
   - Field: `project_id` → Your default GCP project ID (e.g., "my-project-123")

   **SSH Signing Key** (in Infrastructure vault)
   - Your SSH key should already exist as "Github" with category "SSH Key"
   - Must have a `public key` field for Git commit signing

8. **Verify 1Password integration works**:
   ```bash
   op read "op://Private/Git Config/name"
   op read "op://Private/Git Config/email"
   op read "op://Private/Atuin Config/sync_address"
   op read "op://Private/Google Cloud Config/project_id"
   op read "op://Infrastructure/Github/public key"
   ```

   All commands should return your actual values without errors.

### Required: SSH Agent Setup (Optional but Recommended)

9. **Enable 1Password SSH Agent**:
   - Open 1Password app → Settings → SSH Agent
   - Enable "Use the SSH agent"
   - Enable "Display key names when authorizing connections"
   - This manages all your SSH keys securely through 1Password

10. **Add your SSH key to 1Password** (if not already done):
    - Import your existing SSH key or generate a new one in 1Password
    - The key will be available in the Infrastructure vault
    - Used for Git commit signing and SSH authentication

### Optional: GitHub SSH Signing

To enable verified commits on GitHub:
1. Go to GitHub.com → Settings → SSH and GPG keys
2. Add your SSH public key to **both** sections:
   - "SSH keys" (for authentication) 
   - "SSH signing keys" (for commit verification)

### Optional: Google Cloud Platform Setup

After applying dotfiles, set up Google Cloud:

1. **Update your project ID** in 1Password:
   ```bash
   op item edit "Google Cloud Config" project_id="your-actual-project-id"
   ```

2. **Run the setup function**:
   ```bash
   gcloud_setup
   ```

This will:
- Initialize Google Cloud CLI
- Set your default project from 1Password
- Enable common APIs
- Set up application default credentials
- Install useful gcloud components

3. **Create service account for CLI usage** (avoids repeated signin):
   ```bash
   gcloud_create_service_account cli-automation "Service account for CLI operations" --default
   ```
   
   This creates a service account and stores its key in 1Password. The `--default` flag makes it your default credential, so you won't need to sign in interactively.

4. **Create API keys** (for applications):
   ```bash
   gcloud_create_api_key my-app-key "API key for my application"
   ```

**Benefits of Service Accounts:**
- ✅ **No interactive signin** required
- ✅ **Credentials stored securely** in 1Password  
- ✅ **Automatic credential management** via dotfiles
- ✅ **Works in CI/CD environments**
- ✅ **Granular permission control**

⚠️  **Without completing the 1Password setup above, `chezmoi apply` will fail!**

---

## 🚀 Quick Start

### New Machine Setup

```bash
# One-liner installation
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply GizmoTickler/dotfiles
```

### Manual Installation

```bash
# Install Chezmoi
brew install chezmoi

# Initialize with this repository
chezmoi init https://github.com/GizmoTickler/dotfiles.git

# Preview changes
chezmoi diff

# Apply dotfiles
chezmoi apply

# Install tools with Homebrew
brew bundle --file ~/.config/brew/Brewfile
```

### Set Fish as Default Shell

```bash
# Add Fish to shells
echo $(brew --prefix)/bin/fish | sudo tee -a /etc/shells

# Change default shell
chsh -s $(brew --prefix)/bin/fish

# Restart terminal
exec fish
```

## 📁 Repository Structure

```
dotfiles/
├── home/                          # Chezmoi source directory
│   ├── .chezmoi.yaml.tmpl        # Chezmoi configuration
│   ├── dot_config/               
│   │   ├── fish/
│   │   │   ├── config.fish       # Main Fish config
│   │   │   ├── conf.d/           # Modular configurations
│   │   │   └── functions/        # Custom Fish functions
│   │   ├── starship.toml         # Prompt configuration
│   │   └── brew/
│   │       └── Brewfile          # Homebrew packages
│   ├── dot_gitconfig.tmpl        # Git configuration
│   ├── dot_gitignore_global      # Global Git ignore
│   └── private_dot_ssh/          # SSH configuration
└── README.md                     # This file
```

## 🛠 Customization

### Personal Configuration

Edit the Chezmoi data in `~/.config/chezmoi/chezmoi.yaml`:

```yaml
data:
  name: "Your Name"
  email: "your.email@example.com"
  git:
    signingkey: "your-ssh-key"
```

### Adding New Configurations

```bash
# Add a new dotfile to Chezmoi
chezmoi add ~/.newconfig

# Edit with templates
chezmoi edit ~/.newconfig

# Apply changes
chezmoi apply
```

### Machine-Specific Settings

Use Chezmoi templates for different environments:

```bash
{{- if eq .machine.type "work" }}
# Work-specific configuration
{{- else }}
# Personal configuration
{{- end }}
```

## 📦 Included Tools

### Shell & Prompt
- Fish Shell - Modern shell with better defaults
- Starship - Cross-shell prompt with Git/Kubernetes info

### Modern CLI Replacements  
- `bat` → Better `cat` with syntax highlighting
- `eza` → Better `ls` with icons and Git status
- `fd` → Better `find` with intuitive syntax
- `ripgrep` → Better `grep` with speed and features
- `fzf` → Fuzzy finder for files and history
- `zoxide` → Better `cd` with intelligent ranking

### Development Tools
- **Neovim** - Modern Vim with comprehensive LSP support, autocompletion, and plugin ecosystem
  - Language servers for Python, JavaScript/TypeScript, Go, Rust, Lua, and more
  - Integrated formatters and linters (Black, Prettier, Stylua, etc.)
  - Telescope fuzzy finder for files, symbols, and project navigation
  - Git integration with Gitsigns
- **Atuin** - Encrypted shell history sync across machines
- **Git** - Complete setup with LFS and SSH signing support
- **Programming Languages** - Managed entirely via Homebrew (Node.js, Python, Go, Rust)
  - No version managers needed - consistent system-wide versions
  - Global development directories and environment variables preconfigured

### Kubernetes Ecosystem
- kubectl with completions
- k9s - Kubernetes TUI dashboard
- Helm - Package manager for Kubernetes
- Talosctl - Talos Linux management
- Kustomize - Kubernetes YAML templating

### Productivity
- 1Password CLI integration
- Custom Fish abbreviations (shortcuts)
- Useful functions (mkcd, extract, gcommit)
- Git aliases and helpers

## 🔧 Daily Usage

### Common Abbreviations
- `g` → `git`
- `k` → `kubectl`  
- `ll` → `eza -l --icons --git`
- `cm` → `chezmoi`
- `cat` → `bat` (if installed)
- `v` → `nvim` (Neovim)
- `vim` → `nvim` (Neovim)
- `py` → `python3` (Python)
- `ni` → `npm install` (Node.js)
- `gob` → `go build` (Go)
- `opstatus` → `op_status` (1Password status)
- `opg` → `op_get` (Get 1Password item)
- `opc` → `op_copy` (Copy 1Password item)
- `opload` → `op_load_secrets` (Load common secrets)

### Useful Functions
- `mkcd <dir>` - Create directory and cd into it
- `extract <file>` - Extract any archive format
- `gcommit "message"` - Quick commit with optional push
- `kctx` - Switch Kubernetes context
- `kns` - Switch Kubernetes namespace

### Kubernetes Shortcuts
- `kgp` → `kubectl get pods`
- `kgs` → `kubectl get svc`
- `kgn` → `kubectl get nodes`

### Neovim Key Bindings
- `<Space>` - Leader key for all custom commands
- `<Space>ff` - Find files with Telescope
- `<Space>fg` - Live grep search
- `<Space>fb` - Find open buffers
- `<Space>e` - Toggle file explorer
- `gd` - Go to definition
- `gr` - Find references
- `K` - Show hover information
- `<Space>ca` - Code actions
- `<Space>rn` - Rename symbol
- `<Space>f` - Format buffer

### Google Cloud Shortcuts
- `gc` → `gcloud` (Google Cloud CLI)
- `gcl` → `gcloud_project_list` (List projects)
- `gcs <id>` → `gcloud_switch <project_id>` (Switch project)
- `gcst` → `gcloud_status` (Show current config)
- `gce` → `gcloud compute instances` (Compute instances)
- `gck` → `gcloud container clusters` (GKE clusters)
- `gcr` → `gcloud container images` (Container registry)

## 🔄 Syncing Changes

```bash
# Make changes and review
chezmoi status
chezmoi diff

# Apply changes
chezmoi apply

# Update from remote
chezmoi update

# Edit configuration
chezmoi edit ~/.config/fish/config.fish

# Go to Chezmoi source directory
chezmoi cd
```

## 🔐 1Password Integration

### Complete Secret Management
This dotfiles setup includes comprehensive 1Password CLI integration for:

**Environment Variables & API Keys**
```bash
# Automatically loaded from 1Password
export GITHUB_TOKEN=$(op item get "GitHub Personal Access Token" --field password)
export OPENAI_API_KEY=$(op item get "OpenAI API Key" --field password)
```

**Git Configuration** 
```bash
# Git credentials from 1Password
name = {{ onepasswordRead "op://Personal/Git Config/username" }}
email = {{ onepasswordRead "op://Personal/Git Config/email" }}
```

**SSH Key Management**
- 1Password SSH agent handles all connections automatically
- SSH config uses simple `Include ~/.ssh/1Password/config`
- All SSH keys stored and managed in 1Password vault
- Zero manual SSH key management required

### Setup 1Password CLI
```bash
# Install 1Password CLI
brew install 1password-cli

# Sign in to your account  
op signin

# Initialize common development secrets
op_init_dev
```

### Available 1Password Functions
- `op_status` - Check signin status
- `op_get <item> [field]` - Get item field value
- `op_copy <item> [field]` - Copy to clipboard  
- `op_search <query>` - Search items
- `op_create` - Create new item interactively
- `op_init_dev` - Setup common dev secrets
- `op_load_secrets` - Load common env vars into Fish session

### Security Features
- SSH keys managed via 1Password SSH agent
- Environment variables loaded from secure vault
- Private configurations use `private_` prefix
- Sensitive data uses Chezmoi templates
- Git commit signing with SSH keys

## 🆘 Troubleshooting

### 1Password Integration Issues

**"Connect with 1Password CLI" not working:**
- Ensure 1Password desktop app is running
- Check 1Password app → Settings → Developer → "Connect with 1Password CLI" is enabled
- Restart terminal after enabling CLI integration

**"account is not signed in" error:**
- Modern setup: CLI should authenticate through desktop app (no manual signin needed)
- Legacy method: `op signin --account my.1password.com`
- Verify with: `op whoami`

**"isn't an item" errors:**
- Verify vault names: `op vault list`
- Check item exists: `op item list --vault Private | grep "Git Config"`
- Create missing items as described in Prerequisites section
- Ensure vault permissions allow CLI access

**"field not found" errors:**
- Check field names are exact: `op item get "Git Config" --vault Private`
- Field names are case-sensitive
- Use the exact field names from the Prerequisites section

**Template errors during `chezmoi apply`:**
- Test 1Password reads manually first: `op read "op://Private/Git Config/name"`
- Ensure all required vault items exist before applying
- Verify 1Password CLI integration is working: `op whoami`
- Check vault permissions and item field names

### Fish Shell Issues
```bash
# Reload Fish configuration
exec fish

# Check Fish status
fish_config doctor
```

### Chezmoi Issues
```bash
# Re-initialize Chezmoi
chezmoi init --force

# Verify configuration
chezmoi data

# Check for conflicts
chezmoi status -v
```

### Tool Installation
```bash
# Reinstall all Homebrew packages
brew bundle --file ~/.config/brew/Brewfile

# Update all tools
brew update && brew upgrade
```

## 🤝 Contributing

Feel free to fork and adapt these dotfiles for your own use. If you have suggestions or improvements, please open an issue or pull request.

## 📚 Resources

- [Chezmoi Documentation](https://www.chezmoi.io/)
- [Fish Shell Documentation](https://fishshell.com/docs/current/)
- [Starship Configuration](https://starship.rs/config/)
- [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle)

---

*Happy coding! 🐠⭐*