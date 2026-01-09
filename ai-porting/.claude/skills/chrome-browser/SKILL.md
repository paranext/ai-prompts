---
name: chrome-browser
description: "[paranext-core ONLY] Visual verification and console inspection for Platform.Bible UI using Chrome MCP. REQUIRED for Component Builder agent. Use to take screenshots, read console logs, inspect DOM, and verify UI matches golden masters. Requires 'claude --chrome' flag. NOT for use in PT9/legacy Paratext codebases."
---

# Chrome Browser Skill

Visual verification and console inspection for Platform.Bible using Chrome MCP.

## Prerequisites

**REQUIRED**: This skill requires Chrome MCP to be enabled:

```bash
claude --chrome
```

If you're running without `--chrome`, this skill will NOT work. The Component Builder agent requires this capability.

## Quick Reference

| Action | Tool |
|--------|------|
| Open URL | Navigate to localhost:1212 |
| Take screenshot | Screenshot tool |
| Read console | Console read tool |
| Inspect DOM | DOM query tool |
| Click element | Click tool |
| Type text | Type tool |

## Workflow: Visual Verification

### 1. Start the App

First, ensure Platform.Bible is running:

```bash
npm start
```

Wait for the app to be ready (localhost:1212 responding).

### 2. Navigate to Component

Use Chrome MCP to open the target URL:

```
Navigate to: http://localhost:1212
```

For specific routes:

```
Navigate to: http://localhost:1212/settings
Navigate to: http://localhost:1212/project/{projectId}
```

### 3. Take Screenshot

Capture the current view for comparison:

```
Take screenshot
```

Save the screenshot for comparison against golden masters in:
`.context/features/{feature}/golden-masters/`

### 4. Compare to Golden Master

Visual comparison checklist:

- [ ] Layout matches PT9 golden master
- [ ] Colors and styling correct
- [ ] Text content matches
- [ ] Icons and images present
- [ ] Spacing and alignment correct

### 5. Document Differences

If there are intentional differences from PT9, document them:

```markdown
## Visual Differences from PT9

1. **Button styling**: Using Platform.Bible design system colors
2. **Font**: Using system font instead of PT9 custom font
3. **Icons**: Using Lucide icons instead of PT9 custom icons
```

## Console Inspection

### Read Console Output

After navigating to the component:

```
Read browser console
```

### Look For

| Type | Indicates |
|------|-----------|
| `console.error` | Runtime errors - **must fix** |
| `console.warn` | Warnings - should investigate |
| React warnings | Component issues |
| Network errors | API/data problems |

### Common Console Issues

**React warnings**:
- "Each child in a list should have a unique 'key' prop"
- "Cannot update a component while rendering a different component"
- "Warning: validateDOMNesting"

**Network errors**:
- "Failed to fetch" - API endpoint issue
- "WebSocket connection failed" - PAPI connection issue

## DOM Inspection

### Query Elements

Check if expected elements exist:

```
Query: button[data-testid="save-button"]
Query: .project-list-item
Query: #main-content
```

### Verify Structure

Check component hierarchy:

```
Query: .settings-panel > .settings-section > .setting-item
```

## Interaction Testing

### Click Elements

```
Click: button[data-testid="submit"]
Click: .menu-item:first-child
```

### Type in Inputs

```
Type "test value" into: input[name="projectName"]
```

### Verify After Interaction

1. Take screenshot after action
2. Check console for errors
3. Verify DOM changes

## Integration with Component Builder

### Required Workflow for Component Builder Agent

1. **Verify Chrome MCP is available**
   - If not: Abort with error message

2. **Start app** (using app-runner skill)
   ```bash
   npm start
   ```

3. **Wait for ready**
   ```bash
   until curl -s http://localhost:1212 > /dev/null; do sleep 1; done
   ```

4. **Navigate to component under development**

5. **Take screenshot at each milestone**:
   - Initial render
   - Loading state
   - Populated state
   - Error state
   - After interactions

6. **Check console after each state**:
   - No React warnings
   - No JavaScript errors
   - No network failures

7. **Compare to golden masters**

8. **Document visual verification results**

## Golden Master Comparison

### Location

Golden masters are stored in:

```
.context/features/{feature}/golden-masters/
├── scenario-001/
│   ├── screenshot.png      # PT9 screenshot
│   ├── input.json          # Test data
│   └── metadata.json       # Scenario description
└── scenario-002/
    └── ...
```

### Comparison Process

1. Load PT9 golden master screenshot
2. Take screenshot of PT10 implementation
3. Compare visually:
   - Same layout structure?
   - Same visual hierarchy?
   - Same content?
4. Document any intentional differences

### Acceptable Differences

Some differences are expected between PT9 and PT10:

| Category | PT9 | PT10 | Acceptable? |
|----------|-----|------|-------------|
| Design system | WinForms | React + Tailwind | Yes |
| Icons | Custom | Lucide/shadcn | Yes |
| Fonts | MS fonts | System fonts | Yes |
| Behavior | Identical | Identical | Required |
| Data | Identical | Identical | Required |

## Troubleshooting

### Chrome MCP Not Available

Error: "Chrome MCP tools not found"

Solution: Restart Claude with Chrome flag:
```bash
claude --chrome
```

### App Not Responding

1. Check if app is running:
   ```bash
   curl -s http://localhost:1212
   ```

2. Start app if needed:
   ```bash
   npm start
   ```

3. Wait for ready, then retry

### Screenshot Fails

1. Ensure page has fully loaded
2. Wait for any animations to complete
3. Check for overlays/modals blocking content

## See Also

- [reference.md](reference.md) - Chrome MCP tool details
- [visual-verification.md](visual-verification.md) - Detailed verification workflow
- [app-runner skill](../app-runner/SKILL.md) - Start the app
- [log-inspector skill](../log-inspector/SKILL.md) - Debug issues
