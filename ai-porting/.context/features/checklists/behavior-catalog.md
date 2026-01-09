# Behavior Catalog: Checklists

## Overview

The Checklists feature provides 13 different types of tabular comparisons of scripture data across one or more projects. Users can view and compare verse text, section headings, markers, footnotes, cross-references, quotation marks, and other scripture elements. The tool supports filtering, sorting, navigation to verses, and optionally hiding exact matches between comparative texts.

## User Context

### Primary Users

- **Translators**: Compare their translation against source texts or other translations to verify consistency
- **Translation Consultants**: Review translation quality by comparing verse structures and formatting across projects
- **Back Translators**: Verify that their back translation matches the original translation structure
- **Project Administrators**: Check consistency of markers, section headings, and book titles across projects

### User Stories

- As a translator, I want to compare verse text between my project and a source text so that I can identify missing or extra content
- As a consultant, I want to see where section headings differ between projects so that I can verify appropriate text divisions
- As a translator, I want to find the longest sentences in my translation so that I can check for readability issues
- As a checker, I want to compare quotation mark usage across projects so that I can identify inconsistent quote patterns
- As a translator, I want to find and compare specific words or phrases across multiple projects so that I can verify consistent terminology

### Usage Frequency

- **Daily**: Translators actively working on checking and revision use checklists frequently
- **Occasionally**: Most checklist types are used during specific checking phases

## Entry Points

### Menu: Tools > Checklists > Verse Text

- **Handler**: `TextForm.checklistsVerseTextToolStripMenuItem_Click`
- **Location**: `Paratext/Paratext/TextForm.cs:2408`
- **Invokes**: `ShowChecklists(ChecklistType.Verses)`

### Menu: Tools > Checklists > Words or Phrases

- **Handler**: `TextForm.wordsOrPhrasesToolStripMenuItem_Click`
- **Location**: `Paratext/Paratext/TextForm.cs:2413`
- **Invokes**: `ShowChecklists(ChecklistType.WordsPhrases)`

### Menu: Tools > Checklists > Section Headings

- **Handler**: `TextForm.checklistsSectionHeadingsToolStripMenuItem_Click`
- **Location**: `Paratext/Paratext/TextForm.cs:2418`
- **Invokes**: `ShowChecklists(ChecklistType.SectionHeadings)`

### Menu: Tools > Checklists > Book Titles

- **Handler**: `TextForm.checklistsBookTitlesToolStripMenuItem_Click`
- **Location**: `Paratext/Paratext/TextForm.cs:2423`
- **Invokes**: `ShowChecklists(ChecklistType.BookTitles)`

### Menu: Tools > Checklists > References (Cross References)

- **Handler**: `TextForm.checklistsCrossReferencesToolStripMenuItem_Click`
- **Location**: `Paratext/Paratext/TextForm.cs:2428`
- **Invokes**: `ShowChecklists(ChecklistType.CrossReferences)`

### Menu: Tools > Checklists > Markers

- **Handler**: `TextForm.checklistsMarkersToolStripMenuItem_Click`
- **Location**: `Paratext/Paratext/TextForm.cs:2433`
- **Invokes**: `ShowChecklists(ChecklistType.Markers)`

### Menu: Tools > Checklists > Footnotes

- **Handler**: `TextForm.checklistsFootnotesToolStripMenuItem_Click`
- **Location**: `Paratext/Paratext/TextForm.cs:2438`
- **Invokes**: `ShowChecklists(ChecklistType.Footnotes)`

### Menu: Tools > Checklists > Relatively Long Verses

- **Handler**: `TextForm.checklistsRelativelyLongVersesToolStripMenuItem_Click`
- **Location**: `Paratext/Paratext/TextForm.cs:2443`
- **Invokes**: `ShowChecklists(ChecklistType.RelativelyLongVerses)`

### Menu: Tools > Checklists > Relatively Short Verses

- **Handler**: `TextForm.checklistsRelativelyShortVersesToolStripMenuItem_Click`
- **Location**: `Paratext/Paratext/TextForm.cs:2448`
- **Invokes**: `ShowChecklists(ChecklistType.RelativelyShortVerses)`

