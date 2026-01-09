# Behavior Catalog: Creating Projects

## Overview

Project creation in Paratext 9 enables users to create new translation projects with various configurations. The system supports multiple project types including standard translations, back translations, daughter translations, study Bible projects, and consultant notes. Project creation involves setting up project metadata, initializing Mercurial versioning, and establishing relationships with base projects for derived types.

## User Context

### Primary Users
- **Translators**: Create new translation projects for their language
- **Translation Consultants**: Create consultant notes projects and back translation projects
- **Project Administrators**: Set up projects with appropriate settings and permissions
- **Study Bible Teams**: Create Study Bible additions and publication projects

### User Stories
- As a translator, I want to create a new translation project so that I can begin translating Scripture into my language
- As a translation consultant, I want to create a back translation project based on an existing translation so that I can review translation accuracy
- As a project administrator, I want to set up a daughter translation project so that a team can use an existing translation as their base
- As a Study Bible editor, I want to create a Study Bible additions project so that I can add study notes to an existing translation

### Usage Frequency
- Daily: Infrequent (project creation happens once per project)
- Typical: 1-5 times per user over their entire Paratext usage
- Peak: During initial setup of translation programs

## Entry Points

### Menu: File > New Project
- **Handler**: `MainForm.newProjectToolStripMenuItem_Click`
- **Location**: `/Users/martijnbartelson/code/paratext/Paratext/Paratext/MainForm.cs:886`
- **Notes**: Primary entry point for creating new projects via UI

### API: Plugin Interface
- **Handler**: `ParatextPluginHost.CreateNewProject`
- **Location**: `/Users/martijnbartelson/code/paratext/Paratext/ParatextBase/Plugins/ParatextPluginHost.cs:132`
- **Notes**: Programmatic entry point for plugins to create projects

### Interlinearizer Output Project
- **Handler**: `ProjectPropertiesForm.SetupForInterlinearOutputProject`
- **Location**: `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ProjectMenu/ProjectPropertiesForm.cs:352`
- **Notes**: Creates project from interlinearizer workflow

### Study Bible Publication Project
- **Handler**: `ProjectPropertiesForm.SetupForStudyBiblePublicationProject`
- **Location**: `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ProjectMenu/ProjectPropertiesForm.cs:435`
- **Notes**: Creates merged Study Bible publication from base text and additions

## Behaviors

### BHV-001: Create New ScrText Object
- **Source**: `ScrText.ctor(ParatextUser)` at `/Users/martijnbartelson/code/paratext/Paratext/ParatextData/ScrText.cs`
- **Trigger**: User opens New Project dialog or plugin calls CreateNewProject
- **Input**: ParatextUser (the user creating the project)
- **Output**: New ScrText instance with default settings
- **Side Effects**: None (object not yet persisted)
- **Error Handling**: None at this stage
- **Edge Cases**: Guest users cannot create projects (checked in UI)

#### UI/UX Details
- **Keyboard shortcut**: N/A (menu only)
- **Accessibility**: Standard WinForms dialog
- **Visual feedback**: ProjectPropertiesForm dialog opens
- **Undo support**: Cancel button reverts all changes

---

### BHV-002: Initialize Default Project Settings
- **Source**: `ProjectPropertiesUtils.CreateDefaultBaseProject` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectPropertiesUtils.cs:38`
- **Trigger**: New project creation when no base project is specified
- **Input**: None
- **Output**: ScrText with default values:
  - `FullName`: empty string
  - `FileNamePrePart`: empty string
  - `FileNameForm`: "41MAT"
  - `Versification`: ScrVers.English
  - `DefaultStylesheetFileName`: "usfm.sty"
  - `Encoding`: "65001" (UTF-8)
  - `NormalizationForm`: ProjectNormalization.NFC
  - `UsfmVersion`: UsfmVersionOption.Version3
- **Side Effects**: None
- **Error Handling**: None
- **Edge Cases**: None

---

### BHV-003: Initialize Project From Base Project
- **Source**: `ProjectPropertiesUtils.InitializeScrTextWithDefaultValues` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectPropertiesUtils.cs:64`
- **Trigger**: Creating project based on existing project
- **Input**: ScrText to initialize, base ScrText, short name, long name
- **Output**: ScrText initialized with:
  - Versification from base
  - LanguageID from base
  - LanguageName from base
  - MinParatextDataVersion set to MinSupportedParatextDataVersion
  - Name set to shortName
  - FullName set to longName
  - Encoding from base
  - Editable = true
  - Copyright from base
  - NormalizationForm = NFC
- **Side Effects**: None
- **Error Handling**: None
- **Edge Cases**: Base project may have custom versification

---

