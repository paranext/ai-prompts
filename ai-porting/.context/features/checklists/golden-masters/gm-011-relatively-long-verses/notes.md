# Scenario: Relatively Long Verses Checklist

## What This Tests

- Relative verse length comparison between projects
- Score calculation and sorting
- Missing verse handling with infinity score
- Result limiting

## Expected Behavior

1. **Score Calculation**: Score = target verse length / source verse length
2. **Sorting**: Descending by score (highest ratio first)
3. **Max Results**: Limited to 100 results (HighScoresOnly)
4. **Missing Verse**: Infinity score (1000000) ensures they appear first

## Edge Cases Covered

- **EC-005**: Empty/missing verse gets infinity score
- **PRE-005**: Requires at least two texts for comparison

## Known Quirks

- Must have at least two projects selected
- Section headings and footnotes excluded from length calculation
- Very short source verses can cause extremely high ratios

## Invariants Verified

- **INV-001**: Row cell count equals column count
- **POST-002**: Score-based sorting (descending)

## Verification Notes

When comparing PT10 output:

1. **Score calculation**: Verify ratio formula
2. **Sort order**: Highest scores first
3. **Missing handling**: Infinity score for missing verses
4. **Result limit**: Exactly 100 rows max

## PT10 Implementation Guidance

- Calculate length ratio for each verse
- Use 1000000F for missing verses (practical infinity)
- Sort descending by score
- Take top 100 results
- Exclude section headings and footnotes from length
