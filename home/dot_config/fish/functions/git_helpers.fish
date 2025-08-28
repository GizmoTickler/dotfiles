# Quick Git operations
function gcommit --description "Quick commit with message and optional push"
    if test (count $argv) -eq 0
        echo "Usage: gcommit <message>"
        return 1
    end
    
    git add .
    git commit -m "$argv"
    
    read -P "Push to remote? [y/N] " -l push_confirm
    if test "$push_confirm" = "y" -o "$push_confirm" = "Y"
        git push
    end
end

function gclone --description "Clone repository and cd into it"
    if test (count $argv) -eq 0
        echo "Usage: gclone <repository_url>"
        return 1
    end
    
    set repo_name (basename $argv[1] .git)
    git clone $argv[1] && cd $repo_name
end