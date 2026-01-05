# Specification Decisions: Checklists

**Date**: 2025-01-04
**Phase**: Phase 2 - Specification

## Decision 1: UI Logic Extractor Skipped

**Agent**: Phase 2 Orchestrator
**Context**: Level C features don't require logic extraction since there's no extractable business logic - it's all UI-layer code.

**Options Considered**:
1. Run UI Logic Extractor anyway - Unnecessary overhead, would document "no extraction needed"
2. Skip UI Logic Extractor - Appropriate for Level C classification

**Decision**: Skip UI Logic Extractor
**Rationale**: Checklists is Level C (95% UI layer). The "logic" is data extraction and presentation, not portable business rules. There's nothing to extract to pure functions.
**Consequences**: Phase 2 proceeds directly to Spec Generator.

---

## Decision 2: Golden Master Strategy - Structural vs Exact Comparison

**Agent**: Spec Generator
**Context**: Since we cannot run PT9 to capture actual outputs, we need to decide how to structure golden masters.

**Options Considered**:
1. **Exact content capture** - Would require running PT9 with test data
2. **Structural specification** - Document expected structure, column counts, behaviors

**Decision**: Structural specification with placeholder content
**Rationale**: We don't have access to run PT9. Golden masters document the expected structure and behavior patterns. Actual content verification will use structural comparison (row counts, cell counts, column structure) rather than exact content matching.
**Consequences**:
- Golden masters focus on structure, not exact verse content
- Comparison config uses "structural" mode
- Tests verify shape and behavior, not specific text

---

## Decision 3: Golden Master Coverage - All 13 Types

**Agent**: Spec Generator
**Context**: Need to decide which checklist types to prioritize for golden masters.

**Options Considered**:
1. **Selective coverage** - Pick 5-7 most critical types
2. **Complete coverage** - Create golden masters for all 13 types

**Decision**: Complete coverage (20 golden masters total)
**Rationale**: Each checklist type has distinct extraction logic. Missing coverage could lead to incorrect implementations. The additional 7 golden masters are worth the effort for a High complexity feature.
**Consequences**: 20 golden masters created covering all 13 types plus 3 cross-cutting scenarios.

---

## Decision 4: Critical Scenario Identification

**Agent**: Spec Generator
**Context**: Need to identify scenarios that are critical for correct behavior.

**Options Considered**:
1. Treat all scenarios equally
2. Elevate specific scenarios to CRITICAL status

**Decision**: Two scenarios elevated to CRITICAL:
- **gm-019 (Versification Alignment)** - INV-004 invariant
- **gm-020 (Verse Bridge)** - EC-002 edge case

**Rationale**: These scenarios involve the complex CLRowsBuilder algorithm and have high risk of incorrect implementation. Failure to match PT9 behavior would be a significant regression.
**Consequences**: CRITICAL scenarios must pass before Phase 3 is considered complete.

---

## Decision 5: Result Type Design - Discriminated Union

**Agent**: Contract Writer
**Context**: Need to design the result type for checklist operations.

**Options Considered**:
1. **Single type with optional error** - `{ data?: ChecklistData; error?: string }`
2. **Discriminated union** - `{ success: true; data: ... } | { success: false; error: ... }`
3. **Exception-based** - Throw on error, return data on success

**Decision**: Discriminated union with `success` boolean
**Rationale**: TypeScript can narrow types based on the discriminant, providing type-safe access to either data or error. This pattern is common in PAPI responses.
**Consequences**: All API methods use `ChecklistResult` type with success/failure discrimination.

---

## Decision 6: Cell Content Model - Structured vs String

**Agent**: Contract Writer
**Context**: Need to design how cell content is represented for React rendering.

**Options Considered**:
1. **HTML string** - `content: "<p>Verse text</p>"` - Like PT9's XSLT output
2. **Plain string** - `content: "Verse text"`
3. **Structured paragraphs** - `{ paragraphs: [{ items: [...] }] }`

**Decision**: Structured paragraphs with typed items
**Rationale**:
- Avoids HTML parsing in React
- Enables type-safe rendering
- Allows inline formatting (bold, italic) without dangerouslySetInnerHTML
- Replaces PT9's XSLT anti-pattern

**Consequences**: Cell content uses `ChecklistParagraph[]` with typed `ChecklistParagraphItem` union.

---

## Decision 7: Settings Type Hierarchy

**Agent**: Contract Writer
**Context**: Need to design settings types for 4 different settings dialog types.

**Options Considered**:
1. **Single flat type** - All settings in one object with optional fields
2. **Type per checklist** - 13 different settings types
3. **Base + specialized inheritance** - Common base with specialized extensions

**Decision**: Base type (`ChecklistSettingsBase`) + 5 specialized types
**Rationale**: Balances type safety with complexity. Checklist types that share settings can use the same specialized type. TypeScript can enforce required fields per checklist type.
**Consequences**:
- `ChecklistSettingsBase` (common fields)
- `WordsPhraseSettings`, `MarkersSettings`, `RelativeLengthSettings`, `QuotationSettings`, `LongTextSettings`

---

## Decision 8: Implementation Strategy - Component-First

**Agent**: Contract Writer
**Context**: Need to determine Phase 3 implementation approach based on Level C classification.

**Options Considered**:
1. **Full TDD** - Write tests first for all logic
2. **Component-First** - Build UI components iteratively with visual verification
3. **Hybrid** - TDD for some, Component-First for rest

**Decision**: Component-First
**Rationale**: Level C (95% UI) means most code is presentation logic. Visual verification is more effective than test-first for UI components. Golden masters provide the acceptance criteria.
**Consequences**: Phase 3 uses Component Builder agent, not TDD Test Writer.

---

## Summary

| Decision | Impact |
|----------|--------|
| Skip UI Logic Extractor | Faster Phase 2 |
| Structural golden masters | Tests verify behavior, not content |
| All 13 types covered | Complete test coverage |
| 2 CRITICAL scenarios | Clear priority for verification |
| Discriminated union results | Type-safe error handling |
| Structured cell content | Clean React rendering |
| Settings type hierarchy | Type-safe per-checklist settings |
| Component-First strategy | Appropriate for Level C |
