# Specification Summary: Creating Projects

> **Single Source of Truth**: See [README.md](./README.md) for complete feature details.

## Quick Reference

| Attribute | Value | Details |
|-----------|-------|---------|
| Classification | Level **A** | [README.md#classification](./README.md#classification) |
| ParatextData Reuse | 95% | [README.md#rationale](./README.md#rationale) |
| Effort | **Low to Medium** | [README.md#summary](./README.md#summary) |
| Strategy | **Full TDD** | [README.md#implementation-strategy](./README.md#implementation-strategy) |

## Counts

| Artifact | Count |
|----------|-------|
| Behaviors | 20 |
| Test Scenarios | 65 |
| Test Specifications | 85 |
| Property Tests | 23 |
| API Methods | 5 |
| Error Codes | 19 |
| Invariants | 7 |

## Detailed Artifacts

| Artifact | Description |
|----------|-------------|
| [README.md](./README.md) | **Canonical source** - classification, scope, strategy |
| [task-description.md](./task-description.md) | Original scope and non-goals |
| [Behavior Catalog](./behavior-catalog.md) | All 20 discovered behaviors |
| [Boundary Map](./boundary-map.md) | Architecture boundaries and data flow |
| [Data Contracts](./data-contracts.md) | API specifications (5 methods, TypeScript/C# types) |
| [Test Scenarios](./characterization/test-scenarios.json) | 65 test scenarios with property tests |
| [Test Specifications](./test-specifications/) | 85 specifications across 7 files |

## Test Specifications Overview

| Spec File | Focus Area | Specs | Property Tests |
|-----------|------------|-------|----------------|
| [spec-001](./test-specifications/spec-001-project-creation.json) | Project Creation | 7 | 3 |
| [spec-002](./test-specifications/spec-002-name-validation.json) | Name Validation | 21 | 5 |
| [spec-003](./test-specifications/spec-003-derived-projects.json) | Derived Projects | 13 | 3 |
| [spec-004](./test-specifications/spec-004-project-types.json) | Project Types | 10 | 2 |
| [spec-005](./test-specifications/spec-005-versioning.json) | Versioning/GUID | 9 | 4 |
| [spec-006](./test-specifications/spec-006-settings-persistence.json) | Settings | 15 | 3 |
| [spec-007](./test-specifications/spec-007-plugin-api.json) | Plugin API | 10 | 3 |

## API Methods

| Method | Purpose | Complexity |
|--------|---------|------------|
| `createProject` | Create new project with all settings | High |
| `validateProjectName` | Validate short name rules | Medium |
| `generateUniqueName` | Auto-generate unique name | Low |
| `generateAbbreviation` | Abbreviate full name to short | Low |
| `cancelProjectCreation` | Clean up cancelled creation | Medium |

## Invariants

| ID | Description | Enforcement |
|----|-------------|-------------|
| INV-001 | Unique project names (case-insensitive) | ScrTextCollection |
| INV-002 | Unique project GUIDs | VersioningManager |
| INV-003 | Directory matches short name | ScrText.Name |
| INV-004 | Derived projects require base | TranslationInformation |
| INV-005 | Resources cannot be versioned | VersionedText |
| INV-006 | Save before collection add | UpdateScrText flow |
| INV-007 | GUID required before collection add | ScrTextCollection.Add |

## Phase 3 Implementation Path

Based on Full TDD strategy:

1. **C# Service Layer** - IProjectCreationService wrapping ParatextData
2. **PAPI Commands** - createProject, validateProjectName, etc.
3. **TypeScript Types** - Input/output DTOs and type guards
4. **Integration Tests** - End-to-end validation

## Key ParatextData APIs

| API | Usage |
|-----|-------|
| `ScrText` | Core project creation and configuration |
| `ScrTextCollection` | Project registry and duplicate checking |
| `VersioningManager` | Mercurial init and GUID assignment |
| `TranslationInformation` | Project type and base project |
| `ParatextUtils.ValidateShortName` | Name validation rules |

## Stakeholder Questions

None at this time. All specifications are complete based on PT9 analysis.

## Next Steps

1. Proceed to **Phase 3: Implementation** with `/porting/phase-3-implementation creating-projects`
2. Alignment Agent will fill TBD placeholders for PT10 namespaces and locations
3. TDD Test Writer will create failing tests from specifications
4. TDD Implementer will implement code to pass tests

---

*Generated: 2026-01-04*
*Phase: 2 - Specification*
