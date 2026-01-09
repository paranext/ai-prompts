# Scenario: Verses Checklist - Single Project

## What This Tests

- Basic verses checklist functionality with a single project
- Verse content extraction from USFM tokens
- Row generation with verse references
- Navigation link generation
- Proper exclusion of verse 0 (introduction)

## Expected Behavior

1. **Row Generation**: Each verse in Genesis 1 (verses 1-31) generates one row
2. **Cell Content**: Each row contains exactly 1 cell with the verse text
3. **Reference Links**: Each reference is a clickable link in format `goto:GEN 1:X`
4. **Verse 0 Exclusion**: Even if the source has introduction text (verse 0), it is excluded (FB-29600)
5. **No Section Headings**: With showSectionHeadings=false, headings are stripped from content
6. **No Footnotes**: With showFootnotes=false, footnotes are stripped from content

## Edge Cases Covered

- **EC-013 Verse 0 Exclusion**: Introduction content is explicitly filtered out
- Genesis 1 is a straightforward chapter with no verse bridges

## Known Quirks

- PT9 uses XSLT transformation for HTML rendering - PT10 will use React
- Edit links only appear if user has edit permission for the book/chapter
- The window title format is "Verses for {ProjectName} {Range}"

## Invariants Verified

- **INV-001**: Single project = 1 cell per row (N projects = N cells)
- **INV-003**: Every row has a valid first cell reference
- **POST-003**: Rows are sorted by verse reference order

## Verification Notes

When comparing PT10 output to this golden master:

1. **Structure check**: Verify 31 rows, 1 cell per row
2. **Reference check**: All references are valid VerseRef objects
3. **Order check**: Rows appear in biblical order GEN 1:1 through GEN 1:31
4. **Exclusion check**: No verse 0 content appears
5. **Setting respect**: Section headings and footnotes are excluded

## PT10 Implementation Guidance

- Use ParatextData `ScrText.Parser.GetUsfmTokens()` for content extraction
- Filter tokens to exclude verse 0 (`verseNum == 0`)
- Implement `showSectionHeadings` and `showFootnotes` as content filters
- Generate React DataTable rows instead of HTML via XSLT
