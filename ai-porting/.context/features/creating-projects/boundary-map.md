# Boundary Map: Creating Projects

## ParatextData Layer (Portable - .NET Standard 2.0)

| Class | Purpose | Reusable in PT10 | Notes |
|-------|---------|------------------|-------|
| `ScrText` | Core project representation | **Yes** | Central class for all project operations |
| `ScrTextCollection` | Registry of all loaded projects | **Yes** | Manages project loading, finding, adding |
| `ProjectSettings` | Settings.xml read/write | **Yes** | All settings serialization logic |
| `Setting` (enum) | Named settings constants | **Yes** | Defines all valid setting names |
| `TranslationInformation` | Project type and base project info | **Yes** | Serialized as "Type:Name:Guid" |
| `ProjectType` | Project type enumeration | **Yes** | Standard, BackTranslation, Daughter, etc. |
| `ProjectTypeExtensions` | Project type helper methods | **Yes** | IsDerivedType, IsStudyBible, etc. |
| `VersioningManager` | Manages versioned text instances | **Yes** | Factory for VersionedText |
| `VersionedText` | Mercurial integration per project | **Yes** | Repository init, GUID calculation |
| `Hg` | Mercurial command abstraction | **Yes** | Init, Commit, status operations |
| `LanguageId` | BCP-47 language identifier | **Yes** | Language validation and parsing |
| `ScrVers` / `ScrVersType` | Versification schemes | **Yes** | Bible book/chapter/verse structures |
| `ProjectNormalization` | Unicode normalization enum | **Yes** | NFC, NFD, Undefined |
| `UsfmVersionOption` | USFM version enum | **Yes** | Version2, Version3 |
| `ProjectVisibility` | Public/Test/Confidential enum | **Yes** | Project visibility settings |
| `BiblicalTermsInfo` | Associated biblical terms list | **Yes** | Links to terms database |
| `CommentTag` | Note tag definition | **Yes** | Tag name, icon, etc. |
| `CommentTags` | Collection of comment tags | **Yes** | Load/save tag definitions |
| `HexId` | GUID wrapper | **Yes** | 40-character hex identifiers |
| `RegistrationInfo` | User info | **Yes** | DefaultUser for project creation |

## ParatextBase Layer (Shared UI Components)

| Class | Purpose | Reusable in PT10 | Notes |
|-------|---------|------------------|-------|
| `ParatextUtils.ValidateShortName` | Short name validation | **Partial** | Logic is reusable, UI strings need extraction |
| `ParatextUtils.projectNameValidChars` | Valid character set | **Yes** | "A-Za-z0-9_" |

## UI Layer (Needs Rewrite - WinForms)

| Class | Purpose | Logic to Extract |
|-------|---------|------------------|
| `ProjectPropertiesForm` | Main project creation/edit dialog | All validation logic, tab orchestration |
| `ProjectNameForm` | Short/full name editing | `FormTextNameAbbrev` algorithm |
| `LanguageIDSelectionForm` | Language selection | None (pure UI) |
| `LanguageSettingsForm` | Font/writing system setup | None (pure UI) |
| `ChooseEncodingForm` | Encoding selection | None (pure UI) |
| `EditFilingPatternForm` | File naming pattern | None (pure UI) |
| `BookChooserCtrl` | Book selection control | None (pure UI) |
| `MainForm` | Menu handling | None (event wiring) |

### ProjectPropertiesUtils (Mixed - Needs Extraction)

| Method | Location | Status | Notes |
|--------|----------|--------|-------|
| `CreateDefaultBaseProject` | ToolsMenu/ProjectPropertiesUtils.cs:38 | **Move to ParatextData** | Pure data operations |
| `InitializeScrTextWithDefaultValues` | ToolsMenu/ProjectPropertiesUtils.cs:64 | **Move to ParatextData** | Pure data operations |
| `CalculateTranslationInfo` | ToolsMenu/ProjectPropertiesUtils.cs:175 | **Move to ParatextData** | Pure data operations |
| `UpdateScrText` | ToolsMenu/ProjectPropertiesUtils.cs:218 | **Split** | Core logic to ParatextData, UI notifications stay |
| `NextUnusedProjectName` | ToolsMenu/ProjectPropertiesUtils.cs:443 | **Move to ParatextData** | Pure data operations |
| `CalcFileNamePostPart` | ToolsMenu/ProjectPropertiesUtils.cs:479 | **Move to ParatextData** | Pure string operation |
| `MakeCopyOfBase` | ToolsMenu/ProjectPropertiesUtils.cs:88 | **Move to ParatextData** | Progress callback pattern |
| `UpdateCommentTags` | ToolsMenu/ProjectPropertiesUtils.cs:156 | **Move to ParatextData** | Pure data operations |

