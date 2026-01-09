# Specification Decisions: Creating Projects

**Date**: 2026-01-04
**Phase**: Phase 2 - Specification

## Decision 1: Skip UI Logic Extractor (Level A Classification)

**Agent**: Phase 2 Coordinator
**Context**: Determining whether to run the UI Logic Extractor subagent for this feature.

**Options Considered**:
1. Run UI Logic Extractor - Document all UI code for potential extraction
2. Skip UI Logic Extractor - Level A features don't have significant UI-embedded logic

**Decision**: Skip UI Logic Extractor
**Rationale**: This is a Level A feature with 95% ParatextData reuse. The UI Logic Extractor is only applicable to Level B features where business logic is embedded in the UI layer. In this feature:
- All core logic is in ParatextData (ScrText, ScrTextCollection, VersioningManager, etc.)
- UI layer (WinForms) is a thin wrapper for input collection and display
- No business logic needs extraction from UI

**Consequences**:
- No `ui-logic-extraction.md` artifact will be created
- Phase 3 will proceed directly with TDD against ParatextData APIs
- React UI will be simple form components with validation feedback

---

## Decision 2: Test Specifications Over Golden Masters

**Agent**: Spec Generator
**Context**: Choosing the appropriate specification strategy for a Level A feature.

**Options Considered**:
1. Golden masters - Capture PT9 outputs to compare against PT10
2. Test specifications - Define assertions against ParatextData API contracts
3. Hybrid - Both golden masters and specifications

**Decision**: Test Specifications (primary), minimal golden masters (documentation only)
**Rationale**: For Level A features, ParatextData.dll IS the oracle. The same binary runs in both PT9 and PT10, so:
- Output comparison is meaningless (same code produces same output)
- What matters is correct API usage and invariant enforcement
- Golden masters only useful for documenting Settings.xml format

**Consequences**:
- Created 85 test specifications across 7 files in `test-specifications/`
- Created 23 property test definitions for invariant verification
- Golden masters NOT created as primary test artifacts
- Phase 3 will write TDD tests from specifications, not comparison tests

---

## Decision 3: Full TDD Implementation Strategy

**Agent**: Contract Writer
**Context**: Determining the Phase 3 implementation approach based on code distribution.

**Options Considered**:
1. Full TDD - Test-driven development for all components
2. Hybrid - TDD for backend, Component-First for UI
3. Component-First - Visual-first development with tests after

**Decision**: Full TDD
**Rationale**:
- Level A classification with 95% ParatextData reuse
- Core logic is already implemented in ParatextData.dll
- PT10 work is primarily integration/wrapping, not new logic
- UI is minimal (form inputs with validation feedback)
- Well-defined API contracts enable test-first approach

**Consequences**:
- Phase 3 will start with TDD Test Writer creating failing tests
- Tests will target C# service layer, PAPI commands, and TypeScript types
- No Component Builder agent needed
- UI tests can be simple integration tests

---

## Decision 4: API Method Granularity

**Agent**: Contract Writer
**Context**: Deciding how to structure the PAPI command interface.

**Options Considered**:
1. Single createProject command with all parameters
2. Multiple commands: createProject + validateProjectName + generateUniqueName + generateAbbreviation
3. Single command with sub-operations

**Decision**: Multiple discrete commands (Option 2)
**Rationale**:
- Validation should be callable independently for real-time UI feedback
- Name generation utilities useful outside project creation
- Follows single-responsibility principle
- Matches existing PT9 behavior (separate validation and creation)

**Consequences**:
- 5 API methods defined: createProject, validateProjectName, generateUniqueName, generateAbbreviation, cancelProjectCreation
- Each method has clear input/output contract
- UI can call validation independently during form input
- More granular testing possible

---

## Decision 5: Error Code Strategy

**Agent**: Contract Writer
**Context**: Defining error handling approach for API methods.

**Options Considered**:
1. Generic error messages - Simple success/failure with message string
2. Semantic error codes - Typed error codes with structured data
3. Exception-based - Throw exceptions for error conditions

**Decision**: Semantic error codes with discriminated union results
**Rationale**:
- TypeScript benefits from typed error handling
- UI needs specific error codes for localization
- Discriminated unions enable compile-time exhaustiveness checking
- Cleaner than exceptions for expected validation failures

**Consequences**:
- 19 error codes defined (NAME_TOO_SHORT, NAME_DUPLICATE, MISSING_BASE_PROJECT, etc.)
- CreateProjectResult is discriminated union: CreateProjectSuccess | CreateProjectError
- UI can pattern-match on error codes for specific handling
- Errors include both code and human-readable message

---

## Decision 6: TBD Placeholders for PT10 Alignment

**Agent**: Contract Writer
**Context**: Handling unknown PT10-specific details during Phase 2.

**Options Considered**:
1. Assume naming conventions - Guess namespace/location based on patterns
2. Leave blank - Empty fields to fill later
3. Use {TBD:description} placeholders - Explicit markers for Alignment Agent

**Decision**: Use {TBD:description} placeholders
**Rationale**:
- Makes it explicit what needs Phase 3 alignment
- Prevents incorrect assumptions about PT10 structure
- Alignment Agent can search for these markers
- Self-documenting what decisions remain

**Consequences**:
- Contracts include {TBD:CSharpNamespace}, {TBD:ExtensionName}, {TBD:CommandPrefix}
- Alignment Agent in Phase 3 will replace with actual values
- No premature decisions about PT10 architecture
- Clear delineation between spec (Phase 2) and implementation (Phase 3)

---

## Summary

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | Skip UI Logic Extractor | Level A - no UI-embedded logic |
| 2 | Test specs over golden masters | ParatextData is the oracle |
| 3 | Full TDD strategy | High ParatextData reuse, well-defined contracts |
| 4 | Multiple granular API methods | Real-time validation, single responsibility |
| 5 | Semantic error codes | Type safety, localization support |
| 6 | TBD placeholders | Explicit alignment markers for Phase 3 |