### Menu: Tools > Checklists > Long Sentences

- **Handler**: `TextForm.checklistsLongSentencesToolStripMenuItem_Click`
- **Location**: `Paratext/Paratext/TextForm.cs:2453`
- **Invokes**: `ShowChecklists(ChecklistType.LongSentences)`

### Menu: Tools > Checklists > Long Paragraphs

- **Handler**: `TextForm.checklistsLongParagraphsToolStripMenuItem_Click`
- **Location**: `Paratext/Paratext/TextForm.cs:2458`
- **Invokes**: `ShowChecklists(ChecklistType.LongParagraphs)`

### Menu: Tools > Checklists > Quotation Marks

- **Handler**: `TextForm.quotationMarksToolStripMenuItem_Click`
- **Location**: `Paratext/Paratext/TextForm.cs:2262`
- **Invokes**: `ShowChecklists(ChecklistType.QuotationDifferences)`

### Menu: Tools > Checklists > Punctuation

- **Handler**: `TextForm.punctuationToolStripMenuItem_Click`
- **Location**: `Paratext/Paratext/TextForm.cs:2463`
- **Invokes**: `ShowChecklists(ChecklistType.Punctuation)`

### API Entry Point: BiblicalTermsForm

- **Handler**: `BiblicalTermsForm` (for Words/Phrases checklist)
- **Location**: `Paratext/BiblicalTerms/Internal/BiblicalTermsForm.cs:1351`
- **Purpose**: Opens Words/Phrases checklist with pre-configured search strings from Biblical Terms

### Common Entry Point: ShowChecklists

- **Handler**: `ParatextWindowWithMenus.ShowChecklists`
- **Location**: `ParatextBase/ParatextWindows/ParatextWindowWithMenus.cs:1209`
- **Purpose**: Creates and shows the ChecklistsTool window

---

## Behaviors

### Behavior: BHV-001 Initialize Checklist Tool

- **Source**: `ChecklistsTool.Initialize` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:132`
- **Trigger**: Tool window is opened via menu or API
- **Input**:
  - `ScrText newScrText` - the primary scripture text to analyze
  - `ChecklistType newChecklistType` - type of checklist to display
- **Output**: Configured checklist tool window ready for display
- **Side Effects**:
  - Loads persisted memento settings (comparative texts, verse range, hide matches flag)
  - Registers form with DialogRestorer
  - Listens for WriteLockManager changes
- **Error Handling**: None at initialization level
- **Edge Cases**:
  - Comparative texts may no longer exist (filtered out during load)
  - Verse range may be invalid (reset to default)

#### UI/UX Details

- **Keyboard shortcut**: None (menu access only)
- **Accessibility**: Standard Windows Forms accessibility
- **Visual feedback**: Loading dialog shows "Building Checklist"
- **Undo support**: N/A (read-only display)

---

### Behavior: BHV-002 Display Checklist Data

- **Source**: `ChecklistsTool.DisplayChecklists` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:424`
- **Trigger**: Form shown, settings changed, or project text modified
- **Input**:
  - List of ScrTexts (primary + comparative)
  - Verse range (optional)
  - Initialization value map with settings
  - Show verse text flag
  - Hide matches flag
- **Output**: HTML table rendered in XmlDisplayControl showing checklist data
- **Side Effects**:
  - Updates window title with verse range
  - Updates match count label
  - Scrolls to previous position if possible
- **Error Handling**:
  - Catches `ProgressCancelledException` (user cancelled)
  - Catches `SettingsHaveNotBeenReviewedException` (shows error dialog)
- **Edge Cases**:
  - Limits display to `maxRows = 5000` items
  - Shows warning when truncating

#### UI/UX Details

- **Keyboard shortcut**: N/A
- **Accessibility**: Screen reader can read HTML content
- **Visual feedback**: Progress dialog during generation
- **Undo support**: N/A

---

### Behavior: BHV-003 Build Rows from Data Sources

