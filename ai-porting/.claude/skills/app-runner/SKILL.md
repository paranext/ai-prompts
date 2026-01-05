---
name: app-runner
description: "[paranext-core ONLY] Start, stop, and check status of Platform.Bible Electron app. Use when you need to run the app for visual verification, integration testing, or debugging. Supports full app or individual processes (renderer, main, data provider). NOT for use in PT9/legacy Paratext codebases."
allowed-tools: Bash, Read
---

# App Runner Skill

Manage the Platform.Bible Electron application lifecycle for development and testing.

## Quick Reference

| Action | Command |
|--------|---------|
| Start full app | `npm start` |
| Start renderer only | `npm run start:renderer` |
| Start main only | `npm run start:main` |
| Start data provider | `npm run start:data` |
| Check if running | `curl -s http://localhost:1212 > /dev/null && echo "Running" || echo "Stopped"` |
| Stop all processes | See Stop Commands below |

## Starting the App

### Full Application (All Processes)

Start all processes together - main, renderer, extension host, and webpack dev server:

```bash
npm start
```

**Wait for ready**: The app is ready when `http://localhost:1212` responds. This typically takes 30-60 seconds on first start.

```bash
# Wait for app to be ready (with timeout)
for i in {1..60}; do
  curl -s http://localhost:1212 > /dev/null && echo "App ready!" && break
  echo "Waiting for app... ($i/60)"
  sleep 1
done
```

### Individual Processes

For faster iteration, start only what you need:

**Renderer/UI only** (fastest for UI development):
```bash
npm run start:renderer
```

**Main process only**:
```bash
npm run start:main
```

**C# Data Provider only** (run in separate terminal):
```bash
npm run start:data
# Or with dotnet watch for auto-reload:
cd c-sharp && dotnet watch --project ParanextDataProvider.csproj
```

## Stopping the App

### Graceful Shutdown

Stop all Node.js and Electron processes related to Platform.Bible:

```bash
# macOS/Linux
pkill -f "electron.*paranext" 2>/dev/null
pkill -f "node.*webpack.*paranext" 2>/dev/null
pkill -f "npm.*start" 2>/dev/null

# Also stop the .NET data provider if running
pkill -f "dotnet.*ParanextDataProvider" 2>/dev/null
```

### Force Kill (if graceful fails)

```bash
# Kill by port
lsof -ti:1212 | xargs kill -9 2>/dev/null  # Webpack dev server
lsof -ti:8876 | xargs kill -9 2>/dev/null  # WebSocket server
```

## Checking Status

### Is the App Running?

```bash
# Quick check - renderer available
curl -s http://localhost:1212 > /dev/null && echo "Renderer: Running" || echo "Renderer: Stopped"

# Check WebSocket server (main process)
curl -s http://localhost:8876 > /dev/null && echo "WebSocket: Running" || echo "WebSocket: Stopped"
```

### List Running Processes

```bash
# See all Platform.Bible related processes
ps aux | grep -E "(electron|webpack|paranext|ParanextDataProvider)" | grep -v grep
```

## Development Workflow

### Typical Component Development Flow

1. **Start the app**:
   ```bash
   npm start
   ```

2. **Wait for ready**:
   ```bash
   until curl -s http://localhost:1212 > /dev/null; do sleep 1; done
   echo "App ready for testing"
   ```

3. **Make changes** - Hot reload will apply TypeScript/React changes automatically

4. **When done, stop**:
   ```bash
   pkill -f "electron.*paranext"
   ```

### Fast UI Iteration

For faster feedback when only changing UI code:

```bash
# Terminal 1: Start just the renderer
npm run start:renderer

# Make UI changes - they hot reload instantly
# No need to restart for TypeScript/React changes
```

## Troubleshooting

### Port Already in Use

```bash
# Find what's using port 1212
lsof -i :1212

# Kill it
lsof -ti:1212 | xargs kill -9
```

### App Won't Start

1. Check for zombie processes:
   ```bash
   ps aux | grep -E "(electron|webpack)" | grep -v grep
   ```

2. Kill all and retry:
   ```bash
   pkill -f electron; pkill -f webpack; npm start
   ```

3. Check logs for errors - see `log-inspector` skill

## See Also

- [reference.md](reference.md) - Detailed process architecture
- [log-inspector skill](../log-inspector/SKILL.md) - Debug app issues via logs
