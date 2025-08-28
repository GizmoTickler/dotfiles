# 1Password helper functions for Fish shell - simplified and focused

# Create a new 1Password item interactively
function op_create --description "Create a new 1Password item interactively"
    if not type -q op
        echo "❌ 1Password CLI not installed"
        return 1
    end
    
    echo "🔐 Creating new 1Password item"
    read -P "Item title: " title
    read -P "Username (optional): " username
    read -s -P "Password: " password
    read -P "URL (optional): " url
    read -P "Notes (optional): " notes
    
    set cmd "op item create --title=\"$title\""
    
    if test -n "$username"
        set cmd "$cmd --username=\"$username\""
    end
    
    if test -n "$password"
        set cmd "$cmd --password=\"$password\""
    end
    
    if test -n "$url"
        set cmd "$cmd --url=\"$url\""
    end
    
    if test -n "$notes"
        set cmd "$cmd --notes=\"$notes\""
    end
    
    eval $cmd
    echo "✅ Item '$title' created successfully"
end

# Search 1Password items
function op_search --description "Search 1Password items"
    if test (count $argv) -eq 0
        echo "Usage: op_search <query>"
        return 1
    end
    
    op item list --format table | grep -i "$argv[1]"
end

# Show 1Password item details
function op_show --description "Show 1Password item details"
    if test (count $argv) -eq 0
        echo "Usage: op_show <item_name>"
        return 1
    end
    
    op item get "$argv[1]" --format json | jq '.'
end

# Copy 1Password item field to clipboard
function op_copy --description "Copy 1Password item field to clipboard"
    if test (count $argv) -lt 1
        echo "Usage: op_copy <item_name> [field_name]"
        return 1
    end
    
    set item $argv[1]
    set field password
    if test (count $argv) -gt 1
        set field $argv[2]
    end
    
    op item get "$item" --field "$field" | pbcopy
    echo "✅ $field for '$item' copied to clipboard"
end

# Generate and save a new password
function op_password --description "Generate and save a new password to 1Password"
    if test (count $argv) -eq 0
        echo "Usage: op_password <item_title> [length]"
        return 1
    end
    
    set title $argv[1]
    set length 32
    if test (count $argv) -gt 1
        set length $argv[2]
    end
    
    set password (op generate --length $length)
    op item create --title "$title" --password "$password"
    echo "✅ Password generated and saved for '$title'"
end

# Initialize common development secrets in 1Password
function op_init_dev --description "Initialize common development secrets in 1Password"
    echo "🔐 Setting up common development secrets in 1Password"
    echo "This will create placeholder items - update with real values"
    
    # GitHub
    op item create --title "GitHub Personal Access Token" --password "ghp_placeholder" --notes "GitHub API access token" >/dev/null 2>&1
    
    # OpenAI
    op item create --title "OpenAI API Key" --password "sk-placeholder" --notes "OpenAI API access key" >/dev/null 2>&1
    
    # Docker Hub
    op item create --title "Docker Hub Token" --username "your-username" --password "dckr_pat_placeholder" --notes "Docker Hub access token" >/dev/null 2>&1
    
    # Git Config
    op item create --title "Git Config" --username "Your Name" --field "email=your.email@example.com" --notes "Git user configuration" >/dev/null 2>&1
    
    echo "✅ Development secrets initialized. Update with real values:"
    echo "   op item edit 'GitHub Personal Access Token'"
    echo "   op item edit 'OpenAI API Key'"
    echo "   op item edit 'Docker Hub Token'"
    echo "   op item edit 'Git Config'"
    echo ""
    echo "📝 SSH keys are automatically managed by 1Password SSH agent"
    echo "   Add SSH keys directly in 1Password app: Settings → SSH Agent"
end

# Load multiple environment variables from 1Password
function op_load_secrets --description "Load common environment variables from 1Password"
    echo "🔐 Loading secrets from 1Password..."
    
    # GitHub Token
    if op item get "GitHub Personal Access Token" >/dev/null 2>&1
        set -gx GITHUB_TOKEN (op item get "GitHub Personal Access Token" --field password)
        echo "✅ GITHUB_TOKEN loaded"
    end
    
    # OpenAI API Key
    if op item get "OpenAI API Key" >/dev/null 2>&1
        set -gx OPENAI_API_KEY (op item get "OpenAI API Key" --field password)
        echo "✅ OPENAI_API_KEY loaded"
    end
    
    # Docker Hub Token
    if op item get "Docker Hub Token" >/dev/null 2>&1
        set -gx DOCKER_HUB_TOKEN (op item get "Docker Hub Token" --field password)
        echo "✅ DOCKER_HUB_TOKEN loaded"
    end
    
    echo "🎉 Secrets loaded into current Fish session"
end