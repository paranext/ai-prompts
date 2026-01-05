# Project Instructions

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Platform.Bible is extensible Bible translation software built on Electron with a TypeScript/React frontend and .NET 8 backend data provider. The core platform provides a minimal framework with functionality delivered primarily through extensions, giving developers flexibility to create and share their desired Bible translation experience.

## Tech Stack

| Layer              | Technology                            |
| ------------------ | ------------------------------------- |
| Desktop Framework  | Electron                              |
| Frontend           | React, TypeScript, SCSS, Tailwind CSS |
| Backend (Node)     | TypeScript, WebSocket (JSON-RPC 2.0)  |
| Backend (Data)     | .NET 8 / C#                           |
| Build System       | Webpack                               |
| Testing            | Vitest, Storybook                     |
| Package Management | npm workspaces (monorepo)             |

## Common Commands

### Development

```bash
# Start development (main command - runs all necessary processes)
npm start

# Build the entire project (TypeScript, extensions, .NET, types)
npm run build
```

### Testing

```bash
# Run all TypeScript tests
npm test

# Run single TypeScript test with watch mode
npm test -- path/to/test-file.test.ts --watch

# Run C# unit tests
cd c-sharp-tests
dotnet test

# Run C# tests with watch mode
cd c-sharp-tests
dotnet watch test
```

### Code Quality

```bash
# Format code (happens automatically on commit)
npm run format

# Lint TypeScript
npm run lint

# Fix linting issues automatically
npm run lint-fix

# Format C# code
cd c-sharp
dotnet tool restore
dotnet csharpier .

# Type checking
npm run typecheck
```

### Storybook

```bash
# Run Storybook for component development
npm run storybook

# Build Storybook
npm run storybook:build
```

### Packaging

```bash
# Package for distribution (creates installers)
npm run package
```

## Architecture

### Multi-Process Architecture

The application runs as four separate processes that communicate via JSON-RPC over WebSocket:

```
┌─────────────────────────────────────────────────────────┐
│                    Main Process (Electron)               │
│  • Window management & app lifecycle                     │
│  • Spawns and manages child processes                    │
└────────────────┬────────────────────────────────────────┘
                 │ JSON-RPC over WebSocket (port 8876)
    ┌────────────┼────────────┬───────────────────┐
    │            │            │                   │
┌───▼────────┐ ┌─▼──────────┐ ┌▼────────────────┐
│ Renderer   │ │ Extension  │ │ .NET Data       │
│ (React UI) │ │ Host       │ │ Provider        │
│            │ │            │ │                 │
│ • Web UI   │ │ • Loads    │ │ • Project data  │
│ • Dialogs  │ │  extensions│ │ • Paratext     │
│ • WebViews │ │ • PAPI     │ │   integration   │
└────────────┘ └────────────┘ └─────────────────┘
```

| Process            | Location              | Entry Point                   | Purpose                                             |
| ------------------ | --------------------- | ----------------------------- | --------------------------------------------------- |
| Main               | `src/main/`           | `main.ts`                     | App lifecycle, window management, system operations |
| Renderer           | `src/renderer/`       | `index.tsx`                   | React UI, PAPI hooks                                |
| Extension Host     | `src/extension-host/` | `extension-host.ts`           | Runs extensions, PAPI backend services              |
| .NET Data Provider | `c-sharp/`            | `ParanextDataProvider.csproj` | Paratext data access, Bible text operations         |

### Shared Code

- `src/shared/` - Code shared across all processes

  - Services, models, utilities
  - Core PAPI implementation
  - Network communication layer

- `src/node/` - Code shared between Node.js processes (main and extension host)
  - Node-specific utilities and polyfills

### Key Architectural Concepts

**PAPI (Platform API)**: The central API through which extensions interact with the platform and each other. Exposed as a global `papi` object in extensions.

**Network Services**: Communication between processes uses a custom network layer with request/response patterns over IPC/WebSockets.

**WebViews**: Extension UI components are React components (`.web-view.tsx`) or HTML (`.web-view.html`) that run in isolated contexts.

**Data Providers**: Extensions can register data providers that expose data to other extensions through standardized interfaces (Project Data Providers, etc.).

## Extension Development

Core extensions are in `extensions/src/`. Each extension folder contains:

- `package.json` - npm package metadata
- `manifest.json` - extension manifest with metadata and contribution points
- `src/main.ts` - extension entry point
- `src/types/<extension-name>.d.ts` - TypeScript declarations for extension API
- `assets/` - static assets, icons, descriptions
- `contributions/` - JSON files for menus, settings, etc.

Extensions are automatically bundled in two steps:

1. WebViews are bundled independently (with dependencies)
2. Main extension code is bundled (without external dependencies available via PAPI)

Key extension files to be aware of:

- **platform-scripture** - Core scripture display and editing
- **platform-scripture-editor** - Scripture editor UI
- **paratext-registration** - Paratext integration/auth
- **project-notes-data-provider** - Project notes functionality

## Library Packages

The repo includes reusable libraries in `lib/`:

- **papi-dts** - TypeScript type declarations for PAPI
- **platform-bible-react** - React components and hooks for extensions
- **platform-bible-utils** - Utility functions and classes

These are published independently and documented on GitHub Pages.

## Key Files and Locations

