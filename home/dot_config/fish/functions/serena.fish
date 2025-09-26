function serena-install --description "Install Serena MCP server for Claude in the current project"
    # Get the current working directory
    set -l project_dir (pwd)

    # Run the Claude MCP add command with Serena
    echo "🤖 Installing Serena MCP server for Claude in: $project_dir"
    claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project $project_dir

    if test $status -eq 0
        echo "✅ Serena MCP server installed successfully!"
        echo "   You can now use Serena's intelligent code tools in Claude."
    else
        echo "❌ Failed to install Serena MCP server"
        return 1
    end
end

function serena-remove --description "Remove Serena MCP server from Claude"
    echo "🗑️  Removing Serena MCP server from Claude..."
    claude mcp remove serena

    if test $status -eq 0
        echo "✅ Serena MCP server removed successfully!"
    else
        echo "❌ Failed to remove Serena MCP server"
        return 1
    end
end

function serena-status --description "Check if Serena MCP server is installed"
    echo "🔍 Checking Serena MCP server status..."
    claude mcp list | grep -q serena

    if test $status -eq 0
        echo "✅ Serena MCP server is installed"
        claude mcp list | grep serena
    else
        echo "❌ Serena MCP server is not installed"
        echo "   Run 'serena-install' to install it for the current project"
    end
end

function serena --description "Manage Serena MCP server for Claude"
    if test (count $argv) -eq 0
        # Default to install if no arguments
        serena-install
    else
        switch $argv[1]
            case install
                serena-install
            case remove
                serena-remove
            case status
                serena-status
            case help '*'
                echo "Serena MCP Server Manager for Claude"
                echo ""
                echo "Usage:"
                echo "  serena [command]"
                echo ""
                echo "Commands:"
                echo "  install  - Install Serena MCP server for the current project (default)"
                echo "  remove   - Remove Serena MCP server from Claude"
                echo "  status   - Check if Serena MCP server is installed"
                echo "  help     - Show this help message"
                echo ""
                echo "Examples:"
                echo "  serena                  # Install for current project"
                echo "  serena install          # Install for current project"
                echo "  serena remove           # Remove Serena"
                echo "  serena status           # Check installation status"
        end
    end
end