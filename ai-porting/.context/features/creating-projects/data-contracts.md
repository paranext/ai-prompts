# Data Contracts: Creating Projects

## Overview

This document defines the formal API contracts for the Creating Projects feature in PT10. It serves as the single source of truth for the interface between:
- **TypeScript (UI/Extension layer)**: React components and PAPI command handlers
- **C# (Data Provider layer)**: ParatextData integration via .NET interop

The contracts are designed for a **Level A** feature with **95% ParatextData reuse**. All core business logic resides in ParatextData.dll; PT10 provides a thin orchestration layer.

### Related Documents
- Behavior Catalog: 20 behaviors (BHV-001 through BHV-020)
- Business Rules: 7 invariants (INV-001 through INV-007), 11 validation rules (VAL-001 through VAL-011)
- Test Specifications: 85 specifications across 7 files

---

## TypeScript Types

### Input Types

```typescript
/**
 * Request to create a new Paratext project.
 * Maps to ParatextData ScrText initialization.
 *
 * @see BHV-001, BHV-002, BHV-007
 */
interface CreateProjectRequest {
  /** Project short name (3-8 chars, A-Za-z0-9_). Forms directory name. */
  shortName: string;

  /** Human-readable project name (1+ chars). */
  fullName: string;

  /** Project type determining base project requirements. */
  projectType: ProjectType;

  /** BCP-47 language identifier (e.g., "en", "es-419"). */
  languageId: string;

  /** Human-readable language name (e.g., "English", "Spanish"). */
  languageName: string;

  /** Bible versification scheme. */
  versification: VersificationType;

  /** Unicode normalization form. Default: NFC. */
  normalizationForm?: NormalizationType;

  /** Text encoding. Default: UTF-8 (65001). */
  encoding?: string;

  /** USFM version. Default: Version3. */
  usfmVersion?: UsfmVersionType;

  /** Copyright notice. Optional. */
  copyright?: string;

  /**
   * Base project reference for derived project types.
   * Required when projectType.isDerivedType() is true.
   * @see INV-004
   */
  baseProjectId?: string;

  /** Planned books for the project scope. Optional. */
  plannedBooks?: BookId[];

  /** Comment tags for note projects. Optional. */
  commentTags?: CommentTag[];
}

/**
 * Request to validate a project short name.
 * @see BHV-005, VAL-001 through VAL-006
 */
interface ValidateProjectNameRequest {
  /** The short name to validate. */
  shortName: string;

  /** True if validating for a new project (checks uniqueness). */
  isNewProject: boolean;

  /** Original name if editing existing project (for self-collision check). */
  originalName?: string;
}

/**
 * Request to generate a unique project name.
 * @see BHV-004
 */
interface GenerateUniqueNameRequest {
  /** Initial short name to derive unique name from. */
  shortName: string;

  /** Initial long name to derive unique name from. */
  longName: string;

  /** Force numeric suffix even if base name is available. */
  forceNumbered?: boolean;
}

/**
 * Request to generate an abbreviation from a full name.
 * @see BHV-006
 */
interface GenerateAbbreviationRequest {
  /** Full project name to abbreviate. */
  fullName: string;
}
```

### Output Types

```typescript
/**
 * Result of project creation operation.
 * Uses discriminated union for type-safe error handling.
 */
type CreateProjectResult = CreateProjectSuccess | CreateProjectError;

interface CreateProjectSuccess {
  success: true;

  /** The unique project identifier (40-char hex GUID). */
  projectId: string;

  /** The assigned short name (may differ if auto-generated). */
  shortName: string;

  /** Full path to project directory. */
  projectPath: string;
}

interface CreateProjectError {
  success: false;

  /** Semantic error code for programmatic handling. */
  errorCode: ProjectCreationErrorCode;

  /** Human-readable error message. */
  errorMessage: string;

  /** Additional context for debugging. */
  details?: Record<string, unknown>;
}

/**
 * Result of name validation.
 */
interface ValidationResult {
  /** True if the name is valid. */
  valid: boolean;

  /** Error code if invalid. */
  errorCode?: NameValidationErrorCode;

  /** Localized error message if invalid. */
  errorMessage?: string;
}

/**
 * Result of unique name generation.
 */
interface GenerateUniqueNameResult {
  /** Generated unique short name. */
  shortName: string;

  /** Generated unique long name. */
  longName: string;

  /** True if the name was modified to ensure uniqueness. */
  wasModified: boolean;
}

/**
 * Result of abbreviation generation.
 */
interface GenerateAbbreviationResult {
  /** Generated abbreviation (3-8 chars). */
  abbreviation: string;
}

/**
 * Minimal project information returned by queries.
 */
interface ProjectInfo {
  /** Project short name. */
  shortName: string;

  /** Project full name. */
  fullName: string;

  /** Project GUID (40-char hex). */
  projectId: string;

  /** Project type. */
  projectType: ProjectType;

  /** Base project ID for derived types. */
  baseProjectId?: string;

  /** BCP-47 language code. */
  languageId: string;
}
```

### Enum Types

