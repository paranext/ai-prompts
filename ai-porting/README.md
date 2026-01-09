# AI Porting - Claude Code Configuration

This directory contains Claude Code configuration files for the Paratext and paranext-core project. Since these files cannot be committed directly to the main repositories, they are managed here and symlinked into the project.

**Start here:**
- [.claude/README.md](.claude/README.md) — Claude Code configuration reference
- [.context/AI-Porting-Workflow.md](.context/AI-Porting-Workflow.md) — Complete porting workflow and strategy

## Directory Structure

```
ai-porting/
├── README.md                 # This file
├── setup-claude.sh           # Setup script (macOS/Linux)
├── setup-claude.ps1          # Setup script (Windows PowerShell)
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

### macOS / Linux

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

### Windows (PowerShell)

```powershell
# Clone the repo (same level as paranext-core and/or Paratext)
cd C:\path\to\your\projects
git clone https://github.com/paranext/ai-prompts.git

# Run the setup script
cd ai-prompts\ai-porting

# For paranext-core (full setup with CLAUDE.md files)
.\setup-claude.ps1 ..\..\paranext-core

# For legacy Paratext (without CLAUDE.md files)
.\setup-claude.ps1 ..\..\Paratext -NoClaudeMd
```

> **Note:** Windows requires either **Developer Mode** enabled or running PowerShell as **Administrator** to create symlinks. See [Troubleshooting](#windows-symlink-permissions) below.

The script will:

1. Create symlinks for `.claude/` and `.context/` at the project root
2. Create symlinks for `CLAUDE.md` files (unless `--no-claude-md` is used)
3. Back up any existing files before replacing them
4. Save the target path for future `--update` calls

## Updating the Configuration

The script remembers which projects you've configured. After pulling updates:

**macOS / Linux:**
```bash
git pull
cd ai-porting
./setup-claude.sh --update
```

**Windows:**
```powershell
git pull
cd ai-porting
.\setup-claude.ps1 -Update
```

### Managing Targets

**macOS / Linux:**
```bash
./setup-claude.sh --list                       # List all saved targets
./setup-claude.sh --remove ../../paranext-core # Remove a target
```

**Windows:**
```powershell
.\setup-claude.ps1 -List                         # List all saved targets
.\setup-claude.ps1 -Remove ..\..\paranext-core   # Remove a target
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

### Windows symlink permissions

Windows requires special permissions to create symbolic links. The setup script will fail with a clear error if it cannot create symlinks.

**Option 1: Enable Developer Mode (recommended)**

1. Open **Settings** > **Update & Security** > **For developers**
2. Enable **Developer Mode**
3. Restart your terminal and re-run the script

**Option 2: Run as Administrator**

Right-click PowerShell and select "Run as administrator", then run the setup script.

### Windows execution policy

If PowerShell blocks the script, you may need to adjust the execution policy:

```powershell
# Allow scripts for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or run with bypass (one-time)
powershell -ExecutionPolicy Bypass -File .\setup-claude.ps1 ..\..\paranext-core
```

## Documentation

- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [Memory & CLAUDE.md](https://docs.anthropic.com/en/docs/claude-code/memory)
- [Settings Reference](https://docs.anthropic.com/en/docs/claude-code/settings)
- [Skills](https://docs.anthropic.com/en/docs/claude-code/skills)
- [Subagents](https://docs.anthropic.com/en/docs/claude-code/sub-agents)
