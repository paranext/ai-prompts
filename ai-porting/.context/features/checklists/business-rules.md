# Business Rules: Checklists

## Overview

The Checklists feature is primarily a read-only comparison and display tool. Business rules focus on data extraction accuracy, row alignment across projects with different versifications, and consistent filtering/matching behavior.

## Invariants

Rules that must ALWAYS hold true:

### Invariant: INV-001 Row Count Equals Columns

- **Rule**: Every row must have exactly N cells where N equals the number of projects being compared
- **Source**: `CLRowsBuilder.AddRowOfGrabbedCells` at `Paratext/Paratext/Checklists/CLRowsBuilder.cs:315`
- **Enforced by**: Empty CLCell created for missing content
- **Violation handling**: Empty cell inserted automatically

### Invariant: INV-002 Max Rows Limit

- **Rule**: Displayed rows must not exceed maxRows (5000)
- **Source**: `ChecklistsTool.GetChecklistData` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:510`
- **Enforced by**: `Take(maxRows)` after generation
- **Violation handling**: Warning shown to user, excess rows truncated

### Invariant: INV-003 First Cell Reference Required

- **Rule**: The first cell in a row must have a valid verse reference (except for error messages)
- **Source**: `CLDataSource.GetCellsForBook` at `Paratext/Paratext/Checklists/CLDataSource.cs:191`
- **Enforced by**: Cell construction from paragraph tokens includes verse reference
- **Violation handling**: Cells without reference not added to results

### Invariant: INV-004 Versification Consistency

- **Rule**: All verse references in a row must be normalized to the primary project's versification for comparison
- **Source**: `CLRowsBuilder.BuildReferenceMappings` at `Paratext/Paratext/Checklists/CLRowsBuilder.cs:114`
- **Enforced by**: `vRef.ChangeVersification(versification)` during mapping
- **Violation handling**: References converted before comparison

### Invariant: INV-005 No Duplicate Cells Per Row

- **Rule**: Within a single row, each column (project) appears exactly once
- **Source**: `CLRowsBuilder.AddIfUnhandled` at `Paratext/Paratext/Checklists/CLRowsBuilder.cs:285`
- **Enforced by**: `handledCells` HashSet tracks processed cells
- **Violation handling**: Returns false if cell already handled

### Invariant: INV-006 Settings Visibility Per Type

- **Rule**: Settings button only visible for types that have configurable settings
- **Source**: `ChecklistsTool.Initialize` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:171`
- **Enforced by**: Visibility set based on checklistType
- **Violation handling**: N/A (compile-time logic)

## Validation Rules

Input constraints that are checked:

### Validation: VAL-001 Primary ScrText Required

- **Field/Input**: `scrText` parameter in Initialize
- **Rule**: Primary scripture text must not be null
- **Source**: `ChecklistsTool.DisplayChecklists` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:426`
- **Error message**: Returns false (silent failure)
- **When checked**: On display

### Validation: VAL-002 Scripture Reference Settings Required for Cross References

- **Field/Input**: Cross reference text content
- **Rule**: Book abbreviations must be defined for cross-reference parsing
- **Source**: `CLCrossReferencesDataSource.PostProcessParagraph` at `Paratext/Paratext/Checklists/CLNoteCellsDataSource.cs:183`
- **Error message**: "In order to check cross references for the {0} project, you must first enter or verify the punctuation, abbreviations, and short names..."
- **When checked**: When building cross-reference cells

### Validation: VAL-003 Quote Settings Required for Quotation Differences

- **Field/Input**: Quote mark settings
- **Rule**: Quotation mark settings must be complete for quotation comparison
- **Source**: `CLQuoteDiffsDataSource.ValidateSourceSettings` at `Paratext/Paratext/Checklists/CLQuoteDiffsDataSource.cs:55`
- **Error message**: "In order to run this check, go to {setup command}..."
- **When checked**: Before building quotation cells

### Validation: VAL-004 Comparative Text Exists

- **Field/Input**: Comparative text list from memento
- **Rule**: Comparative texts must still exist in ScrTextCollection
- **Source**: `ChecklistsTool.Initialize` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:140`
- **Error message**: None (silently removed from list)
- **When checked**: On initialization

