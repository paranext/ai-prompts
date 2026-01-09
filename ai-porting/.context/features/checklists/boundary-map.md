# Boundary Map: Checklists

## ParatextData Layer (Portable)

The ParatextData layer provides minimal support for checklists - primarily USFM parsing and verse reference handling. The actual checklist logic is almost entirely in the UI layer.

| Class | Purpose | Reusable in PT10 |
|-------|---------|------------------|
| `ScrText` | Scripture text access, USFM storage | Yes (via NuGet) |
| `ScrText.Parser.GetUsfmTokens()` | Get USFM tokens for a book | Yes |
| `ScrText.Parser.GetBookUsfm()` | Get raw USFM for a book | Yes |
| `ScrText.Parser.GetVerseTextSafe()` | Get verse text | Yes |
| `UsfmToken` | USFM token representation | Yes |
| `UsfmTokenType` | Token type enumeration | Yes |
| `ScrParserState` | Parser state during token iteration | Yes |
| `VerseRef` | Verse reference handling | Yes |
| `ScrVers` | Versification system | Yes |
| `ScrStylesheet` | Stylesheet access for marker info | Yes |
| `ScrTag` | Style tag definition | Yes |
| `QuotationMarkInfo` | Quote mark settings | Yes |
| `CharacterCategorizer` | Character classification | Yes |
| `LexicalAnalyser` | Morphological analysis | Yes |
| `CrossReferenceScanner` | Parse scripture references | Yes (in Paratext.Checks.References) |
| `ParallelPassageReferenceScanner` | Parse parallel passage references | Yes |

## UI Layer (Needs Rewrite)

Almost all checklist functionality is in the Paratext UI layer. This code needs complete rewrite for PT10.

### Core Classes

| Class | Purpose | Logic to Extract |
|-------|---------|------------------|
| `ChecklistsTool` | Main window, toolbar, HTML display | - Entry point handling<br>- Settings persistence<br>- XSLT/HTML rendering pipeline |
| `ChecklistsTool.Designer` | Windows Forms designer | All UI definitions |
| `IChecklistsTool` | Interface for checklist window | API contract only |
| `ChecklistType` (enum) | Enum of 13 checklist types | Direct port (already in SubsystemInterfaces) |

### Data Model Classes

