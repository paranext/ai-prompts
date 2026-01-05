# Scenario: Cross References Checklist - With Verse Text

## What This Tests

- showReferencedVerseText setting toggle
- Verse content fetching for references
- Display formatting with reference and content

## Expected Behavior

1. **Setting Toggle**: Show Verse Text button enables this mode
2. **Content Fetching**: Each referenced verse's content is retrieved
3. **Display**: Reference followed by the verse text content
4. **Invalid References**: Still show error message but no verse text

## Edge Cases Covered

- Missing referenced verses
- Invalid reference parsing

## Known Quirks

- Show Verse Text button only visible for CrossReferences and Markers checklists
- Verse text is from the SAME project, not a different source
- Performance may be slower when fetching many verse texts

## Invariants Verified

- **INV-001**: Row cell count equals column count

## Verification Notes

When comparing PT10 output:

1. **Setting toggle**: Verify button toggles the display
2. **Content inclusion**: Referenced verse text appears
3. **Performance**: May need optimization for large result sets

## PT10 Implementation Guidance

- Add Show Verse Text toggle button (only for CrossReferences, Markers)
- When enabled, fetch verse content for each parsed reference
- Cache verse content to avoid repeated fetches
- Handle missing verses gracefully
