# Scenario: Hide Matches Filtering

## What This Tests

- Hide Matches toggle functionality
- Row filtering based on cell matching
- Button visibility conditions
- Reset behavior on comparative text change

## Expected Behavior

1. **Filtering**: Rows where ALL cells match are removed
2. **Visibility**: Button only visible with comparative texts
3. **Reset**: hideMatches resets to false when comparative texts change
4. **Count**: Hidden row count shown to user

## Edge Cases Covered

- Button visibility without comparative texts
- State reset on comparative text change

## Known Quirks

- For Markers type, equivalent markers are considered matching
- Changing comparative texts resets the state
- Display shows count of hidden matches

## Invariants Verified

- **INV-001**: Row cell count equals column count

## Verification Notes

When comparing PT10 output:

1. **Toggle behavior**: On/off state toggle
2. **Filtering**: Only different rows shown
3. **Button visibility**: Hidden without comparative texts
4. **Reset**: State resets on comparative change

## PT10 Implementation Guidance

- Implement toggle button state
- Compare cell content for matching
- Track and display hidden count
- Reset state when comparative texts change
- For Markers, use equivalence groups for matching
