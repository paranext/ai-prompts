# Visual Verification Workflow

Detailed workflow for comparing PT10 implementation against PT9 golden masters.

## Pre-Verification Checklist

Before starting visual verification:

- [ ] Chrome MCP enabled (`claude --chrome`)
- [ ] Platform.Bible app running (`npm start`)
- [ ] Golden masters available in `.context/features/{feature}/golden-masters/`
- [ ] Feature implementation complete
- [ ] No TypeScript errors (`npm run typecheck`)
- [ ] Tests passing (`npm test`)

## Step-by-Step Verification

### Step 1: Load Golden Master Reference

1. Open the golden master directory:
   ```
   .context/features/{feature}/golden-masters/
   ```

2. Review each scenario:
   ```
   scenario-001/
   ├── screenshot.png      # PT9 visual reference
   ├── input.json          # Test data to reproduce
   └── metadata.json       # Scenario description
   ```

3. Note key visual elements to verify:
   - Layout structure
   - Component placement
   - Visual styling
   - Text content
   - Interactive elements

### Step 2: Prepare Test Data

If the golden master includes `input.json`:

1. Load the test data into the app
2. Or use the same data generation approach

Example `input.json`:
```json
{
  "projectId": "test-project-001",
  "books": ["GEN", "EXO"],
  "settings": {
    "showNotes": true,
    "fontSize": 14
  }
}
```

### Step 3: Navigate to Component

Using Chrome MCP:

```
Navigate to: http://localhost:1212/{route}
```

Wait for the component to fully render.

### Step 4: Capture Initial State

```
Take screenshot
```

Compare against `screenshot.png` from golden master.

### Step 5: Systematic Comparison

#### Layout Comparison

| Aspect | PT9 (Golden Master) | PT10 (Current) | Match? |
|--------|---------------------|----------------|--------|
| Header position | | | |
| Sidebar width | | | |
| Content area | | | |
| Footer | | | |

#### Component Comparison

| Component | PT9 | PT10 | Match? | Notes |
|-----------|-----|------|--------|-------|
| Buttons | | | | |
| Inputs | | | | |
| Lists | | | | |
| Tables | | | | |

#### Visual Style Comparison

| Style | PT9 | PT10 | Match? | Notes |
|-------|-----|------|--------|-------|
| Colors | | | | |
| Typography | | | | |
| Spacing | | | | |
| Borders | | | | |
| Icons | | | | |

### Step 6: Test Interactions

For each interactive element in the golden master:

1. **Identify the interaction** from behavior catalog
2. **Perform the action** using Chrome MCP:
   ```
   Click: button.action-button
   ```
3. **Capture result**:
   ```
   Take screenshot
   ```
4. **Check console** for errors:
   ```
   Read console
   ```
5. **Compare** to expected behavior

### Step 7: Test Edge Cases

Verify edge case handling matches PT9:

| Edge Case | Expected Behavior | Actual Behavior | Match? |
|-----------|-------------------|-----------------|--------|
| Empty data | | | |
| Single item | | | |
| Maximum items | | | |
| Invalid input | | | |
| Network error | | | |

### Step 8: Document Results

Create verification report:

```markdown
# Visual Verification Report: {Feature}

## Date: {date}
## Verifier: {agent/human}

## Summary
- Scenarios verified: {count}
- Matching: {count}
- Intentional differences: {count}
- Issues found: {count}

## Scenario Results

### Scenario 001: {Description}

**Golden Master**: scenario-001/screenshot.png
**PT10 Screenshot**: [attached]

**Comparison**:
- Layout: ✅ Matches
- Styling: ⚠️ Different colors (intentional - using Platform.Bible design system)
- Content: ✅ Matches
- Interactions: ✅ All working

**Console Output**: No errors

---

### Scenario 002: {Description}
...

## Intentional Differences

| Difference | Reason | Approved By |
|------------|--------|-------------|
| Button colors | Platform.Bible design system | Design team |
| Icon set | Using Lucide icons | Consistency |

## Issues Found

| Issue | Severity | Description | Resolution |
|-------|----------|-------------|------------|
| None | - | - | - |

## Conclusion

✅ Visual verification PASSED
```

## Common Issues and Resolutions

### Layout Mismatch

**Symptom**: Components in different positions

**Check**:
1. CSS flexbox/grid settings
2. Component order in JSX
3. Responsive breakpoints

**Resolution**: Adjust CSS to match PT9 layout

### Styling Differences

**Symptom**: Colors, fonts, spacing differ

**Check**:
1. Are differences intentional (design system)?
2. Are base styles applied?
3. Are theme variables correct?

**Resolution**:
- Intentional: Document and get approval
- Unintentional: Fix styling

### Missing Content

**Symptom**: Text or elements missing

**Check**:
1. Is data loading correctly?
2. Are conditional renders working?
3. Check console for errors

**Resolution**: Debug data flow

### Interaction Failure

**Symptom**: Click/action doesn't work

**Check**:
1. Event handlers attached?
2. PAPI calls working?
3. State updating correctly?

**Resolution**: Debug event handling

## Verification Approval

### Approval Criteria

For visual verification to pass:

1. **Layout**: Must match PT9 golden master structure
2. **Content**: Must display same data correctly
3. **Interactions**: Must behave identically to PT9
4. **Console**: No errors (warnings acceptable with justification)
5. **Differences**: All intentional differences documented and approved

### Approval Process

1. Complete verification report
2. Attach all screenshots
3. Document all differences
4. Get human approval for intentional differences
5. Update phase-status.md with verification results

### Rejection Criteria

Verification fails if:

- Layout fundamentally different without approval
- Content missing or incorrect
- Interactions broken
- Console errors present
- Undocumented differences exist
