# Edge Cases: Checklists

## Summary

- Total edge cases identified: 14
- By severity: Critical (4), High (6), Medium (3), Low (1)
- All edge cases documented from business-rules.md with expanded reproduction steps and test coverage

---

## Edge Case: EC-001 Missing Verse in Comparative Text

### Scenario
A verse exists in the primary scripture text but does not exist in one or more comparative texts. This can occur due to:
- Different versification systems between projects
- Incomplete translation in the comparative project
- Variants in the source text (e.g., some verses only in certain manuscripts)

### Reproduction Steps
1. Open Verses checklist with a primary project
2. Add a comparative text that is missing verses (e.g., a project in draft state)
3. Select a verse range that includes verses missing in the comparative project
4. Observe the display

### Current Behavior
- An empty `CLCell` is placed in the column for the missing verse
- The row is still displayed with the primary project's content
- Row alignment is maintained across all columns
- No error message or warning is shown for the missing content

### Source
- Code location: `Paratext/Paratext/Checklists/CLRowsBuilder.cs:321`
- Method: `CLRowsBuilder.AddRowOfGrabbedCells()`

### Test Coverage
- Scenario ID: TS-072
- Golden master candidate: No
- Automated test feasibility: High

### Risk Assessment
- Likelihood of occurrence: High (common with draft projects or different versifications)
- Impact if behavior changes: High (would break comparative display alignment)
- Severity: **High**

### Notes
This is core functionality for the comparative checklist feature. Empty cells are intentional to maintain visual alignment and allow users to see where content is missing.

---

## Edge Case: EC-002 Verse Bridges with Different Ranges

### Scenario
The primary project has a verse bridge (e.g., verses 1-2 combined) while the comparative project has the verses separately (v.1, v.2), or vice versa.

### Reproduction Steps
1. Open Verses checklist with a primary project containing verse bridges
2. Add a comparative project that separates those verses
3. Select a range containing the bridge
4. Observe how cells are aligned

### Current Behavior
- `CLRowsBuilder.ExpandGrabCountToAlignCells()` merges cells up to `MAX_CELLS_TO_GRAB` (3) to align references
- When primary has v.1-2 bridge and comparative has v.1 and v.2:
  - Primary shows bridged content in one cell
  - Comparative cells for v.1 and v.2 are merged to align
- Maximum of 3 cells can be merged together to prevent excessive cell merging

### Source
- Code location: `Paratext/Paratext/Checklists/CLRowsBuilder.cs:142`
- Method: `CLRowsBuilder.ExpandGrabCountToAlignCells()`
- Constant: `CLRowsBuilder.MAX_CELLS_TO_GRAB = 3` at line 16

### Test Coverage
- Scenario ID: TS-073
- Golden master candidate: Yes
- Automated test feasibility: High

### Risk Assessment
- Likelihood of occurrence: Medium (common in certain books with numbering variants)
- Impact if behavior changes: Critical (would break row alignment entirely)
- Severity: **Critical**

### Notes
This is the most complex algorithm in the checklists feature. The `MAX_CELLS_TO_GRAB` limit of 3 prevents runaway merging when versifications are highly divergent. Domain constraint DC-005 codifies this limit.

---

## Edge Case: EC-003 Section Heading Before Chapter Marker

### Scenario
A user has incorrectly placed a section heading (`\s`, `\s1`, etc.) before the chapter marker (`\c`). This can happen when:
- User error during editing
- Imported text with structural issues
- Intentional placement for book introductions

### Reproduction Steps
1. Create a project with section heading placed before a chapter marker
2. Open Section Headings checklist
3. Observe the reference assigned to that heading

### Current Behavior
- The system uses the previous verse reference for the heading
- It does not go beyond the chapter marker to find the next verse
- For headings at the very beginning of a book (before \c 1), the reference will be the book start
- Related to FB-35863 bug fix

### Source
- Code location: `Paratext/Paratext/Checklists/CLParagraphCellsDataSource.cs:122`
- Method: `CLParagraphCellsDataSource.FindVerseRefForParagraph()`

### Test Coverage
- Scenario ID: TS-042
- Golden master candidate: No
- Automated test feasibility: Medium (requires specific test data)

### Risk Assessment
- Likelihood of occurrence: Low (uncommon but happens)
- Impact if behavior changes: Medium (would affect navigation from section headings)
- Severity: **Medium**

### Notes
This is a defensive behavior to handle malformed USFM. The original bug (FB-35863) caused incorrect verse navigation.

---

## Edge Case: EC-004 Missing Book Title

### Scenario
A book in the project has no title markers (`\mt`, `\mt1`, `\mt2`, etc.).