- **Source**: `CLDataSource.BuildRows` at `Paratext/Paratext/Checklists/CLDataSource.cs:97`
- **Trigger**: `DisplayChecklists` calls `GetChecklistData`
- **Input**:
  - `CLData checklist` - output container
  - `VerseRef firstVerseRef, lastVerseRef` - verse range
  - `Dictionary<string,string> initializationValueMap` - settings
  - `bool showReferencedVerseText` - include verse text with references
  - `bool hideMatches` - filter out matching rows
- **Output**: Populated `CLData` with rows and cells
- **Side Effects**: Creates data source instances for each ScrText
- **Error Handling**: Returns false if source is invalid
- **Edge Cases**:
  - Empty column cells for missing content
  - Different versifications handled via mapping

---

### Behavior: BHV-004 Navigate to Verse Reference

- **Source**: `ChecklistsTool.HtmlEditor_BeforeNavigate` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:711`
- **Trigger**: User clicks on a reference link in the checklist (starts with "goto:")
- **Input**: URL target string containing verse reference
- **Output**: Main window navigates to the specified verse
- **Side Effects**: Calls `MainForm.Current.Windows.GotoReference`
- **Error Handling**: None explicit
- **Edge Cases**:
  - URL-encoded spaces converted (`%20` -> ` `)
  - Section headings navigate to previous verse

#### UI/UX Details

- **Keyboard shortcut**: N/A (click only)
- **Accessibility**: Links are focusable
- **Visual feedback**: Instant navigation
- **Undo support**: N/A

---

### Behavior: BHV-005 Edit Scripture from Checklist

- **Source**: `ChecklistsTool.HtmlEditor_BeforeNavigate` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:715`
- **Trigger**: User clicks "edit" link in the checklist (starts with "edit:")
- **Input**: URL target string containing verse reference
- **Output**: Opens EditScrTextForm modal dialog
- **Side Effects**:
  - On OK, refreshes checklist display
  - May save changes to scripture text
- **Error Handling**: Dialog handles its own errors
- **Edge Cases**: Only shown if user has edit permissions for the chapter

#### UI/UX Details

- **Keyboard shortcut**: N/A
- **Accessibility**: Links are accessible
- **Visual feedback**: Modal edit dialog
- **Undo support**: Via EditScrTextForm

---

### Behavior: BHV-006 Choose Comparative Texts

- **Source**: `ChecklistsTool.ChooseComparitiveTexts` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:549`
- **Trigger**: User clicks "Comparative Texts" toolbar button
- **Input**: Current list of comparative texts
- **Output**: Updated list of ScrTexts to compare against
- **Side Effects**:
  - Resets hideMatches to false
  - Persists new selection
  - Refreshes display
- **Error Handling**: Handles special project names (LXX/GRK -> LXX)
- **Edge Cases**:
  - Comparative texts removed from collection are filtered out
  - Current project excluded from selection

#### UI/UX Details

- **Keyboard shortcut**: N/A
- **Accessibility**: Standard list selection dialog
- **Visual feedback**: Dialog for selection
- **Undo support**: N/A

---

### Behavior: BHV-007 Choose Verse Range

- **Source**: `ChecklistsTool.ChooseVerseRange` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:588`
- **Trigger**: User clicks "Verse Range" toolbar button
- **Input**: Current first and last verse references
- **Output**: Updated verse range for checklist
- **Side Effects**:
  - Persists new range
  - Refreshes display
- **Error Handling**: None explicit
- **Edge Cases**:
  - "All verses" resets to default (empty) references
  - BookTitles always starts at beginning of book

#### UI/UX Details

- **Keyboard shortcut**: N/A
- **Accessibility**: Standard dialog
- **Visual feedback**: Range shown in title bar
- **Undo support**: N/A

---

### Behavior: BHV-008 Toggle Hide Matches

