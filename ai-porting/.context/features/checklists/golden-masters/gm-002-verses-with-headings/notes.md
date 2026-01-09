# Scenario: Verses Checklist - With Section Headings

## What This Tests

- Verses checklist setting: showSectionHeadings=true
- Integration of section heading content into verse cells
- Proper handling of headings in poetry books (Psalms)
- Settings dialog and persistence

## Expected Behavior

1. **Setting Effect**: When showSectionHeadings=true, section heading text is included in the verse cell
2. **Heading Placement**: Heading text appears at the start of the cell content
3. **Visual Distinction**: Heading text should be visually distinct from verse text
4. **Psalms Handling**:
   - Regular section headings (\\s, \\s1) are included
   - Psalm superscriptions in verse 0 are still excluded (verse 0 rule applies)

## Edge Cases Covered

- Poetry book with potential multiple headings
- Psalms with superscriptions
- Stanza breaks (\\b) after headings

## Known Quirks

- Psalm superscriptions are stored in verse 0 in USFM, so they are excluded
- Some translations have section headings before each Psalm
- Stanza breaks after headings should be skipped when finding verse reference

## Invariants Verified

- **INV-001**: Row cell count equals column count (1 cell per row)

## Verification Notes

When comparing PT10 output:

1. **Setting toggle**: Verify showSectionHeadings can be toggled
2. **Content inclusion**: Heading text appears when setting is true
3. **Verse 0 exclusion**: Superscriptions still excluded
4. **Persistence**: Setting should persist across sessions

## PT10 Implementation Guidance

- Implement showSectionHeadings setting in VerseSettingsForm equivalent
- When true, include heading paragraph content in verse cell
- Use stylesheet to identify heading markers (scSection text type)
- Store setting in memento/settings storage
