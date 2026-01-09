# Scenario: Verses Checklist - Multi-Project Comparison

## What This Tests

- Multi-project verse comparison functionality
- Column alignment across multiple projects
- Comparative text selection and display
- Cell alignment algorithm (CLRowsBuilder)

## Expected Behavior

1. **Column Structure**: Reference column + one column per project (4 columns total)
2. **Row Generation**: One row per verse in the range
3. **Cell Alignment**: All cells in a row correspond to the same verse reference
4. **Column Order**: Primary project first, then comparative texts in selection order

## Edge Cases Covered

- Projects with same versification (straightforward alignment)
- Multiple comparative texts

## Known Quirks

- Column headers use project short names
- Edit links only appear in primary project column if user has permission
- Reference uses primary project's versification

## Invariants Verified

- **INV-001**: Each row has exactly N cells (N = number of projects)
- **INV-004**: Versification consistency across columns
- **INV-005**: No duplicate cells per row

## Verification Notes

When comparing PT10 output:

1. **Structure check**: 4 columns, 10 rows
2. **Alignment check**: Each row has content from all 3 projects for same verse
3. **Order check**: Projects appear in correct column order
4. **Reference check**: References aligned to primary versification

## PT10 Implementation Guidance

- Use CLRowsBuilder equivalent for cell alignment
- Maintain project order from selection
- Primary project determines reference display
- Handle comparative text selection dialog
