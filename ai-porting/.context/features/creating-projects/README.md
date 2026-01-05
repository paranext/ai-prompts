# Creating Projects

## Classification

| Field | Value |
|-------|-------|
| Level | **A** |
| ParatextData Reuse | **95%** |
| Confidence | **High** |

## Rationale

The Creating Projects feature is classified as **Level A (ParatextData-Heavy)** based on the following analysis:

### Code Distribution

| Layer | Components | Lines (Est.) | Reusability |
|-------|------------|--------------|-------------|
| ParatextData | 26 classes/enums | ~85% | Fully reusable |
| ParatextBase | 2 utilities | ~5% | Partially reusable |
| UI (WinForms) | 8 forms/controls | ~10% | Needs rewrite |

### Key Determining Factors

1. **Core Logic in Portable Layer**: All critical business logic resides in ParatextData:
   - `ScrText` - Core project representation and persistence
   - `ScrTextCollection` - Project registry and discovery
   - `ProjectSettings` - Settings serialization to Settings.xml
   - `VersioningManager` / `VersionedText` - Mercurial repository initialization and GUID assignment
   - `TranslationInformation` - Project type and base project relationships

2. **UI is Thin Wrapper**: The WinForms code primarily handles:
   - Dialog presentation and navigation
   - User input collection
   - Validation feedback display
   - Progress reporting

3. **ProjectPropertiesUtils Analysis**: The 8 methods in this mixed-layer utility are pure data operations:
   - `CreateDefaultBaseProject` - Sets default ScrText values
   - `InitializeScrTextWithDefaultValues` - Copies values from base project
   - `CalculateTranslationInfo` - Creates TranslationInformation object
   - `UpdateScrText` - Orchestrates save operations (calls ParatextData APIs)
   - `NextUnusedProjectName` - String manipulation with ScrTextCollection lookup
   - `CalcFileNamePostPart` - Pure string formatting
   - `MakeCopyOfBase` - Book copying via ScrText APIs
   - `UpdateCommentTags` - Tag persistence via CommentTags API

   All of these either directly call ParatextData APIs or perform simple data transformations that can be reimplemented in PT10.

4. **All Invariants Enforced by ParatextData**:
   - INV-001 (Unique names) - `ScrTextCollection`
   - INV-002 (Unique GUIDs) - `VersioningManager`
   - INV-004 (Derived require base) - `TranslationInformation`
   - INV-005 (Resources not versioned) - `VersionedText`

### Validation of Pre-Classification

The task-description.md pre-classified this as Level A (95% reuse). This analysis **confirms** that classification:

- The 20 behaviors documented in behavior-catalog.md map directly to ParatextData operations
- The 7 invariants in business-rules.md are all enforced at the ParatextData layer
- The data flow shows UI only collects inputs and displays results; all persistence goes through ParatextData

## Testing Strategy

Based on **Level A** classification, the testing approach focuses on direct API testing:

### Primary: ParatextData API Contract Tests

Test directly against ParatextData.dll APIs in PT10:

1. **ScrText Creation and Configuration**
   - Create new ScrText with default settings
   - Set project name, full name, language, versification
   - Verify Settings.xml serialization format

2. **Project Name Validation**
   - Test `ValidateShortName` with all validation rules (VAL-001 through VAL-006)
   - Property-based tests for valid character sets
   - Edge cases: reserved names, case collisions

3. **VersioningManager Integration**
   - Test GUID assignment via `EnsureHasGuid`
   - Test Mercurial repository initialization
   - Verify `.hg` directory structure

4. **Derived Project Types**
   - Test all `ProjectType` enum values
   - Verify `TranslationInformation` construction for each type
   - Test base project linking and license inheritance

5. **ScrTextCollection Operations**
   - Test `Add` operation with valid GUID
   - Test project discovery after add
   - Test duplicate name prevention

### Secondary: Specification-Based Tests

Create test specifications (not captured golden masters) for:

1. **Settings.xml Structure**
   - Document expected XML format for each project type
   - Verify required vs optional fields
   - Test encoding and normalization settings

2. **Project Directory Structure**
   - Expected files after creation (Settings.xml, .hg/, etc.)
   - File naming patterns per project type

### Property-Based Tests

Test invariants from business-rules.md:

```
Property: All project short names are unique (case-insensitive)
Property: All project GUIDs are globally unique
Property: Derived projects always have valid base project reference
Property: Project directory name always equals short name
```

### Minimal Golden Masters

Golden masters are NOT the primary strategy for Level A, but may be useful for:
- Settings.xml output format verification (as documentation, not test oracles)
- Complex edge cases with multiple interacting settings

## Implementation Approach

### Reusable Components (ParatextData)

The following can be used directly via ParatextData.dll NuGet reference:

| Component | Usage in PT10 |
|-----------|---------------|
| `ScrText` | Create and configure new projects |
| `ScrTextCollection` | Register projects, check for duplicates |
| `ProjectSettings` | All settings persistence |
| `VersioningManager` | Initialize Mercurial, assign GUID |
| `VersionedText` | Repository operations |
| `TranslationInformation` | Project type and base project |
| `ProjectType` enum | All project type definitions |
| `ProjectTypeExtensions` | Helper methods (IsDerivedType, etc.) |
| `LanguageId` | Language validation |
| `ScrVers` / `ScrVersType` | Versification schemes |
| `CommentTag` / `CommentTags` | Note tag management |
| All setting enums | ProjectNormalization, UsfmVersionOption, etc. |