- **Source**: `ChecklistsTool.uiHideMatches_Click` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:861`
- **Trigger**: User clicks "Hide Matches" toolbar button
- **Input**: Current hideMatches state
- **Output**: Toggled hideMatches state
- **Side Effects**:
  - Persists state
  - Refreshes display with rows filtered
  - Updates excluded count label
- **Error Handling**: Reverts to false if display fails
- **Edge Cases**: Only visible for certain checklist types with comparative texts

#### UI/UX Details

- **Keyboard shortcut**: N/A
- **Accessibility**: Checkbox button
- **Visual feedback**: Check mark on button, count of hidden items
- **Undo support**: N/A

---

### Behavior: BHV-009 Toggle Show Verse Text

- **Source**: `ChecklistsTool.uiShowVerseText_Click` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:872`
- **Trigger**: User clicks "Show Verse Text" toolbar button
- **Input**: Current showVerseText state
- **Output**: Toggled state
- **Side Effects**:
  - Persists state
  - Refreshes display with/without verse text
- **Error Handling**: Reverts to false if display fails
- **Edge Cases**: Only visible for CrossReferences and Markers checklists

---

### Behavior: BHV-010 Print Checklist

- **Source**: `ChecklistsTool.printToolStripButton_Click` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:765`
- **Trigger**: User clicks Print toolbar button
- **Input**: Current checklistData
- **Output**: Print preview/print dialog
- **Side Effects**: Temporarily adds header to data
- **Error Handling**: Early return if no data
- **Edge Cases**: None specific

---

### Behavior: BHV-011 Save Checklist as HTML

- **Source**: `ChecklistsTool.saveToolStripButton_Click` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:793`
- **Trigger**: User clicks Save toolbar button
- **Input**: Current checklistData and file path from SaveFileDialog
- **Output**: HTML file written to disk
- **Side Effects**: File I/O
- **Error Handling**: Early return if no data or dialog cancelled
- **Edge Cases**: Uses UTF-8 encoding

---

### Behavior: BHV-012 Copy Selection to Clipboard

- **Source**: `ChecklistsTool.copyToolStripButton_Click` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:826`
- **Trigger**: User clicks Copy toolbar button
- **Input**: Current HTML selection
- **Output**: Text copied to clipboard
- **Side Effects**: Clipboard modification
- **Error Handling**: None explicit
- **Edge Cases**: Only copies text content, not formatting

---

### Behavior: BHV-013 Configure Settings (Per Checklist Type)

- **Source**: `ChecklistsTool.uiSettings_Click` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:880`
- **Trigger**: User clicks Settings toolbar button (only visible for certain types)
- **Input**: Current initialization values
- **Output**: Updated settings stored in initializationValueMap
- **Side Effects**:
  - Opens type-specific settings dialog
  - Refreshes display if OK clicked
- **Error Handling**: Dialog handles its own errors
- **Edge Cases**: Different dialogs for each type:
  - Markers: `MarkerSettingsForm` (equivalent markers, filter)
  - WordsPhrases: `WordOrPhraseSettingsForm` (search strings, morphology)
  - Punctuation: `PunctuationSettingsForm` (filter characters)
  - Verses: `VerseSettingsForm` (section headings, footnotes)

---

### Behavior: BHV-014 Respond to Project Changes

- **Source**: `ChecklistsTool.ChangeListener` at `Paratext/Paratext/Checklists/ChecklistsTool.cs:221`
- **Trigger**: WriteLockManager fires change event
- **Input**: WriteLock and WriteScope of the change
- **Output**: Updated display or closed window
- **Side Effects**: May close window if project removed
- **Error Handling**: Checks if projects still present
- **Edge Cases**:
  - Entire project removed: close window
  - Comparative text removed: update list
  - Book text changed: refresh display

---

## Checklist Type-Specific Behaviors

### Behavior: BHV-100 Verses Checklist Data Extraction

- **Source**: `CLVersesDataSource.GetTokensForBook` at `Paratext/Paratext/Checklists/CLVerseCellsDataSource.cs:43`
- **Trigger**: Building checklist data for Verses type
- **Input**: Book number, verse range, optional settings (show section headings, show footnotes)
- **Output**: List of CLParagraphTokens for each verse
- **Business Logic**:
  - Excludes verse 0 (introduction)
  - Can optionally include section headings and footnotes
  - Merges verses within cells
- **Edge Cases**:
  - Verse bridges result in single cell
  - FB-29600: Verse 0 explicitly excluded

---

### Behavior: BHV-101 Section Headings Data Extraction

