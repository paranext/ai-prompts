# Data Contracts: Checklists

## Overview

The Checklists feature provides 13 types of tabular comparisons of scripture data across one or more projects. The data flow involves:

1. **Request Layer**: Client sends checklist request with type, projects, range, and settings
2. **Data Extraction Layer**: USFM tokens are extracted and processed per checklist type
3. **Row Building Layer**: Cells are aligned across projects by verse reference
4. **Response Layer**: Structured data returned for UI rendering

This contract defines the interface between the TypeScript UI layer (React components) and the C# data provider layer (ParatextData integration).

---

## 1. Input Types

### ChecklistType Enumeration

Defines the 13 types of checklists available.

**Purpose**: Identify which checklist algorithm to use for data extraction.

#### TypeScript Definition

```typescript
/**
 * Enumeration of all supported checklist types.
 * Maps directly to PT9's ChecklistType enum.
 */
export enum ChecklistType {
  /** Verse text comparison across projects */
  Verses = 'Verses',
  /** Words or phrases search with optional morphological matching */
  WordsPhrases = 'WordsPhrases',
  /** Section heading comparison */
  SectionHeadings = 'SectionHeadings',
  /** Book title comparison */
  BookTitles = 'BookTitles',
  /** Cross-reference and parallel passage comparison */
  CrossReferences = 'CrossReferences',
  /** USFM paragraph marker comparison */
  Markers = 'Markers',
  /** Footnote content comparison */
  Footnotes = 'Footnotes',
  /** Top 100 verses with highest length ratio vs comparative text */
  RelativelyLongVerses = 'RelativelyLongVerses',
  /** Top 100 verses with lowest length ratio vs comparative text */
  RelativelyShortVerses = 'RelativelyShortVerses',
  /** Top 100 longest sentences */
  LongSentences = 'LongSentences',
  /** Top 100 longest paragraphs */
  LongParagraphs = 'LongParagraphs',
  /** Quotation mark count differences */
  QuotationDifferences = 'QuotationDifferences',
  /** Punctuation sequence comparison */
  Punctuation = 'Punctuation',
}
```

#### C# Definition

```csharp
namespace {TBD:CSharpNamespace}
{
    /// <summary>
    /// Enumeration of all supported checklist types.
    /// </summary>
    public enum ChecklistType
    {
        Verses,
        WordsPhrases,
        SectionHeadings,
        BookTitles,
        CrossReferences,
        Markers,
        Footnotes,
        RelativelyLongVerses,
        RelativelyShortVerses,
        LongSentences,
        LongParagraphs,
        QuotationDifferences,
        Punctuation
    }
}
```

### ChecklistRequest

**Purpose**: Request to generate checklist data.

#### TypeScript Definition

```typescript
/**
 * Request to generate checklist data.
 */
export interface ChecklistRequest {
  /** Type of checklist to generate */
  checklistType: ChecklistType;

  /** Primary project ID */
  primaryProjectId: string;

  /** Comparative project IDs (empty array for single-project checklists) */
  comparativeProjectIds: string[];

  /** Optional verse range filter */
  verseRange?: VerseRange;

  /** Type-specific settings */
  settings: ChecklistSettings;
}

/**
 * Verse range specification.
 */
export interface VerseRange {
  /** Starting verse reference (e.g., "GEN 1:1") */
  first: string;
  /** Ending verse reference (e.g., "GEN 1:31") */
  last: string;
}
```

#### C# Definition

```csharp
namespace {TBD:CSharpNamespace}
{
    /// <summary>
    /// Request to generate checklist data.
    /// </summary>
    public class ChecklistRequest
    {
        /// <summary>
        /// Type of checklist to generate.
        /// </summary>
        public ChecklistType ChecklistType { get; set; }

        /// <summary>
        /// Primary project ID.
        /// </summary>
        public string PrimaryProjectId { get; set; } = string.Empty;

        /// <summary>
        /// Comparative project IDs. Empty for single-project checklists.
        /// </summary>
        public List<string> ComparativeProjectIds { get; set; } = new();

        /// <summary>
        /// Optional verse range filter. Null for all verses.
        /// </summary>
        public VerseRange? VerseRange { get; set; }

        /// <summary>
        /// Type-specific settings.
        /// </summary>
        public ChecklistSettings Settings { get; set; } = new();
    }

    /// <summary>
    /// Verse range specification.
    /// </summary>
    public class VerseRange
    {
        /// <summary>
        /// Starting verse reference (e.g., "GEN 1:1").
        /// </summary>
        public string First { get; set; } = string.Empty;

        /// <summary>
        /// Ending verse reference (e.g., "GEN 1:31").
        /// </summary>
        public string Last { get; set; } = string.Empty;
    }
}
```

#### Validation Rules

| Field | Rule | Error Code |
|-------|------|------------|
| `primaryProjectId` | Must be a valid project ID in ScrTextCollection | `INVALID_PROJECT` |
| `comparativeProjectIds[*]` | Each must be a valid project ID | `INVALID_COMPARATIVE_PROJECT` |
| `verseRange.first` | Must be a valid verse reference if provided | `INVALID_VERSE_RANGE` |
| `verseRange.last` | Must be >= first if provided | `INVALID_VERSE_RANGE` |
| RelativelyLong/ShortVerses | Must have at least one comparative project | `COMPARATIVE_REQUIRED` |

### ChecklistSettings

**Purpose**: Type-specific configuration for checklist generation.

#### TypeScript Definition

