# 1Password CLI Integration

Your dotfiles use 1Password's native SSH agent integration and CLI for secure secret management.

## 🚀 Quick Setup

1. **Install 1Password CLI**:
   ```bash
   brew install 1password-cli
   ```

2. **Sign in to your account**:
   ```bash
   op signin
   ```

3. **Enable SSH Agent in 1Password app**:
   - Open 1Password app
   - Settings → Developer → SSH Agent → Enable
   - Add your SSH keys to 1Password items

## 🔐 SSH Integration (Automatic)

Your SSH setup is beautifully simple:

**`~/.ssh/config`**:
```bash
Include ~/.ssh/1Password/config
```

**What this does**:
- 1Password automatically generates `~/.ssh/1Password/config` with all your hosts and keys
- SSH agent integration is automatic via 1Password app
- All SSH keys are managed in 1Password vault
- No manual key management needed!

**Your current SSH hosts** (automatically managed):
- SC01, WLC01, homegateway, NAS01, Linode servers, and more
- All keys are SHA256 fingerprinted and automatically rotated

## 🌍 Environment Variables

### Method 1: Template-based (Recommended)

In your `.chezmoi.yaml.tmpl`:
```yaml
secrets:
  github_token: "{{ onepasswordRead \"op://Personal/GitHub Personal Access Token/password\" }}"
```

In your `~/.env.tmpl`:
```bash
export GITHUB_TOKEN="{{ .secrets.github_token }}"
```

### Method 2: Runtime Loading (Fish shell)

```fish
# Load secrets on demand
set -gx GITHUB_TOKEN (op_get "GitHub Personal Access Token")
set -gx OPENAI_API_KEY (op_get "OpenAI API Key")
```

## 🛠 Available Fish Functions

- `op_status` - Check CLI and SSH agent status
- `op_get <item> [field]` - Get item field value
- `op_copy <item> [field]` - Copy to clipboard  
- `op_search <query>` - Search items
- `op_load_env` - Show examples for loading env vars

## 📋 Common 1Password Items to Create

### Development API Keys
```bash
op item create --title="GitHub Personal Access Token" --password="ghp_..."
op item create --title="OpenAI API Key" --password="sk-..."
op item create --title="Docker Hub Token" --password="dckr_pat_..."
```

### Git Configuration
```bash
op item create --title="Git Config" --username="Your Name" --field="email=you@example.com"
```

## 🔧 Usage Examples

### Check Status
```fish
op_status
# ✅ 1Password CLI: Signed in
# ✅ 1Password SSH Agent: Running
```

### Load API Keys
```fish
# Quick environment loading
set -gx GITHUB_TOKEN (op_get "GitHub Personal Access Token")
set -gx OPENAI_API_KEY (op_get "OpenAI API Key")
```

### SSH (Automatic)
```bash
# Just SSH normally - 1Password handles everything!
ssh user@hostname
# Key is automatically provided by 1Password SSH agent
```

## 🎯 Your Current Setup Benefits

1. **Zero SSH key management** - All handled by 1Password
2. **Automatic host configuration** - Generated from 1Password items  
3. **Secure secret storage** - All API keys in encrypted vault
4. **Cross-device sync** - SSH keys and configs sync everywhere
5. **Audit trail** - 1Password tracks all secret access

This is an incredibly clean and secure setup! 🔐✨