```typescript
/**
 * Project type enumeration.
 * Maps directly to ParatextData ProjectType enum.
 * @see spec-004
 */
enum ProjectType {
  /** Not yet specified. */
  NotSpecified = 0,

  /** Standard translation project. No base required. */
  Standard = 1,

  /** Back translation of another project. Requires base. */
  BackTranslation = 2,

  /** Daughter translation based on another project. Requires base. */
  Daughter = 3,

  /** Study Bible additions project. Requires scripture base. */
  StudyBibleAdditions = 4,

  /** Published/merged Study Bible. Requires base. */
  StudyBiblePublished = 5,

  /** Consultant notes project. Requires base. */
  ConsultantNotes = 6,

  /** Auxiliary project. Requires base. Shares license with parent. */
  Auxiliary = 7,

  /** Manual transliteration. Requires base. Shares license with parent. */
  TransliterationManual = 8,

  /** Encoder-based transliteration. Requires base. Shares license with parent. */
  TransliterationWithEncoder = 9,
}

/**
 * Bible versification schemes.
 * Maps to ParatextData ScrVersType.
 */
enum VersificationType {
  English = 'English',
  Original = 'Original',
  Septuagint = 'Septuagint',
  Vulgate = 'Vulgate',
  RussianProtestant = 'RussianProtestant',
  RussianOrthodox = 'RussianOrthodox',
}

/**
 * Unicode normalization forms.
 * Maps to ParatextData ProjectNormalization.
 */
enum NormalizationType {
  /** No normalization specified. */
  Undefined = 'Undefined',

  /** Canonical decomposition followed by canonical composition (recommended). */
  NFC = 'NFC',

  /** Canonical decomposition. */
  NFD = 'NFD',
}

/**
 * USFM version options.
 * Maps to ParatextData UsfmVersionOption.
 */
enum UsfmVersionType {
  Version2 = 'Version2',
  Version3 = 'Version3',
}

/**
 * Error codes for project creation failures.
 */
enum ProjectCreationErrorCode {
  // Name validation errors (VAL-001 through VAL-006)
  NAME_TOO_SHORT = 'NAME_TOO_SHORT',
  NAME_TOO_LONG = 'NAME_TOO_LONG',
  NAME_INVALID_CHARS = 'NAME_INVALID_CHARS',
  NAME_CONTAINS_SPACE = 'NAME_CONTAINS_SPACE',
  NAME_RESERVED = 'NAME_RESERVED',
  NAME_DUPLICATE = 'NAME_DUPLICATE',
  NAME_CASE_COLLISION = 'NAME_CASE_COLLISION',
  FOLDER_EXISTS = 'FOLDER_EXISTS',

  // Input validation errors (VAL-007 through VAL-011)
  FULL_NAME_REQUIRED = 'FULL_NAME_REQUIRED',
  INVALID_LANGUAGE_ID = 'INVALID_LANGUAGE_ID',
  TRANSLATION_INFO_REQUIRED = 'TRANSLATION_INFO_REQUIRED',
  LANGUAGE_ID_REQUIRED = 'LANGUAGE_ID_REQUIRED',
  NAME_CHANGE_FORBIDDEN = 'NAME_CHANGE_FORBIDDEN',

  // Derived project errors (INV-004)
  BASE_PROJECT_REQUIRED = 'BASE_PROJECT_REQUIRED',
  BASE_PROJECT_NOT_FOUND = 'BASE_PROJECT_NOT_FOUND',

  // System errors
  DIRECTORY_CREATION_FAILED = 'DIRECTORY_CREATION_FAILED',
  MERCURIAL_INIT_FAILED = 'MERCURIAL_INIT_FAILED',
  GUID_CALCULATION_FAILED = 'GUID_CALCULATION_FAILED',
  SETTINGS_SAVE_FAILED = 'SETTINGS_SAVE_FAILED',
  COLLECTION_ADD_FAILED = 'COLLECTION_ADD_FAILED',

  // Permission errors
  USER_IS_GUEST = 'USER_IS_GUEST',
  PERMISSION_DENIED = 'PERMISSION_DENIED',

  // Resource restriction (INV-005)
  RESOURCE_VERSIONING_FORBIDDEN = 'RESOURCE_VERSIONING_FORBIDDEN',

  // Unknown/generic
  UNKNOWN_ERROR = 'UNKNOWN_ERROR',
}

/**
 * Error codes specific to name validation.
 */
enum NameValidationErrorCode {
  TOO_SHORT = 'TOO_SHORT',
  TOO_LONG = 'TOO_LONG',
  INVALID_CHARS = 'INVALID_CHARS',
  CONTAINS_SPACE = 'CONTAINS_SPACE',
  RESERVED_NAME = 'RESERVED_NAME',
  DUPLICATE = 'DUPLICATE',
  CASE_COLLISION = 'CASE_COLLISION',
  FOLDER_EXISTS = 'FOLDER_EXISTS',
}

/**
 * Book identifiers using standard 3-letter codes.
 */
type BookId = 'GEN' | 'EXO' | 'LEV' | 'NUM' | 'DEU' | /* ... all 66+ books */ string;
```

### Validation Types

