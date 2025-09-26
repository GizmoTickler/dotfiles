#!/bin/bash
# Set fish as the default shell

# Check if fish is installed
if ! command -v fish &> /dev/null; then
    echo "Fish shell is not installed. Installing via Homebrew..."
    if command -v brew &> /dev/null; then
        brew install fish
    else
        echo "Homebrew not found. Please install fish manually."
        exit 1
    fi
fi

FISH_PATH=$(which fish)

# Add fish to /etc/shells if not already there
if ! grep -q "$FISH_PATH" /etc/shells; then
    echo "Adding fish to /etc/shells (may require password)"
    echo "$FISH_PATH" | sudo tee -a /etc/shells
fi

# Check current shell
CURRENT_SHELL=$(dscl . -read /Users/$USER UserShell | awk '{print $2}')

if [ "$CURRENT_SHELL" != "$FISH_PATH" ]; then
    echo "Changing default shell to fish..."
    chsh -s "$FISH_PATH"
    echo "Default shell changed to fish. You may need to restart your terminal."
else
    echo "Fish is already your default shell."
fi

# Remove mise if installed via Homebrew
if brew list mise &> /dev/null; then
    echo "Removing mise from Homebrew..."
    brew uninstall mise
    echo "Mise has been removed."
fi