### BHV-004: Generate Unique Project Name
- **Source**: `ProjectPropertiesUtils.NextUnusedProjectName` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectPropertiesUtils.cs:443`
- **Trigger**: Default naming when creating new project
- **Input**: Initial short name, initial long name, forceNumbered flag
- **Output**: Modified shortName and longName guaranteed to be unique
- **Side Effects**: Queries ScrTextCollection to check existing projects
- **Error Handling**: None
- **Edge Cases**:
  - Trims digits from end of name before appending numbers
  - If name is "AB2", tries "AB1", "AB2", etc.
  - Iterates up to 9999 to find unused name

---

### BHV-005: Validate Project Short Name
- **Source**: `ParatextUtils.ValidateShortName` at `/Users/martijnbartelson/code/paratext/Paratext/ParatextBase/ParatextUtils.cs:164`
- **Trigger**: User enters or changes short name
- **Input**: Short name string, newProject flag, original name (for edits)
- **Output**: null if valid, localized error message if invalid
- **Side Effects**: Queries ScrTextCollection to check for duplicates
- **Error Handling**: Returns specific error messages for each validation failure:
  - Length < 3 or > 8 characters
  - Contains spaces
  - Contains invalid characters (only A-Z, a-z, 0-9, _ allowed)
  - Name already exists (for new projects)
  - Case-insensitive duplicate exists
  - Folder already exists with that name
  - Reserved Windows filename (e.g., CON, PRN)
- **Edge Cases**: Case-insensitive comparison for duplicates

---

### BHV-006: Generate Short Name from Full Name
- **Source**: `ProjectNameForm.FormTextNameAbbrev` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectNameForm.cs:80`
- **Trigger**: User types full name before typing short name
- **Input**: Full project name string
- **Output**: Abbreviated short name (3-8 characters)
- **Side Effects**: None
- **Error Handling**: None
- **Edge Cases**:
  - Extracts first letter of each word
  - Extracts digits separately, uses last 2 digits
  - Appends digits to end
  - If abbreviation < 3 chars, pads with last valid character
  - Max 8 characters total

---

### BHV-007: Create Project Directory
- **Source**: `ProjectPropertiesUtils.UpdateScrText` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectPropertiesUtils.cs:285`
- **Trigger**: User clicks OK on new project dialog
- **Input**: ScrText, shortName
- **Output**: Directory created at `{SettingsDirectory}/{shortName}`
- **Side Effects**: Creates folder on filesystem
- **Error Handling**: Returns without creating project if folder creation fails
- **Edge Cases**: Directory may already exist (handled by validation)

---

### BHV-008: Initialize Mercurial Repository
- **Source**: `VersionedText.ctor` at `/Users/martijnbartelson/code/paratext/Paratext/ParatextData/Repository/VersionedText.cs:59`
- **Trigger**: First access to VersionedText for a project
- **Input**: ScrText
- **Output**: Mercurial repository initialized in project directory
- **Side Effects**:
  - Creates .hg directory
  - Initializes Hg repository via `Hg.Default.Init`
  - Saves initial ScrText settings
- **Error Handling**: Throws ArgumentException if ScrText is a resource project
- **Edge Cases**: Resources cannot have versioning

---

### BHV-009: Assign Project GUID
- **Source**: `VersioningManager.EnsureHasGuid` at `/Users/martijnbartelson/code/paratext/Paratext/ParatextData/Repository/VersioningManager.cs`
- **Source Also**: `VersionedText.CalculateGuid` at `/Users/martijnbartelson/code/paratext/Paratext/ParatextData/Repository/VersionedText.cs:142`
- **Trigger**: Project created or first committed
- **Input**: ScrText
- **Output**: HexId GUID assigned to project
- **Side Effects**:
  - Commits if no revisions exist (to create GUID basis)
  - Sets scrText.Settings.Guid
  - Saves settings to disk
- **Error Handling**: Throws InvalidOperationException if GUID cannot be calculated
- **Edge Cases**: GUID is derived from first mercurial revision hash

---

### BHV-010: Add Project to Collection
- **Source**: `ScrTextCollection.Add` at `/Users/martijnbartelson/code/paratext/Paratext/ParatextData/ScrTextCollection.cs`
- **Trigger**: After project is saved with GUID
- **Input**: ScrText
- **Output**: Project added to in-memory collection
- **Side Effects**: Project becomes visible in UI project lists
- **Error Handling**: None documented
- **Edge Cases**: Must have GUID before adding

---

### BHV-011: Set Project Type and Base Project
- **Source**: `ProjectPropertiesUtils.CalculateTranslationInfo` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectPropertiesUtils.cs:175`
- **Trigger**: User selects project type and optionally a base project
- **Input**: ProjectType, optional base ScrText
- **Output**: TranslationInformation object with Type, BaseProjectName, BaseProjectGuid
- **Side Effects**: Ensures base project has GUID via VersioningManager.EnsureHasGuid
- **Error Handling**: None
- **Edge Cases**: Derived types require base project name

---

