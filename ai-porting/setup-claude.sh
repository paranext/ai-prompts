#!/bin/bash

# Setup script for Claude Code configuration symlinks
# This script lives in the config repo and links files into a target project

# How to use:
# 1. Make the script executable
# chmod +x setup-claude.sh

# 2. Run from anywhere, passing the target project path
#
# For paranext-core (full setup with CLAUDE.md files):
# ./setup-claude.sh ../../paranext-core
#
# For legacy Paratext (without CLAUDE.md files):
# ./setup-claude.sh ../../Paratext --no-claude-md
#
# To update all previously configured targets after pulling new changes (create symlinks for new files in all targets):
# ./setup-claude.sh --update
#
# To list all previously configured targets:
# ./setup-claude.sh --list
#
# To remove a target from the saved list:
# ./setup-claude.sh --remove ../../paranext-core

set -e

CONFIG_REPO="$(cd "$(dirname "$0")" && pwd)"
TARGETS_FILE="$CONFIG_REPO/.setup-targets"

# Function to show usage
show_usage() {
    echo "Usage: $0 <target-project-path> [--no-claude-md]"
    echo "       $0 --update"
    echo "       $0 --list"
    echo "       $0 --remove <path>"
    echo ""
    echo "Options:"
    echo "  --no-claude-md    Skip CLAUDE.md symlinks (for legacy codebases)"
    echo "  --update          Re-run setup for all saved targets"
    echo "  --list            Show all saved targets"
    echo "  --remove <path>   Remove a target from the saved list"
    echo ""
    echo "Examples:"
    echo "  $0 ../paranext-core                  # Full setup with CLAUDE.md files"
    echo "  $0 ../paratext --no-claude-md        # Without CLAUDE.md files"
    echo "  $0 --update                          # Update all targets after git pull"
}

# Function to save target to .setup-targets
save_target() {
    local target_path="$1"
    local flags="$2"

    # Remove existing entry for this path (if any)
    if [[ -f "$TARGETS_FILE" ]]; then
        grep -v "^${target_path}|" "$TARGETS_FILE" > "${TARGETS_FILE}.tmp" 2>/dev/null || true
        mv "${TARGETS_FILE}.tmp" "$TARGETS_FILE"
    fi

    # Add the new/updated entry
    echo "${target_path}|${flags}" >> "$TARGETS_FILE"
}

# Function to create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"
    local name="$(basename "$target")"

    if [[ ! -e "$source" ]]; then
        echo "  Skipping $name (not found in config repo)"
        return
    fi

    if [[ -L "$target" ]]; then
        echo "  Updating $name (replacing existing symlink)"
        rm "$target"
    elif [[ -e "$target" ]]; then
        echo "  Backing up existing $name to ${name}.backup"
        mv "$target" "${target}.backup"
    fi

    ln -s "$source" "$target"
    echo "  ✓ Linked $name"
}

# Function to run setup for a single target
run_setup() {
    local target_project="$1"
    local no_claude_md="$2"

    echo "Setting up Claude Code symlinks..."
    echo "Config repo: $CONFIG_REPO"
    echo "Target project: $target_project"
    echo ""

    # Create symlinks for root-level config
    echo "Root configuration:"
    create_symlink "$CONFIG_REPO/.claude" "$target_project/.claude"
    create_symlink "$CONFIG_REPO/.context" "$target_project/.context"

    if [[ "$no_claude_md" != "--no-claude-md" ]]; then
        create_symlink "$CONFIG_REPO/claude-md/CLAUDE.md" "$target_project/CLAUDE.md"

        # Create symlinks for subdirectory CLAUDE.md files
        echo ""
        echo "Subdirectory CLAUDE.md files:"
        create_symlink "$CONFIG_REPO/claude-md/c-sharp/CLAUDE.md" "$target_project/c-sharp/CLAUDE.md"
        create_symlink "$CONFIG_REPO/claude-md/extension-host/CLAUDE.md" "$target_project/src/extension-host/CLAUDE.md"
        create_symlink "$CONFIG_REPO/claude-md/platform-bible-react/CLAUDE.md" "$target_project/lib/platform-bible-react/CLAUDE.md"
        create_symlink "$CONFIG_REPO/claude-md/extensions/CLAUDE.md" "$target_project/extensions/CLAUDE.md"
    else
        echo ""
        echo "Skipping CLAUDE.md files (--no-claude-md flag)"
    fi

    echo ""
    echo "Done! Claude Code configuration is now linked."
    echo ""

    # Check for Worktrunk installation
    echo "Checking prerequisites..."
    if command -v wt &> /dev/null; then
        echo "  ✓ Worktrunk is installed"
    else
        echo "  ⚠ Worktrunk not found - required for git-worktree skill"
        echo ""
        echo "  Install Worktrunk for parallel agent development:"
        echo "    brew install max-sixty/worktrunk/wt"
        echo "    wt config shell install"
        echo ""
        echo "  See: https://worktrunk.dev/"
    fi
    echo ""

    echo "Note: Make sure these are in the target project's .gitignore:"
    echo "  .claude"
    echo "  .context"
    if [[ "$no_claude_md" != "--no-claude-md" ]]; then
        echo "  CLAUDE.md"
        echo "  c-sharp/CLAUDE.md"
        echo "  src/extension-host/CLAUDE.md"
        echo "  lib/platform-bible-react/CLAUDE.md"
        echo "  extensions/CLAUDE.md"
    fi
}

