# Scenario: Relatively Short Verses Checklist

## What This Tests

- Inverse relative length comparison
- Finding verses that are short in target relative to source

## Expected Behavior

1. **Score Calculation**: Score = source verse length / target verse length
2. **Sorting**: Descending by score (shortest relative first)
3. **Max Results**: Limited to 100 results
4. **Missing Verse**: Missing target verse = infinity score

## Known Quirks

- Inverse of Relatively Long Verses checklist
- Same algorithm, different ratio direction
- Missing target verses appear first (target is empty = infinitely short)

## Invariants Verified

- **INV-001**: Row cell count equals column count
- **POST-002**: Score-based sorting

## Verification Notes

When comparing PT10 output:

1. **Score formula**: Inverse of Long Verses
2. **Sort order**: Highest scores first
3. **Result limit**: 100 rows max

## PT10 Implementation Guidance

- Share logic with Relatively Long Verses
- Swap numerator/denominator in ratio calculation
- Same infinity handling for missing verses
