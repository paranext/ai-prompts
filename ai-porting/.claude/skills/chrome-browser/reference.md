# Chrome Browser Reference

## Chrome MCP Overview

The Chrome MCP (Model Context Protocol) server provides Claude with tools to interact with a Chrome browser. This enables:

- Visual verification of UI components
- Console log inspection
- DOM manipulation and querying
- Automated interactions (click, type, scroll)
- Screenshot capture

## Launching with Chrome MCP

```bash
# Start Claude with Chrome integration
claude --chrome
```

This requires:
- Google Chrome browser (not Chromium alternatives)
- Claude in Chrome extension v1.0.36+
- Claude Code CLI v2.0.73+
- Paid Claude plan (Pro, Team, Enterprise)

## Available Tools

### Navigation

| Tool | Purpose | Example |
|------|---------|---------|
| Navigate | Open URL | `Navigate to http://localhost:1212` |
| Reload | Refresh page | `Reload the page` |
| Back | Go back | `Go back` |
| Forward | Go forward | `Go forward` |

### Screenshots

| Tool | Purpose | Notes |
|------|---------|-------|
| Screenshot | Capture visible area | Returns image for comparison |
| Full page screenshot | Capture entire page | Includes scrolled content |

### Console

| Tool | Purpose | Returns |
|------|---------|---------|
| Read console | Get console output | All console.log/warn/error |
| Clear console | Clear console | - |

### DOM Inspection

| Tool | Purpose | Example |
|------|---------|---------|
| Query | Find elements | `Query: button.primary` |
| Get text | Get element text | `Get text of: .title` |
| Get attribute | Get element attribute | `Get href of: a.link` |

### Interactions

| Tool | Purpose | Example |
|------|---------|---------|
| Click | Click element | `Click: button[type=submit]` |
| Type | Enter text | `Type "hello" into: input.search` |
| Scroll | Scroll page | `Scroll down 500px` |
| Hover | Hover element | `Hover over: .menu-item` |

### Window Management

| Tool | Purpose | Example |
|------|---------|---------|
| Resize | Change window size | `Resize to 1280x720` |
| Get size | Get current size | `Get window size` |

## Platform.Bible Specific Usage

### Target URL

Platform.Bible runs at:

```
Development: http://localhost:1212
```

### Important Routes

| Route | Purpose |
|-------|---------|
| `/` | Main application |
| `/settings` | Settings panel |
| `/project/{id}` | Project view |

### Common Selectors

Platform.Bible uses consistent patterns:

```css
/* Test IDs */
[data-testid="component-name"]

/* Component classes */
.papi-button
.papi-input
.papi-select

/* Layout sections */
#main-content
#sidebar
#toolbar
```

## Visual Verification Workflow

### Standard Process

```
1. Navigate → http://localhost:1212/{route}
2. Wait → Page fully loaded
3. Screenshot → Capture current state
4. Console → Check for errors
5. Compare → Against golden master
6. Document → Any differences
```

### Multiple States

Capture different component states:

| State | How to Trigger |
|-------|----------------|
| Default | Initial load |
| Loading | Before data loads |
| Populated | After data loads |
| Error | Trigger error condition |
| Empty | No data available |
| Selected | Click to select |
| Disabled | Disable condition |

### Responsive Testing

Test at different viewport sizes:

```
Resize to 1920x1080  # Desktop
Resize to 1366x768   # Laptop
Resize to 768x1024   # Tablet
```

## Console Output Interpretation

### Log Levels

| Level | Indicator | Action |
|-------|-----------|--------|
| Error | Red | Must fix before approval |
| Warning | Yellow | Should investigate |
| Info | Blue | Informational only |
| Debug | Gray | Development info |

### React-Specific Messages

| Message | Meaning | Fix |
|---------|---------|-----|
| "key" prop warning | Missing key in list | Add unique key |
| "validateDOMNesting" | Invalid HTML structure | Fix nesting |
| "Cannot update..." | State update during render | Move to useEffect |

### Network Messages

| Message | Meaning | Fix |
|---------|---------|-----|
| "Failed to fetch" | API call failed | Check endpoint |
| "WebSocket closed" | Connection lost | Restart app |
| "CORS error" | Cross-origin issue | Check server config |

## Debugging with Chrome MCP

### Find Why Element Missing

```
1. Query: .expected-element
   → If not found, check parent
2. Query: .parent-component
   → Check if parent exists
3. Screenshot
   → See actual rendered state
```

### Debug Event Handler

```
1. Console: Clear
2. Click: button.action
3. Console: Read
   → See what happened
```

### Track State Changes

```
1. Screenshot (before)
2. Click: .trigger-button
3. Wait 500ms
4. Screenshot (after)
5. Compare
```

## Limitations

### No Headless Mode

Chrome MCP requires a visible browser window. Cannot run in headless mode.

### Same Origin Only

Can only interact with pages on same origin as the current tab.

### Extension Required

The Claude in Chrome extension must be installed and active.

### Rate Limiting

Some operations may have rate limits to prevent abuse.

## Best Practices

### Screenshot Naming

Use descriptive names:
```
{component}-{state}-{viewport}.png
settings-panel-populated-desktop.png
project-list-empty-tablet.png
```

### Wait for Stability

Before screenshots:
- Wait for data to load
- Wait for animations to complete
- Wait for images to render

### Console Check Frequency

Check console:
- After initial navigation
- After each interaction
- Before final verification

### Document Everything

Record in verification report:
- Screenshots taken
- Console output reviewed
- Differences noted
- Approvals obtained