# Parse arguments
TARGET_PROJECT=""
NO_CLAUDE_MD=""
DO_UPDATE=false
DO_LIST=false
DO_REMOVE=false
REMOVE_PATH=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-claude-md)
            NO_CLAUDE_MD="--no-claude-md"
            shift
            ;;
        --update)
            DO_UPDATE=true
            shift
            ;;
        --list)
            DO_LIST=true
            shift
            ;;
        --remove)
            DO_REMOVE=true
            shift
            if [[ $# -gt 0 ]]; then
                REMOVE_PATH="$1"
                shift
            fi
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            if [[ -z "$TARGET_PROJECT" ]]; then
                TARGET_PROJECT="$1"
            fi
            shift
            ;;
    esac
done

# Handle --list
if [[ "$DO_LIST" == true ]]; then
    if [[ ! -f "$TARGETS_FILE" ]] || [[ ! -s "$TARGETS_FILE" ]]; then
        echo "No saved targets."
        exit 0
    fi
    echo "Saved targets:"
    while IFS='|' read -r path flags; do
        if [[ -n "$flags" ]]; then
            echo "  $path ($flags)"
        else
            echo "  $path"
        fi
    done < "$TARGETS_FILE"
    exit 0
fi

# Handle --remove
if [[ "$DO_REMOVE" == true ]]; then
    if [[ -z "$REMOVE_PATH" ]]; then
        echo "Error: --remove requires a path argument"
        show_usage
        exit 1
    fi

    # Resolve to absolute path if relative
    if [[ "$REMOVE_PATH" != /* ]]; then
        REMOVE_PATH="$(cd "$REMOVE_PATH" 2>/dev/null && pwd)" || {
            echo "Error: Path not found: $REMOVE_PATH"
            exit 1
        }
    fi

    if [[ ! -f "$TARGETS_FILE" ]]; then
        echo "No saved targets."
        exit 0
    fi

    if grep -q "^${REMOVE_PATH}|" "$TARGETS_FILE"; then
        grep -v "^${REMOVE_PATH}|" "$TARGETS_FILE" > "${TARGETS_FILE}.tmp" 2>/dev/null || true
        mv "${TARGETS_FILE}.tmp" "$TARGETS_FILE"
        echo "Removed: $REMOVE_PATH"
    else
        echo "Target not found: $REMOVE_PATH"
        exit 1
    fi
    exit 0
fi

# Handle --update
if [[ "$DO_UPDATE" == true ]]; then
    if [[ ! -f "$TARGETS_FILE" ]] || [[ ! -s "$TARGETS_FILE" ]]; then
        echo "No saved targets. Run setup with a target path first."
        exit 1
    fi

    echo "Updating all saved targets..."
    echo ""

    while IFS='|' read -r path flags; do
        if [[ -d "$path" ]]; then
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            run_setup "$path" "$flags"
            echo ""
        else
            echo "Warning: Skipping $path (directory not found)"
        fi
    done < "$TARGETS_FILE"

    echo "All targets updated!"
    exit 0
fi

# Normal setup flow - requires target path
if [[ -z "$TARGET_PROJECT" ]]; then
    show_usage
    exit 1
fi

# Resolve to absolute path
if [[ "$TARGET_PROJECT" != /* ]]; then
    TARGET_PROJECT="$(cd "$TARGET_PROJECT" 2>/dev/null && pwd)" || {
        echo "Error: Target directory not found: $TARGET_PROJECT"
        exit 1
    }
fi

# Save target for future --update calls
save_target "$TARGET_PROJECT" "$NO_CLAUDE_MD"

# Run the setup
run_setup "$TARGET_PROJECT" "$NO_CLAUDE_MD"
