---
name: log-inspector
description: "[paranext-core ONLY] Read and analyze Platform.Bible application logs including Electron (main, renderer, extension-host) and C# data provider logs. Use when debugging test failures, runtime errors, or unexpected behavior. NOT for use in PT9/legacy Paratext codebases."
allowed-tools: Bash, Read, Grep
---

# Log Inspector Skill

Read and analyze Platform.Bible application logs for debugging and troubleshooting.

## Quick Reference

| Action | Command |
|--------|---------|
| Recent errors | `grep -i "error\|exception" "$LOG_PATH" \| tail -20` |
| Watch live | `tail -f "$LOG_PATH"` |
| Filter by process | `grep "\[main\]" "$LOG_PATH"` |
| Last 50 lines | `tail -50 "$LOG_PATH"` |

## Log Locations

### Electron Logs (main, renderer, extension-host)

```bash
# macOS
LOG_PATH=~/Library/Logs/Platform.Bible/main.log

# Windows (PowerShell)
$LOG_PATH="$env:APPDATA\Platform.Bible\logs\main.log"

# Linux
LOG_PATH=~/.config/Platform.Bible/logs/main.log
```

### C# Data Provider Logs

The .NET data provider logs to console when running `npm run start:data`. For file-based logs:

```bash
# Check c-sharp directory for log files
ls -la c-sharp/ParanextDataProvider/logs/ 2>/dev/null || echo "No C# log directory"
```

## Viewing Logs

### Recent Errors

Find the most recent errors across all processes:

```bash
# macOS example
grep -iE "error|exception|fail" ~/Library/Logs/Platform.Bible/main.log | tail -30
```

### Watch Live Logs

Monitor logs in real-time while testing:

```bash
# macOS
tail -f ~/Library/Logs/Platform.Bible/main.log

# With highlighting (if `ccze` installed)
tail -f ~/Library/Logs/Platform.Bible/main.log | ccze -A
```

### Filter by Process Type

Platform.Bible logs include process tags:

| Tag | Process |
|-----|---------|
| `[main]` | Main Electron process |
| `[rend]` | Renderer process |
| `[exth]` | Extension host |
| `[unkn]` | Unknown/other |

```bash
# Only main process logs
grep "\[main\]" ~/Library/Logs/Platform.Bible/main.log

# Only renderer logs
grep "\[rend\]" ~/Library/Logs/Platform.Bible/main.log

# Only extension host
grep "\[exth\]" ~/Library/Logs/Platform.Bible/main.log
```

### Filter by Log Level

Log levels: `error`, `warn`, `info`, `verbose`, `debug`

```bash
# Only errors and warnings
grep -E "\[(error|warn)\]" ~/Library/Logs/Platform.Bible/main.log

# Debug messages (verbose)
grep "\[debug\]" ~/Library/Logs/Platform.Bible/main.log
```

### Search for Specific Patterns

```bash
# Find stack traces
grep -A 10 "Error:" ~/Library/Logs/Platform.Bible/main.log

# Find specific function/class
grep "DataProvider" ~/Library/Logs/Platform.Bible/main.log

# Find by timestamp (logs format: [YYYY-MM-DD HH:MM:SS.mmm])
grep "2025-12-31 14:" ~/Library/Logs/Platform.Bible/main.log
```

## Log Format

Platform.Bible uses `electron-log` with this format:

```
[YYYY-MM-DD HH:MM:SS.mmm] [level] [process] message [at function file.ts:line:col]
```

Example:
```
[2025-12-31 14:30:15.123] [error] [main] Failed to connect [at connect network.ts:45:8]
```

## Log Rotation

- **Max file size**: 3 MB before archiving
- **Archive count**: Up to 5 old log files
- **Archive naming**: `main.log.old-1`, `main.log.old-2`, etc.

To view older logs:
```bash
# List all log files
ls -la ~/Library/Logs/Platform.Bible/

# View previous log
cat ~/Library/Logs/Platform.Bible/main.log.old-1
```

## Debugging Workflows

### Test Failure Investigation

1. **Clear logs** (optional):
   ```bash
   echo "" > ~/Library/Logs/Platform.Bible/main.log
   ```

2. **Run the failing test**

3. **Check for errors**:
   ```bash
   grep -iE "error|exception" ~/Library/Logs/Platform.Bible/main.log
   ```

4. **Look for stack traces**:
   ```bash
   grep -A 20 "Error:" ~/Library/Logs/Platform.Bible/main.log
   ```

### Runtime Issue Investigation

1. **Start watching logs**:
   ```bash
   tail -f ~/Library/Logs/Platform.Bible/main.log
   ```

2. **Reproduce the issue in the app**

3. **Look for errors in the output**

4. **Search for specific component**:
   ```bash
   grep "ComponentName" ~/Library/Logs/Platform.Bible/main.log
   ```

### C# Data Provider Issues

When debugging .NET backend:

1. **Run data provider in foreground**:
   ```bash
   npm run start:data
   # Watch console output for errors
   ```

2. **Check for .NET exceptions**:
   ```bash
   # In the console output, look for:
   # - System.Exception
   # - Unhandled exception
   # - Stack trace lines starting with "at"
   ```

## Command-Line Log Level Override

When starting the app, override log verbosity:

```bash
# More verbose
npm start -- --logLevel=debug

# Less verbose (production-like)
npm start -- --logLevel=warn
```

## See Also

- [log-locations.md](log-locations.md) - Platform-specific paths
- [reference.md](reference.md) - Log format details
- [app-runner skill](../app-runner/SKILL.md) - Start/stop the app