- **Source**: `CLSectionHeadingsDataSource.GetDesiredMarkers` at `Paratext/Paratext/Checklists/CLParagraphCellsDataSource.cs:301`
- **Trigger**: Building checklist data for SectionHeadings type
- **Input**: Book number
- **Output**: List of section heading paragraphs
- **Business Logic**:
  - Uses stylesheet to identify heading markers (scSection text type)
  - Reference is set to first verse following the heading
- **Edge Cases**:
  - Heading before chapter marker uses previous verse reference (FB-35863)
  - Stanza breaks after headings handled correctly (FB-24651)

---

### Behavior: BHV-102 Book Titles Data Extraction

- **Source**: `CLBookTitlesDataSource.GetCellsForBook` at `Paratext/Paratext/Checklists/CLParagraphCellsDataSource.cs:328`
- **Trigger**: Building checklist data for BookTitles type
- **Input**: Book number
- **Output**: Book title paragraphs or "No Book Title Present" message
- **Business Logic**:
  - Uses stylesheet to identify title markers (scTitle text type)
  - Always starts at beginning of book
- **Edge Cases**: Missing title shows explicit warning message

---

### Behavior: BHV-103 Footnotes Data Extraction

- **Source**: `CLFootnotesDataSource.GetTokensForBook` at `Paratext/Paratext/Checklists/CLNoteCellsDataSource.cs:23`
- **Trigger**: Building checklist data for Footnotes type
- **Input**: Book number
- **Output**: List of footnote content by verse
- **Business Logic**: Only includes `\f` markers (not `\x` cross-references)

---

### Behavior: BHV-104 Cross References Data Extraction

- **Source**: `CLCrossReferencesDataSource.GetTokensForBook` at `Paratext/Paratext/Checklists/CLNoteCellsDataSource.cs:84`
- **Trigger**: Building checklist data for CrossReferences type
- **Input**: Book number
- **Output**: List of cross-reference and parallel passage content
- **Business Logic**:
  - Includes `\x`, `\xt`, `\r`, `\mr`, `\sr`, `\ior`, `\rq`, `\fig` references
  - Optionally includes referenced verse text
  - Uses CrossReferenceScanner and ParallelPassageReferenceScanner
- **Error Handling**:
  - Requires ReferenceSettingsHaveBeenReviewed
  - Shows error message for invalid references
- **Edge Cases**:
  - Figure references parsed from attributes
  - Footnote origin references (`\fr`) included

---

### Behavior: BHV-105 Markers Data Extraction

- **Source**: `CLMarkersDataSource.GetCellsForBook` at `Paratext/Paratext/Checklists/CLParagraphCellsDataSource.cs:174`
- **Trigger**: Building checklist data for Markers type
- **Input**: Book number, marker filter, marker equivalence mappings
- **Output**: List of paragraph markers with optional text
- **Business Logic**:
  - Shows `\marker` prefix for each paragraph
  - Can filter to specific markers
  - Supports equivalent marker mappings for comparison
  - Merges verses within cells
- **Edge Cases**:
  - Empty filter shows all paragraph markers
  - Equivalent markers (e.g., `p/m`) considered matching

---

### Behavior: BHV-106 Relatively Long/Short Verses Data Extraction

- **Source**: `CLRelativelyLongVersesDataSource`, `CLRelativelyShortVersesDataSource` at `Paratext/Paratext/Checklists/CLVerseCellsDataSource.cs:214,237`
- **Trigger**: Building checklist data for RelativelyLongVerses or RelativelyShortVerses
- **Input**: Two or more scripture texts
- **Output**: Top 100 verses with highest relative length difference
- **Business Logic**:
  - Score = ratio of text lengths between projects
  - Sorted by score (most different first)
  - Excludes section headings and footnotes
  - HighScoresOnly = true limits to 100 results
- **Edge Cases**:
  - Missing verse in one project = infinite score
  - Shows warning if second text not provided

---

### Behavior: BHV-107 Long Sentences Data Extraction

