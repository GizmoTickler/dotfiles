# Complete iTerm2 setup and configuration
function setup_iterm2_complete --description "Complete iTerm2 setup with color scheme and preferences"
    if test "$TERM_PROGRAM" != "iTerm.app"
        echo "❌ Not running in iTerm2. Please run this from iTerm2."
        return 1
    end
    
    echo "🎨 Setting up complete iTerm2 integration..."
    
    # Install shell integration
    setup_iterm2
    
    # Install color scheme
    echo "🎨 Installing Catppuccin color scheme..."
    set color_scheme_path {{ .chezmoi.homeDir }}/.config/iterm2/catppuccin-mocha.itermcolors
    
    if test -f "$color_scheme_path"
        echo "📋 Opening color scheme - import it in iTerm2 Preferences > Profiles > Colors"
        open "$color_scheme_path"
        echo ""
        echo "📝 Manual steps needed:"
        echo "  1. Go to iTerm2 > Preferences > Profiles > Colors"
        echo "  2. Click 'Color Presets' dropdown (bottom right)"
        echo "  3. Select 'Import...' and choose the opened file"
        echo "  4. Select 'Catppuccin Mocha' from the presets dropdown"
    else
        echo "⚠️  Color scheme file not found at: $color_scheme_path"
    end
    
    echo ""
    echo "🔤 Font recommendations:"
    echo "  • Fira Code Nerd Font (installed via Homebrew)"
    echo "  • Hack Nerd Font (installed via Homebrew)"
    echo "  • Meslo LG Nerd Font (installed via Homebrew)"
    echo ""
    echo "📝 To set font:"
    echo "  1. iTerm2 > Preferences > Profiles > Text"
    echo "  2. Click 'Change Font' and select a Nerd Font"
    echo "  3. Size: 14pt recommended"
    echo "  4. Enable 'Use ligatures' for Fira Code"
    
    echo ""
    echo "⚙️  Additional recommended settings:"
    echo "  • Profiles > Terminal > Scrollback: Unlimited"
    echo "  • Profiles > Session > When idle: Don't send anything"
    echo "  • Profiles > Keys > Key Mappings: Natural Text Editing preset"
    echo "  • General > Selection: Copy to pasteboard on selection"
    
    echo ""
    echo "🎯 Starship prompt integration:"
    echo "  • Your Starship prompt is already configured"
    echo "  • It will show Git status, Kubernetes context, and more"
    echo "  • Colors will match the Catppuccin theme"
    
    echo ""
    echo "✅ iTerm2 setup guide complete!"
    echo "🔄 Restart iTerm2 to ensure all changes take effect"
end