### Code to Extract/Reimplement

These methods from `ProjectPropertiesUtils` need to be reimplemented in PT10 (not modified in PT9):

| Method | Complexity | Notes |
|--------|------------|-------|
| `CreateDefaultBaseProject` | Low | 10 lines of default value assignment |
| `InitializeScrTextWithDefaultValues` | Low | Copy ~10 properties from base |
| `NextUnusedProjectName` | Medium | Loop with ScrTextCollection lookup |
| `CalcFileNamePostPart` | Low | Simple string concatenation |
| `FormTextNameAbbrev` | Low | Word abbreviation algorithm (~30 lines) |

**Estimated effort**: 1-2 days of implementation

### UI to Rewrite (React)

The following WinForms components need React replacements:

| WinForms Component | PT10 Replacement |
|--------------------|------------------|
| `ProjectPropertiesForm` | Multi-step form or wizard component |
| `ProjectNameForm` | Text inputs with validation |
| `LanguageIDSelectionForm` | Language selector (likely existing) |
| `LanguageSettingsForm` | Font/writing system config |
| `ChooseEncodingForm` | Encoding dropdown |
| `BookChooserCtrl` | Book selection checkboxes |

**Note**: PT10 may already have some of these components. The Alignment Agent will identify existing infrastructure in Phase 3.

## Scope

### In Scope

- Standard translation project creation
- Back translation project creation
- Daughter translation project creation
- Study Bible project creation (additions and publication)
- Consultant notes project creation
- Project name validation
- Versification selection
- Language configuration
- Mercurial repository initialization
- GUID assignment

### Out of Scope

- Resource project creation (system-managed)
- Project import/migration from other formats
- Project deletion (separate feature)
- Project modification/renaming (separate workflow)
- Send/Receive operations (separate feature)

## Dependencies

### Features This Depends On

| Feature | Type | Required For |
|---------|------|--------------|
| User Authentication | Runtime | Must have logged-in user (not guest) |
| Language Management | Data | Valid BCP-47 language codes |
| Versification System | Data | ScrVers selection |
| Mercurial VCS | Runtime | Repository initialization |

### Features That Depend On This

| Feature | Type | Dependency |
|---------|------|------------|
| Send/Receive | Data | Projects must exist to sync |
| Project Notes | Data | Notes need project context |
| All Project Windows | UI | Projects must be created to open |
| Import/Export | Data | Target project must exist |

## PT10 Integration Notes (TBD - filled by Alignment Agent in Phase 3)

- Target extension: _TBD_
- Related existing code in paranext-core: _TBD_
- Dependencies on existing PT10 services: _TBD_

## Risk Assessment

### Low Risk Areas

1. **Core ParatextData APIs** - Well-tested, stable interfaces
2. **Project type handling** - Enum-based, straightforward
3. **Settings persistence** - XML serialization is mature

### Medium Risk Areas

1. **Mercurial integration** - May need process spawning or native bindings
2. **GUID calculation** - Depends on first commit hash; timing-sensitive
3. **Language settings** - LDML file handling complexity

### Potential Issues

1. **File system operations** - Cross-platform path handling
2. **Mercurial availability** - May need bundled Hg or alternative VCS
3. **Progress reporting** - Async patterns differ between WinForms and React

## Summary

Creating Projects is a **Level A** feature with **95% ParatextData reuse**. The implementation path is:

1. **Use ParatextData.dll directly** for all core operations
2. **Reimplement ~5 utility methods** from ProjectPropertiesUtils (~100 lines total)
3. **Build React UI** to collect user inputs and display validation
4. **Write API contract tests** against ParatextData operations
5. **Minimal golden masters** only for Settings.xml format documentation

**Estimated Total Effort**: Low to Medium
- Backend integration: 1-2 days
- UI development: 3-5 days (depending on existing components)
- Testing: 2-3 days

## Implementation Strategy

**Strategy**: Full TDD
**Rationale**: Level A feature with 95% ParatextData reuse. All core logic is in ParatextData.dll which will be used directly via .NET interop.

### Phase 3 Path

- [ ] TDD for: C# data provider service wrapping ParatextData operations
- [ ] TDD for: PAPI command handlers (createProject, validateProjectName, etc.)
- [ ] TDD for: TypeScript types and validation utilities
- [ ] Component-First for: N/A (minimal UI - form inputs with validation)

### Key Implementation Tasks

1. **C# Service Layer** (TDD)
   - `IProjectCreationService` implementation
   - ParatextData ScrText, ScrTextCollection, VersioningManager integration
   - DTO mapping between PAPI requests and ParatextData types

2. **PAPI Commands** (TDD)
   - `{TBD:ExtensionName}.createProject`
   - `{TBD:ExtensionName}.validateProjectName`
   - `{TBD:ExtensionName}.generateUniqueName`
   - `{TBD:ExtensionName}.generateAbbreviation`

3. **TypeScript Types**
   - Input/output type definitions
   - Enum mappings to ParatextData enums
   - Type guards and validation utilities

4. **Integration Tests**
   - End-to-end project creation flow
   - Validation rule coverage
   - Error handling and cleanup scenarios

### Dependencies on Existing Infrastructure

- ParatextData.dll (NuGet reference)
- Mercurial VCS (for repository initialization)
- File system access (project directory creation)
- User authentication (guest check)

### Not Needed (Level A)

- Golden master capture (specification-based tests instead)
- UI logic extraction (thin UI layer)
- Component-first development (form-based UI)