### Validation: VAL-005 Edit Permission Required for Edit Link

- **Field/Input**: User permissions for book/chapter
- **Rule**: Edit link only shown if user can edit the specific book and chapter
- **Source**: `ChecklistsTool.SetCellEditability` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:530`
- **Error message**: N/A (link not shown)
- **When checked**: After row generation

## Preconditions

Conditions that must be true before operations:

### Precondition: PRE-001 Display Checklists

- **Required state**: `scrText` must not be null
- **Source**: `ChecklistsTool.DisplayChecklists` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:426`
- **Failure behavior**: Returns false without display

### Precondition: PRE-002 Build Rows

- **Required state**: At least one ScrText must be in checklist.ScrTexts
- **Source**: `CLDataSource.BuildRows` at `Paratext/Paratext/Checklists/CLDataSource.cs:100`
- **Failure behavior**: Returns empty rows

### Precondition: PRE-003 Print Checklist

- **Required state**: `checklistData` must not be null
- **Source**: `ChecklistsTool.printToolStripButton_Click` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:767`
- **Failure behavior**: Early return

### Precondition: PRE-004 Navigate to Verse

- **Required state**: Target URL must start with "goto:" or "edit:"
- **Source**: `ChecklistsTool.HtmlEditor_BeforeNavigate` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:711`
- **Failure behavior**: Navigation cancelled but no error

### Precondition: PRE-005 Relative Verse Length Comparison

- **Required state**: At least two ScrTexts required for RelativelyLongVerses/RelativelyShortVerses
- **Source**: `CLVerseCellsDataSource.IsSecondTextMissing` at `Paratext/Paratext/Checklists/CLVerseCellsDataSource.cs:169`
- **Failure behavior**: Warning shown to user

## Postconditions

Guaranteed states after operations:

### Postcondition: POST-001 BuildRows Completion

- **Guaranteed result**: All rows have cells for all columns (possibly empty)
- **Source**: `CLRowsBuilder.AddRowOfGrabbedCells` at `Paratext/Paratext/Checklists/CLRowsBuilder.cs:315`

### Postcondition: POST-002 HighScoresOnly Sorting

- **Guaranteed result**: For types with HighScoresOnly, rows are sorted by score and limited to 100
- **Source**: `CLDataSource.BuildRows` at `Paratext/Paratext/Checklists/CLDataSource.cs:183`

### Postcondition: POST-003 Rows Ordered by Reference

- **Guaranteed result**: Rows are ordered by first verse reference (within the primary column)
- **Source**: `CLRowsBuilder.FindInsertionIndex` at `Paratext/Paratext/Checklists/CLRowsBuilder.cs:349`

### Postcondition: POST-004 Settings Persisted