```typescript
/**
 * Short name validation constraints.
 * @see VAL-001 through VAL-006
 */
interface ShortNameConstraints {
  /** Minimum length (inclusive). */
  minLength: 3;

  /** Maximum length (inclusive). */
  maxLength: 8;

  /** Allowed character pattern. */
  pattern: RegExp; // /^[A-Za-z0-9_]+$/

  /** Reserved Windows filenames that cannot be used. */
  reservedNames: readonly string[]; // ['CON', 'PRN', 'AUX', 'NUL', 'COM1'-'COM9', 'LPT1'-'LPT9']
}

/**
 * Full name validation constraints.
 * @see VAL-007
 */
interface FullNameConstraints {
  /** Minimum length after trimming. */
  minLength: 1;

  /** Characters that are auto-converted. */
  autoConvert: { '\\': '/' };
}

/**
 * Comment tag definition for note projects.
 * @see BHV-014
 */
interface CommentTag {
  /** Tag identifier. */
  id: string;

  /** Display name. */
  name: string;

  /** Icon identifier. */
  icon?: string;
}
```

### Type Guards and Utilities

```typescript
/**
 * Check if a project type requires a base project.
 * @see INV-004, spec-004-03
 */
function isDerivedType(type: ProjectType): boolean {
  return [
    ProjectType.BackTranslation,
    ProjectType.Daughter,
    ProjectType.StudyBibleAdditions,
    ProjectType.StudyBiblePublished,
    ProjectType.ConsultantNotes,
    ProjectType.Auxiliary,
    ProjectType.TransliterationManual,
    ProjectType.TransliterationWithEncoder,
  ].includes(type);
}

/**
 * Check if a project type is a Study Bible type.
 * @see spec-004-04
 */
function isStudyBibleType(type: ProjectType): boolean {
  return type === ProjectType.StudyBibleAdditions ||
         type === ProjectType.StudyBiblePublished;
}

/**
 * Check if a project type shares license with parent.
 * @see spec-004-05, CON-004
 */
function sharesLicenseWithParent(type: ProjectType): boolean {
  return [
    ProjectType.BackTranslation,
    ProjectType.Auxiliary,
    ProjectType.TransliterationManual,
    ProjectType.TransliterationWithEncoder,
  ].includes(type);
}

/**
 * Get the standard stylesheet for a project type.
 * @see spec-004-06, CON-005
 */
function getStandardStylesheet(type: ProjectType): string {
  return isStudyBibleType(type) ? 'usfm_sb.sty' : 'usfm.sty';
}

/**
 * Type guard for successful creation result.
 */
function isCreateSuccess(result: CreateProjectResult): result is CreateProjectSuccess {
  return result.success === true;
}

/**
 * Type guard for creation error result.
 */
function isCreateError(result: CreateProjectResult): result is CreateProjectError {
  return result.success === false;
}
```

---

## C# Types (ParatextData Interop)

### Request/Response DTOs

```csharp
using Paratext.Data;
using Paratext.Data.ProjectSettingsAccess;
using Paratext.Data.Repository;

namespace {TBD:CSharpNamespace}
{
    /// <summary>
    /// Data transfer object for project creation requests from TypeScript layer.
    /// Maps incoming JSON-RPC requests to ParatextData operations.
    /// </summary>
    public record CreateProjectRequestDto(
        string ShortName,
        string FullName,
        ProjectType ProjectType,
        string LanguageId,
        string LanguageName,
        ScrVersType Versification,
        ProjectNormalization NormalizationForm = ProjectNormalization.NFC,
        string Encoding = "65001",
        UsfmVersionOption UsfmVersion = UsfmVersionOption.Version3,
        string? Copyright = null,
        string? BaseProjectId = null,
        string[]? PlannedBooks = null,
        CommentTagDto[]? CommentTags = null
    );

    /// <summary>
    /// Data transfer object for comment tags.
    /// </summary>
    public record CommentTagDto(
        string Id,
        string Name,
        string? Icon = null
    );

    /// <summary>
    /// Result of project creation operation.
    /// </summary>
    public record CreateProjectResultDto
    {
        public bool Success { get; init; }
        public string? ProjectId { get; init; }
        public string? ShortName { get; init; }
        public string? ProjectPath { get; init; }
        public string? ErrorCode { get; init; }
        public string? ErrorMessage { get; init; }

        public static CreateProjectResultDto Succeeded(string projectId, string shortName, string projectPath)
            => new() { Success = true, ProjectId = projectId, ShortName = shortName, ProjectPath = projectPath };

        public static CreateProjectResultDto Failed(string errorCode, string errorMessage)
            => new() { Success = false, ErrorCode = errorCode, ErrorMessage = errorMessage };
    }

    /// <summary>
    /// Request for name validation.
    /// </summary>
    public record ValidateProjectNameRequestDto(
        string ShortName,
        bool IsNewProject,
        string? OriginalName = null
    );

    /// <summary>
    /// Result of name validation.
    /// </summary>
    public record ValidationResultDto(
        bool Valid,
        string? ErrorCode = null,
        string? ErrorMessage = null
    );

    /// <summary>
    /// Request for unique name generation.
    /// </summary>
    public record GenerateUniqueNameRequestDto(
        string ShortName,
        string LongName,
        bool ForceNumbered = false
    );

    /// <summary>
    /// Result of unique name generation.
    /// </summary>
    public record GenerateUniqueNameResultDto(
        string ShortName,
        string LongName,
        bool WasModified
    );

    /// <summary>
    /// Minimal project information for queries.
    /// </summary>
    public record ProjectInfoDto(
        string ShortName,
        string FullName,
        string ProjectId,
        ProjectType ProjectType,
        string? BaseProjectId,
        string LanguageId
    );
}
```

