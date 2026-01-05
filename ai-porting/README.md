# AI Porting - Claude Code Configuration

This directory contains Claude Code configuration files for the Paratext and paranext-core project. Since these files cannot be committed directly to the main repositories, they are managed here and symlinked into the project.

**Start here:**
- [.claude/README.md](.claude/README.md) — Claude Code configuration reference
- [.context/AI-Porting-Workflow.md](.context/AI-Porting-Workflow.md) — Complete porting workflow and strategy

## Directory Structure

```
ai-porting/
├── README.md                 # This file
├── setup-claude.sh           # Setup script to create symlinks
├── .claude/                  # Claude Code configuration
│   ├── settings.json         # Project settings
│   ├── commands/             # Custom slash commands
│   │   └── porting/          # Porting workflow commands
│   ├── skills/               # Claude skills (auto-invoked)
│   ├── agents/               # Custom subagents
│   └── rules/                # Modular instruction files
├── .context/                 # Project context and documentation
│   ├── *.md                  # Workflow guides, coding standards
│   ├── features/             # Feature requirements and artifacts
│   ├── decisions/            # Architectural decision records
│   ├── plans/                # Implementation plans
│   └── standards/            # Coding and testing standards
└── claude-md/                # CLAUDE.md files for various directories
    ├── CLAUDE.md             # Root-level project instructions
    ├── c-sharp/CLAUDE.md     # C# backend instructions
    ├── extension-host/CLAUDE.md
    ├── platform-bible-react/CLAUDE.md
    └── extensions/CLAUDE.md
```

## Quick Start

```bash
# Clone the repo (same level as paranext-core and/or Paratext)
cd /path/to/your/projects
git clone https://github.com/paranext/ai-prompts.git

# Run the setup script
cd ai-prompts/ai-porting
chmod +x setup-claude.sh

# For paranext-core (full setup with CLAUDE.md files)
./setup-claude.sh ../../paranext-core

# For legacy Paratext (without CLAUDE.md files)
./setup-claude.sh ../../Paratext --no-claude-md
```

The script will:

1. Create symlinks for `.claude/` and `.context/` at the project root
2. Create symlinks for `CLAUDE.md` files (unless `--no-claude-md` is used)
3. Back up any existing files before replacing them
4. Save the target path for future `--update` calls

## Updating the Configuration

The script remembers which projects you've configured. After pulling updates:

```bash
# From the ai-prompts directory
git pull

# Update all previously configured targets
cd ai-porting
./setup-claude.sh --update
```

### Managing Targets

```bash
# List all saved targets
./setup-claude.sh --list

# Remove a target from the saved list
./setup-claude.sh --remove ../../paranext-core
```

To contribute changes:

```bash
# Make your changes to files in the ai-porting directory
git add .
git commit -m "Update Claude configuration"
git push
```

## What Gets Symlinked

| Source (this repo)                         | Target (paranext-core)               |
| ------------------------------------------ | ------------------------------------ |
| `.claude/`                                 | `.claude/`                           |
| `.context/`                                | `.context/`                          |
| `claude-md/CLAUDE.md`                      | `CLAUDE.md`                          |
| `claude-md/c-sharp/CLAUDE.md`              | `c-sharp/CLAUDE.md`                  |
| `claude-md/extension-host/CLAUDE.md`       | `src/extension-host/CLAUDE.md`       |
| `claude-md/platform-bible-react/CLAUDE.md` | `lib/platform-bible-react/CLAUDE.md` |
| `claude-md/extensions/CLAUDE.md`           | `extensions/CLAUDE.md`               |

## Adding to .gitignore

The symlinked files should be ignored in paranext-core. Add these to `.gitignore`:

```gitignore
# Claude Code configuration (symlinked from external repo)
.claude
.context
CLAUDE.md
c-sharp/CLAUDE.md
src/extension-host/CLAUDE.md
lib/platform-bible-react/CLAUDE.md
extensions/CLAUDE.md
```

## Troubleshooting

### Cannot @ reference .claude or .context files

Since these folders are gitignored, Claude Code won't show them in @ autocomplete by default. Disable "Respect Git Ignore" in Claude Code settings:

1. In Claude Code, type `/` and select **General Config**
2. Uncheck **Respect Git Ignore**

### Symlinks not visible in VS Code

If you've configured VS Code to hide gitignored files, symlinks may be hidden. Check this setting:

```json
{
  "explorer.excludeGitIgnore": false
}
```

### Permission denied when running setup script

Make the script executable:

```bash
chmod +x setup-claude.sh
```

### Symlink points to wrong location

If you move directories, re-run the setup script to recreate symlinks with correct paths.

## Documentation

- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [Memory & CLAUDE.md](https://docs.anthropic.com/en/docs/claude-code/memory)
- [Settings Reference](https://docs.anthropic.com/en/docs/claude-code/settings)
- [Skills](https://docs.anthropic.com/en/docs/claude-code/skills)
- [Subagents](https://docs.anthropic.com/en/docs/claude-code/sub-agents)