## Data Flow

```
User Action (Menu Click)
         |
         v
+---------------------+
| MainForm            |  UI Layer
| newProjectToolStrip |
+---------------------+
         |
         v
+------------------------+
| ProjectPropertiesForm  |  UI Layer
| (wizard-like dialog)   |
+------------------------+
         |
         | collects: shortName, fullName, languageId,
         |           projectType, baseProject, versification,
         |           encoding, normalization, plannedBooks
         v
+------------------------+
| ProjectPropertiesUtils |  Mixed Layer
| .UpdateScrText()       |  (should be ParatextData)
+------------------------+
         |
         v
+------------------------+
| FileUtils.CreateFolder |  Utility
| (creates project dir)  |
+------------------------+
         |
         v
+------------------------+
| ScrText                |  ParatextData
| .Name = shortName      |
| .Settings.* = values   |
+------------------------+
         |
         v
+------------------------+
| VersioningManager      |  ParatextData
| .EnsureHasGuid()       |
+------------------------+
         |
         v
+------------------------+
| VersionedText          |  ParatextData
| (init Hg repository)   |
+------------------------+
         |
         v
+------------------------+
| ScrText.Save()         |  ParatextData
| (writes Settings.xml)  |
+------------------------+
         |
         v
+------------------------+
| ScrTextCollection.Add  |  ParatextData
| (registers project)    |
+------------------------+
         |
         v
+------------------------+
| UI Update              |  UI Layer
| (project visible)      |
+------------------------+
```

## Key API Boundaries

### ScrText Constructor
- **Method**: `ScrText(ParatextUser user)`
- **Purpose**: Creates new project instance
- **Called from**: UI layer (ProjectPropertiesForm, ParatextPluginHost)
- **Returns**: Uninitialized ScrText

### ScrText.Name Property
- **Method**: `string Name { get; set; }`
- **Purpose**: Sets project short name and triggers directory path calculation
- **Called from**: ProjectPropertiesUtils.UpdateScrText
- **Returns**: N/A (property)
- **Side Effects**: Updates directory path

### ScrText.Save()
- **Method**: `void Save()`
- **Purpose**: Persists Settings.xml to disk
- **Called from**: ProjectPropertiesUtils.UpdateScrText
- **Returns**: void

### ScrTextCollection.Add()
- **Method**: `void Add(ScrText scrText)`
- **Purpose**: Registers project in global collection
- **Called from**: ProjectPropertiesUtils.UpdateScrText
- **Returns**: void
- **Precondition**: ScrText must have GUID

### VersioningManager.EnsureHasGuid()
- **Method**: `void EnsureHasGuid(ScrText scrText)`
- **Purpose**: Ensures project has assigned GUID (creating if needed)
- **Called from**: ProjectPropertiesUtils.UpdateScrText
- **Returns**: void
- **Side Effects**: May create initial Hg commit

### VersioningManager.Get()
- **Method**: `VersionedText Get(ScrText scrText)`
- **Purpose**: Gets or creates VersionedText for project
- **Called from**: Various
- **Returns**: VersionedText instance

### TranslationInformation Constructor
- **Method**: `TranslationInformation(Enum<ProjectType> type, string baseProjectName = "", HexId guid = null)`
- **Purpose**: Creates project type info
- **Called from**: ProjectPropertiesUtils.CalculateTranslationInfo
- **Returns**: TranslationInformation
- **Validation**: Derived types must have baseProjectName

## ParatextData Reuse Estimate