### Mapping to ParatextData Types

| TypeScript Type | C# DTO | ParatextData Type | Notes |
|-----------------|--------|-------------------|-------|
| `CreateProjectRequest` | `CreateProjectRequestDto` | `ScrText` + properties | Creates and configures ScrText instance |
| `ProjectType` enum | `ProjectType` | `Paratext.Data.ProjectType` | Direct mapping |
| `VersificationType` | `ScrVersType` | `Paratext.Data.ScrVersType` | Enum values match |
| `NormalizationType` | `ProjectNormalization` | `Paratext.Data.ProjectNormalization` | Enum values match |
| `UsfmVersionType` | `UsfmVersionOption` | `Paratext.Data.UsfmVersionOption` | Enum values match |
| `projectId` (string) | `HexId` | `Paratext.Data.HexId` | 40-char hex GUID |
| `languageId` (string) | `LanguageId` | `Paratext.Data.LanguageId` | BCP-47 validation |
| `TranslationInformation` | - | `Paratext.Data.ProjectSettingsAccess.TranslationInformation` | Project type + base reference |

### Service Interface

```csharp
namespace {TBD:CSharpNamespace}
{
    /// <summary>
    /// Service interface for project creation operations.
    /// Wraps ParatextData operations for PT10 integration.
    /// </summary>
    public interface IProjectCreationService
    {
        /// <summary>
        /// Creates a new project with the specified settings.
        /// </summary>
        /// <param name="request">Project creation request.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>Result indicating success or failure with details.</returns>
        Task<CreateProjectResultDto> CreateProjectAsync(
            CreateProjectRequestDto request,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Validates a project short name.
        /// </summary>
        /// <param name="request">Validation request.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>Validation result.</returns>
        Task<ValidationResultDto> ValidateProjectNameAsync(
            ValidateProjectNameRequestDto request,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Generates a unique project name based on the input.
        /// </summary>
        /// <param name="request">Generation request.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>Generated unique name.</returns>
        Task<GenerateUniqueNameResultDto> GenerateUniqueNameAsync(
            GenerateUniqueNameRequestDto request,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Generates an abbreviation from a full project name.
        /// </summary>
        /// <param name="fullName">Full name to abbreviate.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>Generated abbreviation (3-8 chars).</returns>
        Task<string> GenerateAbbreviationAsync(
            string fullName,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Gets a list of all projects available for use as base projects.
        /// </summary>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>List of project info DTOs.</returns>
        Task<IReadOnlyList<ProjectInfoDto>> GetAvailableBaseProjectsAsync(
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Cancels project creation and cleans up any partial state.
        /// </summary>
        /// <param name="shortName">Short name of project being cancelled.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        Task CancelProjectCreationAsync(
            string shortName,
            CancellationToken cancellationToken = default);
    }
}
```

---

## API Methods

### Method: CreateProject

Creates a new Paratext project with the specified configuration.

#### C# Signature

```csharp
Task<CreateProjectResultDto> CreateProjectAsync(
    CreateProjectRequestDto request,
    CancellationToken cancellationToken = default);
```

#### TypeScript Signature

```typescript
function createProject(request: CreateProjectRequest): Promise<CreateProjectResult>;
```

#### Preconditions

| ID | Condition | Error Code | Source |
|----|-----------|------------|--------|
| PRE-001 | User is not a guest | `USER_IS_GUEST` | MainForm.UpdateMenuItemState |
| PRE-003 | All validation rules pass | Various | ProjectPropertiesForm.cmdOK_Click |
| PRE-004 | Base project exists (if derived type) | `BASE_PROJECT_NOT_FOUND` | TranslationInformation.BaseScrText |

#### Postconditions

| ID | Condition | Source |
|----|-----------|--------|
| POST-001 | Project directory exists at `{SettingsDirectory}/{shortName}` | BHV-007 |
| POST-002 | Settings.xml exists in project directory | BHV-007, INV-006 |
| POST-003 | .hg directory exists (Mercurial initialized) | BHV-008 |
| POST-004 | Project has valid GUID | BHV-009, INV-002 |
| POST-005 | Project is in ScrTextCollection | BHV-010 |
| POST-006 | Study Bible projects have copied books | BHV-012 |
| POST-007 | License-sharing types have license.json copied | BHV-013, CON-004 |

#### Error Conditions