- **Guaranteed result**: After close, settings are persisted to memento
- **Source**: `ChecklistsTool.ChecklistsTool_FormClosed` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:967`

## State Transitions

### State: Checklist Display

| From State | Event/Action | To State | Conditions |
|------------|--------------|----------|------------|
| Empty | Form.Shown | Loaded | ScrText valid |
| Loaded | Change Primary Text | Loaded | New ScrText valid |
| Loaded | Change Comparative Texts | Loaded | Always |
| Loaded | Change Verse Range | Loaded | Range valid |
| Loaded | Toggle Hide Matches | Loaded | Comparative texts exist |
| Loaded | Project Removed | Closed | Primary project removed |
| Loaded | Project Removed | Loaded | Comparative project removed |
| Loaded | Text Changed | Loaded | Any project text modified |

### State: Hide Matches Toggle

| From State | Event/Action | To State | Conditions |
|------------|--------------|----------|------------|
| Showing All | Click Hide Matches | Hiding Matches | At least one comparative text |
| Hiding Matches | Click Hide Matches | Showing All | Always |

### State: Settings for Type

| Checklist Type | Available Settings |
|----------------|-------------------|
| Verses | Section Headings, Footnotes |
| Markers | Equivalent Markers, Marker Filter |
| WordsPhrases | Search Strings, Morphology Matching |
| Punctuation | Punctuation Filter |
| Others | None |

## Domain Constraints

Business logic constraints from the domain:

### Constraint: DC-001 Only Paragraph Styles Extracted

- **Rule**: Only paragraph-style markers are extracted (not character styles) for paragraph-based checklists
- **Rationale**: Character styles are inline and don't represent document structure
- **Source**: `CLParagraphCellsDataSource.HeadingMarkers` at `Paratext/Paratext/Checklists/CLParagraphCellsDataSource.cs:27`
- **Related features**: Section Headings, Markers, Long Paragraphs

### Constraint: DC-002 Sentence Final Punctuation Defines Sentences

- **Rule**: Sentence boundaries are determined by CharacterCategorizer.IsSentenceFinalPunctuation
- **Rationale**: Different languages have different sentence-ending punctuation
- **Source**: `CLLongSentencesDataSource.SplitIntoSentences` at `Paratext/Paratext/Checklists/CLParagraphCellsDataSource.cs:396`
- **Related features**: Long Sentences

### Constraint: DC-003 Verse 0 Excluded from Verse Checklist

- **Rule**: Verse 0 (introduction) is not included in Verse Text checklist
- **Rationale**: Introduction text is not verse text, avoiding confusion
- **Source**: `CLVerseCellsDataSource.GetTokensForBook` at `Paratext/Paratext/Checklists/CLVerseCellsDataSource.cs:100`
- **Related features**: Verses (FB-29600)

### Constraint: DC-004 Book Titles Start at Book Beginning

- **Rule**: Book Titles checklist always starts at chapter 1 regardless of verse range
- **Rationale**: Book titles appear before chapter 1
- **Source**: `ChecklistsTool.AlwaysStartAtBeginningOfBook` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:620`
- **Related features**: Book Titles

### Constraint: DC-005 Max Cells to Merge

- **Rule**: Maximum of 3 cells can be merged together for verse bridging alignment
- **Rationale**: Prevents excessive merging that would create oversized cells
- **Source**: `CLRowsBuilder.MAX_CELLS_TO_GRAB` at `Paratext/Paratext/Checklists/CLRowsBuilder.cs:16`
- **Related features**: All verse-based checklists

### Constraint: DC-006 Quotation Count Comparison

- **Rule**: Quotation differences are determined by counting quote marks, not by comparing quote text
- **Rationale**: Projects may use different quote characters but same structure
- **Source**: `CLQuoteDiffsDataSource.HasSameValue` at `Paratext/Paratext/Checklists/CLQuoteDiffsDataSource.cs:112`
- **Related features**: Quotation Marks

### Constraint: DC-007 Equivalent Markers for Matching

- **Rule**: Markers can be declared equivalent for matching purposes (e.g., p/m, s/s1)
- **Rationale**: Different projects may use slightly different but equivalent markers
- **Source**: `CLMarkersDataSource.IsEquivalentMarker` at `Paratext/Paratext/Checklists/CLParagraphCellsDataSource.cs:223`
- **Related features**: Markers

### Constraint: DC-008 Figure References Included

- **Rule**: Cross-reference checklist includes figure references (from `\fig` marker ref attribute)
- **Rationale**: Figures can reference scripture passages
- **Source**: `CLCrossReferencesDataSource.GetTokensForBook` at `Paratext/Paratext/Checklists/CLNoteCellsDataSource.cs:127`
- **Related features**: Cross References

## Edge Cases

Special cases with specific handling:

### Edge Case: EC-001 Missing Verse in Comparative Text