- **Source**: `CLLongSentencesDataSource.GetTokensForBook` at `Paratext/Paratext/Checklists/CLParagraphCellsDataSource.cs:365`
- **Trigger**: Building checklist data for LongSentences type
- **Input**: Book number
- **Output**: Top 100 longest sentences
- **Business Logic**:
  - Splits text on sentence-final punctuation (using CharacterCategorizer)
  - Score = inverse of sentence length
  - HighScoresOnly = true limits results
- **Edge Cases**:
  - Each sentence gets its own cell (no verse merging)
  - Non-letter, non-whitespace characters after punctuation kept with sentence

---

### Behavior: BHV-108 Long Paragraphs Data Extraction

- **Source**: `CLLongParagraphsDataSource` at `Paratext/Paratext/Checklists/CLParagraphCellsDataSource.cs:476`
- **Trigger**: Building checklist data for LongParagraphs type
- **Input**: Book number
- **Output**: Top 100 longest paragraphs
- **Business Logic**:
  - Uses non-heading paragraph markers
  - Score = inverse of paragraph length
  - HighScoresOnly = true
- **Edge Cases**: Each paragraph gets its own cell

---

### Behavior: BHV-109 Quotation Marks Data Extraction

- **Source**: `CLQuoteDiffsDataSource.GetTokensForBook` at `Paratext/Paratext/Checklists/CLQuoteDiffsDataSource.cs:75`
- **Trigger**: Building checklist data for QuotationDifferences type
- **Input**: Book number, quote settings from each project
- **Output**: Verses with different quotation mark counts
- **Business Logic**:
  - Uses QuotationCheck to count quotes per verse
  - Compares quote counts between projects
  - Hides verses without quotation marks
  - Supports nested quotes (inner, inner-inner)
- **Error Handling**:
  - Validates quote settings complete
  - Shows setup warning if incomplete
- **Edge Cases**:
  - Different quote characters per project handled
  - Continuer marks counted separately

---

### Behavior: BHV-110 Punctuation Data Extraction

- **Source**: `CLPunctuationDataSource.AcceptParagraph` at `Paratext/Paratext/Checklists/CLPunctuationCellsDataSource.cs:44`
- **Trigger**: Building checklist data for Punctuation type
- **Input**: Book number, optional punctuation filter
- **Output**: Verses containing filtered punctuation
- **Business Logic**:
  - Uses CharacterCategorizer.IsPunctuation
  - Can filter to specific punctuation characters
  - Compares punctuation sequences between projects
- **Edge Cases**:
  - Empty filter includes all punctuation
  - Spaces removed from filter

---

### Behavior: BHV-111 Words/Phrases Data Extraction

- **Source**: `CLTermDataSource.GetTokensForBook` at `Paratext/Paratext/Checklists/CLTermDataSource.cs:57`
- **Trigger**: Building checklist data for WordsPhrases type
- **Input**: Book number, search strings per project, morphology matching flag
- **Output**: Verses containing matched words/phrases with highlighting
- **Business Logic**:
  - Uses WordOrPhraseMatcher to find matches
  - Supports morphological matching via LexicalAnalyser
  - Marks matched text with special marker for highlighting
  - Multiple search strings per project (newline-separated)
- **Edge Cases**:
  - Match highlighting uses special `||m3tch` marker
  - Can be launched from BiblicalTermsForm with pre-configured search

---

## Dependencies

### ParatextData Layer Dependencies

- `ScrText` - Scripture text access
- `UsfmToken`, `UsfmTokenType` - USFM parsing
- `ScrParserState` - Parser state tracking
- `VerseRef`, `ScrVers` - Verse reference handling
- `ScrStylesheet`, `ScrTag` - Stylesheet access
- `QuotationMarkInfo`, `QuotationCheck` - Quote mark handling
- `CharacterCategorizer` - Character classification
- `LexicalAnalyser` - Morphological matching

### UI Dependencies

- `XmlDisplayControl` - HTML rendering
- `XslCompiledTransform` - XSLT transformation (ChecklistsView.xslt)
- `CSSCreator` - Dynamic CSS generation
- Various settings dialogs (MarkerSettingsForm, etc.)

### External Features

- Verse navigation (MainForm.GotoReference)
- Edit scripture (EditScrTextForm)
- Biblical Terms integration (for Words/Phrases)
