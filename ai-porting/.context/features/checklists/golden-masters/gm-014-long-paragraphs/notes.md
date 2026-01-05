# Scenario: Long Paragraphs Checklist

## What This Tests

- Paragraph boundary detection
- Length-based sorting
- Non-heading paragraph filtering

## Expected Behavior

1. **Paragraph Detection**: Uses non-heading paragraph markers
2. **Exclusions**: Section headings excluded
3. **Scoring**: Score = paragraph length (characters)
4. **Max Results**: 100 longest paragraphs

## Known Quirks

- Uses stylesheet to identify paragraph markers
- Headings (scSection text type) are excluded
- Each paragraph gets its own cell

## Invariants Verified

- **INV-001**: Row cell count equals column count
- **POST-002**: Score-based sorting

## Verification Notes

When comparing PT10 output:

1. **Paragraph identification**: Non-heading markers
2. **Heading exclusion**: No section headings
3. **Sorting**: Longest first

## PT10 Implementation Guidance

- Use stylesheet to find paragraph markers
- Exclude markers with TextType == scSection
- Calculate length of each paragraph
- Sort descending and take top 100