- **Scenario**: A verse exists in primary text but not in comparative text
- **Handling**: Empty cell is placed in that column
- **Source**: `CLRowsBuilder.AddRowOfGrabbedCells` at `Paratext/Paratext/Checklists/CLRowsBuilder.cs:321`

### Edge Case: EC-002 Verse Bridges with Different Ranges

- **Scenario**: Primary has v.1-2, comparative has v.1, v.2 separately
- **Handling**: Cells merged up to MAX_CELLS_TO_GRAB (3) to align references
- **Source**: `CLRowsBuilder.ExpandGrabCountToAlignCells` at `Paratext/Paratext/Checklists/CLRowsBuilder.cs:142`

### Edge Case: EC-003 Section Heading Before Chapter Marker

- **Scenario**: User incorrectly places section heading before chapter marker
- **Handling**: Use previous verse reference, don't go beyond chapter marker (FB-35863)
- **Source**: `CLParagraphCellsDataSource.FindVerseRefForParagraph` at `Paratext/Paratext/Checklists/CLParagraphCellsDataSource.cs:122`

### Edge Case: EC-004 Missing Book Title

- **Scenario**: Book has no title markers (mt, etc.)
- **Handling**: Display "No Book Title Present" message in cell
- **Source**: `CLBookTitlesDataSource.GetCellsForBook` at `Paratext/Paratext/Checklists/CLParagraphCellsDataSource.cs:333`

### Edge Case: EC-005 Empty Verse for Relative Length

- **Scenario**: One text has verse, other doesn't, for relative length comparison
- **Handling**: Score set to infinity (1000000F) so it appears first
- **Source**: `CLVerseCellsDataSource.SetRowScore` at `Paratext/Paratext/Checklists/CLVerseCellsDataSource.cs:155`

### Edge Case: EC-006 No Quotes in Verse

- **Scenario**: Verse has no quotation marks in quotation difference checklist
- **Handling**: Row marked for deletion if no quotes in any column
- **Source**: `CLQuoteDiffsDataSource.PostProcessRows` at `Paratext/Paratext/Checklists/CLQuoteDiffsDataSource.cs:179`

### Edge Case: EC-007 URL Encoded Spaces

- **Scenario**: Older browsers encode spaces as %20 in navigation URLs
- **Handling**: Replace %20 with space before parsing verse reference
- **Source**: `ChecklistsTool.MakeVerseRef` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:477`

### Edge Case: EC-008 Invalid Cross Reference

- **Scenario**: Cross reference text cannot be parsed as valid scripture reference
- **Handling**: Show error message in cell ("There is an error in the reference")
- **Source**: `CLCrossReferencesDataSource.PostProcessParagraph` at `Paratext/Paratext/Checklists/CLNoteCellsDataSource.cs:193`

### Edge Case: EC-009 Comparative Project Removed

- **Scenario**: Comparative project deleted while checklist open
- **Handling**: Remove from comparative list, refresh display
- **Source**: `ChecklistsTool.ChangeListener` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:237`

### Edge Case: EC-010 Primary Project Removed

- **Scenario**: Primary project deleted while checklist open
- **Handling**: Close the checklist window
- **Source**: `ChecklistsTool.ChangeListener` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:233`

### Edge Case: EC-011 Stanza Break After Section Heading

- **Scenario**: Poetry `\b` marker follows section heading
- **Handling**: Skip `\b` and `\i*` markers when finding next non-heading paragraph (FB-24651)
- **Source**: `CLParagraphCellsDataSource.FindVerseRefForParagraph` at `Paratext/Paratext/Checklists/CLParagraphCellsDataSource.cs:115`

### Edge Case: EC-012 LXX/HEB Special Names

- **Scenario**: Special project names LXX/GRK and HEB/GRK need normalization
- **Handling**: Convert to LXX and HEB respectively when finding in collection
- **Source**: `ChecklistsTool.ChooseComparitiveTexts` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:555`
