---
name: git-worktree
description: "[paranext-core ONLY] Create and manage Git worktrees for isolated parallel development using Worktrunk. Use when working on multiple features simultaneously, enabling parallel agent work, or testing in isolation without affecting main checkout. NOT for use in PT9/legacy Paratext codebases."
allowed-tools: Bash, Read
---

# Git Worktree Skill

Create and manage isolated Git worktrees for parallel development in Platform.Bible using [Worktrunk](https://worktrunk.dev/).

## Prerequisites

Install Worktrunk before using this skill:

```bash
# macOS/Linux (Homebrew)
brew install max-sixty/worktrunk/wt

# Enable shell integration (required for directory switching)
wt config shell install

# Restart your shell or source your shell config
```

## Quick Reference

| Operation | Command |
|-----------|---------|
| Create worktree | `wt switch -c feat` |
| Create + spawn Claude | `wt switch -c -x claude feat` |
| List worktrees | `wt list` |
| Switch to worktree | `wt switch feat` |
| Remove worktree | `wt remove feat` |
| Commit with LLM message | `wt step commit` |
| Full merge workflow | `wt merge` |

## Why Use Worktrees?

Worktrees allow multiple agents (or developers) to work on different features **simultaneously** without:
- Merge conflicts from switching branches
- Losing uncommitted work
- Waiting for one feature to complete before starting another

## Creating a Worktree

### For a New Feature

```bash
# Create worktree with new branch
wt switch -c feature/creating-projects

# This:
# 1. Creates ../worktrees/feature-creating-projects/ directory
# 2. Creates branch: feature/creating-projects
# 3. Runs post-create hooks (npm install, dotnet restore)
# 4. Switches to the new worktree directory
```

### Create and Spawn Claude Agent

```bash
# Create worktree and immediately launch Claude Code in it
wt switch -c -x claude feature/usb-syncing
```

This is the primary workflow for parallel agent development.

### Switch to Existing Worktree

```bash
# Switch to an existing worktree
wt switch feature/creating-projects
```

## Listing Worktrees

```bash
wt list
```

Shows all worktrees with:
- Branch name
- Current commit
- CI status (if available)
- PR links (if available)

## Removing a Worktree

### When Work is Complete

```bash
# Remove worktree and optionally the branch
wt remove feature/creating-projects
```

### Force Remove (with uncommitted changes)

```bash
wt remove --force feature/creating-projects
```

## Commit Workflow

### Simple Commit with LLM Message

```bash
# Stage changes and commit with auto-generated message
wt step commit
```

Requires the `llm` CLI to be installed. See [reference.md](reference.md) for setup.

### Manual Commit

Standard git commands still work in worktrees:

```bash
git add .
git commit -m "Your message"
```

## Merge Workflow

When your feature is ready:

```bash
# Runs: commit -> squash -> rebase -> push -> cleanup
wt merge
```

This single command:
1. Commits any pending changes
2. Squashes commits into one
3. Rebases onto main
4. Pushes to remote
5. Cleans up the worktree

## Parallel Agent Workflow

### Scenario: Two Agents Working in Parallel

**Agent A** works on Creating Projects:
```bash
wt switch -c -x claude feature/creating-projects
# Claude Code spawns and works in this worktree
```

**Agent B** works on USB Syncing (simultaneously):
```bash
wt switch -c -x claude feature/usb-syncing
# Another Claude Code instance works independently
```

Both agents work in complete isolation with their own:
- Working directory
- `node_modules/`
- Build outputs
- Uncommitted changes

### When Complete

Each agent can merge independently:
```bash
wt merge
```

## Directory Structure

Worktrees are created as **siblings** to the main checkout:

```
code/paratext/
├── paranext-core/                    # Main checkout (main branch)
│   ├── .claude/                      # Symlink to ai-prompts
│   ├── .context/                     # Symlink to ai-prompts
│   ├── .config/wt.toml               # Worktrunk config with hooks
│   └── ...
│
├── worktrees/                        # All worktrees here
│   ├── feature-creating-projects/    # Worktree 1
│   ├── feature-usb-syncing/          # Worktree 2
│   └── experiment/                   # Worktree 3
│
└── ai-prompts/                       # AI porting artifacts
```

## Project Configuration

Platform.Bible uses `.config/wt.toml` to configure Worktrunk:

```toml
[hooks]
post-create = [
  "npm install",
  "cd c-sharp && dotnet restore && cd .."
]

[worktree]
path = "../worktrees/{{ branch | sanitize }}"
```

This ensures every new worktree is automatically initialized with dependencies.

## Important Notes

### Shared Git Database

All worktrees share the same `.git` database:
- Branches created in one worktree are visible in all
- Commits are shared across worktrees
- Stashes are NOT shared (stash is per-worktree)

### Symlinks (.claude, .context)

The `.claude/` and `.context/` directories are symlinks in paranext-core. In worktrees:
- Symlinks are preserved
- Changes to `.claude/` or `.context/` affect ALL worktrees
- This is intentional - AI artifacts should be consistent

### Node Modules

Each worktree has its own `node_modules/`:
- Worktrunk's `post-create` hook runs `npm install` automatically
- Changes to `package.json` require re-running `npm install`

### Branch Restrictions

- Cannot check out the same branch in multiple worktrees
- Main checkout typically stays on `main` branch
- Feature branches go in worktrees

## Troubleshooting

### "Branch is already checked out"

The branch is already in use by another worktree:
```bash
# Find which worktree has it
wt list

# Either remove that worktree or use a different branch
```

### Worktrunk Not Found

Ensure Worktrunk is installed and shell integration is enabled:
```bash
brew install max-sixty/worktrunk/wt
wt config shell install

# Restart your shell or source your shell config
```

### Hooks Not Running

Check that `.config/wt.toml` exists in the repository root and contains the hooks configuration.

## See Also

- [reference.md](reference.md) - Full Worktrunk command reference
- [Worktrunk Documentation](https://worktrunk.dev/)
- [app-runner skill](../app-runner/SKILL.md) - Run the app in a worktree
- [log-inspector skill](../log-inspector/SKILL.md) - Debug issues