### Reproduction Steps
1. Create or select a project where a book is missing title markers
2. Open Book Titles checklist
3. Include that book in the verse range
4. Observe the display

### Current Behavior
- An explicit warning message "No Book Title Present" is displayed in the cell
- This is localized text, not an error condition
- The row is still displayed so users can see which books are missing titles

### Source
- Code location: `Paratext/Paratext/Checklists/CLParagraphCellsDataSource.cs:333`
- Method: `CLBookTitlesDataSource.GetCellsForBook()`

### Test Coverage
- Scenario ID: TS-045
- Golden master candidate: No
- Automated test feasibility: High

### Risk Assessment
- Likelihood of occurrence: Medium (common in new or partial projects)
- Impact if behavior changes: Low (informational message only)
- Severity: **Low**

### Notes
This is a helpful feature for identifying missing content during translation checking.

---

## Edge Case: EC-005 Empty Verse for Relative Length Comparison

### Scenario
In the Relatively Long Verses or Relatively Short Verses checklists, one text has content for a verse while the other text has no content (empty or missing verse).

### Reproduction Steps
1. Open Relatively Long Verses checklist
2. Select primary project and comparative project where one is missing some verses
3. Observe how missing verses are scored and ranked

### Current Behavior
- Score is set to infinity (1000000F) for verses missing in one project
- These verses appear at the TOP of the sorted list (most different)
- This ensures missing verses are immediately visible to the user
- Logic assumes that a verse present in one but not the other is maximally different

### Source
- Code location: `Paratext/Paratext/Checklists/CLVerseCellsDataSource.cs:155`
- Method: `CLVerseCellsDataSource.SetRowScore()`

### Test Coverage
- Scenario ID: TS-056
- Golden master candidate: No
- Automated test feasibility: High

### Risk Assessment
- Likelihood of occurrence: Medium (common with draft or partial translations)
- Impact if behavior changes: High (would change sort order significantly)
- Severity: **High**

### Notes
This is intentional behavior to surface missing content. The constant 1000000F is used as a practical infinity value.

---

## Edge Case: EC-006 No Quotes in Verse

### Scenario
In the Quotation Marks (QuotationDifferences) checklist, a verse has no quotation marks in any of the compared projects.

### Reproduction Steps
1. Open Quotation Marks checklist with multiple projects
2. Include verses that contain no quotation marks in any project
3. Observe which verses appear in the results

### Current Behavior
- Rows where no column has any quotation marks are marked for deletion
- The `PostProcessRows()` method removes these rows entirely
- Only verses with at least some quotation marks (in at least one project) are shown
- This prevents the list from being cluttered with irrelevant verses

### Source
- Code location: `Paratext/Paratext/Checklists/CLQuoteDiffsDataSource.cs:179`
- Method: `CLQuoteDiffsDataSource.PostProcessRows()`

### Test Coverage
- Scenario ID: TS-063
- Golden master candidate: No
- Automated test feasibility: High

### Risk Assessment
- Likelihood of occurrence: High (many verses have no quotes)
- Impact if behavior changes: Medium (would show many irrelevant rows)
- Severity: **Medium**

### Notes
This filtering is essential for usability. Without it, narrative passages would flood the display with empty comparisons.

---

## Edge Case: EC-007 URL Encoded Spaces

### Scenario
Navigation URLs in the checklist HTML contain URL-encoded spaces (`%20`) instead of actual space characters. This occurs with older browser rendering or certain verse reference formats.

### Reproduction Steps
1. Open any checklist
2. Click on a reference link for a book with space in the name (e.g., "1 Corinthians")
3. Observe that navigation succeeds despite encoded spaces

### Current Behavior
- The `MakeVerseRef()` method replaces `%20` with space characters before parsing
- Navigation proceeds with the decoded reference
- No error is shown to the user

### Source
- Code location: `Paratext/Paratext/Checklists/ChecklistsTool.cs:477`
- Method: `ChecklistsTool.MakeVerseRef()`

### Test Coverage
- Scenario ID: TS-017
- Golden master candidate: No
- Automated test feasibility: High

### Risk Assessment
- Likelihood of occurrence: Medium (depends on browser/rendering)
- Impact if behavior changes: High (would break navigation for some references)
- Severity: **High**

### Notes
This is a compatibility fix for varying browser behaviors. In PT10 with React rendering, this may not be needed but should be tested.

---

## Edge Case: EC-008 Invalid Cross Reference

### Scenario
A cross-reference text in the scripture cannot be parsed as a valid scripture reference. This can occur due to:
- Typos in the reference
- Non-standard abbreviations
- Malformed USFM

