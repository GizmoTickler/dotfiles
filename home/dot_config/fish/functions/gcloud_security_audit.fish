# Google Cloud security audit function
function gcloud_security_audit --description "Audit Google Cloud security configuration"
    if not type -q gcloud; or not type -q op
        echo "❌ Requires both gcloud and 1Password CLI"
        return 1
    end
    
    echo "🔍 Google Cloud Security Audit"
    echo "================================"
    
    set project_id (gcloud config get-value project 2>/dev/null)
    if test -z "$project_id"
        echo "❌ No project configured"
        return 1
    end
    
    echo "📋 Project: $project_id"
    echo ""
    
    # Check service account permissions
    echo "🔐 Service Account Analysis:"
    if test -n "$GOOGLE_APPLICATION_CREDENTIALS"
        if test -f "$GOOGLE_APPLICATION_CREDENTIALS"
            # Extract service account email from key file
            set sa_email (jq -r '.client_email' "$GOOGLE_APPLICATION_CREDENTIALS" 2>/dev/null)
            if test -n "$sa_email"
                echo "   Service Account: $sa_email"
                
                # Check IAM bindings for this service account
                echo "   Roles assigned:"
                gcloud projects get-iam-policy $project_id \
                    --flatten="bindings[].members" \
                    --filter="bindings.members:serviceAccount:$sa_email" \
                    --format="table(bindings.role)" 2>/dev/null | tail -n +2 | while read role
                    echo "   • $role"
                end
                
                # Check key age
                set key_id (jq -r '.private_key_id' "$GOOGLE_APPLICATION_CREDENTIALS" 2>/dev/null)
                if test -n "$key_id"
                    set key_info (gcloud iam service-accounts keys list \
                        --iam-account="$sa_email" \
                        --filter="name:$key_id" \
                        --format="value(validAfterTime)" 2>/dev/null)
                    if test -n "$key_info"
                        echo "   Key created: $key_info"
                    end
                end
            else
                echo "   ⚠️  Invalid service account key file"
            end
            
            # Check file permissions
            set perms (stat -f "%OLp" "$GOOGLE_APPLICATION_CREDENTIALS" 2>/dev/null)
            if test "$perms" = "600"
                echo "   ✅ File permissions: $perms (secure)"
            else
                echo "   ⚠️  File permissions: $perms (should be 600)"
            end
        else
            echo "   ❌ Service account key file not found: $GOOGLE_APPLICATION_CREDENTIALS"
        end
    else
        echo "   ⚠️  No service account configured (using user credentials)"
    end
    
    echo ""
    echo "🔑 1Password Integration:"
    
    # Check if service account key is in 1Password
    if op item get "Google Cloud Service Account" --vault Private >/dev/null 2>&1
        echo "   ✅ Service account key stored in 1Password"
    else
        echo "   ⚠️  Service account key not found in 1Password"
    end
    
    # Check if project config is in 1Password
    if op item get "Google Cloud Config" --vault Private >/dev/null 2>&1
        echo "   ✅ Project configuration stored in 1Password"
    else
        echo "   ⚠️  Project configuration not found in 1Password"
    end
    
    echo ""
    echo "📊 Security Recommendations:"
    
    # Check for over-privileged roles
    if gcloud projects get-iam-policy $project_id \
        --flatten="bindings[].members" \
        --filter="bindings.members:serviceAccount AND bindings.role:(roles/owner OR roles/editor OR roles/viewer)" \
        --format="value(bindings.role)" 2>/dev/null | grep -q "roles/viewer\|roles/editor\|roles/owner"
        echo "   ⚠️  Consider using more specific roles instead of viewer/editor/owner"
    else
        echo "   ✅ Using specific IAM roles (good practice)"
    end
    
    # Check for API keys
    set api_key_count (gcloud alpha services api-keys list --format="value(name)" 2>/dev/null | wc -l | tr -d ' ')
    if test "$api_key_count" -gt 0
        echo "   📝 $api_key_count API key(s) configured - review restrictions periodically"
    end
    
    echo ""
    echo "🛡️  Security Best Practices:"
    echo "   • Rotate service account keys every 90 days"
    echo "   • Use service accounts with minimal required permissions"
    echo "   • Monitor service account usage in Cloud Logging"
    echo "   • Enable audit logging for sensitive operations"
    echo "   • Consider using Workload Identity for GKE workloads"
end