```typescript
/**
 * Settings that apply to all checklist types.
 */
export interface ChecklistSettings {
  /** Hide rows where all cells have identical content */
  hideMatches: boolean;
}

/**
 * Settings for Verses checklist type.
 */
export interface VersesSettings extends ChecklistSettings {
  /** Include section headings in verse text */
  showSectionHeadings: boolean;
  /** Include footnotes in verse text */
  showFootnotes: boolean;
}

/**
 * Settings for Cross References and Markers checklist types.
 */
export interface ReferencedTextSettings extends ChecklistSettings {
  /** Include verse text with references/markers */
  showReferencedVerseText: boolean;
}

/**
 * Settings for Markers checklist type.
 */
export interface MarkersSettings extends ReferencedTextSettings {
  /** Filter to specific markers (empty = all paragraph markers) */
  markerFilter: string[];
  /**
   * Marker equivalence mappings for comparison.
   * Format: { "p": ["m", "pi"], "s": ["s1"] }
   */
  equivalentMarkers: Record<string, string[]>;
}

/**
 * Settings for Words/Phrases checklist type.
 */
export interface WordsPhrasesSettings extends ChecklistSettings {
  /**
   * Search strings per project.
   * Key is project ID, value is newline-separated search strings.
   */
  searchStrings: Record<string, string>;
  /** Use morphological matching via LexicalAnalyser */
  matchByMorphology: boolean;
}

/**
 * Settings for Punctuation checklist type.
 */
export interface PunctuationSettings extends ChecklistSettings {
  /** Filter to specific punctuation characters (empty = all punctuation) */
  punctuationFilter: string;
}
```

#### C# Definition

```csharp
namespace {TBD:CSharpNamespace}
{
    /// <summary>
    /// Base settings for all checklist types.
    /// </summary>
    public class ChecklistSettings
    {
        /// <summary>
        /// Hide rows where all cells have identical content.
        /// </summary>
        public bool HideMatches { get; set; }
    }

    /// <summary>
    /// Settings for Verses checklist type.
    /// </summary>
    public class VersesSettings : ChecklistSettings
    {
        /// <summary>
        /// Include section headings in verse text.
        /// </summary>
        public bool ShowSectionHeadings { get; set; }

        /// <summary>
        /// Include footnotes in verse text.
        /// </summary>
        public bool ShowFootnotes { get; set; }
    }

    /// <summary>
    /// Settings for checklist types that can show referenced verse text.
    /// </summary>
    public class ReferencedTextSettings : ChecklistSettings
    {
        /// <summary>
        /// Include verse text with references/markers.
        /// </summary>
        public bool ShowReferencedVerseText { get; set; }
    }

    /// <summary>
    /// Settings for Markers checklist type.
    /// </summary>
    public class MarkersSettings : ReferencedTextSettings
    {
        /// <summary>
        /// Filter to specific markers. Empty list includes all paragraph markers.
        /// </summary>
        public List<string> MarkerFilter { get; set; } = new();

        /// <summary>
        /// Marker equivalence mappings for comparison.
        /// Key is marker, value is list of equivalent markers.
        /// </summary>
        public Dictionary<string, List<string>> EquivalentMarkers { get; set; } = new();
    }

    /// <summary>
    /// Settings for Words/Phrases checklist type.
    /// </summary>
    public class WordsPhrasesSettings : ChecklistSettings
    {
        /// <summary>
        /// Search strings per project.
        /// Key is project ID, value is newline-separated search strings.
        /// </summary>
        public Dictionary<string, string> SearchStrings { get; set; } = new();

        /// <summary>
        /// Use morphological matching via LexicalAnalyser.
        /// </summary>
        public bool MatchByMorphology { get; set; }
    }

    /// <summary>
    /// Settings for Punctuation checklist type.
    /// </summary>
    public class PunctuationSettings : ChecklistSettings
    {
        /// <summary>
        /// Filter to specific punctuation characters. Empty includes all punctuation.
        /// </summary>
        public string PunctuationFilter { get; set; } = string.Empty;
    }
}
```

---

## 2. Output Types

### ChecklistData

**Purpose**: Container for checklist results with metadata.

#### TypeScript Definition

```typescript
/**
 * Result of checklist generation.
 */
export type ChecklistResult =
  | { success: true; data: ChecklistData }
  | { success: false; error: ChecklistError };

/**
 * Complete checklist data with rows and metadata.
 */
export interface ChecklistData {
  /** Checklist type that was generated */
  checklistType: ChecklistType;

  /** Column definitions (one per project) */
  columns: ChecklistColumn[];

  /** Data rows */
  rows: ChecklistRow[];

  /** Metadata about the generation */
  metadata: ChecklistMetadata;
}

/**
 * Column definition for a project in the checklist.
 */
export interface ChecklistColumn {
  /** Project ID */
  projectId: string;

  /** Display name for the column header */
  displayName: string;

  /** Whether this is the primary project */
  isPrimary: boolean;

  /** Whether cells in this column are editable (user has permission) */
  isEditable: boolean;
}

/**
 * Metadata about checklist generation.
 */
export interface ChecklistMetadata {
  /** Total rows before any filtering */
  totalRows: number;

  /** Number of rows hidden by hideMatches filter */
  hiddenMatchCount: number;

  /** Whether max rows limit (5000) was reached */
  maxRowsReached: boolean;

  /** Verse range that was processed */
  processedRange: VerseRange;

  /** Window title for display */
  windowTitle: string;

  /** Generation timestamp */
  generatedAt: string;
}

/**
 * Error information when checklist generation fails.
 */
export interface ChecklistError {
  /** Error code for programmatic handling */
  code: ChecklistErrorCode;

  /** Human-readable error message */
  message: string;

  /** Project ID if error is project-specific */
  projectId?: string;

  /** Additional context for error recovery */
  recoveryHint?: string;
}

export type ChecklistErrorCode =
  | 'INVALID_PROJECT'
  | 'INVALID_COMPARATIVE_PROJECT'
  | 'INVALID_VERSE_RANGE'
  | 'COMPARATIVE_REQUIRED'
  | 'SETTINGS_NOT_REVIEWED'
  | 'QUOTE_SETTINGS_INCOMPLETE'
  | 'CANCELLED'
  | 'INTERNAL_ERROR';
```

