# Setup iTerm2 shell integration
function setup_iterm2 --description "Install and configure iTerm2 shell integration"
    if test "$TERM_PROGRAM" != "iTerm.app"
        echo "❌ Not running in iTerm2"
        return 1
    end
    
    echo "🔧 Setting up iTerm2 shell integration..."
    
    # Download shell integration if not present
    if not test -e ~/.iterm2_shell_integration.fish
        echo "📥 Downloading iTerm2 shell integration..."
        curl -L https://iterm2.com/shell_integration/fish \
            -o ~/.iterm2_shell_integration.fish
    else
        echo "✅ iTerm2 shell integration already installed"
    end
    
    # Install iTerm2 utilities
    if not type -q imgcat
        echo "📥 Installing iTerm2 utilities..."
        curl -L https://iterm2.com/utilities/imgcat -o /usr/local/bin/imgcat
        chmod +x /usr/local/bin/imgcat 2>/dev/null || echo "⚠️  Could not make imgcat executable (run with sudo)"
    end
    
    if not type -q it2dl
        curl -L https://iterm2.com/utilities/it2dl -o /usr/local/bin/it2dl
        chmod +x /usr/local/bin/it2dl 2>/dev/null || echo "⚠️  Could not make it2dl executable (run with sudo)"
    end
    
    echo "✅ iTerm2 integration setup complete!"
    echo "💡 Restart your shell or run 'exec fish' to activate"
    echo ""
    echo "Available commands:"
    echo "  • title <name>     - Set tab title"
    echo "  • iterm2_profile <profile> - Change color profile"
    echo "  • imgcat <image>   - Display images in terminal"
    echo "  • it2dl <file>     - Download files from remote servers"
end