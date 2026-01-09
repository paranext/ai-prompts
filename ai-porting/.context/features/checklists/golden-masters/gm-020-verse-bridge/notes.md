# Scenario: Verse Bridge Alignment

## What This Tests

- Verse bridge cell merging algorithm
- MAX_CELLS_TO_GRAB limit (3)
- Cell alignment across bridged and non-bridged content

## Expected Behavior

1. **Cell Merging**: ExpandGrabCountToAlignCells merges cells to align
2. **Max Merge**: Maximum 3 cells can be merged (DC-005)
3. **Alignment**: Bridged content aligns with merged separate verses
4. **Invariant**: Row still has correct cell count after merging

## Edge Cases Covered

- **EC-002**: Critical severity - verse bridges with different ranges

## Known Quirks

- MAX_CELLS_TO_GRAB = 3 prevents runaway merging
- If more than 3 cells would need merging, partial merge occurs
- Content from merged cells is concatenated

## Invariants Verified

- **INV-001**: Row cell count equals column count (still true after merge)

## Verification Notes

When comparing PT10 output:

1. **Merge limit**: Max 3 cells merged
2. **Alignment**: Content aligns correctly
3. **Row structure**: Cell count invariant maintained

## PT10 Implementation Guidance

- Implement ExpandGrabCountToAlignCells algorithm
- Constant MAX_CELLS_TO_GRAB = 3
- Merge cells when verse ranges don't align
- Concatenate content from merged cells
- Test with projects that have different bridging patterns

## CRITICAL

This is a CRITICAL edge case (EC-002).
The algorithm is complex and must be reimplemented carefully.
Incorrect implementation would break row alignment entirely.