#### C# Definition

```csharp
namespace {TBD:CSharpNamespace}
{
    /// <summary>
    /// Result wrapper for checklist generation.
    /// </summary>
    public class ChecklistResult
    {
        public bool Success { get; set; }
        public ChecklistData? Data { get; set; }
        public ChecklistError? Error { get; set; }

        public static ChecklistResult Ok(ChecklistData data) =>
            new() { Success = true, Data = data };

        public static ChecklistResult Fail(ChecklistError error) =>
            new() { Success = false, Error = error };
    }

    /// <summary>
    /// Complete checklist data with rows and metadata.
    /// </summary>
    public class ChecklistData
    {
        public ChecklistType ChecklistType { get; set; }
        public List<ChecklistColumn> Columns { get; set; } = new();
        public List<ChecklistRow> Rows { get; set; } = new();
        public ChecklistMetadata Metadata { get; set; } = new();
    }

    /// <summary>
    /// Column definition for a project in the checklist.
    /// </summary>
    public class ChecklistColumn
    {
        public string ProjectId { get; set; } = string.Empty;
        public string DisplayName { get; set; } = string.Empty;
        public bool IsPrimary { get; set; }
        public bool IsEditable { get; set; }
    }

    /// <summary>
    /// Metadata about checklist generation.
    /// </summary>
    public class ChecklistMetadata
    {
        public int TotalRows { get; set; }
        public int HiddenMatchCount { get; set; }
        public bool MaxRowsReached { get; set; }
        public VerseRange ProcessedRange { get; set; } = new();
        public string WindowTitle { get; set; } = string.Empty;
        public DateTime GeneratedAt { get; set; }
    }

    /// <summary>
    /// Error information when checklist generation fails.
    /// </summary>
    public class ChecklistError
    {
        public string Code { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public string? ProjectId { get; set; }
        public string? RecoveryHint { get; set; }
    }
}
```

### ChecklistRow

**Purpose**: Single row of checklist data representing one verse reference.

#### TypeScript Definition

```typescript
/**
 * Single row in the checklist (one verse reference).
 */
export interface ChecklistRow {
  /** Row identifier (unique within this checklist) */
  id: string;

  /** Verse reference for this row (in primary project's versification) */
  reference: string;

  /** Navigation link for clicking reference */
  referenceLink: string;

  /** Cells for each project (same order as columns) */
  cells: ChecklistCell[];

  /**
   * Score for sorting (only for scored checklist types).
   * Higher score = more relevant (e.g., longer sentence, bigger ratio).
   */
  score?: number;

  /** Whether this row was hidden by hideMatches filter */
  isHiddenMatch?: boolean;
}
```

#### C# Definition

```csharp
namespace {TBD:CSharpNamespace}
{
    /// <summary>
    /// Single row in the checklist.
    /// </summary>
    public class ChecklistRow
    {
        public string Id { get; set; } = string.Empty;
        public string Reference { get; set; } = string.Empty;
        public string ReferenceLink { get; set; } = string.Empty;
        public List<ChecklistCell> Cells { get; set; } = new();
        public float? Score { get; set; }
        public bool IsHiddenMatch { get; set; }
    }
}
```

### ChecklistCell

**Purpose**: Single cell representing one project's data for a verse.

#### TypeScript Definition

```typescript
/**
 * Single cell in a checklist row.
 */
export interface ChecklistCell {
  /** Project ID this cell belongs to */
  projectId: string;

  /** Whether the cell has any content */
  hasContent: boolean;

  /** Paragraphs of content in this cell */
  paragraphs: ChecklistParagraph[];

  /** Edit link if user can edit this cell's content */
  editLink?: string;

  /** Error message if cell has an error (e.g., invalid reference) */
  error?: CellError;

  /** Message to display (e.g., "No Book Title Present") */
  message?: CellMessage;

  /** For QuotationDifferences: quote count information */
  quoteInfo?: QuoteCellInfo;

  /** For Punctuation: punctuation sequence */
  punctuationSequence?: string;

  /** Text length for scoring (RelativelyLong/Short verses) */
  textLength?: number;
}

/**
 * Error information within a cell.
 */
export interface CellError {
  /** Error message */
  message: string;
  /** Tooltip with additional details */
  tooltip?: string;
}

/**
 * Message information within a cell.
 */
export interface CellMessage {
  /** Message text */
  message: string;
  /** Tooltip with additional details */
  tooltip?: string;
}

/**
 * Quote count information for QuotationDifferences checklist.
 */
export interface QuoteCellInfo {
  /** Total outer quote count */
  outerQuoteCount: number;
  /** Inner quote count */
  innerQuoteCount?: number;
  /** Inner-inner quote count */
  innerInnerQuoteCount?: number;
  /** Continuer mark count */
  continuerCount?: number;
}
```

#### C# Definition

```csharp
namespace {TBD:CSharpNamespace}
{
    /// <summary>
    /// Single cell in a checklist row.
    /// </summary>
    public class ChecklistCell
    {
        public string ProjectId { get; set; } = string.Empty;
        public bool HasContent { get; set; }
        public List<ChecklistParagraph> Paragraphs { get; set; } = new();
        public string? EditLink { get; set; }
        public CellError? Error { get; set; }
        public CellMessage? Message { get; set; }
        public QuoteCellInfo? QuoteInfo { get; set; }
        public string? PunctuationSequence { get; set; }
        public int? TextLength { get; set; }
    }

    /// <summary>
    /// Error information within a cell.
    /// </summary>
    public class CellError
    {
        public string Message { get; set; } = string.Empty;
        public string? Tooltip { get; set; }
    }

    /// <summary>
    /// Message information within a cell.
    /// </summary>
    public class CellMessage
    {
        public string Message { get; set; } = string.Empty;
        public string? Tooltip { get; set; }
    }

    /// <summary>
    /// Quote count information for QuotationDifferences checklist.
    /// </summary>
    public class QuoteCellInfo
    {
        public int OuterQuoteCount { get; set; }
        public int? InnerQuoteCount { get; set; }
        public int? InnerInnerQuoteCount { get; set; }
        public int? ContinuerCount { get; set; }
    }
}
```

