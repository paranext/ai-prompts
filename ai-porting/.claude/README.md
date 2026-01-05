# Claude Code Configuration

This folder contains Claude Code configuration for the project. It is symlinked from a separate config repository to keep these files out of the main project's version control.

The configuration also includes a `.context` folder containing project-specific context for AI-assisted porting work: workflow guides, coding standards, architectural decisions, and implementation plans.

## Folder Structure

```
.claude/
├── README.md               # This file
├── settings.json           # Shared project configuration
├── settings.local.json     # Personal overrides (gitignored)
├── commands/               # Custom slash commands (user-invoked)
│   └── *.md
├── skills/                 # Claude skills (model-invoked)
│   └── skill-name/
│       ├── SKILL.md
│       └── ...
├── agents/                 # Custom subagents
│   └── *.md
└── rules/                  # Modular instruction files
    └── *.md

.context/
├── *.md                    # Workflow guides, overviews, coding standards
├── Decisions.md            # Cross-cutting decisions (affecting multiple features)
├── features/               # Feature requirements and artifacts
│   └── {feature}/          # Per-feature documentation
│       └── decisions/      # Feature-specific decisions by phase
│           └── phase-{N}-decisions.md
├── plans/                  # Implementation plans
│   └── *.md
└── standards/              # Coding and testing standards
```

## Files and Folders

### settings.json

Project-wide configuration including permissions, environment variables, and hooks. Applies to all team members.

[Documentation](https://docs.anthropic.com/en/docs/claude-code/settings)

### settings.local.json

Personal overrides that don't affect teammates. Automatically gitignored.

### commands/

Custom slash commands that you invoke explicitly by typing `/command-name`. Each `.md` file becomes a command.

Example: `commands/review.md` → invoke with `/review`

**Porting commands:** See [commands/porting/README.md](commands/porting/README.md) for the AI-assisted porting workflow.

[Documentation](https://docs.anthropic.com/en/docs/claude-code/slash-commands)

### skills/

Packaged expertise that Claude automatically applies when relevant. Each skill is a folder containing a `SKILL.md` file with YAML frontmatter, plus optional supporting files (templates, scripts, examples).

Skills are **model-invoked** — Claude decides when to use them based on context.

[Documentation](https://docs.anthropic.com/en/docs/claude-code/skills)

### agents/

Custom subagents (specialized AI assistants) that handle specific tasks independently with their own context. Each `.md` file defines an agent with its system prompt and tool permissions.

Agents are delegated to for complex tasks and operate in isolation from your main conversation.

[Documentation](https://docs.anthropic.com/en/docs/claude-code/sub-agents)

### rules/

Modular instruction files organized by topic. These are discovered recursively and loaded as additional context. Use this to break up a large CLAUDE.md into focused, maintainable files.

[Documentation](https://docs.anthropic.com/en/docs/claude-code/memory)

### Hooks (in settings.json)

Shell commands that execute automatically at specific points in Claude Code's lifecycle. Hooks provide deterministic control—ensuring certain actions always happen without relying on the model.

**Hook events:** `PreToolUse`, `PostToolUse`, `UserPromptSubmit`, `Notification`, `Stop`, `SubagentStop`, `PreCompact`, `SessionStart`, `SessionEnd`, `PermissionRequest`

Common uses: auto-formatting, custom notifications, compliance logging, protecting sensitive files.

[Documentation](https://docs.anthropic.com/en/docs/claude-code/hooks)

### .context/

Project-specific context for AI-assisted porting work. This folder provides Claude with background knowledge about the codebase, porting workflows, and project standards.

**Contents:**
- **Workflow guides** — Step-by-step processes (e.g., `AI-Porting-Workflow.md`)
- **Codebase overviews** — Architecture and structure documentation (e.g., `Paratext9-Overview.md`, `Paratext10-Overview.md`)
- **Coding standards** — Style guides and conventions (e.g., `Code-Style-Guide.md`, `Testing-Guide.md`)
- **features/** — Per-feature requirements, artifacts, and documentation (includes per-feature `decisions/` folder)
- **Decisions.md** — Cross-cutting decisions affecting multiple features
- **plans/** — Implementation plans for features being ported
- **standards/** — Coding and testing standards

## Related Files (Outside .claude/)

### CLAUDE.md

Project-level instructions and context loaded at startup. Can live at the repository root or inside `.claude/`.

Subdirectory `CLAUDE.md` files are also supported — they're loaded when working in or referencing files within that directory.

[Documentation](https://docs.anthropic.com/en/docs/claude-code/memory)

## Skills vs Commands vs Agents

| Type | Invocation | Best For |
|------|------------|----------|
| **Commands** | Manual (`/command`) | Quick prompts, simple instructions |
| **Skills** | Automatic (Claude decides) | Reusable patterns, packaged expertise |
| **Agents** | Delegated tasks | Complex work needing isolated context |

## Setup

This configuration is managed via symlinks from a separate repository. Run the setup script to link the config:

```bash
# For paranext-core (full setup with CLAUDE.md files)
./setup-claude.sh /path/to/paranext-core

# For legacy Paratext (without CLAUDE.md files)
./setup-claude.sh /path/to/paratext --no-claude-md

# After pulling updates, re-run for all saved targets
./setup-claude.sh --update
```

The script remembers configured targets. Use `--update` after `git pull` to refresh all symlinks.

Other options: `--list` (show saved targets), `--remove <path>` (remove a target).

**Gitignore entries for paranext-core:**
```
.claude
.context
CLAUDE.md
c-sharp/CLAUDE.md
src/extension-host/CLAUDE.md
lib/platform-bible-react/CLAUDE.md
extensions/CLAUDE.md
```

**Gitignore entries for legacy Paratext:**
```
.claude
.context
```

## More Information

- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [Memory & CLAUDE.md](https://docs.anthropic.com/en/docs/claude-code/memory)
- [Settings Reference](https://docs.anthropic.com/en/docs/claude-code/settings)