| Condition | Error Code | Message | Source |
|-----------|------------|---------|--------|
| Short name < 3 chars | `NAME_TOO_SHORT` | "Short name must not be less than 3 or more than 8 characters in length" | VAL-001 |
| Short name > 8 chars | `NAME_TOO_LONG` | "Short name must not be less than 3 or more than 8 characters in length" | VAL-001 |
| Short name contains spaces | `NAME_CONTAINS_SPACE` | "Short name must not contain spaces" | VAL-003 |
| Short name has invalid chars | `NAME_INVALID_CHARS` | "Short name can only contain letters A-Z, digits 0-9, and underscores." | VAL-002 |
| Reserved Windows filename | `NAME_RESERVED` | "Project Short Name is a reserved file name on Windows and cannot be used." | VAL-004 |
| Duplicate name (exact) | `NAME_DUPLICATE` | "A project already exists with the name '{name}'" | INV-001 |
| Case-insensitive collision | `NAME_CASE_COLLISION` | "Another project exists ({name}) with the same name, but a different case." | VAL-005 |
| Folder already exists | `FOLDER_EXISTS` | "A folder exists ({path}) with the same name." | VAL-006 |
| Empty full name | `FULL_NAME_REQUIRED` | "You must enter a full name" | VAL-007 |
| Invalid language ID | `INVALID_LANGUAGE_ID` | "Language ID '{id}' is not a valid language tag." | VAL-008 |
| Derived type without base | `BASE_PROJECT_REQUIRED` | "Derived project types require a base project" | INV-004 |
| Base project not found | `BASE_PROJECT_NOT_FOUND` | "Base project '{id}' not found" | PRE-004 |
| Directory creation failed | `DIRECTORY_CREATION_FAILED` | "Could not create project directory" | BHV-007 |
| Mercurial init failed | `MERCURIAL_INIT_FAILED` | "Failed to initialize version control" | BHV-008 |
| GUID calculation failed | `GUID_CALCULATION_FAILED` | "Failed to assign project identifier" | BHV-009 |

#### Example Usage

```typescript
// TypeScript - Creating a standard translation project
const result = await papi.commands.sendCommand(
  '{TBD:ExtensionName}.createProject',
  {
    shortName: 'NewTrans',
    fullName: 'New Translation Project',
    projectType: ProjectType.Standard,
    languageId: 'es-419',
    languageName: 'Spanish (Latin America)',
    versification: VersificationType.English,
  }
);

if (isCreateSuccess(result)) {
  console.log(`Project created: ${result.projectId}`);
} else {
  console.error(`Creation failed: ${result.errorCode} - ${result.errorMessage}`);
}

// TypeScript - Creating a back translation project
const btResult = await papi.commands.sendCommand(
  '{TBD:ExtensionName}.createProject',
  {
    shortName: 'NewBT',
    fullName: 'New Back Translation',
    projectType: ProjectType.BackTranslation,
    languageId: 'en',
    languageName: 'English',
    versification: VersificationType.English, // Will be inherited from base
    baseProjectId: 'abc123...', // Required for derived types
  }
);
```

```csharp
// C# - Service implementation calling ParatextData
public async Task<CreateProjectResultDto> CreateProjectAsync(
    CreateProjectRequestDto request,
    CancellationToken cancellationToken = default)
{
    // Validate short name
    var validationError = ParatextUtils.ValidateShortName(
        request.ShortName, isNewProject: true, originalName: null);
    if (validationError != null)
    {
        return CreateProjectResultDto.Failed("NAME_VALIDATION_FAILED", validationError);
    }

    // Create ScrText instance
    var user = RegistrationInfo.DefaultUser;
    var scrText = new ScrText(user);

    // Apply default settings (BHV-002)
    scrText.Settings.FullName = request.FullName;
    scrText.Settings.FileNameForm = "41MAT";
    scrText.Settings.DefaultStylesheetFileName = GetStylesheet(request.ProjectType);
    scrText.Settings.Encoding = request.Encoding;
    scrText.Settings.NormalizationForm = request.NormalizationForm;
    scrText.Settings.UsfmVersion = request.UsfmVersion;

    // Set up translation info (BHV-011)
    var translationInfo = CreateTranslationInfo(request);
    scrText.Settings.TranslationInfo = translationInfo;

    // Create directory and initialize (BHV-007, BHV-008)
    scrText.Name = request.ShortName;
    FileUtils.CreateFolder(scrText.Directory);

    // Initialize versioning and assign GUID (BHV-009)
    VersioningManager.Default.EnsureHasGuid(scrText);

    // Save settings (INV-006)
    scrText.Save();

    // Add to collection (BHV-010, INV-007)
    ScrTextCollection.Add(scrText);

    return CreateProjectResultDto.Succeeded(
        scrText.Settings.Guid.ToString(),
        scrText.Name,
        scrText.Directory);
}
```

#### Test Scenario References

- spec-001-07: Complete project creation flow
- spec-001-01 through spec-001-06: Individual steps

---

### Method: ValidateProjectName

Validates a project short name against all validation rules.

#### C# Signature

```csharp
Task<ValidationResultDto> ValidateProjectNameAsync(
    ValidateProjectNameRequestDto request,
    CancellationToken cancellationToken = default);
```

#### TypeScript Signature

```typescript
function validateProjectName(request: ValidateProjectNameRequest): Promise<ValidationResult>;
```

#### Preconditions

None - validation can be performed at any time.

#### Postconditions

None - validation is a pure function with no side effects.

#### Error Conditions

| Condition | Error Code | Message |
|-----------|------------|---------|
| Length < 3 | `TOO_SHORT` | "Short name must not be less than 3 or more than 8 characters in length" |
| Length > 8 | `TOO_LONG` | "Short name must not be less than 3 or more than 8 characters in length" |
| Contains space | `CONTAINS_SPACE` | "Short name must not contain spaces" |
| Invalid character | `INVALID_CHARS` | "Short name can only contain letters A-Z, digits 0-9, and underscores." |
| Reserved name | `RESERVED_NAME` | "Project Short Name is a reserved file name on Windows and cannot be used." |
| Duplicate (exact) | `DUPLICATE` | "A project already exists with the name '{name}'" |
| Case collision | `CASE_COLLISION` | "Another project exists ({name}) with the same name, but a different case." |
| Folder exists | `FOLDER_EXISTS` | "A folder exists ({path}) with the same name." |

