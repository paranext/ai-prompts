# Scenario: Quotation Marks Checklist

## What This Tests

- Quote mark counting and comparison
- Quote settings validation
- Nested quote handling

## Expected Behavior

1. **Quote Detection**: Uses project's QuotationMarkInfo settings
2. **Comparison**: By count, not by text matching
3. **Filtering**: Verses without quotes in any column are excluded
4. **Nested Quotes**: Supports outer, inner, inner-inner levels

## Edge Cases Covered

- **EC-006**: Verses without quotes are excluded from results
- **VAL-003**: Quote settings must be complete before running

## Known Quirks

- Different quote characters per language/project
- Continuer marks (for continued quotes) counted separately
- If quote settings not complete, shows setup warning

## Invariants Verified

- **INV-001**: Row cell count equals column count

## Verification Notes

When comparing PT10 output:

1. **Settings validation**: Check quote settings complete
2. **Count comparison**: Verify comparison logic
3. **Filtering**: No-quote verses excluded

## PT10 Implementation Guidance

- Use QuotationMarkInfo for quote characters
- Use QuotationCheck or similar for counting
- Validate settings complete before proceeding
- Filter out verses with no quotes in any column
