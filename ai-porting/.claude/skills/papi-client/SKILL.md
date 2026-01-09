---
name: papi-client
description: "[paranext-core ONLY] Send JSON-RPC requests to the Platform.Bible WebSocket API (PAPI). Use for service discovery, executing commands, querying project data, and debugging. Requires app to be running. NOT for use in PT9/legacy Paratext codebases."
allowed-tools: Bash, Read
---

# PAPI Client Skill

Send JSON-RPC requests to the Platform.Bible WebSocket API for debugging, testing, and automation.

## Prerequisites

This skill requires `websocat` for WebSocket communication:

```bash
# Check if available
which websocat || echo "websocat not found - please install"

# macOS
brew install websocat

# Linux (via cargo)
cargo install websocat
```

If `websocat` is not available, ask the user to install it before proceeding.

## Quick Reference

| Action | Command |
|--------|---------|
| Check if app running | `curl -s http://localhost:8876 > /dev/null && echo "Running" \|\| echo "Stopped"` |
| Discover all methods | `echo '{"jsonrpc":"2.0","id":1,"method":"rpc.discover","params":[]}' \| websocat ws://localhost:8876` |
| Get OS platform | `echo '{"jsonrpc":"2.0","id":1,"method":"command:platform.getOSPlatform","params":[]}' \| websocat ws://localhost:8876` |
| Get all projects | `echo '{"jsonrpc":"2.0","id":1,"method":"object:ProjectLookupService.getMetadataForAllProjects","params":[{}]}' \| websocat ws://localhost:8876` |
| Get log content | `echo '{"jsonrpc":"2.0","id":1,"method":"command:platform.getLogFileContent","params":[]}' \| websocat ws://localhost:8876` |

## Checking Connection

Always verify the app is running before sending requests:

```bash
# Quick check - WebSocket server available
curl -s http://localhost:8876 > /dev/null && echo "App running" || echo "Start app first with: npm start"

# Check if port is in use
lsof -i :8876
```

## Service Discovery

Discover all available methods dynamically using `rpc.discover`:

```bash
# Get all registered methods
echo '{"jsonrpc":"2.0","id":1,"method":"rpc.discover","params":[]}' | websocat ws://localhost:8876

# Count available methods
echo '{"jsonrpc":"2.0","id":1,"method":"rpc.discover","params":[]}' | websocat ws://localhost:8876 | jq '.result.methods | length'

# List all method names
echo '{"jsonrpc":"2.0","id":1,"method":"rpc.discover","params":[]}' | websocat ws://localhost:8876 | jq -r '.result.methods[].name'

# Find command methods only
echo '{"jsonrpc":"2.0","id":1,"method":"rpc.discover","params":[]}' | websocat ws://localhost:8876 | jq -r '.result.methods[].name | select(startswith("command:"))'
```

## Platform Commands

### Safe (Read-Only)

```bash
# Get OS platform ("win32", "darwin", "linux")
echo '{"jsonrpc":"2.0","id":1,"method":"command:platform.getOSPlatform","params":[]}' | websocat ws://localhost:8876

# Get current log file content
echo '{"jsonrpc":"2.0","id":1,"method":"command:platform.getLogFileContent","params":[]}' | websocat ws://localhost:8876

# Check if in full screen mode
echo '{"jsonrpc":"2.0","id":1,"method":"command:platform.isFullScreen","params":[]}' | websocat ws://localhost:8876
```

### UI Modification

```bash
# Increase zoom by 10%
echo '{"jsonrpc":"2.0","id":1,"method":"command:platform.zoomIn","params":[]}' | websocat ws://localhost:8876

# Decrease zoom by 10%
echo '{"jsonrpc":"2.0","id":1,"method":"command:platform.zoomOut","params":[]}' | websocat ws://localhost:8876
```

### Destructive Commands

**Use with caution - these affect the running application:**

```bash
# Restart extension host (extensions will reload)
echo '{"jsonrpc":"2.0","id":1,"method":"command:platform.restartExtensionHost","params":[]}' | websocat ws://localhost:8876

# Restart the entire application
echo '{"jsonrpc":"2.0","id":1,"method":"command:platform.restart","params":[]}' | websocat ws://localhost:8876

# Close the application
echo '{"jsonrpc":"2.0","id":1,"method":"command:platform.quit","params":[]}' | websocat ws://localhost:8876
```

## Network Object Queries

Query data from registered network objects:

```bash
# Get metadata for all projects
echo '{"jsonrpc":"2.0","id":1,"method":"object:ProjectLookupService.getMetadataForAllProjects","params":[{}]}' | websocat ws://localhost:8876

# Pretty print project list
echo '{"jsonrpc":"2.0","id":1,"method":"object:ProjectLookupService.getMetadataForAllProjects","params":[{}]}' | websocat ws://localhost:8876 | jq '.result'

# Get metadata for a specific project (replace <projectId>)
echo '{"jsonrpc":"2.0","id":1,"method":"object:ProjectLookupService.getMetadataForProject","params":["<projectId>"]}' | websocat ws://localhost:8876
```

## Response Handling

### Success Response

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": <data>
}
```

Extract the result with `jq`:
```bash
... | websocat ws://localhost:8876 | jq '.result'
```

### Error Response

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {
    "code": -32601,
    "message": "Method not found"
  }
}
```

Check for errors:
```bash
... | websocat ws://localhost:8876 | jq 'if .error then "Error: " + .error.message else .result end'
```

## Common Workflows

### Debug Project Discovery

```bash
# 1. Verify app is running
curl -s http://localhost:8876 > /dev/null && echo "App running" || exit 1

# 2. Check how many methods are registered
echo '{"jsonrpc":"2.0","id":1,"method":"rpc.discover","params":[]}' | websocat ws://localhost:8876 | jq '.result.methods | length'

# 3. List all projects
echo '{"jsonrpc":"2.0","id":1,"method":"object:ProjectLookupService.getMetadataForAllProjects","params":[{}]}' | websocat ws://localhost:8876 | jq '.result'
```

### Check Application State

```bash
# Get platform info
echo '{"jsonrpc":"2.0","id":1,"method":"command:platform.getOSPlatform","params":[]}' | websocat ws://localhost:8876

# Get recent logs
echo '{"jsonrpc":"2.0","id":1,"method":"command:platform.getLogFileContent","params":[]}' | websocat ws://localhost:8876 | jq -r '.result' | tail -50
```

## Troubleshooting

### Connection Refused

```bash
# Check if app is running
ps aux | grep -E "(electron|ParanextDataProvider)" | grep -v grep

# Check if port 8876 is in use
lsof -i :8876

# Start the app if not running
npm start
```

### Method Not Found (-32601)

1. Use `rpc.discover` to see available methods
2. Check method name format: `category:directive`
3. Commands need `command:` prefix
4. Network objects need `object:` prefix

### Timeout / No Response

- Default timeout is 30 seconds
- Some operations may take longer during startup
- Ensure the app has fully initialized before sending requests

### websocat Not Found

Install websocat:
```bash
# macOS
brew install websocat

# Linux (requires Rust/cargo)
cargo install websocat

# Or download binary from: https://github.com/vi/websocat/releases
```

## See Also

- [reference.md](reference.md) - Protocol details and method catalog
- [app-runner skill](../app-runner/SKILL.md) - Start/stop the application
- [log-inspector skill](../log-inspector/SKILL.md) - Analyze application logs