### Reproduction Steps
1. Create a project with an invalid cross-reference (e.g., `\x + \xt See XXX 99:99\x*`)
2. Open Cross References checklist
3. Observe how the invalid reference is displayed

### Current Behavior
- An error message is shown in the cell: "There is an error in the reference"
- The row is still displayed so users can identify the problem
- Processing continues for other valid references
- No exception is thrown

### Source
- Code location: `Paratext/Paratext/Checklists/CLNoteCellsDataSource.cs:193`
- Method: `CLCrossReferencesDataSource.PostProcessParagraph()`

### Test Coverage
- Scenario ID: TS-049
- Golden master candidate: No
- Automated test feasibility: High

### Risk Assessment
- Likelihood of occurrence: Low (requires malformed data)
- Impact if behavior changes: Medium (error visibility)
- Severity: **Medium**

### Notes
This error handling is important for data quality checking. Users rely on seeing these errors to fix their cross-references.

---

## Edge Case: EC-009 Comparative Project Removed

### Scenario
A comparative project is deleted from the ScrTextCollection while the checklist window is open.

### Reproduction Steps
1. Open Verses checklist with comparative texts selected
2. In another window, delete one of the comparative projects
3. Observe the checklist behavior

### Current Behavior
- The `ChangeListener` detects the project removal via WriteLockManager
- The removed project is removed from the comparative texts list
- The display is refreshed with the remaining projects
- No error message is shown
- Checklist continues to work with remaining projects

### Source
- Code location: `Paratext/Paratext/Checklists/ChecklistsTool.cs:237`
- Method: `ChecklistsTool.ChangeListener()`

### Test Coverage
- Scenario ID: TS-037
- Golden master candidate: No
- Automated test feasibility: Medium (requires simulating project deletion)

### Risk Assessment
- Likelihood of occurrence: Low (unusual workflow)
- Impact if behavior changes: High (could cause crashes or stale data)
- Severity: **High**

### Notes
This graceful handling is important for robustness. In PT10, this will need to be handled via subscription to project change events.

---

## Edge Case: EC-010 Primary Project Removed

### Scenario
The primary project (the one the checklist was opened for) is deleted while the checklist window is open.

### Reproduction Steps
1. Open Verses checklist for a project
2. In another window, delete that primary project
3. Observe the checklist behavior

### Current Behavior
- The `ChangeListener` detects the primary project removal
- The checklist window is closed automatically
- No error message is shown to the user
- Any unsaved state is lost (though checklists have no unsaved state)

### Source
- Code location: `Paratext/Paratext/Checklists/ChecklistsTool.cs:233`
- Method: `ChecklistsTool.ChangeListener()`

### Test Coverage
- Scenario ID: TS-036
- Golden master candidate: No
- Automated test feasibility: Medium (requires simulating project deletion)

### Risk Assessment
- Likelihood of occurrence: Very Low (unusual workflow)
- Impact if behavior changes: Critical (could cause crashes)
- Severity: **Critical**

### Notes
This is defensive coding to prevent crashes when the underlying project no longer exists. The window must close because all operations require a valid ScrText.

---

## Edge Case: EC-011 Stanza Break After Section Heading

### Scenario
In poetry books (Psalms, etc.), a stanza break (`\b`) or other formatting marker (`\i*`) follows a section heading. When determining the verse reference for the section heading, these markers should be skipped.

### Reproduction Steps
1. Create or use a project with section heading followed by `\b` marker
2. Open Section Headings checklist
3. Observe the reference assigned to that heading

### Current Behavior
- `\b` (blank line/stanza break) and `\i*` markers are skipped when finding the next non-heading paragraph
- The verse reference is taken from the first verse text following these markers
- This prevents incorrect reference assignment
- Related to FB-24651 bug fix

### Source
- Code location: `Paratext/Paratext/Checklists/CLParagraphCellsDataSource.cs:115`
- Method: `CLParagraphCellsDataSource.FindVerseRefForParagraph()`

### Test Coverage
- Scenario ID: TS-043
- Golden master candidate: No
- Automated test feasibility: Medium (requires specific test data)

### Risk Assessment
- Likelihood of occurrence: Medium (common in poetry books)
- Impact if behavior changes: Medium (incorrect references)
- Severity: **High**

### Notes
Poetry formatting is complex. This fix ensures proper handling of common poetry patterns.

---

## Edge Case: EC-012 LXX/HEB Special Project Names

### Scenario
Special resource project names like "LXX/GRK" and "HEB/GRK" need to be normalized when looking them up in the ScrTextCollection.

