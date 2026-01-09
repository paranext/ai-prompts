# Scenario: Book Titles Checklist

## What This Tests

- Book title extraction from USFM
- Proper marker type identification (scTitle text type)
- Reference assignment to book start
- Missing title handling

## Expected Behavior

1. **Marker Detection**: Uses stylesheet to find markers with `TextType == scTitle`
2. **Common Markers**: \\mt, \\mt1, \\mt2, \\mt3
3. **One Row Per Book**: Each book in range gets one row
4. **Reference**: Always points to start of book (e.g., GEN 1:1)
5. **Missing Title**: Shows localized "No Book Title Present" message

## Edge Cases Covered

- **EC-004**: Missing book title - explicit warning message shown

## Known Quirks

- DC-004: Even if range starts at GEN 3:1, the title lookup starts at GEN 1:1
- Multiple title markers (\\mt1, \\mt2) are combined into single cell
- Navigation takes you to start of book, not to title paragraphs

## Invariants Verified

- **INV-001**: Row cell count equals column count

## Verification Notes

When comparing PT10 output:

1. **Row count**: One row per book in range
2. **Reference**: All references point to book starts
3. **Missing handling**: Test with book lacking title markers
4. **Range independence**: Start of range doesn't affect title lookup

## PT10 Implementation Guidance

- Use `ScrStylesheet.GetTag(marker).TextType == ScrTextType.scTitle`
- Always iterate from beginning of each book
- Concatenate all scTitle paragraphs for each book
- Use localized string for missing title message
