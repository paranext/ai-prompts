# Scenario: Markers Checklist

## What This Tests

- Paragraph marker extraction from USFM
- Marker prefix display
- Verse merging within paragraphs

## Expected Behavior

1. **Marker Display**: Each cell shows \\marker prefix (e.g., "\\p In the beginning...")
2. **Paragraph Extraction**: All paragraph-style markers extracted
3. **Empty Filter**: Shows all paragraph markers
4. **Verse Merging**: Multiple verses in same paragraph combined

## Edge Cases Covered

- Various paragraph marker types (\\p, \\m, \\q1, \\q2, \\pi, etc.)

## Known Quirks

- Filter setting allows restricting to specific markers
- Equivalent markers setting is for comparison, not extraction

## Invariants Verified

- **INV-001**: Row cell count equals column count

## Verification Notes

When comparing PT10 output:

1. **Marker prefix**: Every cell starts with \\marker
2. **Filtering**: Empty filter shows all paragraphs
3. **Verse merging**: Multi-verse paragraphs have combined content

## PT10 Implementation Guidance

- Use stylesheet to identify paragraph markers
- Prepend marker name to cell content
- Merge verses within same paragraph
- Reference is first verse of paragraph
