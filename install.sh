#!/bin/bash

# Dotfiles Bootstrap Script
# Quick setup for new machines with 1Password CLI integration

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
info() { echo -e "${CYAN}[STEP]${NC} $1"; }

DOTFILES_REPO="${DOTFILES_REPO:-GizmoTickler/dotfiles}"

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
else
    error "Unsupported OS: $OSTYPE"
    exit 1
fi

log "🚀 Setting up dotfiles on $OS"

# Check prerequisites
check_prerequisites() {
    info "🔍 Checking prerequisites..."
    
    # Check if 1Password app is installed
    if [[ "$OS" == "macOS" ]]; then
        if [[ ! -d "/Applications/1Password 7 - Password Manager.app" ]] && [[ ! -d "/Applications/1Password.app" ]]; then
            error "❌ 1Password app is required but not found!"
            error "   Please install 1Password from: https://1password.com/downloads/"
            error "   Or run: brew install --cask 1password"
            exit 1
        fi
    fi
    
    log "✅ Prerequisites check passed"
}

# Install Homebrew if not present (macOS/Linux)
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        info "🍺 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        if [[ "$OS" == "Linux" ]]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
        fi
    else
        log "✅ Homebrew already installed"
    fi
}

# Install essential tools
install_essentials() {
    info "🔧 Installing essential tools..."
    
    # Install 1Password CLI
    if ! command -v op &> /dev/null; then
        log "Installing 1Password CLI..."
        brew install 1password-cli
    else
        log "✅ 1Password CLI already installed"
    fi
    
    # Install Chezmoi
    if ! command -v chezmoi &> /dev/null; then
        log "Installing Chezmoi..."
        brew install chezmoi
    else
        log "✅ Chezmoi already installed"
    fi
}

# Setup 1Password CLI authentication
setup_1password() {
    info "🔐 Setting up 1Password CLI authentication..."
    
    # Check if already signed in
    if op account list &> /dev/null; then
        log "✅ 1Password CLI already authenticated"
        return 0
    fi
    
    echo ""
    warn "⚠️  1Password CLI authentication required!"
    warn "   You'll need to sign in to access your secrets."
    echo ""
    
    # Prompt for account
    read -p "Enter your 1Password account domain (e.g., my.1password.com): " account
    if [[ -z "$account" ]]; then
        error "Account domain is required!"
        exit 1
    fi
    
    # Sign in
    log "Signing in to 1Password..."
    if ! op signin "$account"; then
        error "Failed to sign in to 1Password!"
        error "Please ensure:"
        error "  1. Your account domain is correct"
        error "  2. You have the correct credentials" 
        error "  3. 1Password desktop app is running"
        exit 1
    fi
    
    log "✅ 1Password CLI authenticated successfully"
}

# Initialize dotfiles
setup_dotfiles() {
    info "📦 Initializing dotfiles from $DOTFILES_REPO..."
    
    # Initialize chezmoi with the repository
    if ! chezmoi init "https://github.com/$DOTFILES_REPO.git"; then
        error "Failed to initialize chezmoi repository!"
        exit 1
    fi
    
    # Apply dotfiles (this will use 1Password for secret resolution)
    log "Applying dotfiles configuration..."
    if ! chezmoi apply; then
        error "Failed to apply dotfiles!"
        error "This might be due to missing 1Password secrets."
        error "Please ensure all required items exist in your 1Password vault:"
        error "  - Git Config (with name and email fields)"
        error "  - Atuin Config (with sync_address field)" 
        error "  - SSH Key for GitHub (in Infrastructure vault)"
        exit 1
    fi
    
    log "✅ Dotfiles applied successfully"
}

# Install tools from Brewfile
install_tools() {
    info "📦 Installing development tools..."
    if [[ -f ~/.config/brew/Brewfile ]]; then
        log "Installing tools from Brewfile..."
        if ! brew bundle --file ~/.config/brew/Brewfile; then
            warn "Some tools failed to install, but continuing..."
        fi
    else
        warn "Brewfile not found, skipping tool installation"
    fi
    log "✅ Tool installation completed"
}

# Set Fish as default shell
setup_fish() {
    info "🐟 Setting up Fish shell..."
    local fish_path
    fish_path=$(brew --prefix)/bin/fish
    
    if command -v fish &> /dev/null; then
        log "Configuring Fish as default shell..."
        
        # Add Fish to shells if not present
        if ! grep -q "$fish_path" /etc/shells 2>/dev/null; then
            echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
        fi
        
        # Change default shell if not already Fish
        if [[ "$SHELL" != "$fish_path" ]]; then
            if chsh -s "$fish_path"; then
                log "✅ Default shell changed to Fish"
            else
                warn "Failed to change default shell, you can do it manually later"
            fi
        else
            log "✅ Fish is already the default shell"
        fi
    else
        warn "Fish shell not installed, skipping shell setup"
    fi
}

# Main installation
main() {
    echo ""
    info "🚀 Starting dotfiles bootstrap for $OS..."
    echo ""
    
    check_prerequisites
    install_homebrew
    install_essentials  
    setup_1password
    setup_dotfiles
    install_tools
    setup_fish
    
    echo ""
    log "🎉 Bootstrap complete!"
    echo ""
    info "📋 What was installed:"
    log "   ✅ Homebrew package manager"
    log "   ✅ 1Password CLI (authenticated)"
    log "   ✅ Chezmoi dotfiles manager"
    log "   ✅ Development tools from Brewfile"
    log "   ✅ Fish shell with Starship prompt"
    log "   ✅ Neovim with modern plugin setup"
    log "   ✅ Git with SSH signing configured"
    echo ""
    info "🔄 Next steps:"
    log "   1. Restart your terminal or run: exec fish"
    log "   2. Verify 1Password integration: op item list"
    log "   3. Check Git signing: git log --show-signature -1"
    log "   4. Review configuration: chezmoi edit"
    echo ""
    info "🔐 Security notes:"
    log "   • All secrets are managed via 1Password"
    log "   • SSH agent integration is configured"
    log "   • Git commits are signed with SSH keys"
    echo ""
    log "📚 Documentation: https://github.com/$DOTFILES_REPO"
    echo ""
}

# Run with error handling
if ! main "$@"; then
    error "Bootstrap failed! Check the output above for errors."
    exit 1
fi