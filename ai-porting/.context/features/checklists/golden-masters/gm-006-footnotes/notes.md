# Scenario: Footnotes Checklist

## What This Tests

- Footnote extraction from USFM
- Proper filtering to include only \\f markers
- Exclusion of \\x cross-references
- Footnote content preservation

## Expected Behavior

1. **Marker Extraction**: Only \\f footnote markers are extracted
2. **Exclusion**: \\x cross-reference markers are handled by Cross References checklist
3. **Reference**: Points to verse containing the footnote
4. **Content**: Full footnote content including nested markers

## Edge Cases Covered

- None specific to this scenario
- Multiple footnotes per verse handled

## Known Quirks

- Footnotes and cross-references use similar USFM structure but different checklists
- Footnote callers (+ or * or letter) are preserved in content
- Multiple footnotes in same verse may appear as separate rows

## Invariants Verified

- **INV-001**: Row cell count equals column count

## Verification Notes

When comparing PT10 output:

1. **Marker filtering**: Only \\f markers appear, no \\x
2. **Content check**: Nested markers preserved
3. **Reference check**: References match verses with footnotes

## PT10 Implementation Guidance

- Use USFM token parsing to find \\f markers
- Exclude \\x markers (handled by Cross References)
- Preserve nested content (\\ft, \\fk, \\fq, etc.)
- Reference is current verse when footnote encountered
