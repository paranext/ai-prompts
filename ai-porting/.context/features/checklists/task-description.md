# Checklists - Task Description

> This task must comply with the [Porting Constitution](../../Constitution.md).

## 1. Feature Overview

| Field              | Value            |
| ------------------ | ---------------- |
| Feature Name       | Checklists       |
| Level              | C                |
| ParatextData Reuse | 5%               |
| Priority           | 4 (High effort)  |

## 2. Goals & Non-Goals

### Goals

- Provide 13 checklist types for scripture quality assurance
- Generate tabular comparisons of scripture data across projects
- Support filtering, sorting, and navigation to verses

### Non-Goals (Explicit)

- Persisting checklist results (generated dynamically)
- Custom/user-defined checklist types
- Automated fixing of identified issues

## 3. Legacy Context

| Field                 | Value                                  |
| --------------------- | -------------------------------------- |
| PT9 Code Files        | `Paratext/Checklists/ChecklistsTool.cs`, `Paratext/Checklists/CLData.cs`, `Paratext/Checklists/CLDataSource.cs` |
| ParatextData APIs     | USFM parsing, versification (minimal direct use) |
| Known Anti-Patterns   | XSLT/HTML rendering pipeline, 13 data source subclasses |
| Existing PT9 Tests    | TBD by Archaeologist |

## 4. PT10 Target

| Field                   | Value                              |
| ----------------------- | ---------------------------------- |
| Target Location         | `c-sharp/Checks/`, `extensions/src/platform-checklists/` |
| Existing Infrastructure | `CheckRunner` (14 check types), `InventoryDataProvider` |
| Integration Points      | PAPI commands, `platform-bible-react` data table components |

## 5. Edge Cases & Constraints

- 13 checklist types with different data extraction logic
- Verse-level and paragraph-level comparisons
- Performance with large multi-project comparisons

## 6. Test & Verification Notes

- Golden masters: Checklist output for each of 13 types
- Property tests: Row/cell alignment across projects
- Manual verification: Table rendering, filtering, verse navigation

## 7. Reviewer Notes

| Field                   | Value |
| ----------------------- | ----- |
| Human Reviewer          |       |
| Priority                | 4     |
| Additional Instructions | Highest-effort feature due to 13 data source implementations |