### ChecklistParagraph

**Purpose**: Paragraph of content within a cell.

#### TypeScript Definition

```typescript
/**
 * Paragraph within a checklist cell.
 */
export interface ChecklistParagraph {
  /** USFM marker for this paragraph (e.g., "p", "s", "q1") */
  marker?: string;

  /** Content items in this paragraph */
  items: ParagraphItem[];

  /** Verse reference for this paragraph (if different from row reference) */
  reference?: string;
}

/**
 * Union type for paragraph content items.
 */
export type ParagraphItem =
  | TextItem
  | VerseNumberItem
  | LinkItem
  | HighlightedTextItem;

/**
 * Plain text content.
 */
export interface TextItem {
  type: 'text';
  /** Text content */
  text: string;
  /** USFM marker for character styling */
  marker?: string;
}

/**
 * Verse number display.
 */
export interface VerseNumberItem {
  type: 'verseNumber';
  /** Verse number or range (e.g., "1", "1-2") */
  number: string;
}

/**
 * Navigation link (e.g., cross-reference target).
 */
export interface LinkItem {
  type: 'link';
  /** Display text */
  text: string;
  /** Link target (verse reference) */
  target: string;
}

/**
 * Highlighted text (for Words/Phrases search matches).
 */
export interface HighlightedTextItem {
  type: 'highlight';
  /** Matched text */
  text: string;
}
```

#### C# Definition

```csharp
namespace {TBD:CSharpNamespace}
{
    /// <summary>
    /// Paragraph within a checklist cell.
    /// </summary>
    public class ChecklistParagraph
    {
        public string? Marker { get; set; }
        public List<ParagraphItem> Items { get; set; } = new();
        public string? Reference { get; set; }
    }

    /// <summary>
    /// Base class for paragraph content items.
    /// </summary>
    public abstract class ParagraphItem
    {
        public abstract string Type { get; }
    }

    /// <summary>
    /// Plain text content.
    /// </summary>
    public class TextItem : ParagraphItem
    {
        public override string Type => "text";
        public string Text { get; set; } = string.Empty;
        public string? Marker { get; set; }
    }

    /// <summary>
    /// Verse number display.
    /// </summary>
    public class VerseNumberItem : ParagraphItem
    {
        public override string Type => "verseNumber";
        public string Number { get; set; } = string.Empty;
    }

    /// <summary>
    /// Navigation link.
    /// </summary>
    public class LinkItem : ParagraphItem
    {
        public override string Type => "link";
        public string Text { get; set; } = string.Empty;
        public string Target { get; set; } = string.Empty;
    }

    /// <summary>
    /// Highlighted text for search matches.
    /// </summary>
    public class HighlightedTextItem : ParagraphItem
    {
        public override string Type => "highlight";
        public string Text { get; set; } = string.Empty;
    }
}
```

---

## 3. API Methods

### GetChecklistData

**Purpose**: Generate checklist data based on request parameters.

#### Signatures

```csharp
// C# Data Provider
namespace {TBD:CSharpNamespace}
{
    public interface IChecklistDataProvider
    {
        /// <summary>
        /// Generate checklist data based on request parameters.
        /// </summary>
        /// <param name="request">Checklist generation request.</param>
        /// <param name="progress">Progress reporter for long operations.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>Checklist result with data or error.</returns>
        Task<ChecklistResult> GetChecklistDataAsync(
            ChecklistRequest request,
            IProgress<ChecklistProgress>? progress = null,
            CancellationToken cancellationToken = default);
    }
}
```

```typescript
// TypeScript PAPI command
/**
 * Get checklist data for display.
 * @param request - Checklist generation request
 * @returns Promise resolving to checklist result
 */
export function getChecklistData(request: ChecklistRequest): Promise<ChecklistResult>;
```

#### Preconditions

| Condition | Validation |
|-----------|------------|
| Primary project exists | `projectId` must be in ScrTextCollection |
| Comparative projects exist | Each ID must be in ScrTextCollection |
| Verse range valid | First must be <= last if specified |
| Relative checklist has comparison | RelativelyLong/ShortVerses require at least one comparative project |

#### Postconditions

| Condition | Guarantee |
|-----------|-----------|
| Row cell count | Each row has exactly N cells where N = number of projects (INV-001) |
| Max rows | Result contains at most 5000 rows (INV-002) |
| Row ordering | Rows are sorted by verse reference (POST-003) |
| Score-sorted types | Long sentences/paragraphs and relative verse types sorted by score (POST-002) |

#### Error Conditions

| Condition | Error Code | Message |
|-----------|------------|---------|
| Primary project not found | `INVALID_PROJECT` | "Project '{id}' not found" |
| Comparative project not found | `INVALID_COMPARATIVE_PROJECT` | "Comparative project '{id}' not found" |
| Invalid verse range | `INVALID_VERSE_RANGE` | "Invalid verse range: {first} to {last}" |
| Relative checklist without comparison | `COMPARATIVE_REQUIRED` | "At least one comparative project required for this checklist type" |
| Cross-ref settings not reviewed | `SETTINGS_NOT_REVIEWED` | "Scripture reference settings must be reviewed for {project}" |
| Quote settings incomplete | `QUOTE_SETTINGS_INCOMPLETE` | "Quotation mark settings incomplete for {project}" |
| User cancelled | `CANCELLED` | "Operation cancelled by user" |

