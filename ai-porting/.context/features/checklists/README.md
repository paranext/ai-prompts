# Checklists Feature

## Classification

| Field | Value |
|-------|-------|
| **Level** | C |
| **ParatextData Reuse** | 5% |
| **Testing Strategy** | Component-First with golden masters |
| **Effort** | High |

## Rationale

### Why Level C (Pure UI)

The Checklists feature is classified as Level C because:

1. **Minimal ParatextData usage (5%)**: ParatextData provides only foundational services:
   - USFM token parsing (`ScrText.Parser.GetUsfmTokens`)
   - Verse reference handling (`VerseRef`, `ScrVers`)
   - Character categorization (`CharacterCategorizer`)
   - Stylesheet access (`ScrStylesheet`)
   - Scripture reference parsing (`CrossReferenceScanner`)

2. **Heavy UI layer logic (95%)**: All checklist-specific logic resides in Paratext/ParatextBase:
   - 13 data source subclasses with distinct extraction algorithms
   - Row building and cell alignment across versifications
   - Score calculation for relative verse length comparisons
   - Match filtering and hiding algorithms
   - XML serialization and XSLT/HTML rendering pipeline
   - 4 settings dialogs for type-specific configuration

3. **No portable business logic**: Unlike features such as "Creating Projects" where project creation logic lives in ParatextData, checklists have no reusable business logic layer. The "logic" is the extraction and presentation of data for comparison purposes.

### Code Distribution

| Layer | Estimated Lines | Percentage |
|-------|----------------|------------|
| ParatextData (portable) | ~200 (API surface used) | 5% |
| Paratext UI (rewrite) | ~3500 | 95% |

### Key Classes Requiring Rewrite

- `ChecklistsTool` (~800 lines) - Main window and orchestration
- `CLDataSource` + 13 subclasses (~2000 lines) - Data extraction for each type
- `CLRowsBuilder` (~400 lines) - Cell alignment algorithm
- `CLData`, `CLRow`, `CLCell` (~300 lines) - Data model
- 4 Settings forms - Type-specific configuration UI

## Scope

### In Scope (from task-description.md)

- 13 checklist types for scripture quality assurance:
  1. Verse Text
  2. Words or Phrases
  3. Section Headings
  4. Book Titles
  5. Cross References
  6. Markers
  7. Footnotes
  8. Relatively Long Verses
  9. Relatively Short Verses
  10. Long Sentences
  11. Long Paragraphs
  12. Quotation Marks
  13. Punctuation
- Tabular comparisons across one or more projects
- Filtering, sorting, and navigation to verses
- Hide matches functionality for comparative analysis
- Settings persistence via memento system

### Out of Scope

- Persisting checklist results (generated dynamically)
- Custom/user-defined checklist types
- Automated fixing of identified issues

## Key Components

### ParatextData Layer (5% - Reusable via NuGet)

| Component | Purpose | Reuse Pattern |
|-----------|---------|---------------|
| `ScrText.Parser.GetUsfmTokens()` | USFM token stream | Direct API call |
| `VerseRef`, `ScrVers` | Versification mapping | Direct API call |
| `CharacterCategorizer` | Punctuation/character classification | Direct API call |
| `ScrStylesheet`, `ScrTag` | Marker type identification | Direct API call |
| `CrossReferenceScanner` | Scripture reference parsing | Direct API call |
| `QuotationMarkInfo` | Quote mark settings | Direct API call |
| `LexicalAnalyser` | Morphological matching | Direct API call |

### UI Layer (95% - Requires Rewrite)

| Component | Responsibility | Complexity |
|-----------|---------------|------------|
| `ChecklistsTool` | Window management, toolbar, settings | High |
| `CLDataSource` (base) | Factory, row building orchestration | High |
| 13 Data Source subclasses | Type-specific extraction algorithms | Very High |
| `CLRowsBuilder` | Cross-versification cell alignment | High |
| Data model (CLData, CLRow, CLCell, etc.) | XML serialization, display model | Medium |
| XSLT/CSS pipeline | HTML table rendering | Medium (anti-pattern) |
| 4 Settings forms | Type-specific configuration | Medium |

## Testing Approach

### Level C Testing Strategy: Component-First with Golden Masters

1. **Golden Masters for Each Checklist Type (13 total)**
   - Capture representative output for each checklist type
   - Include edge cases: verse bridges, missing verses, different versifications
   - Use consistent test projects with known content

2. **Critical Behaviors to Test**
   - Row alignment across projects with different versifications (INV-004)
   - Cell merging for verse bridges (EC-002, DC-005)
   - Hide matches filtering accuracy
   - Score-based sorting for relative length checklists
   - Settings persistence and restoration

3. **Edge Case Coverage**
   - Missing verse in comparative text (EC-001)
   - Section heading before chapter marker (EC-003, FB-35863)
   - Empty verse for relative length (EC-005)
   - Invalid cross reference parsing (EC-008)
   - Project removal during display (EC-009, EC-010)

4. **Property-Based Tests**
   - All rows have exactly N cells (INV-001)
   - Max rows limit enforced (INV-002)
   - Rows sorted by reference (POST-003)

