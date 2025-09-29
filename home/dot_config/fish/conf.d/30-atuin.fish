# Atuin - Shell history sync
if type -q atuin
    # Set sync address from 1Password
    set -gx ATUIN_SYNC_ADDRESS https://sh.achva.casa

    # Initialize Atuin for Fish
    # Suppress stderr to hide deprecated bind syntax warning from Atuin 18.8.0
    # (Fixed in newer versions but not yet released to Homebrew)
    atuin init fish 2>/dev/null | source

    # Source the atuin environment if available
    test -f /Users/varuntirumalareddy/.atuin/bin/env.fish && source /Users/varuntirumalareddy/.atuin/bin/env.fish
end