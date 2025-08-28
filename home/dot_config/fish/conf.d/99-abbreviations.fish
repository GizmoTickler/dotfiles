# Fish abbreviations - smart shortcuts that expand when you type them

# Clear existing abbreviations (for clean reloads)
for abbr_name in (abbr --list)
    abbr --erase $abbr_name
end

# === Basic commands ===
abbr c clear
abbr .. "cd .."
abbr ... "cd ../.."
abbr .... "cd ../../.."

# === Modern CLI replacements (conditional) ===
if type -q bat
    abbr cat bat
    abbr less bat
end

if type -q eza
    abbr ls "eza --icons"
    abbr ll "eza -l --icons --git"
    abbr la "eza -la --icons --git"
    abbr lt "eza --tree --icons"
else if type -q lsd
    abbr ls lsd
    abbr ll "lsd -l"
    abbr la "lsd -la"
else
    abbr ll "ls -la"
    abbr la "ls -la"
end

if type -q fd
    abbr find fd
end

if type -q rg
    abbr grep rg
end

if type -q doggo
    abbr dig doggo
end

# === Git abbreviations ===
if type -q git
    abbr g git
    abbr ga "git add"
    abbr gaa "git add --all"
    abbr gc "git commit -m"
    abbr gca "git commit --amend"
    abbr gco "git checkout"
    abbr gcb "git checkout -b"
    abbr gd "git diff"
    abbr gds "git diff --staged"
    abbr gf "git fetch"
    abbr gl "git log --oneline --graph"
    abbr gp "git push"
    abbr gpu "git push -u origin"
    abbr gpl "git pull --rebase --autostash"
    abbr gs "git status -sb"
    abbr gss "git stash save"
    abbr gsp "git stash pop"
    abbr gm "git merge"
    abbr gr "git rebase"
    abbr gri "git rebase -i"
    abbr grs "git reset"
    abbr grh "git reset --hard"
    
    # Advanced git commands
    abbr --command git co checkout
    abbr --command git pl "pull --rebase --autostash"
    abbr --command git pf "push --force-with-lease"
end

# === Kubernetes abbreviations ===
if type -q kubectl
    abbr k kubectl
    abbr kgp "kubectl get pods"
    abbr kgs "kubectl get svc" 
    abbr kgd "kubectl get deployments"
    abbr kgn "kubectl get nodes"
    abbr kdesc "kubectl describe"
    abbr klogs "kubectl logs -f"
    abbr kexec "kubectl exec -it"
    abbr kctx "kubectl config current-context"
    abbr kns "kubectl config set-context --current --namespace"
end

# === Talos ===
if type -q talosctl
    abbr talos talosctl
end

# === Google Cloud ===
if type -q gcloud
    abbr gc gcloud
    abbr gcl "gcloud_project_list"
    abbr gcs "gcloud_switch"
    abbr gcst "gcloud_status"
    abbr gce "gcloud compute instances"
    abbr gck "gcloud container clusters"
    abbr gcr "gcloud container images"
end

# === Homebrew ===
if type -q brew
    abbr bi "brew install"
    abbr bs "brew search"
    abbr bu "brew update"
    abbr bg "brew upgrade"
    abbr bl "brew list"
    abbr bc "brew cleanup"
    abbr bd "brew doctor"
    abbr bci "brew install --cask"
    abbr bcs "brew search --cask"
    abbr bundle "brew bundle"
end

# === Chezmoi ===
if type -q chezmoi
    abbr cm chezmoi
    abbr cma "chezmoi add"
    abbr cmd "chezmoi diff"
    abbr cms "chezmoi status"
    abbr cmr "chezmoi apply"
    abbr cme "chezmoi edit"
    abbr cmcd "chezmoi cd"
    abbr cmu "chezmoi update"
end

# === Development Tools ===
abbr v nvim
abbr vim nvim

# Python tools
if type -q python3
    abbr py python3
    abbr pip pip3
    abbr serve "python3 -m http.server"
end

# pipx for global Python applications
if type -q pipx
    abbr px pipx
    abbr pxi "pipx install"
    abbr pxl "pipx list"
end

# Node.js tools
if type -q npm
    abbr ni "npm install"
    abbr nr "npm run"
    abbr ns "npm start"
    abbr nt "npm test"
end

# Go tools
if type -q go
    abbr gob "go build"
    abbr gor "go run"
    abbr got "go test"
    abbr goi "go install"
end

# === Docker (if available) ===
if type -q docker
    abbr d docker
    abbr dc "docker compose"
    abbr dcup "docker compose up -d"
    abbr dcdown "docker compose down"
    abbr dcps "docker compose ps"
    abbr dclogs "docker compose logs -f"
    abbr dexec "docker exec -it"
end

# === System utilities ===
abbr h history
abbr j jobs
abbr md "mkdir -p"
abbr rd rmdir
abbr myip "curl http://ipecho.net/plain"

# === 1Password CLI (if available) ===
if type -q op
    abbr opstatus "op_status"         # Check 1Password status
    abbr opg "op_get"                # Get item from 1Password
    abbr opl "op item list"          # List 1Password items
    abbr opsearch "op_search"         # Search 1Password items
    abbr opc "op_copy"               # Copy 1Password item to clipboard
    abbr opload "op_load_secrets"     # Load common secrets into environment
    abbr signin "op signin"           # Sign in to 1Password
end

# === Quick config edits ===
abbr fishconfig "$EDITOR ~/.config/fish/config.fish"
abbr starshipconfig "$EDITOR ~/.config/starship.toml"
abbr chezmoiconfig "$EDITOR ~/.config/chezmoi/chezmoi.yaml"
abbr reload "exec fish"

# === iTerm2 integration ===
if test "$TERM_PROGRAM" = "iTerm.app"
    abbr img imgcat                    # Display images in terminal
    abbr dl it2dl                     # Download files
    abbr dark "iterm2_profile Dark"   # Switch to dark profile
    abbr light "iterm2_profile Light" # Switch to light profile
    abbr ssh_profile "iterm2_profile SSH" # Switch to SSH profile
end