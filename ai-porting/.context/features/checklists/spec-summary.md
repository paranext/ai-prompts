# Specification Summary: Checklists

> **Single Source of Truth**: See [README.md](./README.md) for complete feature details.

## Quick Reference

| Attribute | Value | Details |
|-----------|-------|---------|
| Classification | Level C | [README.md#classification](./README.md#classification) |
| Effort | High | [README.md#effort-estimate](./README.md#effort-estimate) |
| Strategy | Component-First | [README.md#implementation-strategy](./README.md#implementation-strategy) |

## Counts

| Artifact | Count |
|----------|-------|
| Behaviors | 25 (14 core + 11 type-specific) |
| Test Scenarios | 85 (52 high, 26 medium, 7 low priority) |
| Test Specifications | N/A (Level C) |
| Golden Masters | 20 (13 types + 3 cross-cutting) |
| API Methods | 3 |
| Types Defined | 24 |
| Invariants | 6 |

## Detailed Artifacts

| Artifact | Description |
|----------|-------------|
| [README.md](./README.md) | **Canonical source** - classification, scope, strategy |
| [Behavior Catalog](./behavior-catalog.md) | All discovered behaviors (25 total) |
| [Boundary Map](./boundary-map.md) | Architecture boundaries (5% ParatextData / 95% UI) |
| [Business Rules](./business-rules.md) | 28 business rules and invariants |
| [Data Contracts](./data-contracts.md) | API specifications (24 types, 3 methods) |
| [Test Scenarios](./characterization/test-scenarios.json) | 85 test scenarios with priorities |
| [Edge Cases](./characterization/edge-cases.md) | 14 edge cases with risk assessment |
| [Requirements](./characterization/requirements.md) | Non-functional requirements |
| [Golden Masters](./golden-masters/) | 20 captured output specifications |

## Golden Master Coverage

| Checklist Type | Golden Master(s) |
|----------------|------------------|
| Verses | gm-001, gm-002, gm-003 |
| Section Headings | gm-004 |
| Book Titles | gm-005 |
| Footnotes | gm-006 |
| Cross References | gm-007, gm-008 |
| Markers | gm-009, gm-010 |
| Relatively Long Verses | gm-011 |
| Relatively Short Verses | gm-012 |
| Long Sentences | gm-013 |
| Long Paragraphs | gm-014 |
| Quotation Marks | gm-015 |
| Punctuation | gm-016 |
| Words/Phrases | gm-017 |

### Cross-Cutting Scenarios

| Scenario | Golden Master | Priority |
|----------|---------------|----------|
| Hide Matches | gm-018 | High |
| Versification Alignment | gm-019 | **CRITICAL** |
| Verse Bridge Alignment | gm-020 | **CRITICAL** |

## Key Implementation Notes

1. **Component-First Strategy**: 95% UI layer requires React component development
2. **13 Extraction Algorithms**: Each checklist type has distinct data extraction logic
3. **Critical Algorithm**: CLRowsBuilder cell alignment (INV-004) - must preserve versification behavior
4. **Anti-Patterns to Replace**: XSLT/HTML pipeline -> React components

## Stakeholder Questions

1. **Biblical Terms Integration**: Should Words/Phrases checklist launch support be included in initial scope?
2. **Performance Requirements**: What is acceptable response time for large multi-project comparisons?
3. **Extension Placement**: Should checklists be a standalone extension or part of checking extension?

## Ready for Phase 3

All Phase 2 deliverables are complete:
- [x] Golden masters (20)
- [x] Data contracts
- [x] Implementation strategy documented
- [x] Test scenarios with traceability
