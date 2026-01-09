# Parallel Passages - Task Description

> This task must comply with the [Porting Constitution](../../Constitution.md).

## 1. Feature Overview

| Field              | Value            |
| ------------------ | ---------------- |
| Feature Name       | Parallel Passages |
| Level              | B                |
| ParatextData Reuse | 40%              |
| Priority           | 5 (Medium-High effort) |

## 2. Goals & Non-Goals

### Goals

- Display biblical verses with similar/identical content across books
- Support passage types: NT-NT, NT-OT, OT-OT, Gospels
- Enable word-level parallelism highlighting with degree indicators
- Persist approval status per passage

### Non-Goals (Explicit)

- Creating/editing parallel passage definitions
- Custom parallelism detection algorithms
- Cross-project parallel passage comparison

## 3. Legacy Context

| Field                 | Value                                  |
| --------------------- | -------------------------------------- |
| PT9 Code Files        | `ParatextData/ParallelPassages/ParallelPassageStatus.cs`, `Paratext/ParallelPassages/ParallelPassagesTool.cs`, `Paratext/ParallelPassages/ParallelPassageView.xslt` |
| ParatextData APIs     | `ParallelPassageStatuses`, `PassageStates` |
| Known Anti-Patterns   | XSLT rendering (290 lines), complex UI data models |
| Existing PT9 Tests    | TBD by Archaeologist |

## 4. PT10 Target

| Field                   | Value                              |
| ----------------------- | ---------------------------------- |
| Target Location         | `c-sharp/Services/`, `extensions/src/platform-parallel-passages/` |
| Existing Infrastructure | None specific to parallel passages |
| Integration Points      | PAPI commands, `platform-bible-react` components, verse navigation |

## 5. Edge Cases & Constraints

- Pre-computed parallel data from `ParallelPassages/ParallelPassages.xml`
- Four degree-of-parallelism levels (None, CalculatedMatch, ExpertClose, ExpertExact)
- Five passage states (Unfinished, Outdated, Finished, MissingText, IgnoredBook)

## 6. Test & Verification Notes

- Golden masters: Parallel passage list output, status persistence XML
- Property tests: Status state transitions, passage filtering logic
- Manual verification: Word-level highlighting, degree color coding, navigation

## 7. Reviewer Notes

| Field                   | Value |
| ----------------------- | ----- |
| Human Reviewer          |       |
| Priority                | 5     |
| Additional Instructions |       |