5. **UI Component Tests**
   - Data table rendering with realistic datasets
   - Settings dialog state management
   - Navigation link generation and handling

### Golden Master Test Cases

| Checklist Type | Test Case | Focus |
|----------------|-----------|-------|
| Verses | Multi-project comparison | Cell alignment |
| Section Headings | Poetry book with stanza breaks | FB-24651 handling |
| Book Titles | Book with missing title | Missing title message |
| Cross References | Invalid reference | Error message display |
| Markers | Equivalent marker mapping | p/m equivalence |
| Relatively Long Verses | Score calculation | Sorting by ratio |
| Long Sentences | Sentence boundary detection | CharacterCategorizer usage |
| Quotation Marks | Different quote settings | Quote count comparison |
| Words/Phrases | Morphological matching | LexicalAnalyser usage |

## Effort Estimate

**Effort**: High

### Complexity Factors

1. **13 distinct data extraction algorithms**: Each checklist type has unique logic for extracting and formatting data from USFM. This is the highest contributor to complexity.

2. **Cross-versification alignment**: The `CLRowsBuilder` implements sophisticated logic for aligning cells from projects with different versification systems.

3. **Multiple settings dialogs**: Four different settings forms with type-specific configuration requirements.

4. **Rendering pipeline replacement**: The XSLT/HTML pipeline is an anti-pattern that needs replacement with modern React components.

5. **Integration with Biblical Terms**: The Words/Phrases checklist can be launched from Biblical Terms with pre-configured search strings.

### Risk Areas

- **Versification edge cases**: Verse bridges and different versification systems create complex alignment scenarios
- **Performance with large comparisons**: Multi-project comparisons over entire books may have performance implications
- **Fidelity of 13 implementations**: Each checklist type has nuanced behavior that must be preserved

### Dependencies

| Feature | Dependency Type | Notes |
|---------|-----------------|-------|
| USFM Parsing | Data (ParatextData) | Core functionality via NuGet |
| Versification | Data (ParatextData) | Verse reference mapping |
| Scripture Reference Settings | Data | Required for cross-reference parsing |
| Quote Settings | Data | Required for quotation mark comparison |
| Stylesheets | Data | Required for marker type identification |
| Main Window Navigation | UI | Navigate to verses from checklist |
| Biblical Terms | UI/API | Can launch Words/Phrases with search strings |

## Implementation Strategy

**Strategy**: Component-First

**Rationale**: Level C (Pure UI, 5% ParatextData reuse) - 95% of logic is UI layer. The checklist logic is data extraction and presentation, not portable business rules.

### Phase 3 Implementation Path

| Component | Approach | Priority |
|-----------|----------|----------|
| Checklist data model | New TypeScript types from data-contracts.md | High |
| Data extraction (13 types) | Rewrite in TypeScript/C# per type | High |
| Row builder / cell alignment | Rewrite CLRowsBuilder algorithm | High |
| Checklist table component | React component using platform-bible-react | High |
| Settings dialogs (4 types) | React dialogs | Medium |
| Toolbar | React toolbar component | Medium |
| Navigation/edit links | PAPI command integration | Medium |
| Print/export | Browser APIs | Low |

### ParatextData Direct Calls

For the 5% reuse, PT10 should call ParatextData APIs directly:

| ParatextData API | Usage |
|------------------|-------|
| `ScrText.Parser.GetUsfmTokens()` | USFM parsing for all checklist types |
| `VerseRef`, `ScrVers` | Versification mapping for cell alignment |
| `CharacterCategorizer` | Punctuation and sentence detection |
| `ScrStylesheet`, `ScrTag` | Marker type identification |
| `CrossReferenceScanner` | Cross-reference parsing |
| `QuotationMarkInfo` | Quote mark settings |
| `LexicalAnalyser` | Morphological matching for Words/Phrases |

### Anti-Patterns to Avoid

1. **XSLT/HTML rendering**: Replace with direct React component rendering
2. **XML serialization**: Use JSON/TypeScript objects throughout
3. **Windows Forms dialogs**: Replace with React dialogs
4. **CSSCreator**: Use Tailwind CSS from platform-bible-react

### Test Strategy

1. **Golden master tests**: Compare PT10 output structure against 20 golden masters
2. **Property-based tests**: Verify invariants (INV-001 through INV-006)
3. **Component tests**: React component behavior with realistic data
4. **Integration tests**: End-to-end checklist generation and display

## PT10 Integration Notes

_TBD: To be filled in by Alignment Agent in Phase 3_

- Target extension: _TBD_
- Related existing code in paranext-core: _TBD_
- Dependencies on existing PT10 services: _TBD_

## Phase 2 Artifacts

| Artifact | Status | Location |
|----------|--------|----------|
| Golden masters | Complete (20) | `golden-masters/` |
| Data contracts | Complete | `data-contracts.md` |
| Test scenarios | Complete (85) | `characterization/test-scenarios.json` |
| Edge cases | Complete (14) | `characterization/edge-cases.md` |
| Requirements | Complete | `characterization/requirements.md` |