#### Example Usage

```typescript
// TypeScript - Real-time validation as user types
const result = await papi.commands.sendCommand(
  '{TBD:ExtensionName}.validateProjectName',
  {
    shortName: 'Test_1',
    isNewProject: true,
  }
);

if (result.valid) {
  enableSubmitButton();
} else {
  showValidationError(result.errorMessage);
}
```

#### Test Scenario References

- spec-002-01 through spec-002-11: All short name validation rules

---

### Method: GenerateUniqueName

Generates a unique project name based on the input, appending numeric suffixes if needed.

#### C# Signature

```csharp
Task<GenerateUniqueNameResultDto> GenerateUniqueNameAsync(
    GenerateUniqueNameRequestDto request,
    CancellationToken cancellationToken = default);
```

#### TypeScript Signature

```typescript
function generateUniqueName(request: GenerateUniqueNameRequest): Promise<GenerateUniqueNameResult>;
```

#### Preconditions

None.

#### Postconditions

- Returned name is guaranteed unique in ScrTextCollection (INV-001)
- Returned name passes all validation rules

#### Error Conditions

None - always succeeds by finding an available name.

#### Example Usage

```typescript
// TypeScript - Auto-generate unique name
const result = await papi.commands.sendCommand(
  '{TBD:ExtensionName}.generateUniqueName',
  {
    shortName: 'ABC',
    longName: 'ABC Translation',
    forceNumbered: false,
  }
);

// If 'ABC' exists, result might be { shortName: 'ABC1', longName: 'ABC Translation 1', wasModified: true }
```

#### Test Scenario References

- spec-002-16: Generate unique project name
- spec-002-17: Trailing digits trimmed
- spec-002-18: Iterate to find unused

---

### Method: GenerateAbbreviation

Generates a short name abbreviation from a full project name.

#### C# Signature

```csharp
Task<string> GenerateAbbreviationAsync(
    string fullName,
    CancellationToken cancellationToken = default);
```

#### TypeScript Signature

```typescript
function generateAbbreviation(request: GenerateAbbreviationRequest): Promise<GenerateAbbreviationResult>;
```

#### Preconditions

None.

#### Postconditions

- Result is 3-8 characters
- Result contains only valid characters (A-Za-z0-9_)

#### Algorithm

1. Extract first letter of each word
2. Extract digits separately, use last 2 digits
3. Append digits to end of letters
4. If result < 3 chars, pad with last valid character from input
5. If result > 8 chars, truncate (leaving room for digits)

#### Example Usage

```typescript
// TypeScript - Auto-generate abbreviation as user types full name
const result = await papi.commands.sendCommand(
  '{TBD:ExtensionName}.generateAbbreviation',
  { fullName: 'New English Translation 2020' }
);

// Result: { abbreviation: 'NET20' }
```

#### Test Scenario References

- spec-002-12: Basic abbreviation
- spec-002-13: With digits
- spec-002-14: Pad to minimum length
- spec-002-15: Truncate to maximum length

---

### Method: CancelProjectCreation

Cancels an in-progress project creation and cleans up any partial state.

#### C# Signature

```csharp
Task CancelProjectCreationAsync(
    string shortName,
    CancellationToken cancellationToken = default);
```

#### TypeScript Signature

```typescript
function cancelProjectCreation(shortName: string): Promise<void>;
```

#### Preconditions

- Project creation was started but not completed

#### Postconditions

- Project directory deleted (if created)
- VersionedText removed from VersioningManager
- Project removed from ScrTextCollection (if added)
- No orphan files remain

#### Error Conditions

None - cleanup is best-effort.

#### Test Scenario References

- spec-005-08: Cancel removes VersionedText
- spec-007-04: Plugin cleanup on error

---

## Events (If Applicable)

### Event: ProjectCreated

Fired when a project is successfully created.

#### Payload

```typescript
interface ProjectCreatedEvent {
  /** The created project's GUID. */
  projectId: string;

  /** The project short name. */
  shortName: string;

  /** The project type. */
  projectType: ProjectType;

  /** Timestamp of creation. */
  createdAt: string; // ISO 8601
}
```

#### Trigger Conditions

- CreateProjectAsync completes successfully
- Project added to ScrTextCollection

#### Non-Trigger Conditions

- Validation failures
- Cancelled creation
- System errors during creation

---

## State Transitions

### Project Creation State Machine

