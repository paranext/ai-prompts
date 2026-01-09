# Worktrunk Command Reference

Complete reference for [Worktrunk](https://worktrunk.dev/) commands and configuration.

## Core Commands

### wt switch

Navigate between worktrees or create new ones:

```bash
wt switch <branch>           # Switch to existing worktree
wt switch -c <branch>        # Create new worktree with new branch
wt switch -c -x claude <branch>  # Create and spawn Claude Code
```

Options:
- `-c, --create` - Create a new worktree
- `-x, --exec <command>` - Execute command after switching (e.g., `claude`)
- `-b, --base <branch>` - Base branch for new worktree (default: main)

Examples:
```bash
# Create worktree for new feature
wt switch -c feature/user-auth

# Create worktree and launch Claude
wt switch -c -x claude feature/api-refactor

# Switch to existing worktree
wt switch feature/user-auth
```

### wt list

Display all worktrees with status information:

```bash
wt list                      # Show all worktrees
wt list --full               # Show full output with PR links
```

Shows:
- Branch name
- Current commit
- CI status (if available)
- PR links (if available)

### wt remove

Clean up worktrees:

```bash
wt remove <branch>           # Remove worktree (fails if dirty)
wt remove --force <branch>   # Force remove with uncommitted changes
```

## Git Workflow Commands

### wt step commit

Stage and commit changes with an LLM-generated message:

```bash
wt step commit               # Commit with auto-generated message
```

Requires the `llm` CLI. See [LLM Setup](#llm-commit-message-setup) below.

### wt step squash

Squash all branch commits into one:

```bash
wt step squash               # Squash with LLM-generated message
```

### wt step rebase

Rebase current branch onto target:

```bash
wt step rebase               # Rebase onto main
```

### wt step push

Push changes to remote:

```bash
wt step push                 # Push and fast-forward target branch
```

### wt merge

Complete merge workflow in one command:

```bash
wt merge                     # commit -> squash -> rebase -> push -> cleanup
```

Options:
- `--no-squash` - Skip squash step
- `--no-commit` - Skip initial commit
- `--no-remove` - Don't remove worktree after merge

### wt step for-each

Run a command in every worktree:

```bash
wt step for-each "npm test"
wt step for-each "git status"
```

Template variables:
- `{{ branch }}` - Branch name
- `{{ commit }}` - Current commit
- `{{ worktree_path }}` - Path to worktree

## Configuration

### Config File Locations

- **User config**: `~/.config/worktrunk/config.toml` - Personal settings
- **Project config**: `.config/wt.toml` - Repository-specific hooks

### Project Configuration (.config/wt.toml)

Platform.Bible configuration:

```toml
[hooks]
# Run after worktree creation (blocking, sequential)
post-create = [
  "npm install",
  "cd c-sharp && dotnet restore && cd .."
]

# Run in background after creation (parallel)
# post-start = ["npm run watch"]

# Run before merge (blocking, fail-fast)
# pre-merge = ["npm test", "npm run lint"]

# Run after merge complete
# post-merge = []

[worktree]
# Template for worktree paths
path = "../worktrees/{{ branch | sanitize }}"

[commit]
# Staging behavior: "all", "tracked", or "none"
stage = "all"

[merge]
# Default merge options
squash = true
rebase = true
remove = true
```

### Hook Template Variables

Available in hook commands:
- `{{ repo }}` - Repository name
- `{{ branch }}` - Branch name
- `{{ worktree_path }}` - Full worktree path

### Available Hooks

| Hook | When | Behavior |
|------|------|----------|
| `post-create` | After worktree creation | Sequential, blocking |
| `post-start` | After creation | Parallel, background |
| `pre-merge` | Before merge | Sequential, fail-fast |
| `post-merge` | After push/cleanup | Sequential |

## LLM Commit Message Setup

Worktrunk can auto-generate commit messages using the `llm` CLI.

### Installation

```bash
# Install llm CLI (Python)
pip install llm

# Configure with your preferred model
llm keys set openai  # or anthropic, etc.
```

### User Configuration

Add to `~/.config/worktrunk/config.toml`:

```toml
[llm]
# Command to generate commit messages
command = "llm"
args = ["-m", "gpt-4o-mini"]
```

### Usage

```bash
# Commit with LLM-generated message
wt step commit

# Squash with LLM-generated message
wt step squash
```

## Shell Integration

Enable directory switching after worktree operations:

```bash
# Install shell integration (required)
wt config shell install

# This adds a shell function that wraps the wt binary
# Restart your shell or source your config after installation
```

Without shell integration, `wt switch` cannot change your current directory.

## Advanced Usage

### Creating Worktree from Remote Branch

```bash
# Fetch and create worktree for PR review
git fetch origin pull/123/head:pr-123
wt switch pr-123
```

### Interactive Selection

If you run `wt switch` without arguments, Worktrunk shows an interactive selector (requires fzf-like capabilities).

### Running Commands Across Worktrees

```bash
# Run tests in all worktrees
wt step for-each "npm test"

# Check git status everywhere
wt step for-each "git status --short"
```

## Platform.Bible Conventions

### Branch Naming

Use descriptive branch names:
- `feature/creating-projects`
- `feature/usb-syncing`
- `bugfix/verse-navigation`
- `experiment/new-api`

Worktrunk sanitizes `/` to `-` for directory names.

### Worktree Location

All worktrees go in `../worktrees/` relative to main checkout:
- Main: `paranext-core/`
- Worktrees: `worktrees/feature-creating-projects/`

### Parallel Agent Workflow

Spawn multiple Claude agents:

```bash
# Terminal 1
wt switch -c -x claude feature/creating-projects

# Terminal 2
wt switch -c -x claude feature/usb-syncing

# Terminal 3
wt switch -c -x claude bugfix/verse-navigation
```

## Troubleshooting

### "wt: command not found"

Install Worktrunk:
```bash
brew install max-sixty/worktrunk/wt
wt config shell install
# Restart shell
```

### Directory doesn't change after switch

Shell integration not installed:
```bash
wt config shell install
# Restart shell or source config
```

### Hooks not running

Check `.config/wt.toml` exists and has valid TOML syntax:
```bash
cat .config/wt.toml
```

### LLM commit fails

Verify `llm` is installed and configured:
```bash
llm --version
llm "test prompt"
```

### Merge conflicts during rebase

Worktrunk stops if conflicts occur:
```bash
# Resolve conflicts
git add .
git rebase --continue

# Then continue merge
wt merge
```

## See Also

- [SKILL.md](SKILL.md) - Quick start guide
- [Worktrunk Documentation](https://worktrunk.dev/)
- [Worktrunk GitHub](https://github.com/max-sixty/worktrunk)
- [Worktrunk Configuration](https://worktrunk.dev/config/)
