# S/R Conflict Resolution - Task Description

> This task must comply with the [Porting Constitution](../../Constitution.md).

## 1. Feature Overview

| Field              | Value            |
| ------------------ | ---------------- |
| Feature Name       | S/R Conflict Resolution |
| Level              | B                |
| ParatextData Reuse | 70%              |
| Priority           | 6 (High effort)  |

## 2. Goals & Non-Goals

### Goals

- Handle merge conflicts when multiple users edit the same scripture text
- Provide "Compare Versions" dialog for viewing differences
- Support conflict resolution actions (accept, replace, manual merge)
- Store conflicts as project comments with status tracking

### Non-Goals (Explicit)

- Send/Receive orchestration (separate concern)
- Internet/ChorusHub sync mechanisms
- Non-scripture file conflict resolution

## 3. Legacy Context

| Field                 | Value                                  |
| --------------------- | -------------------------------------- |
| PT9 Code Files        | `ParatextData/Repository/Mergers/BookFileMerger.cs`, `ParatextData/UsfmDiff/DiffToken.cs`, `Paratext/ToolsMenu/DifferencesToolForm.cs`, `ParatextBase/UsfmDiff/ScrDiffControl.cs` |
| ParatextData APIs     | `BookFileMerger`, `DiffToken`, `NoteConflictType`, `Comment` |
| Known Anti-Patterns   | WinForms two-pane diff viewer, MDI dialog forms |
| Existing PT9 Tests    | TBD by Archaeologist |

## 4. PT10 Target

| Field                   | Value                              |
| ----------------------- | ---------------------------------- |
| Target Location         | `c-sharp/Services/`, `extensions/src/` |
| Existing Infrastructure | `ParatextProjectDataProvider` (comments API complete, thread management) |
| Integration Points      | PAPI commands, comment data provider, web-based diff viewer |

## 5. Edge Cases & Constraints

- Seven conflict types (VerseTextConflict, InvalidVerses, VerseBridgeDifferences, etc.)
- Three-way merge: parent, mine, theirs
- Conflict metadata stored in `AcceptedChangeXml`

## 6. Test & Verification Notes

- Golden masters: Merge output for various conflict scenarios, diff token output
- Property tests: Three-way merge determinism, conflict detection accuracy
- Manual verification: Diff viewer rendering, resolution workflow

## 7. Reviewer Notes

| Field                   | Value |
| ----------------------- | ----- |
| Human Reviewer          |       |
| Priority                | 6     |
| Additional Instructions | Most complex feature - significant UI requirements |