### Reproduction Steps
1. Open Verses checklist
2. Click "Comparative Texts" button
3. Select "LXX/GRK" or similar special resource
4. Observe that it is found correctly

### Current Behavior
- "LXX/GRK" is converted to "LXX" when finding in collection
- "HEB/GRK" is converted to "HEB" when finding in collection
- This normalization happens in `ChooseComparitiveTexts()`
- The display name may still show the full name

### Source
- Code location: `Paratext/Paratext/Checklists/ChecklistsTool.cs:555`
- Method: `ChecklistsTool.ChooseComparitiveTexts()`

### Test Coverage
- Scenario ID: TS-021
- Golden master candidate: No
- Automated test feasibility: Medium (requires special resources available)

### Risk Assessment
- Likelihood of occurrence: Low (only with specific resources)
- Impact if behavior changes: Medium (would break special resource comparison)
- Severity: **Medium**

### Notes
These are legacy naming conventions for Biblical resource texts. PT10 may handle these differently through resource identifiers.

---

## Edge Case: EC-013 Verse 0 (Introduction) Exclusion

### Scenario
USFM verse 0 represents introduction material before verse 1. This should not appear in the Verses checklist.

### Reproduction Steps
1. Open a project with introduction material (content in verse 0)
2. Open Verses checklist
3. Select a range starting from verse 0 or chapter 1
4. Observe that introduction content is excluded

### Current Behavior
- Verse 0 is explicitly excluded from Verses checklist results
- The check `if (tokens.Item1 == 0) continue` skips introduction content
- Related to FB-29600 bug fix
- Other checklists (like Markers) may include verse 0 content

### Source
- Code location: `Paratext/Paratext/Checklists/CLVerseCellsDataSource.cs:100`
- Method: `CLVerseCellsDataSource.GetTokensForBook()`
- Domain constraint: DC-003

### Test Coverage
- Scenario ID: TS-040
- Golden master candidate: No
- Automated test feasibility: High

### Risk Assessment
- Likelihood of occurrence: Medium (many books have introductions)
- Impact if behavior changes: Medium (would include non-verse content)
- Severity: **High**

### Notes
This is intentional filtering to keep the Verses checklist focused on actual verse content. Introduction material is not verse text and would confuse comparisons.

---

## Edge Case: EC-014 Maximum Rows Truncation

### Scenario
When a checklist query would return more than 5000 rows, the results are truncated.

### Reproduction Steps
1. Open Verses checklist
2. Select "All verses" for a project with complete Bible
3. Observe the warning and truncation

### Current Behavior
- Results are limited to `maxRows = 5000` items
- A warning is shown to the user when truncating
- The `Take(maxRows)` LINQ operation is applied after generation
- This prevents performance issues and memory problems with very large result sets

### Source
- Code location: `Paratext/Paratext/Checklists/ChecklistsTool.cs:510`
- Method: `ChecklistsTool.GetChecklistData()`
- Invariant: INV-002

### Test Coverage
- Scenario ID: TS-009
- Golden master candidate: No
- Automated test feasibility: High

### Risk Assessment
- Likelihood of occurrence: Medium (whole Bible comparisons)
- Impact if behavior changes: High (performance/memory issues)
- Severity: **Critical**

### Notes
This limit is a practical constraint for usability. Users can narrow the verse range to see more specific results. PT10 may implement virtual scrolling to show more rows.

---

## Summary Table

| Edge Case | Severity | Likelihood | Golden Master | Scenario ID |
|-----------|----------|------------|---------------|-------------|
| EC-001 Missing Verse in Comparative | High | High | No | TS-072 |
| EC-002 Verse Bridge Alignment | Critical | Medium | Yes | TS-073 |
| EC-003 Section Heading Before Chapter | Medium | Low | No | TS-042 |
| EC-004 Missing Book Title | Low | Medium | No | TS-045 |
| EC-005 Empty Verse for Relative Length | High | Medium | No | TS-056 |
| EC-006 No Quotes in Verse | Medium | High | No | TS-063 |
| EC-007 URL Encoded Spaces | High | Medium | No | TS-017 |
| EC-008 Invalid Cross Reference | Medium | Low | No | TS-049 |
| EC-009 Comparative Project Removed | High | Low | No | TS-037 |
| EC-010 Primary Project Removed | Critical | Very Low | No | TS-036 |
| EC-011 Stanza Break After Heading | High | Medium | No | TS-043 |
| EC-012 LXX/HEB Special Names | Medium | Low | No | TS-021 |
| EC-013 Verse 0 Exclusion | High | Medium | No | TS-040 |
| EC-014 Max Rows Truncation | Critical | Medium | No | TS-009 |