| Class | Purpose | Logic to Extract |
|-------|---------|------------------|
| `CLData` | Container for checklist results | - XML serialization for XSLT<br>- Row/cell organization |
| `CLRow` | Single row (one verse reference) | - FirstRef calculation<br>- Score sorting |
| `CLCell` | Single cell (one project's data) | - Text length calculation<br>- Verse ref formatting |
| `CLParagraph` | Paragraph within cell | - Items aggregation |
| `CLParagraphContents` | Base class for paragraph items | - Abstract type |
| `CLText` | Text content with marker | - Marker and text storage |
| `CLVerse` | Verse number display | - Reference formatting |
| `CLEditLink` | Edit link for editable cells | - Edit capability check |
| `CLLink` | Navigation link | - Reference linking |
| `CLError` | Error message display | - Error text |
| `CLCellError` | Cell-level error info | - Error and tooltip |
| `CLCellMessage` | Cell-level message | - Message and tooltip |
| `CLQuoteCell` | Quote-specific cell | - Quote count |
| `CLPunctuationCell` | Punctuation-specific cell | - Punctuation sequence |

### Data Source Classes (13 subclasses)

| Class | Purpose | Logic to Extract |
|-------|---------|------------------|
| `CLDataSource` | Abstract base, factory method | - Row building algorithm<br>- Cell alignment across columns<br>- Hide matches filtering |
| `CLParagraphCellsDataSource` | Abstract for paragraph-based | - Paragraph token extraction<br>- Heading marker identification |
| `CLVerseCellsDataSource` | Abstract for verse-based | - Verse token extraction<br>- Section heading/footnote inclusion |
| `CLSectionHeadingsDataSource` | Section headings | - Heading marker filtering |
| `CLBookTitlesDataSource` | Book titles | - Title marker filtering<br>- Missing title message |
| `CLLongSentencesDataSource` | Long sentences | - Sentence splitting algorithm<br>- Score calculation |
| `CLLongParagraphsDataSource` | Long paragraphs | - Paragraph filtering<br>- Score calculation |
| `CLMarkersDataSource` | USFM markers | - Marker equivalence mapping<br>- Marker filtering |
| `CLVersesDataSource` | Verse text | - Verse extraction |
| `CLRelativelyLongVersesDataSource` | Relatively long verses | - Relative length scoring |
| `CLRelativelyShortVersesDataSource` | Relatively short verses | - Relative length scoring |
| `CLFootnotesDataSource` | Footnotes | - Footnote extraction |
| `CLCrossReferencesDataSource` | Cross references | - Reference parsing<br>- Verse text inclusion |
| `CLQuoteDiffsDataSource` | Quotation differences | - Quote counting<br>- Quote settings validation |
| `CLPunctuationDataSource` | Punctuation | - Punctuation filtering<br>- Sequence comparison |
| `CLTermDataSource` | Words/phrases search | - Word matching<br>- Morphological matching<br>- Match highlighting |

### Supporting Classes

| Class | Purpose | Logic to Extract |
|-------|---------|------------------|
| `CLRowsBuilder` | Aligns cells into rows | - Cell merging for verse bridges<br>- Reference mapping |
| `CLParagraphTokens` | USFM tokens for paragraph | - Token collection |
| `CLSentenceTokens` | USFM tokens for sentence | - Start/end verse refs |
| `CLQuoteParagraphTokens` | Quote-aware paragraph | - Quote count tracking |
| `SearchStringMap` | Per-project search strings | - Parsing and lookup |
| `WordOrPhraseMatcher` | String matching | - Regex replacement |

### Settings Forms

| Class | Purpose | Logic to Extract |
|-------|---------|------------------|
| `MarkerSettingsForm` | Marker equivalence/filter settings | UI only, settings in initializationValueMap |
| `PunctuationSettingsForm` | Punctuation filter settings | UI only |
| `VerseSettingsForm` | Show headings/footnotes settings | UI only |
| `WordOrPhraseSettingsForm` | Search string settings | UI only, complex per-project config |

### XSLT/CSS Resources

| File | Purpose | Notes |
|------|---------|-------|
| `ChecklistsView.xslt` | Transform CLData XML to HTML | Anti-pattern to replace |
| `ChecklistsView.css` | Style the HTML output | Styling logic |

## Data Flow

```
[User Action: Menu Click]
    |
    v
[TextForm.checklistsXxxToolStripMenuItem_Click]
    |
    v
[ParatextWindowWithMenus.ShowChecklists(ChecklistType)]
    |
    v
[DependencyLookup.Get<IChecklistsTool>()] -> [new ChecklistsTool()]
    |
    v
[ChecklistsTool.Initialize(ScrText, ChecklistType)]
    |
    +-- Load memento (persisted settings)
    +-- Configure UI visibility per type
    |
    v
[ChecklistsTool.DisplayChecklists()]
    |
    +-- [CreateHtml(zoom)] -> CSS generation
    |
    v
[GetChecklistData(scrTexts)]
    |
    v
[CLDataSource.BuildRows(checklist, ...)]
    |
    +-- [CreateDataSource(scrText, ctype)] -> Factory method
    +-- For each ScrText:
    |       +-- [dataSource.GetCells(startRef, endRef)]
    |           +-- [GetTokensForBook(vref)] -> USFM parsing
    |           +-- [BuildCLCell(paragraphTokens)] -> Cell construction
    |
    +-- [CLRowsBuilder.BuildRows(columns)] -> Align cells into rows
    |
    +-- Apply hideMatches filtering
    +-- Apply score-based limiting (for HighScoresOnly types)
    |
    v
[checklistData.ToXml()] -> XML serialization
    |
    v
[XslCompiledTransform.Transform] -> XSLT to HTML
    |
    v
[XmlDisplayControl.Xml = xml] -> HTML display
```

## Key API Boundaries

### Factory Method: CreateDataSource

- **Method**: `CLDataSource.CreateDataSource(ScrText scrText, ChecklistType ctype)`
- **Purpose**: Creates appropriate data source subclass for checklist type
- **Location**: `Paratext/Paratext/Checklists/CLDataSource.cs:435`
- **Called from**: `CLDataSource.BuildRows`
- **Returns**: Specific CLDataSource subclass instance

### Row Building: BuildRows

- **Method**: `static bool CLDataSource.BuildRows(CLData, VerseRef, VerseRef, Dictionary, bool, bool)`
- **Purpose**: Orchestrates data extraction and row alignment
- **Location**: `Paratext/Paratext/Checklists/CLDataSource.cs:97`
- **Called from**: `ChecklistsTool.GetChecklistData`
- **Returns**: Boolean indicating success

### Token Extraction: GetTokensForBook

- **Method**: `abstract List<CLParagraphTokens> CLDataSource.GetTokensForBook(VerseRef vref)`
- **Purpose**: Extract USFM tokens organized by paragraph/verse/sentence
- **Location**: `Paratext/Paratext/Checklists/CLDataSource.cs:189`
- **Called from**: `GetCellsForBook`
- **Returns**: List of paragraph tokens for a book

### Row Alignment: CLRowsBuilder.BuildRows

- **Method**: `List<CLRow> CLRowsBuilder.BuildRows(List<List<CLCell>> columns, bool mergeCells)`
- **Purpose**: Align cells from different projects into rows by verse reference
- **Location**: `Paratext/Paratext/Checklists/CLRowsBuilder.cs:64`
- **Called from**: `CLDataSource.BuildRows`
- **Returns**: List of aligned rows

## ParatextData Reuse Estimate

- **Estimated reuse**: 5%
- **Key reusable components**:
  - USFM token parsing (`ScrText.Parser.GetUsfmTokens`)
  - Verse reference handling (`VerseRef`, `ScrVers`)
  - Character categorization (`CharacterCategorizer`)
  - Stylesheet access (`ScrStylesheet`)
  - Scripture reference parsing (`CrossReferenceScanner`)
- **Components needing adaptation**:
  - Quote settings (`QuotationMarkInfo`) - available but usage patterns differ
  - Lexical analysis (`LexicalAnalyser`) - may have different initialization
- **Components not reusable (must rewrite)**:
  - All `CL*` classes (ChecklistsTool, CLData, CLDataSource hierarchy)
  - Settings forms
  - XSLT/HTML rendering pipeline
  - Cell alignment and row building algorithms

## Configuration & Settings

### Settings That Affect This Feature

| Setting | Location | Default | Effect |
|---------|----------|---------|--------|
| Comparative Texts | Memento (ChecklistsToolsMemento) | Empty | Projects to compare against |
| First Verse Ref | Memento | Empty (all) | Start of verse range |
| Last Verse Ref | Memento | Empty (all) | End of verse range |
| Hide Matches | Memento | false | Filter matching rows |
| Show Verse Text | Memento | false | Include verse text with references |
| Zoom Level | DefaultZoomMemento | 100% | Display zoom |
| Marker Mapping | initializationValueMap | Empty | Equivalent marker pairs |
| Marker Filter | initializationValueMap | Empty | Filter to specific markers |
| Punctuation Filter | initializationValueMap | Empty | Filter to specific punctuation |
| Search Strings | initializationValueMap | Empty | Words/phrases to find (per project) |
| Match by Morphology | initializationValueMap | false | Use stem matching |
| Show Section Headings | initializationValueMap | false | Include headings in verse text |
| Show Footnotes | initializationValueMap | false | Include footnotes in verse text |

### Persistence

- **User preferences**: MementoUI system stores ChecklistsToolsMemento per user
- **Project settings**: None (all settings are user preferences)
- **Storage format**: XML serialization via Memento system

## Integration Points

### Features This Depends On

| Feature | Dependency Type | Notes |
|---------|-----------------|-------|
| USFM Parsing | Data | Core ParatextData functionality |
| Versification | Data | Verse reference mapping across projects |
| Scripture Reference Settings | Data | Required for cross-reference parsing |
| Quote Settings | Data | Required for quotation mark comparison |
| Stylesheets | Data | Required for marker type identification |
| Write Lock Manager | Event | Listen for project changes |
| Main Window | UI | Navigation to verses |
| Edit Form | UI | Edit scripture from checklist |

### Features That Depend On This

| Feature | Dependency Type | Notes |
|---------|-----------------|-------|
| Biblical Terms | UI/API | Can launch Words/Phrases checklist with search strings |

### External Systems

- None (self-contained scripture comparison tool)