```
                 ┌─────────────────┐
                 │    Initial      │
                 │   (No Project)  │
                 └────────┬────────┘
                          │
                          │ CreateProject called
                          ▼
                 ┌─────────────────┐
                 │   Validating    │──── Validation fails ───► (Initial)
                 └────────┬────────┘
                          │
                          │ Validation passes
                          ▼
                 ┌─────────────────┐
                 │ Creating Dirs   │──── Dir creation fails ──► (Initial)
                 └────────┬────────┘
                          │
                          │ Directory created
                          ▼
                 ┌─────────────────┐
                 │ Initializing Hg │──── Hg init fails ───────► Cleanup ──► (Initial)
                 └────────┬────────┘
                          │
                          │ Repository initialized
                          ▼
                 ┌─────────────────┐
                 │ Assigning GUID  │──── GUID fails ──────────► Cleanup ──► (Initial)
                 └────────┬────────┘
                          │
                          │ GUID assigned
                          ▼
                 ┌─────────────────┐
                 │ Saving Settings │──── Save fails ──────────► Cleanup ──► (Initial)
                 └────────┬────────┘
                          │
                          │ Settings saved
                          ▼
                 ┌─────────────────┐
                 │   Registering   │──── Add fails ───────────► Cleanup ──► (Initial)
                 └────────┬────────┘
                          │
                          │ Added to collection
                          ▼
                 ┌─────────────────┐
                 │    Created      │
                 │  (POST-001-007) │
                 └─────────────────┘
```

### Transition Table

| Current State | Action | Next State | Conditions |
|---------------|--------|------------|------------|
| Initial | CreateProject | Validating | Request received |
| Validating | Pass validation | Creating Dirs | All VAL rules pass |
| Validating | Fail validation | Initial | Any VAL rule fails |
| Creating Dirs | Dir created | Initializing Hg | FileUtils.CreateFolder succeeds |
| Creating Dirs | Dir failed | Initial | FileUtils.CreateFolder fails |
| Initializing Hg | Hg initialized | Assigning GUID | VersionedText created |
| Initializing Hg | Hg failed | Cleanup -> Initial | Hg.Init fails |
| Assigning GUID | GUID assigned | Saving Settings | EnsureHasGuid succeeds |
| Assigning GUID | GUID failed | Cleanup -> Initial | EnsureHasGuid fails |
| Saving Settings | Settings saved | Registering | ScrText.Save succeeds |
| Saving Settings | Save failed | Cleanup -> Initial | ScrText.Save fails |
| Registering | Registered | Created | ScrTextCollection.Add succeeds |
| Registering | Registration failed | Cleanup -> Initial | ScrTextCollection.Add fails |
| Created | - | - | Terminal state |

---

## JSON-RPC Format

### Request Template

```json
{
  "jsonrpc": "2.0",
  "id": "unique-request-id",
  "method": "{TBD:ExtensionName}.createProject",
  "params": {
    "shortName": "TestPrj",
    "fullName": "Test Project",
    "projectType": 1,
    "languageId": "en",
    "languageName": "English",
    "versification": "English",
    "normalizationForm": "NFC",
    "encoding": "65001",
    "usfmVersion": "Version3"
  }
}
```

### Success Response Template

```json
{
  "jsonrpc": "2.0",
  "id": "unique-request-id",
  "result": {
    "success": true,
    "projectId": "abc123def456789012345678901234567890abcd",
    "shortName": "TestPrj",
    "projectPath": "/path/to/projects/TestPrj"
  }
}
```

### Error Response Template

```json
{
  "jsonrpc": "2.0",
  "id": "unique-request-id",
  "result": {
    "success": false,
    "errorCode": "NAME_DUPLICATE",
    "errorMessage": "A project already exists with the name 'TestPrj'"
  }
}
```

### Standard JSON-RPC Error (System Errors)

```json
{
  "jsonrpc": "2.0",
  "id": "unique-request-id",
  "error": {
    "code": -32603,
    "message": "Internal error",
    "data": {
      "originalError": "System.IO.IOException: Disk full"
    }
  }
}
```

---

## Invariants

### INV-001: Unique Project Names

**Description**: No two projects can have the same short name (case-insensitive comparison).

**Formal Notation**:
```
forall p1, p2 in Projects:
  p1 != p2 => lowercase(p1.shortName) != lowercase(p2.shortName)
```

**Enforcement**: `ParatextUtils.ValidateShortName` before creation.

---

### INV-002: Unique Project GUIDs

**Description**: Every project must have a globally unique identifier derived from its first Mercurial commit hash.

**Formal Notation**:
```
forall p1, p2 in Projects:
  p1 != p2 => p1.guid != p2.guid
```

**Enforcement**: `VersioningManager.EnsureHasGuid` calculates GUID from commit.

---

### INV-003: Project Directory Matches Name

**Description**: Project directory name must equal project short name.

**Formal Notation**:
```
forall p in Projects:
  basename(p.directory) == p.shortName
```

**Enforcement**: `ScrText.Name` setter updates directory path.

---

### INV-004: Derived Projects Require Base

**Description**: All derived project types must specify a valid base project.

**Formal Notation**:
```
forall p in Projects:
  isDerivedType(p.type) => p.baseProject != null AND exists(p.baseProject)
```

**Enforcement**: `TranslationInformation` constructor throws if derived type has no base.

---

### INV-005: Resource Projects Cannot Be Versioned

**Description**: Resource (copyrighted) projects cannot have Mercurial versioning enabled.

**Formal Notation**:
```
forall p in Projects:
  isResource(p) => !hasVersioning(p)
```

**Enforcement**: `VersionedText` constructor throws ArgumentException.

---

### INV-006: Project Must Be Saved Before Collection Add

**Description**: ScrText must be saved to disk before adding to ScrTextCollection.

**Formal Notation**:
```
add(p, collection) requires exists(p.settingsFile)
```

**Enforcement**: Code ordering in creation flow.

