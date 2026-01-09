# Checklists Golden Masters

## Overview

This directory contains golden masters for the Checklists feature (Level C - Pure UI).
These specifications document expected PT9 behavior that PT10 must replicate.

- **Total Golden Masters**: 20
- **Coverage**: All 13 checklist types + 7 cross-cutting scenarios
- **Created**: 2025-01-04

## Golden Masters Index

### Checklist Type Coverage

| Checklist Type | Golden Masters | Priority |
|----------------|----------------|----------|
| Verses | gm-001, gm-002, gm-003 | High |
| Section Headings | gm-004 | High |
| Book Titles | gm-005 | High |
| Footnotes | gm-006 | High |
| Cross References | gm-007, gm-008 | High |
| Markers | gm-009, gm-010 | High |
| Relatively Long Verses | gm-011 | High |
| Relatively Short Verses | gm-012 | High |
| Long Sentences | gm-013 | High |
| Long Paragraphs | gm-014 | High |
| Quotation Marks | gm-015 | High |
| Punctuation | gm-016 | High |
| Words/Phrases | gm-017 | High |

### Cross-Cutting Scenarios

| Scenario | Golden Master | Priority |
|----------|---------------|----------|
| Hide Matches | gm-018 | High |
| Versification Alignment | gm-019 | Critical |
| Verse Bridge Alignment | gm-020 | Critical |

## Detailed Index

### gm-001-verses-single-project
- **Type**: Verses
- **Scenario**: Single project display
- **Scenarios**: TS-038, TS-007, TS-040
- **Invariants**: INV-001, INV-003, POST-003
- **Priority**: High

### gm-002-verses-with-headings
- **Type**: Verses
- **Scenario**: Section headings setting enabled
- **Scenarios**: TS-039
- **Priority**: High

### gm-003-verses-multi-project
- **Type**: Verses
- **Scenario**: Multi-project comparison with cell alignment
- **Scenarios**: TS-008, TS-015, TS-069
- **Invariants**: INV-001, INV-004, INV-005
- **Priority**: High

### gm-004-section-headings
- **Type**: SectionHeadings
- **Scenario**: Section heading extraction with verse references
- **Scenarios**: TS-041, TS-042, TS-043
- **Edge Cases**: EC-003, EC-011
- **Priority**: High

### gm-005-book-titles
- **Type**: BookTitles
- **Scenario**: Book title extraction per book
- **Scenarios**: TS-044, TS-045
- **Edge Cases**: EC-004
- **Priority**: High

### gm-006-footnotes
- **Type**: Footnotes
- **Scenario**: Footnote content by verse
- **Scenarios**: TS-046
- **Priority**: High

### gm-007-cross-references
- **Type**: CrossReferences
- **Scenario**: Cross reference extraction without verse text
- **Scenarios**: TS-047, TS-048, TS-049, TS-050
- **Validations**: VAL-002
- **Edge Cases**: EC-008
- **Priority**: High

### gm-008-cross-refs-with-text
- **Type**: CrossReferences
- **Scenario**: Cross references with verse text displayed
- **Scenarios**: TS-027
- **Priority**: High

### gm-009-markers
- **Type**: Markers
- **Scenario**: Paragraph markers with content
- **Scenarios**: TS-051, TS-052
- **Priority**: High

### gm-010-markers-equivalent
- **Type**: Markers
- **Scenario**: Equivalent markers for comparison
- **Scenarios**: TS-053
- **Domain Constraints**: DC-007
- **Priority**: High

### gm-011-relatively-long-verses
- **Type**: RelativelyLongVerses
- **Scenario**: Top 100 verses with highest length ratio
- **Scenarios**: TS-054, TS-055, TS-056
- **Edge Cases**: EC-005
- **Preconditions**: PRE-005
- **Priority**: High

### gm-012-relatively-short-verses
- **Type**: RelativelyShortVerses
- **Scenario**: Top 100 verses with lowest length ratio
- **Scenarios**: TS-057
- **Priority**: High

### gm-013-long-sentences
- **Type**: LongSentences
- **Scenario**: Top 100 longest sentences
- **Scenarios**: TS-058, TS-059
- **Domain Constraints**: DC-002
- **Priority**: High

### gm-014-long-paragraphs
- **Type**: LongParagraphs
- **Scenario**: Top 100 longest paragraphs
- **Scenarios**: TS-060
- **Priority**: High

### gm-015-quotation-marks
- **Type**: QuotationDifferences
- **Scenario**: Quote count comparison between projects
- **Scenarios**: TS-061, TS-062, TS-063
- **Validations**: VAL-003
- **Edge Cases**: EC-006
- **Priority**: High

### gm-016-punctuation
- **Type**: Punctuation
- **Scenario**: Punctuation sequence comparison
- **Scenarios**: TS-064, TS-065
- **Priority**: High

### gm-017-words-phrases
- **Type**: WordsPhrases
- **Scenario**: Word/phrase search with highlighting
- **Scenarios**: TS-066, TS-067, TS-068
- **Priority**: High

### gm-018-hide-matches
- **Type**: Cross-cutting (any checklist type)
- **Scenario**: Hide Matches filtering feature
- **Scenarios**: TS-025, TS-026, TS-022
- **Priority**: High

### gm-019-versification-alignment
- **Type**: Cross-cutting (any checklist type)
- **Scenario**: Cross-versification cell alignment
- **Scenarios**: TS-071, TS-083
- **Invariants**: INV-004
- **Priority**: **CRITICAL**

### gm-020-verse-bridge
- **Type**: Cross-cutting (any checklist type)
- **Scenario**: Verse bridge cell merging
- **Scenarios**: TS-073
- **Edge Cases**: EC-002 (CRITICAL)
- **Domain Constraints**: DC-005
- **Priority**: **CRITICAL**

## File Structure

Each golden master directory contains:

```
gm-XXX-{name}/
  input.json           # Input specification
  expected-output.json # Expected output structure
  metadata.json        # Comparison configuration
  notes.md             # Context and implementation guidance
```

## Comparison Strategies

| Strategy | Description |
|----------|-------------|
| structural | Compare output structure (column count, row count) |
| exact | Exact content match (used sparingly) |
| semantic | Compare meaning, ignore formatting differences |

## Invariants Coverage

| Invariant | Coverage |
|-----------|----------|
| INV-001 | Row cell count equals column count | gm-001 through gm-020 |
| INV-002 | Max rows limit (5000) | Not golden-mastered |
| INV-003 | First cell reference required | gm-001, gm-004, gm-005 |
| INV-004 | Versification consistency | gm-003, gm-019 |
| INV-005 | No duplicate cells per row | gm-003 |

## Edge Cases Coverage

| Edge Case | Severity | Golden Master |
|-----------|----------|---------------|
| EC-001 | High | Not captured (behavior documented) |
| EC-002 | Critical | gm-020 |
| EC-003 | Medium | gm-004 |
| EC-004 | Low | gm-005 |
| EC-005 | High | gm-011 |
| EC-006 | Medium | gm-015 |
| EC-008 | Medium | gm-007 |
| EC-011 | High | gm-004 |

## Usage Notes

1. **These are behavioral specifications**, not captured PT9 outputs
2. Expected outputs describe structure and behavior, not exact content
3. PT10 implementation should match these specifications
4. Use metadata.json for comparison configuration when testing

## Next Steps

After golden masters are complete:
1. Contract Writer agent creates data-contracts.md
2. Alignment Agent maps to PT10 infrastructure
3. Component Builder implements React components
4. Equivalence Checker verifies against these golden masters