#### Example Usage

```typescript
// TypeScript usage example
const request: ChecklistRequest = {
  checklistType: ChecklistType.Verses,
  primaryProjectId: 'MyProject',
  comparativeProjectIds: ['SourceText1', 'SourceText2'],
  verseRange: {
    first: 'GEN 1:1',
    last: 'GEN 1:31',
  },
  settings: {
    hideMatches: false,
    showSectionHeadings: true,
    showFootnotes: false,
  } as VersesSettings,
};

const result = await getChecklistData(request);
if (result.success) {
  console.log(`Generated ${result.data.rows.length} rows`);
} else {
  console.error(`Error: ${result.error.message}`);
}
```

#### Golden Master References

- gm-001-verses-single-project (TS-038)
- gm-002-verses-with-headings (TS-039)
- gm-003-verses-multi-project (TS-008)
- All checklist type golden masters (gm-001 through gm-017)

---

### GetAvailableProjects

**Purpose**: Get list of projects available for checklist comparison.

#### Signatures

```csharp
// C# Data Provider
namespace {TBD:CSharpNamespace}
{
    public interface IChecklistDataProvider
    {
        /// <summary>
        /// Get available projects for checklist comparison.
        /// </summary>
        /// <param name="excludeProjectId">Project ID to exclude (typically the primary project).</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>List of available projects.</returns>
        Task<List<ProjectInfo>> GetAvailableProjectsAsync(
            string? excludeProjectId = null,
            CancellationToken cancellationToken = default);
    }

    /// <summary>
    /// Basic project information for selection.
    /// </summary>
    public class ProjectInfo
    {
        public string ProjectId { get; set; } = string.Empty;
        public string DisplayName { get; set; } = string.Empty;
        public string Language { get; set; } = string.Empty;
    }
}
```

```typescript
// TypeScript PAPI command
export interface ProjectInfo {
  projectId: string;
  displayName: string;
  language: string;
}

/**
 * Get available projects for checklist comparison.
 * @param excludeProjectId - Project ID to exclude from results
 * @returns Promise resolving to list of available projects
 */
export function getAvailableProjects(excludeProjectId?: string): Promise<ProjectInfo[]>;
```

#### Preconditions

None.

#### Postconditions

| Condition | Guarantee |
|-----------|-----------|
| Exclusion | If excludeProjectId provided, that project is not in results |
| Validity | All returned projects exist in ScrTextCollection |

#### Error Conditions

None (returns empty array if no projects available).

---

### ValidateChecklistSettings

**Purpose**: Validate settings before generating checklist (prevents errors during generation).

#### Signatures

```csharp
// C# Data Provider
namespace {TBD:CSharpNamespace}
{
    public interface IChecklistDataProvider
    {
        /// <summary>
        /// Validate checklist settings before generation.
        /// </summary>
        /// <param name="request">Checklist request to validate.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>Validation result with any errors.</returns>
        Task<ValidationResult> ValidateChecklistSettingsAsync(
            ChecklistRequest request,
            CancellationToken cancellationToken = default);
    }

    /// <summary>
    /// Validation result.
    /// </summary>
    public class ValidationResult
    {
        public bool IsValid { get; set; }
        public List<ValidationError> Errors { get; set; } = new();
    }

    /// <summary>
    /// Single validation error.
    /// </summary>
    public class ValidationError
    {
        public string Code { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public string? ProjectId { get; set; }
        public string? RecoveryHint { get; set; }
    }
}
```

```typescript
// TypeScript PAPI command
export interface ValidationResult {
  isValid: boolean;
  errors: ValidationError[];
}

export interface ValidationError {
  code: string;
  message: string;
  projectId?: string;
  recoveryHint?: string;
}

/**
 * Validate checklist settings before generation.
 * @param request - Checklist request to validate
 * @returns Promise resolving to validation result
 */
export function validateChecklistSettings(request: ChecklistRequest): Promise<ValidationResult>;
```

---

## 4. Events

### ChecklistDataChanged

**Purpose**: Notify UI when checklist data may be stale due to project changes.

#### TypeScript Definition

```typescript
/**
 * Event fired when checklist data may be stale.
 */
export interface ChecklistDataChangedEvent {
  /** Type of change */
  changeType: 'projectModified' | 'projectRemoved' | 'projectAdded';

  /** Affected project ID */
  projectId: string;

  /** Whether the affected project is the primary project */
  isPrimary: boolean;

  /** Book number if change was to a specific book */
  bookNumber?: number;
}
```

#### Trigger Conditions

