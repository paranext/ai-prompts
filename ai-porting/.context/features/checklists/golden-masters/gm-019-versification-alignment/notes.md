# Scenario: Versification Alignment

## What This Tests

- Cross-versification cell alignment
- Reference normalization to primary versification
- CLRowsBuilder algorithm
- Verse mapping between different versification systems

## Expected Behavior

1. **Reference Display**: All references in primary project's versification
2. **Verse Mapping**: Uses VerseRef and ScrVers APIs
3. **Cell Alignment**: CLRowsBuilder aligns cells correctly
4. **Empty Cells**: Verses that don't map show empty cells

## Edge Cases Covered

- **INV-004**: Critical versification consistency invariant

## Known Quirks

- Psalms have different verse numbers in different versifications
- Superscription handling varies
- Some verses may not have a mapping

## Invariants Verified

- **INV-004**: Versification consistency - cells aligned to same effective verse

## Verification Notes

When comparing PT10 output:

1. **Reference normalization**: Primary versification used
2. **Mapping accuracy**: Correct verse content in cells
3. **Empty cell handling**: Unmapped verses
4. **Psalm testing**: Good test case for differences

## PT10 Implementation Guidance

- Use ParatextData VerseRef for reference handling
- Use ScrVers for versification mapping
- Implement CLRowsBuilder equivalent for cell alignment
- Test with Psalms (superscription differences)
- Test with English vs. Septuagint versification

## CRITICAL

This is one of the most complex behaviors in the checklists feature.
The CLRowsBuilder algorithm must be carefully reimplemented.
Test thoroughly with different versification combinations.
