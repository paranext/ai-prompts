# Scenario: Markers Checklist - Equivalent Markers

## What This Tests

- Equivalent markers configuration
- Marker comparison with equivalence groups
- Settings dialog for markers

## Expected Behavior

1. **Equivalence Format**: "p/m,s/s1" means p=m and s=s1
2. **Comparison Effect**: When Hide Matches is used, equivalent markers match
3. **Display**: Actual marker shown, not equivalence group name

## Edge Cases Covered

- **DC-007**: Different marker styles that are semantically equivalent

## Known Quirks

- Common equivalences: p/m (normal paragraph), s/s1 (section heading levels)
- Equivalence only affects matching, not display
- Multiple pairs separated by commas

## Invariants Verified

- **INV-001**: Row cell count equals column count

## Verification Notes

When comparing PT10 output:

1. **Settings parsing**: Correctly parse equivalence string
2. **Match logic**: Equivalent markers treated as equal
3. **Display**: Actual marker shown in cell

## PT10 Implementation Guidance

- Parse equivalentMarkers string into equivalence groups
- When comparing for Hide Matches, check if markers are in same group
- Store setting via MarkerSettingsForm equivalent