- **Estimated reuse**: 95%
- **Key reusable components**:
  - `ScrText` - core project class
  - `ScrTextCollection` - project registry
  - `ProjectSettings` - settings serialization
  - `VersioningManager` / `VersionedText` - Mercurial integration
  - `TranslationInformation` - project type handling
  - All enum types (ProjectType, Setting, etc.)

- **Components needing adaptation**:
  - `ProjectPropertiesUtils` methods need to move from UI layer to ParatextData
  - Progress reporting callbacks need abstraction

- **Components not reusable**:
  - `ProjectPropertiesForm` - WinForms wizard dialog
  - `ProjectNameForm` - WinForms dialog
  - All WinForms-specific controls

## Configuration & Settings

### Settings That Affect Project Creation

| Setting | Location | Default | Effect |
|---------|----------|---------|--------|
| `Name` | Settings.xml | (required) | Project short name (3-8 chars) |
| `FullName` | Settings.xml | empty | Display name |
| `Copyright` | Settings.xml | empty | Copyright notice |
| `LanguageIsoCode` | Settings.xml | (required) | BCP-47 language tag |
| `Language` | Settings.xml | (required) | Display language name |
| `Versification` | Settings.xml | English | Bible versification scheme |
| `Encoding` | Settings.xml | 65001 | UTF-8 encoding |
| `NormalizationForm` | Settings.xml | NFC | Unicode normalization |
| `TranslationInfo` | Settings.xml | Standard | "Type:BaseName:BaseGuid" |
| `Editable` | Settings.xml | true | Whether project is editable |
| `FileNameForm` | Settings.xml | 41MAT | Book number format |
| `FileNamePrePart` | Settings.xml | empty | Filename prefix |
| `FileNamePostPart` | Settings.xml | {shortName}.SFM | Filename suffix |
| `StyleSheet` | Settings.xml | usfm.sty | Default stylesheet |
| `UsfmVersion` | Settings.xml | Version3 | USFM 2 or 3 |
| `MinParatextVersion` | Settings.xml | varies | Minimum PT version required |
| `Guid` | Settings.xml | (auto) | Unique project identifier |
| `Visibility` | Settings.xml | Public | Public/Test/Confidential |
| `BiblicalTermsListSetting` | Settings.xml | Major | Associated terms list |
| `AllowReadAccess` | Settings.xml | false | Sharing permission |
| `AllowSharingWithSLDR` | Settings.xml | false | SLDR sharing permission |

### Persistence

- **User preferences**: None specific to project creation (dialog position maybe)
- **Project settings**: `{ProjectDir}/Settings.xml`
- **Storage format**: XML (Settings.xml)

### Files Created During Project Creation

| File | Purpose | Created By |
|------|---------|------------|
| `{project}/Settings.xml` | Project settings | ScrText.Save() |
| `{project}/.hg/` | Mercurial repository | VersionedText constructor |
| `{project}/unique.id` | Force-change marker | VersionedText (optional) |
| `{project}/CommentTags.xml` | Note tag definitions | CommentTags.Save() (if tags) |
| `{project}/{lang}.ldml` | Language settings | ScrLanguage.Save() (if needed) |
| `{project}/license.json` | License file | Copied from base (derived) |
| `{project}/AutoCorrect.txt` | Auto-correct rules | Copied (consultant notes) |

## Integration Points

### Features This Depends On

| Feature | Dependency Type | Notes |
|---------|-----------------|-------|
| User Management | Data | Requires logged-in user (ParatextUser) |
| Language Management | Data | Language ID validation |
| Versification | Data | Versification scheme selection |
| Biblical Terms | Data | Optional terms list association |

### Features That Depend On This

| Feature | Dependency Type | Notes |
|---------|-----------------|-------|
| Send/Receive | Data | Projects must exist to sync |
| Project Notes | Data | Notes need project context |
| All Project Windows | UI | Projects must be created to open |
| Import/Export | Data | Target project must exist |

### External Systems

| System | Integration Type | Notes |
|--------|------------------|-------|
| Mercurial | VCS | Repository initialization |
| SLDR | Data | Language data (ldml files) |
| Paratext Registry | API | Project registration (optional) |
| File System | Storage | Project directory creation |
