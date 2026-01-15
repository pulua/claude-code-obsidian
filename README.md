# Claude Code to Obsidian

Claude Codeの会話履歴を自動でObsidianに保存するツールです。

## Features

- **自動保存**: 会話終了時（`/bye`）に自動でObsidianに保存
- **手動保存**: いつでもコマンドで保存可能
- **日付＋連番形式**: `2024-01-15_001.md`, `2024-01-15_002.md` のように整理
- **Obsidianフレンドリー**: フロントマター（YAML）付きで保存

## Requirements

- [Claude Code](https://claude.ai/claude-code) (CLI or VSCode extension)
- [Obsidian](https://obsidian.md/)
- `jq` (JSON processor)
  - macOS: `brew install jq`
  - Linux: `apt install jq`

## Installation

### 1. Clone this repository

```bash
git clone https://github.com/pulua/claude-code-obsidian.git
cd claude-code-obsidian
```

### 2. Run the installer

```bash
chmod +x install.sh
./install.sh
```

The installer will:
- Ask for your Obsidian vault path
- Ask for the folder name to save conversations
- Configure Claude Code hooks for auto-save
- Install `/save` command for manual save

## Usage

### Auto-save (on exit)

会話を終了すると自動で保存されます：

```
/bye
```

### Manual save

**コマンド**: Claude Codeで `/save` と入力

**直接実行**:
```bash
~/.claude/scripts/save-to-obsidian.sh
```

## Output Format

保存されるMarkdownファイルの例：

```markdown
---
created: 2024-01-15 14:30:00
source: Claude Code
tags:
  - claude-code
  - ai-conversation
---

# Claude Code Conversation

**Date:** 2024-01-15 14:30

---

## User

Obsidianに保存する仕組みを作って

## Claude

はい、Claude Codeの会話をObsidianに保存する仕組みを作成します...
```

## File Structure

```
~/.claude/
├── settings.json              # Claude Code settings with hooks
├── scripts/
│   └── save-to-obsidian.sh    # Main save script
├── commands/
│   └── save.md                # /save command definition
~/.claude-obsidian-config      # Your configuration
```

## Configuration

設定は `~/.claude-obsidian-config` に保存されます：

```bash
VAULT_PATH="/path/to/your/vault/Claude"
FOLDER_NAME="Claude"
```

手動で編集することも可能です。

## Uninstall

```bash
# Remove scripts and commands
rm ~/.claude/scripts/save-to-obsidian.sh
rm ~/.claude/commands/save.md

# Remove configuration
rm ~/.claude-obsidian-config

# Remove hooks from settings.json (manually edit)
# Remove the "hooks" section from ~/.claude/settings.json
```

## Troubleshooting

### "No recent conversation found"

会話履歴が見つからない場合：
- Claude Codeで会話を開始してから実行してください
- 60分以上経過した古い会話は検出されません

### "jq is required but not installed"

jqをインストールしてください：
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt install jq
```

## License

MIT License

## Contributing

Issues and Pull Requests are welcome!
