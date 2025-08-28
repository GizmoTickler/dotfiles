# Google Cloud Platform helper functions

# Setup Google Cloud CLI with 1Password integration
function gcloud_setup --description "Setup Google Cloud CLI with 1Password integration"
    if not type -q gcloud
        echo "❌ Google Cloud SDK not installed. Install with: brew install --cask google-cloud-sdk"
        return 1
    end
    
    echo "🔧 Setting up Google Cloud CLI..."
    
    # Initialize gcloud if not already done
    if not test -f ~/.config/gcloud/configurations/config_default
        echo "📋 Running gcloud init..."
        gcloud init
    else
        echo "✅ gcloud already initialized"
    end
    
    # Set project from 1Password if available
    if op read "op://Private/Google Cloud Config/project_id" >/dev/null 2>&1
        set project_id (op read "op://Private/Google Cloud Config/project_id")
        echo "🎯 Setting project to: $project_id"
        gcloud config set project $project_id
    else
        echo "⚠️  Google Cloud Config not found in 1Password"
        echo "   Create item 'Google Cloud Config' in Private vault with 'project_id' field"
    end
    
    # Enable useful APIs
    echo "🔌 Enabling common APIs..."
    gcloud services enable \
        compute.googleapis.com \
        container.googleapis.com \
        cloudbuild.googleapis.com \
        containerregistry.googleapis.com \
        artifactregistry.googleapis.com \
        iam.googleapis.com \
        cloudresourcemanager.googleapis.com \
        --quiet 2>/dev/null || echo "⚠️  Some APIs may require billing to be enabled"
    
    # Setup application default credentials
    echo "🔑 Setting up application default credentials..."
    gcloud auth application-default login
    
    echo "✅ Google Cloud setup complete!"
    echo ""
    echo "💡 Available commands:"
    echo "  • gcloud_project_list  - List available projects"
    echo "  • gcloud_switch <id>   - Switch to different project"
    echo "  • gcloud_status        - Show current configuration"
end

# List available GCP projects
function gcloud_project_list --description "List available Google Cloud projects"
    if not type -q gcloud
        echo "❌ Google Cloud SDK not installed"
        return 1
    end
    
    echo "📋 Available Google Cloud projects:"
    gcloud projects list --format="table(projectId:label=PROJECT_ID,name:label=NAME,projectNumber:label=NUMBER)"
end

# Switch to different GCP project
function gcloud_switch --description "Switch to different Google Cloud project"
    if not type -q gcloud
        echo "❌ Google Cloud SDK not installed"
        return 1
    end
    
    if test (count $argv) -eq 0
        echo "Usage: gcloud_switch <project_id>"
        echo ""
        gcloud_project_list
        return 1
    end
    
    set project_id $argv[1]
    echo "🔄 Switching to project: $project_id"
    
    gcloud config set project $project_id
    
    # Update environment variables
    set -gx GOOGLE_CLOUD_PROJECT $project_id
    set -gx GCLOUD_PROJECT $project_id
    
    echo "✅ Switched to project: $project_id"
end

# Show current GCP configuration
function gcloud_status --description "Show current Google Cloud configuration"
    if not type -q gcloud
        echo "❌ Google Cloud SDK not installed"
        return 1
    end
    
    echo "🌥️  Google Cloud Status:"
    echo "Current project: $(gcloud config get-value project 2>/dev/null || echo 'Not set')"
    echo "Current account: $(gcloud config get-value account 2>/dev/null || echo 'Not signed in')"
    echo "Current region: $(gcloud config get-value compute/region 2>/dev/null || echo 'Not set')"
    echo "Current zone: $(gcloud config get-value compute/zone 2>/dev/null || echo 'Not set')"
    echo ""
    
    # Show environment variables
    echo "Environment variables:"
    echo "GOOGLE_CLOUD_PROJECT: $GOOGLE_CLOUD_PROJECT"
    echo "GCLOUD_PROJECT: $GCLOUD_PROJECT"
    
    if test -n "$GOOGLE_APPLICATION_CREDENTIALS"
        echo "GOOGLE_APPLICATION_CREDENTIALS: $GOOGLE_APPLICATION_CREDENTIALS"
    end
end

