# Creating Projects - Task Description

> This task must comply with the [Porting Constitution](../../Constitution.md).

## 1. Feature Overview

| Field              | Value            |
| ------------------ | ---------------- |
| Feature Name       | Creating Projects |
| Level              | A                |
| ParatextData Reuse | 95%              |
| Priority           | 1 (Low effort)   |

## 2. Goals & Non-Goals

### Goals

- Enable creation of new translation projects in PT10
- Support derived project types (back translations, study Bibles)
- Persist project settings and initialize Mercurial repository

### Non-Goals (Explicit)

- Resource project creation (not user-creatable)
- Project migration/import from other formats
- Advanced project templates beyond PT9 capabilities

## 3. Legacy Context

| Field                 | Value                                  |
| --------------------- | -------------------------------------- |
| PT9 Code Files        | `ParatextData/ScrText.cs`, `ParatextData/ScrTextCollection.cs`, `Paratext/BackupRestore/RestoreForm.cs` |
| ParatextData APIs     | `ScrText`, `ScrTextCollection`, `ProjectSettings`, `VersioningManager` |
| Known Anti-Patterns   | WinForms wizard dialogs |
| Existing PT9 Tests    | TBD by Archaeologist |

## 4. PT10 Target

| Field                   | Value                              |
| ----------------------- | ---------------------------------- |
| Target Location         | `c-sharp/Projects/`, `extensions/src/` |
| Existing Infrastructure | `LocalParatextProjects`, `ParatextProjectDataProviderFactory`, `ProjectSettingsService` |
| Integration Points      | PAPI commands, Settings Service |

## 5. Edge Cases & Constraints

- GUID assignment and uniqueness via `VersioningManager`
- Derived project types require valid base project
- Project name validation (short name constraints)

## 6. Test & Verification Notes

- Golden masters: Settings.xml output for each project type
- Property tests: Project name validation rules, GUID uniqueness
- Manual verification: Project wizard flow, derived project linking

## 7. Reviewer Notes

| Field                   | Value |
| ----------------------- | ----- |
| Human Reviewer          |       |
| Priority                | 1     |
| Additional Instructions |       |