- `papi.d.ts` - Generated PAPI type definitions (see "JSDOC SOURCE/DESTINATION" pattern in README)
- `.erb/configs/` - Webpack configurations for different build targets
- `.vscode/launch.json` - Debug configurations for VS Code
- `electron-builder.json5` - Electron Builder packaging configuration

## Development Workflow

1. Changes to renderer or main TypeScript code hot-reload automatically when running `npm start`
2. Extension changes are watched and rebuilt automatically
3. .NET changes require manual rebuild or running `npm run start:data` in separate terminal
4. Use VS Code "Debug Platform" compound configuration to debug both frontend and backend

## Platform-Specific Notes

**Linux**: May need `--no-sandbox` flag for Electron on Ubuntu 24.04 with AppArmor. See README for setup.

**macOS**: Requires MacPorts with icu4c libraries. The .NET build automatically copies dylibs to output directory during development.

**Windows**: Use WSL2 for cross-platform testing. Follow WSL setup in README.

## TypeScript Configuration

The project uses path aliases defined in `tsconfig.json`:

- `@main/*` → `src/main/*`
- `@node/*` → `src/node/*`
- `@extension-host/*` → `src/extension-host/*`
- `@renderer/*` → `src/renderer/*`
- `@shared/*` → `src/shared/*`

## Testing Strategy

- **Unit tests** (Vitest): TypeScript logic and utilities
- **C# tests** (xUnit): .NET data provider functionality
- **Storybook**: Visual testing of React components
- **GitHub Actions**: Automated CI on push/PR for Windows, macOS, and Linux

## Important Development Patterns

### JSDOC SOURCE/DESTINATION Pattern

To propagate JSDoc comments in `papi.d.ts`:

- Add `/** JSDOC SOURCE serviceName */` at the definition
- Add `/** JSDOC DESTINATION serviceName */` where you want docs copied
- Build system automatically copies documentation between locations

### WebView Special Imports

- `import file from './path?inline'` - Imports file as string (transformed by Webpack)
- `import file from './path?raw'` - Imports file as raw string (no transformation)

### Avoiding Over-Engineering

Follow the principle of minimal necessary complexity:

- Don't add abstractions for single-use code
- Don't add error handling for impossible states
- Don't create configuration for hypothetical future needs
- Three similar lines of code is better than premature abstraction

## Security Considerations

Watch for common vulnerabilities:

- Command injection
- XSS in WebViews
- SQL injection in data providers
- Path traversal in file operations

## Version Management

- Use Node.js version specified in `package.json` → `volta.node` (recommend using Volta)
- Requires .NET 8 SDK
- Extensions and core must match version numbers for compatibility

## Debugging Tips

VS Code launch configurations available:

- "Debug Platform" - Debug both backend and renderer simultaneously
- "Debug .NET Core" - Attach to .NET data provider
- "Debug Extension Host" - Debug extension host process
- "Attach to Renderer" - Attach Chrome DevTools to renderer

## Extended Documentation

For detailed guidance, see the `.context/standards/` folder:

| Topic                 | File                                                                              | Key Content                                                      |
| --------------------- | --------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| Architecture          | [Architecture.md](.context/standards/Architecture.md)                             | Process communication, data providers, network objects, security |
| Code Style            | [Code-Style-Guide.md](.context/standards/Code-Style-Guide.md)                     | TypeScript/C# conventions, localization, components, shadcn/ui   |
| Code Review           | [Code-Review-Guide.md](.context/standards/Code-Review-Guide.md)                   | Reviewable workflow, code stewards, PR approval process          |
| Extension Development | [Extension-Development-Guide.md](.context/standards/Extension-Development-Guide.md) | Extension anatomy, PAPI, WebViews, contributions                 |
| Git & GitHub          | [Git-Guide.md](.context/standards/Git-Guide.md)                                   | Branch strategy, squash-merge, template merges                   |
| Implementation        | [Paranext-Core-Patterns.md](.context/standards/Paranext-Core-Patterns.md)         | C#/TypeScript patterns, naming conventions, test infrastructure  |
| Security              | [Security-Guide.md](.context/standards/Security-Guide.md)                         | CSP design, module restrictions, extension sandboxing            |
| Testing               | [Testing-Guide.md](.context/standards/Testing-Guide.md)                           | Vitest/NUnit, TDD, mocking, Storybook, CI pipeline               |

## Symlinked Directories

The `.claude/` and `.context/` directories are **symlinks** to a separate repository containing AI porting workflow artifacts. This affects tool behavior:

- **Glob tool**: May not find files in symlinked directories (e.g., `.claude/agents/*.md` returns empty)
- **Read tool**: Works normally once you have the file path
- **Workaround**: Use `ls` via Bash to list directory contents, then Read specific files:
  ```bash
  ls -la .claude/agents/
  ```

These directories contain:

- `.claude/agents/` - AI agent definitions for the porting workflow
- `.claude/commands/porting/` - Phase commands for feature migration
- `.context/features/` - Feature-specific artifacts (behavior catalogs, golden masters, contracts)
- `.context/standards/` - Coding standards and patterns documentation

## Links

- [PAPI Documentation](https://paranext.github.io/paranext-core/papi-dts)
- [React Components Docs](https://paranext.github.io/paranext-core/platform-bible-react)
- [Utilities Docs](https://paranext.github.io/paranext-core/platform-bible-utils)
- [Extension Template](https://github.com/paranext/paranext-extension-template/wiki)