### BHV-012: Copy Books from Base Project (Study Bible)
- **Source**: `ProjectPropertiesUtils.MakeCopyOfBase` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectPropertiesUtils.cs:88`
- **Trigger**: Creating Study Bible project
- **Input**: ScrText (new project with base project configured)
- **Output**: All books from base project copied to new project
- **Side Effects**:
  - Copies book content via PutText
  - Creates DerivedTranslationStatus baseline
  - Shows progress dialog
- **Error Handling**: None documented
- **Edge Cases**: Only for Study Bible projects

---

### BHV-013: Copy License from Base Project
- **Source**: `ProjectPropertiesUtils.UpdateScrText` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectPropertiesUtils.cs:345`
- **Trigger**: Creating derived project that shares license with parent
- **Input**: ScrText with TranslationInfo pointing to base project
- **Output**: License file copied from base project
- **Side Effects**: Writes license.json to new project directory
- **Error Handling**: Only copies if base project has license file
- **Edge Cases**: Back translations, Auxiliary, Transliterations share parent license

---

### BHV-014: Set Up Comment Tags (Note Projects)
- **Source**: `ProjectPropertiesUtils.UpdateCommentTags` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectPropertiesUtils.cs:156`
- **Trigger**: Creating project with note tags configured
- **Input**: ScrText, list of CommentTags
- **Output**: Comment tags saved to project
- **Side Effects**: Writes CommentTags.xml
- **Error Handling**: None
- **Edge Cases**: Note projects have specific default tags

---

### BHV-015: Cancel Project Creation
- **Source**: `ProjectPropertiesForm.CancelNewProject` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ProjectMenu/ProjectPropertiesForm.cs:1261`
- **Trigger**: User clicks Cancel or closes dialog without OK
- **Input**: None
- **Output**: Project directory and repository removed
- **Side Effects**:
  - Deletes project directory recursively
  - Removes versioned text from VersioningManager
  - Deletes project registration if created
- **Error Handling**: None documented
- **Edge Cases**: Handles registered projects specially

---

### BHV-016: Save Language Settings
- **Source**: `ProjectPropertiesForm.SaveLanguageSettings` (called from cmdOK_Click)
- **Trigger**: User clicks OK with language settings configured
- **Input**: Language ID, language name, font settings
- **Output**: LDML file created in project directory if needed
- **Side Effects**: May create/update language file
- **Error Handling**: None documented
- **Edge Cases**: Uses global LDML if it exists, creates local copy

---

### BHV-017: Set File Naming Pattern
- **Source**: `ProjectPropertiesUtils.UpdateScrText` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectPropertiesUtils.cs:291-296`
- **Trigger**: New project creation
- **Input**: shortName, fileNameForm, fileNamePrePart, fileNamePostPart
- **Output**: Project settings configured for file naming
- **Side Effects**: None
- **Error Handling**: Calculates fileNamePostPart from shortName if empty
- **Edge Cases**: Default is "{shortName}.SFM" suffix

---

### BHV-018: Set Planned Books
- **Source**: `ProjectPropertiesForm.SaveProjectProgressPlannedBooks` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ProjectMenu/ProjectPropertiesForm.cs:1219`
- **Trigger**: User configures books in project scope
- **Input**: BookSet from book chooser control
- **Output**: Planned books saved to project progress
- **Side Effects**: Writes progress data to project
- **Error Handling**: None
- **Edge Cases**: Updates parallel passages books intersection

---

### BHV-019: Create Project via Plugin API
- **Source**: `ParatextPluginHost.CreateNewProject` at `/Users/martijnbartelson/code/paratext/Paratext/ParatextBase/Plugins/ParatextPluginHost.cs:132`
- **Trigger**: Plugin calls IProjectCreationAccess.CreateNewProject
- **Input**: NewProjectSettings (ShortName, LongName, LanguageId, LanguageName, Copyright, Versification, NormalizationType, Type)
- **Output**: IProject interface to new project
- **Side Effects**:
  - Creates project directory
  - Initializes versioning
  - Saves settings
  - Adds to collection
- **Error Handling**:
  - Throws ParatextPluginException for invalid short name
  - Throws ParatextPluginException for invalid language ID
  - Returns null and cleans up on other errors
- **Edge Cases**: Sets specific file naming to prevent plugin book file creation

---

### BHV-020: Validate Full Name
- **Source**: `ProjectNameForm.ValidateForm` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectNameForm.cs:153`
- **Trigger**: User enters full name
- **Input**: Full name text
- **Output**: Validation error or null
- **Side Effects**: None
- **Error Handling**: Requires length >= 1 character
- **Edge Cases**: Backslash characters are automatically converted to forward slash

## Dependencies

### Features This Depends On
- **User Authentication**: Must have logged-in user (not guest)
- **Language Management**: Language IDs must be valid BCP-47/ISO codes
- **Versification System**: Must select valid versification scheme
- **Mercurial VCS**: Requires Hg for repository initialization

### External Systems
- **SIL Writing Systems**: LDML language data
- **Mercurial**: Version control initialization
- **File System**: Project directory creation
- **Registry Server**: Project registration (optional)

### Shared Components
- `ScrText`: Core project representation
- `ScrTextCollection`: Project registry
- `VersioningManager`: Repository management
- `VersionedText`: Mercurial integration
- `ProjectSettings`: Settings persistence
- `TranslationInformation`: Project type metadata
