# Kubernetes context and namespace switcher
function kctx --description "Switch kubectl context"
    if test (count $argv) -eq 0
        kubectl config get-contexts
        return
    end
    
    kubectl config use-context $argv[1]
end

function kns --description "Switch kubectl namespace"
    if test (count $argv) -eq 0
        kubectl get namespaces
        return
    end
    
    kubectl config set-context --current --namespace=$argv[1]
end