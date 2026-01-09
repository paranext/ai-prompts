# Scenario: Cross References Checklist

## What This Tests

- Cross-reference extraction from multiple USFM markers
- Scripture reference parsing using project settings
- Settings prerequisite validation
- Error handling for invalid references

## Expected Behavior

1. **Marker Extraction**: \\x, \\xt, \\r, \\mr, \\sr, \\ior, \\rq, \\fig references
2. **Parsing**: Uses CrossReferenceScanner and ParallelPassageReferenceScanner
3. **Settings Prerequisite**: VAL-002 - must have reviewed reference settings
4. **Error Display**: Invalid references show "There is an error in the reference"

## Edge Cases Covered

- **EC-008**: Invalid cross reference shows error message
- **DC-008**: Figure references from \\fig marker ref attributes

## Known Quirks

- Requires scripture reference settings to be reviewed first
- If settings not reviewed, throws SettingsHaveNotBeenReviewedException
- Figure references are extracted from the ref attribute of \\fig markers
- Footnote origin references (\\fr) can also contain references

## Invariants Verified

- **INV-001**: Row cell count equals column count

## Verification Notes

When comparing PT10 output:

1. **Settings check**: Must validate settings reviewed before display
2. **Marker coverage**: All reference marker types extracted
3. **Error handling**: Invalid references show error message
4. **Figure references**: Test with \\fig markers containing ref attribute

## PT10 Implementation Guidance

- Check `ReferenceSettingsHaveBeenReviewed` before proceeding
- Use `CrossReferenceScanner` for \\x and \\xt parsing
- Use `ParallelPassageReferenceScanner` for \\r, \\mr, \\sr, \\ior
- Extract ref attribute from \\fig markers
- Wrap parsing in try-catch to handle invalid references gracefully