# Create service account key and store in 1Password
function gcloud_create_service_account --description "Create service account and store key in 1Password"
    if not type -q gcloud; or not type -q op
        echo "❌ Requires both gcloud and 1Password CLI"
        return 1
    end
    
    if test (count $argv) -lt 1
        echo "Usage: gcloud_create_service_account <service-account-name> [description] [--default]"
        echo "  --default  Set this as the default service account for all CLI operations"
        return 1
    end
    
    set sa_name $argv[1]
    set description (test (count $argv) -gt 1; and echo $argv[2]; or echo "Service account created via dotfiles")
    set make_default false
    
    # Check for --default flag
    if contains -- --default $argv
        set make_default true
    end
    
    set project_id (gcloud config get-value project)
    
    echo "🔧 Creating service account: $sa_name"
    
    # Create service account
    gcloud iam service-accounts create $sa_name --description="$description" --display-name="$sa_name"
    
    # Grant minimal roles (principle of least privilege)
    echo "🔐 Granting minimal required roles..."
    gcloud projects add-iam-policy-binding $project_id \
        --member="serviceAccount:$sa_name@$project_id.iam.gserviceaccount.com" \
        --role="roles/serviceusage.serviceUsageConsumer"
    
    echo "💡 Service account created with minimal permissions."
    echo "   Add specific roles as needed:"
    echo "   • roles/compute.viewer (Compute Engine read)"
    echo "   • roles/container.developer (GKE access)"  
    echo "   • roles/storage.objectViewer (Cloud Storage read)"
    echo ""
    echo "   Example: gcloud projects add-iam-policy-binding $project_id \\"
    echo "            --member='serviceAccount:$sa_name@$project_id.iam.gserviceaccount.com' \\"
    echo "            --role='roles/compute.viewer'"
    
    # Create and download key
    set key_file /tmp/"$sa_name-key.json"
    gcloud iam service-accounts keys create $key_file \
        --iam-account="$sa_name@$project_id.iam.gserviceaccount.com"
    
    # Store in 1Password
    echo "🔒 Storing service account key in 1Password..."
    if test $make_default = true
        # Store as the default service account
        op item create \
            --category="Secure Note" \
            --title="Google Cloud Service Account" \
            --vault="Private" \
            "key.json=$(cat $key_file)" \
            "service_account=$sa_name@$project_id.iam.gserviceaccount.com" \
            "project_id=$project_id" \
            "description=$description"
        echo "✅ Set as default service account for CLI operations"
    else
        # Store as a named service account
        op item create \
            --category="Secure Note" \
            --title="Google Cloud Service Account - $sa_name" \
            --vault="Private" \
            "key.json=$(cat $key_file)" \
            "service_account=$sa_name@$project_id.iam.gserviceaccount.com" \
            "project_id=$project_id" \
            "description=$description"
    end
    
    # Clean up temporary file
    rm $key_file
    
    echo "✅ Service account created and key stored in 1Password!"
    echo "🔑 Service account: $sa_name@$project_id.iam.gserviceaccount.com"
    
    if test $make_default = true
        echo "🔄 Restart your shell to use the new service account: exec fish"
    end
end

# Create API key for Google Cloud services
function gcloud_create_api_key --description "Create Google Cloud API key and store in 1Password"
    if not type -q gcloud; or not type -q op
        echo "❌ Requires both gcloud and 1Password CLI"
        return 1
    end
    
    if test (count $argv) -lt 1
        echo "Usage: gcloud_create_api_key <key-name> [description]"
        echo "Example: gcloud_create_api_key my-app-key 'API key for my application'"
        return 1
    end
    
    set key_name $argv[1]
    set description (test (count $argv) -gt 1; and echo $argv[2]; or echo "API key created via dotfiles")
    set project_id (gcloud config get-value project)
    
    echo "🔧 Creating API key: $key_name"
    
    # Create API key
    set api_key (gcloud alpha services api-keys create \
        --display-name="$key_name" \
        --format="value(response.keyString)")
    
    if test -z "$api_key"
        echo "❌ Failed to create API key"
        return 1
    end
    
    echo "🔒 Storing API key in 1Password..."
    op item create \
        --category="API Credential" \
        --title="Google Cloud API Key - $key_name" \
        --vault="Private" \
        "credential=$api_key" \
        "project_id=$project_id" \
        "description=$description" \
        "key_name=$key_name"
    
    echo "✅ API key created and stored in 1Password!"
    echo "🔑 Key name: $key_name"
    echo "💡 Access with: op read \"op://Private/Google Cloud API Key - $key_name/credential\""
end