| Condition | Triggers Event |
|-----------|---------------|
| Primary project text modified | Yes (`projectModified`) |
| Comparative project text modified | Yes (`projectModified`) |
| Primary project deleted | Yes (`projectRemoved`) |
| Comparative project deleted | Yes (`projectRemoved`) |
| New project created | No (checklist doesn't auto-update) |
| Project settings changed | Depends on checklist type |

#### Non-Trigger Conditions

| Condition | Reason |
|-----------|--------|
| Unrelated project modified | Not in checklist's project list |
| User preference changes | Does not affect data |
| Window resized | UI-only change |

---

### NavigateToVerseRequested

**Purpose**: Request navigation to a verse reference from checklist.

#### TypeScript Definition

```typescript
/**
 * Event requesting navigation to a verse.
 */
export interface NavigateToVerseEvent {
  /** Target verse reference */
  verseReference: string;

  /** Project ID for context */
  projectId: string;

  /** Navigation type */
  navigationType: 'view' | 'edit';
}
```

---

## 5. State Transitions

### Checklist Display State

```
                    +------------------+
                    |    Unloaded      |
                    +--------+---------+
                             |
                    openChecklist(request)
                             |
                             v
                    +--------+---------+
                    |    Loading       |
                    +--------+---------+
                             |
          +------------------+------------------+
          |                                     |
     success                               error
          |                                     |
          v                                     v
  +-------+-------+                    +--------+--------+
  |    Loaded     |<---+               |     Error       |
  +-------+-------+    |               +--------+--------+
          |            |                        |
          |    refresh |                  retry |
          |            |                        |
          v            |                        |
  +-------+-------+    |               +--------+--------+
  |   Refreshing  +----+               |    Retrying     |
  +-------+-------+                    +-----------------+
          |
          |
   closeChecklist
          |
          v
  +-------+-------+
  |    Closed     |
  +---------------+
```

### State Transition Table

| Current State | Action | Next State | Conditions |
|---------------|--------|------------|------------|
| Unloaded | `openChecklist(request)` | Loading | Valid request |
| Loading | Data loaded | Loaded | No errors |
| Loading | Error occurred | Error | Error during generation |
| Loading | Cancelled | Unloaded | User cancelled |
| Loaded | `refresh()` | Refreshing | Any trigger |
| Loaded | Project removed (primary) | Closed | Primary project deleted |
| Loaded | Project removed (comparative) | Loaded | Comparative list updated |
| Loaded | `closeChecklist()` | Closed | User closes |
| Refreshing | Data loaded | Loaded | No errors |
| Refreshing | Error occurred | Error | Error during refresh |
| Error | `retry()` | Loading | User retries |
| Error | `closeChecklist()` | Closed | User closes |

---

## 6. JSON-RPC Format

### Request: getChecklistData

```json
{
  "jsonrpc": "2.0",
  "id": "checklist-001",
  "method": "{TBD:command-prefix}.getChecklistData",
  "params": {
    "checklistType": "Verses",
    "primaryProjectId": "MyProject",
    "comparativeProjectIds": ["SourceText1", "SourceText2"],
    "verseRange": {
      "first": "GEN 1:1",
      "last": "GEN 1:31"
    },
    "settings": {
      "hideMatches": false,
      "showSectionHeadings": true,
      "showFootnotes": false
    }
  }
}
```

### Success Response

```json
{
  "jsonrpc": "2.0",
  "id": "checklist-001",
  "result": {
    "success": true,
    "data": {
      "checklistType": "Verses",
      "columns": [
        { "projectId": "MyProject", "displayName": "My Project", "isPrimary": true, "isEditable": true },
        { "projectId": "SourceText1", "displayName": "Source Text 1", "isPrimary": false, "isEditable": false },
        { "projectId": "SourceText2", "displayName": "Source Text 2", "isPrimary": false, "isEditable": false }
      ],
      "rows": [
        {
          "id": "row-001",
          "reference": "GEN 1:1",
          "referenceLink": "goto:GEN 1:1",
          "cells": [
            {
              "projectId": "MyProject",
              "hasContent": true,
              "paragraphs": [
                {
                  "marker": "p",
                  "items": [
                    { "type": "verseNumber", "number": "1" },
                    { "type": "text", "text": "In the beginning God created..." }
                  ]
                }
              ],
              "editLink": "edit:GEN 1:1"
            },
            { "projectId": "SourceText1", "hasContent": true, "paragraphs": [...] },
            { "projectId": "SourceText2", "hasContent": true, "paragraphs": [...] }
          ]
        }
      ],
      "metadata": {
        "totalRows": 31,
        "hiddenMatchCount": 0,
        "maxRowsReached": false,
        "processedRange": { "first": "GEN 1:1", "last": "GEN 1:31" },
        "windowTitle": "Verses for My Project GEN 1:1-31",
        "generatedAt": "2025-01-04T12:00:00Z"
      }
    }
  }
}
```

### Error Response

```json
{
  "jsonrpc": "2.0",
  "id": "checklist-001",
  "result": {
    "success": false,
    "error": {
      "code": "SETTINGS_NOT_REVIEWED",
      "message": "In order to check cross references for the MyProject project, you must first enter or verify the punctuation, abbreviations, and short names used in your MyProject project.",
      "projectId": "MyProject",
      "recoveryHint": "Open Project > Scripture Reference Settings to review and approve the settings."
    }
  }
}
```

---

## 7. Invariants

### INV-001: Row Cell Count Equals Column Count

**Description**: Every row must have exactly N cells where N equals the number of projects being compared.

**Formal Notation**:
```
forall row in ChecklistData.rows:
  row.cells.length == ChecklistData.columns.length
```

**Enforcement**: Empty `ChecklistCell` created for missing content during row building.

### INV-002: Max Rows Limit

**Description**: Displayed rows must not exceed `maxRows` (5000).

**Formal Notation**:
```
ChecklistData.rows.length <= 5000
```

**Enforcement**: Truncation with warning in metadata when limit reached.

### INV-003: First Cell Reference Required

**Description**: The first cell in each row must have content or be explicitly empty (not undefined).

**Formal Notation**:
```
forall row in ChecklistData.rows:
  row.reference != null && row.reference != ""
```

**Enforcement**: Rows without valid reference are not added to results.

### INV-004: Versification Consistency

**Description**: All verse references in a row are normalized to the primary project's versification.

**Formal Notation**:
```
forall row in ChecklistData.rows:
  row.reference.versification == primaryProject.versification
```

**Enforcement**: `VerseRef.ChangeVersification()` during row building.

### INV-005: No Duplicate Cells Per Row

**Description**: Within a single row, each column (project) appears exactly once.

**Formal Notation**:
```
forall row in ChecklistData.rows:
  unique(row.cells.map(c => c.projectId))
```

**Enforcement**: `handledCells` tracking during row building.

### INV-006: Sorted Results

**Description**: Results are sorted appropriately for the checklist type.

**Formal Notation**:
```
if checklistType in [LongSentences, LongParagraphs, RelativelyLongVerses, RelativelyShortVerses]:
  rows.sortedBy(r => r.score, descending)
else:
  rows.sortedBy(r => r.reference.verseId, ascending)
```

---

## 8. PT10 Implementation Alignment (TBD - filled by Alignment Agent in Phase 3)

### C# Implementation

- Namespace: `{TBD:CSharpNamespace}`
- File locations: `{TBD:CSharpFilePath}`
- Base classes to extend: `{TBD:BaseClass}`
- Service pattern (static/DataProvider): `{TBD:ServicePattern}`

### TypeScript Implementation

- Extension name: `{TBD:ExtensionName}`
- Command prefix: `{TBD:CommandPrefix}`
- Type declaration file: `{TBD:TypeDeclarationFile}`

### Test Implementation

- Test framework: `{TBD:TestFramework}`
- Test base class: `{TBD:TestBaseClass}`
- Test file locations: `{TBD:TestFilePath}`
- Mock/dummy objects to use: `{TBD:MockObjects}`

Reference: See `.context/standards/paranext-core-patterns.md` for PT10 conventions.

---

## 9. Checklist Type-Specific Contracts

### Verses Checklist

**Behavior Reference**: BHV-100

**Settings**: `VersesSettings`
- `showSectionHeadings`: Include section headings before verses
- `showFootnotes`: Include footnote content with verses

**Data Extraction**:
- Extract verse text excluding verse 0 (introduction)
- Optionally include section headings (markers with `scSection` text type)
- Optionally include footnote content

**Golden Masters**: gm-001, gm-002, gm-003

---

### Section Headings Checklist

**Behavior Reference**: BHV-101

**Settings**: `ChecklistSettings` (base only)

**Data Extraction**:
- Extract paragraphs with markers of `scSection` text type
- Reference is first verse after heading
- Handle heading before chapter marker (FB-35863)
- Skip stanza breaks after headings (FB-24651)

**Golden Masters**: gm-004

---

### Book Titles Checklist

**Behavior Reference**: BHV-102

**Settings**: `ChecklistSettings` (base only)

**Data Extraction**:
- Extract paragraphs with markers of `scTitle` text type
- Always start at beginning of book (DC-004)
- Show "No Book Title Present" message if missing (EC-004)

**Golden Masters**: gm-005

---

### Footnotes Checklist

**Behavior Reference**: BHV-103

**Settings**: `ChecklistSettings` (base only)

**Data Extraction**:
- Extract content from `\f` markers only (not `\x`)
- Group by verse reference

**Golden Masters**: gm-006

---

### Cross References Checklist

**Behavior Reference**: BHV-104

**Settings**: `ReferencedTextSettings`
- `showReferencedVerseText`: Include verse text for referenced passages

**Data Extraction**:
- Extract from `\x`, `\xt`, `\r`, `\mr`, `\sr`, `\ior`, `\rq`, `\fig` markers
- Parse references using `CrossReferenceScanner` and `ParallelPassageReferenceScanner`
- Include figure references from `\fig` marker ref attribute (DC-008)
- Requires scripture reference settings to be reviewed (VAL-002)
- Show error for invalid references (EC-008)

**Golden Masters**: gm-007, gm-008

---

### Markers Checklist

**Behavior Reference**: BHV-105

**Settings**: `MarkersSettings`
- `showReferencedVerseText`: Include verse text with markers
- `markerFilter`: Filter to specific markers
- `equivalentMarkers`: Marker equivalence for matching (DC-007)

**Data Extraction**:
- Extract paragraph markers with `\marker` prefix
- Apply marker filter if specified
- Consider equivalent markers for hideMatches comparison

**Golden Masters**: gm-009, gm-010

---

### Relatively Long/Short Verses Checklist

**Behavior Reference**: BHV-106

**Settings**: `ChecklistSettings` (base only)

**Data Extraction**:
- Calculate length ratio between projects
- Score = target length / source length (long) or inverse (short)
- Missing verse = infinity score (1000000) (EC-005)
- Exclude section headings and footnotes from length
- Top 100 results only (HighScoresOnly)
- Requires at least two projects (PRE-005)

**Golden Masters**: gm-011, gm-012

---

### Long Sentences Checklist

**Behavior Reference**: BHV-107

**Settings**: `ChecklistSettings` (base only)

**Data Extraction**:
- Split text on sentence-final punctuation (DC-002)
- Use `CharacterCategorizer.IsSentenceFinalPunctuation`
- Score = inverse of sentence length
- Top 100 results only (HighScoresOnly)
- Each sentence in separate cell (no verse merging)

**Golden Masters**: gm-013

---

### Long Paragraphs Checklist

**Behavior Reference**: BHV-108

**Settings**: `ChecklistSettings` (base only)

**Data Extraction**:
- Use non-heading paragraph markers
- Score = inverse of paragraph length
- Top 100 results only (HighScoresOnly)

**Golden Masters**: gm-014

---

### Quotation Marks Checklist

**Behavior Reference**: BHV-109

**Settings**: `ChecklistSettings` (base only)

**Data Extraction**:
- Count quote marks per verse using `QuotationCheck`
- Compare quote counts between projects (DC-006)
- Exclude verses without any quotes (EC-006)
- Support nested quotes (inner, inner-inner)
- Requires quote settings to be complete (VAL-003)

**Golden Masters**: gm-015

---

### Punctuation Checklist

**Behavior Reference**: BHV-110

**Settings**: `PunctuationSettings`
- `punctuationFilter`: Filter to specific punctuation characters

**Data Extraction**:
- Extract punctuation sequences using `CharacterCategorizer.IsPunctuation`
- Apply filter if specified (spaces removed from filter)
- Compare punctuation sequences between projects

**Golden Masters**: gm-016

---

### Words/Phrases Checklist

**Behavior Reference**: BHV-111

**Settings**: `WordsPhrasesSettings`
- `searchStrings`: Per-project search strings (newline-separated)
- `matchByMorphology`: Use morphological matching

**Data Extraction**:
- Find matches using `WordOrPhraseMatcher`
- Optionally use `LexicalAnalyser` for morphological matching
- Highlight matched text with `||m3tch` marker internally
- Can be launched from Biblical Terms with pre-configured search

**Golden Masters**: gm-017

---

## 10. Cross-Cutting Concerns

### Cell Alignment (gm-019, gm-020)

**Versification Alignment** (INV-004):
- All references normalized to primary project's versification
- Uses `VerseRef.ChangeVersification()` for mapping
- Psalms are good test case (superscription differences)

**Verse Bridge Handling** (EC-002, DC-005):
- Cells merged for verse bridges (e.g., v.1-2 vs v.1, v.2)
- Maximum 3 cells merged (`MAX_CELLS_TO_GRAB`)
- `CLRowsBuilder.ExpandGrabCountToAlignCells` handles alignment

### Hide Matches Filtering (gm-018)

- Compares cell content across all columns
- Rows where all cells match are hidden
- For Markers: considers equivalent marker mappings
- For QuotationDifferences: compares quote counts
- Hidden row count reported in metadata

---

## 11. Decisions Made

| Decision | Options Considered | Choice | Rationale |
|----------|-------------------|--------|-----------|
| Result type structure | Discriminated union vs nullable | Discriminated union (`success: boolean`) | Clear separation of success/error paths, TypeScript-friendly |
| Cell content model | Flat string vs structured paragraphs | Structured paragraphs with typed items | Preserves USFM structure, enables rich rendering |
| Settings inheritance | Single settings type vs hierarchy | Inheritance hierarchy | Type-safe per-checklist-type settings |
| Error codes | String literals vs enum | String literal union type | Flexible, serializable, human-readable |
| Score representation | Integer vs float | Float (`number` / `float`) | Allows fractional scores for length ratios |
| Row ID format | UUID vs sequential | String (implementation-defined) | Flexibility for UI keying requirements |
| TBD placeholder usage | Fake namespaces vs explicit placeholders | Explicit `{TBD:*}` markers | Clear indication for Alignment Agent, no false assumptions |

### Decision Details

**Result Type Structure**:
- Context: Need to handle both successful data and errors from data provider
- Options: (1) Nullable data with separate error field, (2) Discriminated union with `success` flag
- Choice: Discriminated union
- Rationale: TypeScript can narrow types based on `success` boolean, making error handling explicit
- Consequences: Client code must check `success` before accessing `data` or `error`

**Cell Content Model**:
- Context: Cells contain rich text with verse numbers, highlights, links
- Options: (1) HTML string (like PT9), (2) Plain text, (3) Structured paragraph/item model
- Choice: Structured model with `ChecklistParagraph` and typed `ParagraphItem`
- Rationale: Enables React component rendering without HTML parsing, preserves semantic structure
- Consequences: More complex data model but cleaner separation of concerns

**Settings Inheritance**:
- Context: 13 checklist types with different configuration options
- Options: (1) Single settings type with all optional fields, (2) Union type, (3) Inheritance hierarchy
- Choice: Inheritance hierarchy with base `ChecklistSettings` and type-specific extensions
- Rationale: Type-safe, clear which settings apply to which types
- Consequences: Client needs to cast settings to correct subtype for each checklist type

---

## 12. Summary

### Types Defined

| Category | Count |
|----------|-------|
| Input types | 10 (ChecklistType, ChecklistRequest, VerseRange, 7 settings types) |
| Output types | 14 (ChecklistResult, ChecklistData, ChecklistRow, ChecklistCell, etc.) |
| **Total types** | **24** |

### Methods Documented

| Method | Purpose |
|--------|---------|
| `getChecklistData` | Main data generation method |
| `getAvailableProjects` | List projects for comparison selection |
| `validateChecklistSettings` | Pre-flight validation |
| **Total methods** | **3** |

### Events

| Event | Purpose |
|-------|---------|
| `ChecklistDataChangedEvent` | Notify of stale data |
| `NavigateToVerseEvent` | Request verse navigation |
| **Total events** | **2** |

### Invariants

| Invariant | Coverage |
|-----------|----------|
| INV-001 (Row cell count) | All golden masters |
| INV-002 (Max rows) | Metadata field |
| INV-003 (Reference required) | All row types |
| INV-004 (Versification) | gm-019 |
| INV-005 (No duplicate cells) | gm-003 |
| INV-006 (Sorted results) | gm-011 through gm-014 |
| **Total invariants** | **6** |

### API Surface Complexity

**Assessment**: **Complex**

Factors:
1. 13 distinct checklist types with different data extraction logic
2. Type-specific settings with inheritance hierarchy
3. Complex cell alignment across versifications
4. Multiple error conditions requiring validation
5. Integration with multiple ParatextData services

### Gaps and Clarifications Needed

1. **Progress reporting**: The `IProgress<ChecklistProgress>` interface is referenced but not fully defined. The Alignment Agent should specify the progress model.

2. **Edit permission model**: The contract assumes `isEditable` is determined by the data provider based on user permissions, but the permission checking mechanism is TBD.

3. **Localization keys**: Error messages are defined as strings; localization key mapping is TBD.

4. **Biblical Terms integration**: The contract supports Words/Phrases checklist but does not define the API for Biblical Terms to launch it with pre-configured search strings.

### Readiness for Phase 3

**Status**: Ready with TBD markers

The contract is complete for the Alignment Agent to:
1. Replace `{TBD:*}` placeholders with actual PT10 patterns
2. Map to existing PT10 infrastructure (PAPI commands, data providers)
3. Identify existing components to reuse (table components, dialogs)
4. Define test infrastructure setup

The Component Builder can begin React component design based on the TypeScript types defined here.
