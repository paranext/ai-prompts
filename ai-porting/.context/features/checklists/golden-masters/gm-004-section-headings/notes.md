# Scenario: Section Headings Checklist

## What This Tests

- Section headings extraction from USFM
- Proper marker type identification (scSection text type)
- Reference assignment to following verse
- Edge cases for malformed USFM structure

## Expected Behavior

1. **Marker Detection**: Uses stylesheet to find markers with `TextType == scSection`
2. **Common Markers**: \\s, \\s1, \\s2, \\s3, \\sr, \\sp, \\sd, etc.
3. **NOT Included**: \\mt (titles), \\ms (major sections - varies by stylesheet)
4. **Reference**: Points to FIRST VERSE following the heading, not the heading itself

## Edge Cases Covered

- **EC-003**: Section heading before chapter marker - uses previous verse reference
- **EC-011**: Stanza break (\\b) or \\i* after heading - these are skipped

## Known Quirks

- The reference shown is the verse AFTER the heading, so navigation takes you there
- Poetry books often have headings followed by \\b markers that must be skipped
- FB-35863: Headings before \\c shouldn't get a reference beyond the chapter

## Invariants Verified

- **INV-001**: Row cell count equals column count
- **INV-003**: First cell reference required (from following verse)

## Verification Notes

When comparing PT10 output:

1. **Marker filtering**: Only scSection markers appear
2. **Reference check**: References are to following verses
3. **Edge case handling**: Test with poetry books for \\b handling
4. **FB-35863**: Test with heading before \\c marker

## PT10 Implementation Guidance

- Use `ScrStylesheet.GetTag(marker).TextType == ScrTextType.scSection`
- Implement FindVerseRefForParagraph logic:
  1. Find first non-heading paragraph after the heading
  2. Skip \\b and \\i* markers
  3. If next paragraph is beyond chapter marker, use previous verse
  4. Extract verse reference from that paragraph
