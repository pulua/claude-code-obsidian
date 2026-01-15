#!/bin/bash

# Claude Code to Obsidian - Installer
# https://github.com/your-username/claude-code-obsidian

set -e

echo "==================================="
echo "Claude Code to Obsidian - Installer"
echo "==================================="
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check for jq
if ! command -v jq &> /dev/null; then
    echo "Warning: jq is not installed"
    echo "Please install it first:"
    echo "  macOS:  brew install jq"
    echo "  Linux:  apt install jq"
    echo ""
fi

# Ask for Obsidian vault path
echo "Enter your Obsidian vault path:"
echo "(e.g., /Users/username/Documents/Obsidian Vault)"
read -r VAULT_PATH

if [[ -z "$VAULT_PATH" ]]; then
    echo "Error: Vault path is required"
    exit 1
fi

# Ask for folder name within vault
echo ""
echo "Enter folder name for Claude conversations (default: Claude):"
read -r FOLDER_NAME
FOLDER_NAME="${FOLDER_NAME:-Claude}"

# Full path for saving
FULL_PATH="$VAULT_PATH/$FOLDER_NAME"

# Create directory if it doesn't exist
mkdir -p "$FULL_PATH"

# Save configuration
CONFIG_FILE="$HOME/.claude-obsidian-config"
cat > "$CONFIG_FILE" << EOF
# Claude Code to Obsidian Configuration
VAULT_PATH="$FULL_PATH"
FOLDER_NAME="$FOLDER_NAME"
EOF

echo ""
echo "Configuration saved to: $CONFIG_FILE"

# Create Claude scripts directory
CLAUDE_SCRIPTS_DIR="$HOME/.claude/scripts"
mkdir -p "$CLAUDE_SCRIPTS_DIR"

# Copy script
cp "$SCRIPT_DIR/save-to-obsidian.sh" "$CLAUDE_SCRIPTS_DIR/"
chmod +x "$CLAUDE_SCRIPTS_DIR/save-to-obsidian.sh"

echo "Script installed to: $CLAUDE_SCRIPTS_DIR/save-to-obsidian.sh"

# Update Claude Code settings for hooks
CLAUDE_SETTINGS="$HOME/.claude/settings.json"

if [[ -f "$CLAUDE_SETTINGS" ]]; then
    # Backup existing settings
    cp "$CLAUDE_SETTINGS" "$CLAUDE_SETTINGS.backup"
    echo "Existing settings backed up to: $CLAUDE_SETTINGS.backup"

    # Check if hooks already exist
    if jq -e '.hooks' "$CLAUDE_SETTINGS" > /dev/null 2>&1; then
        # Add to existing hooks
        jq '.hooks.SessionEnd = [{"matcher": "", "hooks": [{"type": "command", "command": "'"$CLAUDE_SCRIPTS_DIR/save-to-obsidian.sh"'"}]}]' "$CLAUDE_SETTINGS" > "$CLAUDE_SETTINGS.tmp"
        mv "$CLAUDE_SETTINGS.tmp" "$CLAUDE_SETTINGS"
    else
        # Add hooks section
        jq '. + {"hooks": {"SessionEnd": [{"matcher": "", "hooks": [{"type": "command", "command": "'"$CLAUDE_SCRIPTS_DIR/save-to-obsidian.sh"'"}]}]}}' "$CLAUDE_SETTINGS" > "$CLAUDE_SETTINGS.tmp"
        mv "$CLAUDE_SETTINGS.tmp" "$CLAUDE_SETTINGS"
    fi
else
    # Create new settings file
    cat > "$CLAUDE_SETTINGS" << EOF
{
  "hooks": {
    "SessionEnd": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_SCRIPTS_DIR/save-to-obsidian.sh"
          }
        ]
      }
    ]
  }
}
EOF
fi

echo "Claude Code hooks configured"

# Create /save command
CLAUDE_COMMANDS_DIR="$HOME/.claude/commands"
mkdir -p "$CLAUDE_COMMANDS_DIR"

cat > "$CLAUDE_COMMANDS_DIR/save.md" << 'EOF'
# Obsidianに会話を保存

この会話をObsidianに保存してください。

以下のコマンドを実行してください：
~/.claude/scripts/save-to-obsidian.sh
EOF

echo "/save command installed to: $CLAUDE_COMMANDS_DIR/save.md"

echo ""
echo "==================================="
echo "Installation complete!"
echo "==================================="
echo ""
echo "Your conversations will be saved to:"
echo "  $FULL_PATH"
echo ""
echo "How to use:"
echo "  - Auto-save: Conversations are saved when you exit Claude Code (/bye)"
echo "  - Manual save: Type '/save' in Claude Code"
echo "  - Direct run: ~/.claude/scripts/save-to-obsidian.sh"
echo ""