---

### INV-007: GUID Required Before Collection Add

**Description**: ScrText must have a GUID before being added to collection.

**Formal Notation**:
```
add(p, collection) requires p.guid != null
```

**Enforcement**: `EnsureHasGuid` called before `Add`.

---

## PT10 Implementation Alignment (TBD - filled by Alignment Agent in Phase 3)

### C# Implementation

- **Namespace**: `{TBD:CSharpNamespace}`
- **File locations**: `{TBD:CSharpFilePath}`
- **Base classes to extend**: `{TBD:BaseClass}`
- **Service pattern (static/DataProvider)**: `{TBD:ServicePattern}`

### TypeScript Implementation

- **Extension name**: `{TBD:ExtensionName}`
- **Command prefix**: `{TBD:CommandPrefix}`
- **Type declaration file**: `{TBD:TypeDeclarationFile}`

### Test Implementation

- **Test framework**: `{TBD:TestFramework}`
- **Test base class**: `{TBD:TestBaseClass}`
- **Test file locations**: `{TBD:TestFilePath}`
- **Mock/dummy objects to use**: `{TBD:MockObjects}`

### Existing Infrastructure

- **Related services**: `{TBD:RelatedServices}`
- **Data providers**: `{TBD:DataProviders}`
- **Shared types**: `{TBD:SharedTypes}`

Reference: See `.context/standards/paranext-core-patterns.md` for PT10 conventions.

---

## Decisions Made

| Decision | Options Considered | Choice | Rationale |
|----------|-------------------|--------|-----------|
| Result type structure | Exceptions vs Result type vs Union | Discriminated union | Type-safe, explicit error handling without exceptions crossing language boundaries |
| Error code granularity | Generic vs Semantic codes | Semantic codes per validation rule | Enables specific UI feedback and programmatic error handling |
| GUID representation | UUID string vs HexId object | String (40-char hex) | Simpler serialization; ParatextData uses HexId internally |
| Project type enum | String literals vs Numeric enum | Numeric enum matching ParatextData | Direct mapping to C# enum for interop |
| Nullable vs Optional | C# nullable vs TypeScript optional | Both (`?` suffix) | Language-appropriate idioms with clear mapping |
| Cancellation pattern | Events vs Token | CancellationToken | Standard .NET async pattern |

### Decision Details

#### Result Type Structure

**Context**: Need to communicate success/failure with details across TypeScript/C# boundary.

**Options**:
1. Throw exceptions - Simple but requires try/catch, poor for expected failures
2. Generic Result<T> - Works but loses type information
3. Discriminated union - Type-safe success/error with specific fields

**Choice**: Discriminated union with `success: boolean` discriminator.

**Rationale**:
- TypeScript has excellent support for discriminated unions
- JSON serialization is straightforward
- No exception handling overhead for validation failures
- Type guards enable type-safe access to success/error fields

**Consequences**:
- All API consumers must check `success` before accessing result fields
- Error handling is explicit and compile-time checked in TypeScript

---

#### Error Code Granularity

**Context**: How specific should error codes be?

**Options**:
1. Generic codes: `VALIDATION_FAILED`, `SYSTEM_ERROR`
2. Category codes: `NAME_ERROR`, `BASE_ERROR`
3. Semantic codes: `NAME_TOO_SHORT`, `NAME_CASE_COLLISION`, etc.

**Choice**: Semantic codes matching validation rules.

**Rationale**:
- UI can display specific, actionable error messages
- Programmatic handling can retry or prompt based on specific error
- Direct traceability to VAL-xxx rules

**Consequences**:
- More error codes to maintain
- UI must handle many cases (can group for display)
- Adding new validation rules requires new error codes

---

## Report Summary

### Metrics

| Metric | Count |
|--------|-------|
| Input types defined | 5 |
| Output types defined | 7 |
| Enum types defined | 7 |
| API methods documented | 5 |
| Error codes defined | 19 |
| Invariants documented | 7 |
| Behaviors covered | 20/20 |
| Validation rules covered | 11/11 |

### API Surface Complexity Assessment

**Assessment**: **Moderate**

**Rationale**:
- Core API is a single `CreateProject` method with supporting validation helpers
- Type system is straightforward with clear mapping to ParatextData
- Error handling is well-defined but has many specific error codes
- State machine is linear with clear cleanup on failure
- Multiple project types add conditional logic complexity

### Ambiguities Requiring Human Clarification

1. **Command Naming**: The PAPI command names use `{TBD:ExtensionName}` placeholder. Final names depend on extension structure decided in Phase 3.

2. **Event System**: ProjectCreated event is proposed but actual event infrastructure in PT10 needs alignment.

3. **Progress Reporting**: Long-running operations (Study Bible book copying) may need progress callbacks. Current contract doesn't specify progress events.

4. **Language Validation**: Exact BCP-47 validation rules depend on ParatextData.LanguageId implementation. Need to verify edge cases.

### Readiness Assessment for Phase 3

**Status**: **Ready with TBD placeholders**

The contracts are complete and can guide implementation once the Alignment Agent fills in:
- Actual namespace and file locations
- Extension and command naming
- Test infrastructure details
- Existing service patterns to follow

All business logic, validation rules, and error handling are fully specified based on ParatextData behavior observed in Phase 1.
