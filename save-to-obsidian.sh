#!/bin/bash

# Claude Code to Obsidian - Save conversation to Obsidian vault
# https://github.com/your-username/claude-code-obsidian

set -e

# Configuration (set by install.sh or manually)
CONFIG_FILE="$HOME/.claude-obsidian-config"

if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

# Default values if not configured
VAULT_PATH="${VAULT_PATH:-$HOME/Documents/Obsidian Vault/Claude}"
FOLDER_NAME="${FOLDER_NAME:-Claude}"

# Ensure vault directory exists
mkdir -p "$VAULT_PATH"

DATE=$(date +"%Y-%m-%d")

# Determine next sequence number for today
get_next_number() {
    local max=0
    for file in "$VAULT_PATH/${DATE}_"*.md; do
        if [[ -f "$file" ]]; then
            num=$(basename "$file" | sed -n "s/${DATE}_\([0-9]*\)\.md/\1/p")
            if [[ "$num" =~ ^[0-9]+$ ]] && [[ $num -gt $max ]]; then
                max=$num
            fi
        fi
    done
    echo $((max + 1))
}

NEXT_NUM=$(printf "%03d" $(get_next_number))
OUTPUT_FILE="$VAULT_PATH/${DATE}_${NEXT_NUM}.md"

# Find Claude Code conversation history
CLAUDE_PROJECTS_DIR="$HOME/.claude/projects"

# Find the most recently modified conversation file (within last 60 minutes)
LATEST_CONVERSATION=$(find "$CLAUDE_PROJECTS_DIR" -name "*.jsonl" -type f -mmin -60 2>/dev/null | xargs ls -t 2>/dev/null | head -1)

if [[ -z "$LATEST_CONVERSATION" ]]; then
    echo "Error: No recent conversation found"
    echo "Make sure you have an active Claude Code session"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed"
    echo "Install it with: brew install jq (macOS) or apt install jq (Linux)"
    exit 1
fi

# Convert JSONL to Markdown
{
    echo "---"
    echo "created: $(date +"%Y-%m-%d %H:%M:%S")"
    echo "source: Claude Code"
    echo "tags:"
    echo "  - claude-code"
    echo "  - ai-conversation"
    echo "---"
    echo ""
    echo "# Claude Code Conversation"
    echo ""
    echo "**Date:** $(date +"%Y-%m-%d %H:%M")"
    echo ""
    echo "---"
    echo ""

    while IFS= read -r line; do
        type=$(echo "$line" | jq -r '.type // empty' 2>/dev/null)

        if [[ "$type" == "user" ]]; then
            # User messages have content as array with text objects
            message=$(echo "$line" | jq -r '
                if .message.content | type == "array" then
                    [.message.content[] | select(.type == "text") | .text] | join("\n")
                elif .message.content | type == "string" then
                    .message.content
                else
                    empty
                end
            ' 2>/dev/null)
            if [[ -n "$message" && "$message" != "null" ]]; then
                echo "## User"
                echo ""
                echo "$message"
                echo ""
            fi
        elif [[ "$type" == "assistant" ]]; then
            content=$(echo "$line" | jq -r '
                if .message.content | type == "array" then
                    [.message.content[] | select(.type == "text") | .text] | join("\n")
                elif .message.content | type == "string" then
                    .message.content
                else
                    empty
                end
            ' 2>/dev/null)

            if [[ -n "$content" && "$content" != "null" ]]; then
                echo "## Claude"
                echo ""
                echo "$content"
                echo ""
            fi
        fi
    done < "$LATEST_CONVERSATION"
} > "$OUTPUT_FILE"

echo "Saved: $OUTPUT_FILE"
