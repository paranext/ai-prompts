# Business Rules: Creating Projects

## Overview

Project creation in Paratext 9 is governed by rules that ensure project uniqueness, valid configurations, and proper relationships between projects. These rules protect data integrity and maintain compatibility across different versions of Paratext.

## Invariants

Rules that must ALWAYS hold true:

### INV-001: Unique Project Names
- **Rule**: No two projects can have the same short name (case-insensitive comparison)
- **Source**: `ParatextUtils.ValidateShortName` at `/Users/martijnbartelson/code/paratext/Paratext/ParatextBase/ParatextUtils.cs:180`
- **Enforced by**: Short name validation before project creation
- **Violation handling**: Error message displayed, creation blocked

### INV-002: Unique Project GUIDs
- **Rule**: Every project must have a globally unique identifier (GUID)
- **Source**: `VersioningManager.EnsureHasGuid` at `/Users/martijnbartelson/code/paratext/Paratext/ParatextData/Repository/VersioningManager.cs`
- **Enforced by**: GUID calculated from first Mercurial commit hash
- **Violation handling**: Commit forced if no GUID exists

### INV-003: Project Directory Matches Name
- **Rule**: Project directory name must equal project short name
- **Source**: `ScrText.Directory` property
- **Enforced by**: Name setter updates directory path
- **Violation handling**: Project becomes inaccessible

### INV-004: Derived Projects Require Base
- **Rule**: All derived project types must specify a valid base project
- **Source**: `TranslationInformation.ctor` at `/Users/martijnbartelson/code/paratext/Paratext/ParatextData/ProjectSettingsAccess/TranslationInformation.cs:84`
- **Enforced by**: Constructor throws if derived type has no base name
- **Violation handling**: `InvalidOperationException` thrown

### INV-005: Resource Projects Cannot Be Versioned
- **Rule**: Resource (copyrighted) projects cannot have versioning enabled
- **Source**: `VersionedText.ctor` at `/Users/martijnbartelson/code/paratext/Paratext/ParatextData/Repository/VersionedText.cs:62`
- **Enforced by**: Constructor throws ArgumentException
- **Violation handling**: `ArgumentException("Versioning a Resource is forbidden.")`

### INV-006: Project Must Be Saved Before Collection Add
- **Rule**: ScrText must be saved to disk before adding to ScrTextCollection
- **Source**: `ProjectPropertiesUtils.UpdateScrText` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectPropertiesUtils.cs:359`
- **Enforced by**: Code ordering (Save called before Add)
- **Violation handling**: Project may not appear in UI if order violated

### INV-007: GUID Required Before Collection Add
- **Rule**: ScrText must have a GUID before being added to collection
- **Source**: `ProjectPropertiesUtils.UpdateScrText` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectPropertiesUtils.cs:358`
- **Enforced by**: EnsureHasGuid called before Add
- **Violation handling**: Could result in null reference errors downstream

## Validation Rules

Input constraints that are checked:

### VAL-001: Short Name Length
- **Field/Input**: Project short name
- **Rule**: Must be 3-8 characters in length
- **Source**: `ParatextUtils.ValidateShortName` at `/Users/martijnbartelson/code/paratext/Paratext/ParatextBase/ParatextUtils.cs:166`
- **Error message**: "Short name must not be less than 3 or more than 8 characters in length"
- **When checked**: On every short name change in UI

### VAL-002: Short Name Characters
- **Field/Input**: Project short name
- **Rule**: Must contain only A-Z, a-z, 0-9, and underscore (_)
- **Source**: `ParatextUtils.ValidateShortName` at `/Users/martijnbartelson/code/paratext/Paratext/ParatextBase/ParatextUtils.cs:174`
- **Error message**: "Short name can only contain letters A-Z, digits 0-9, and underscores."
- **When checked**: On every short name change in UI

### VAL-003: Short Name No Spaces
- **Field/Input**: Project short name
- **Rule**: Must not contain whitespace characters
- **Source**: `ParatextUtils.ValidateShortName` at `/Users/martijnbartelson/code/paratext/Paratext/ParatextBase/ParatextUtils.cs:172`
- **Error message**: "Short name must not contain spaces"
- **When checked**: On every short name change in UI

### VAL-004: Short Name Not Reserved
- **Field/Input**: Project short name
- **Rule**: Must not be a Windows reserved filename (CON, PRN, AUX, NUL, COM1-9, LPT1-9)
- **Source**: `ParatextUtils.ValidateShortName` at `/Users/martijnbartelson/code/paratext/Paratext/ParatextBase/ParatextUtils.cs:199`
- **Error message**: "Project Short Name is a reserved file name on Windows and cannot be used."
- **When checked**: On new project creation

### VAL-005: Short Name Case Uniqueness
- **Field/Input**: Project short name
- **Rule**: Must not match existing project when compared case-insensitively
- **Source**: `ParatextUtils.ValidateShortName` at `/Users/martijnbartelson/code/paratext/Paratext/ParatextBase/ParatextUtils.cs:183`
- **Error message**: "Another project exists ({0}) with the same name, but a different case. You will need to use a different short name for this project."
- **When checked**: On new project creation

### VAL-006: Directory Not Exists
- **Field/Input**: Project short name
- **Rule**: No folder may exist with that name in projects directory
- **Source**: `ParatextUtils.ValidateShortName` at `/Users/martijnbartelson/code/paratext/Paratext/ParatextBase/ParatextUtils.cs:191`
- **Error message**: "A folder exists ({0}) with the same name. You will need to use a different short name for this project."
- **When checked**: On new project creation

### VAL-007: Full Name Required
- **Field/Input**: Project full (long) name
- **Rule**: Must have at least 1 character (after trimming)
- **Source**: `ProjectNameForm.ValidateForm` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectNameForm.cs:157`
- **Error message**: "You must enter a full name"
- **When checked**: On dialog validation

### VAL-008: Language ID Valid
- **Field/Input**: Language ID
- **Rule**: Must be a valid BCP-47 / ISO language code
- **Source**: `ParatextPluginHost.CreateNewProject` at `/Users/martijnbartelson/code/paratext/Paratext/ParatextBase/Plugins/ParatextPluginHost.cs:141`
- **Error message**: "Language ID '{0}' is not a valid language tag."
- **When checked**: On project creation via API

### VAL-009: Translation Info Not Null
- **Field/Input**: TranslationInformation parameter
- **Rule**: Must not be null when calling UpdateScrText
- **Source**: `ProjectPropertiesUtils.UpdateScrText` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectPropertiesUtils.cs:273`
- **Error message**: ArgumentNullException thrown
- **When checked**: On UpdateScrText call

### VAL-010: Language ID Not Null
- **Field/Input**: LanguageId parameter
- **Rule**: Must not be null when calling UpdateScrText
- **Source**: `ProjectPropertiesUtils.UpdateScrText` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectPropertiesUtils.cs:276`
- **Error message**: ArgumentNullException thrown
- **When checked**: On UpdateScrText call

### VAL-011: Cannot Change Existing Short Name
- **Field/Input**: Short name for existing project
- **Rule**: Short name cannot be changed after project creation
- **Source**: `ProjectPropertiesUtils.UpdateScrText` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectPropertiesUtils.cs:279`
- **Error message**: "project short name cannot be changed"
- **When checked**: On UpdateScrText for existing project

## Preconditions

Conditions that must be true before operations:

### PRE-001: User Cannot Be Guest
- **Required state**: User must not be a guest user
- **Source**: `MainForm.UpdateMenuItemState` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/MainForm.cs:2505`
- **Failure behavior**: New Project menu item disabled

### PRE-002: Dialog Result OK Before Save
- **Required state**: User must click OK (not Cancel) for project to be saved
- **Source**: `MainForm.newProjectToolStripMenuItem_Click` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/MainForm.cs:890`
- **Failure behavior**: Project creation cancelled, any temp data cleaned up

### PRE-003: Valid Data Before OK
- **Required state**: All form validation must pass
- **Source**: `ProjectPropertiesForm.cmdOK_Click` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ProjectMenu/ProjectPropertiesForm.cs:670`
- **Failure behavior**: OK button click blocked/ignored

### PRE-004: Base Project Exists for Derived Types
- **Required state**: Selected base project must exist and be accessible
- **Source**: `TranslationInformation.BaseScrText` at `/Users/martijnbartelson/code/paratext/Paratext/ParatextData/ProjectSettingsAccess/TranslationInformation.cs:120`
- **Failure behavior**: Returns null, UI prevents selection

### PRE-005: Base Project Has GUID Before Deriving
- **Required state**: Base project must have GUID before derived project is created
- **Source**: `ProjectPropertiesUtils.CalculateTranslationInfo` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectPropertiesUtils.cs:180`
- **Failure behavior**: EnsureHasGuid is called automatically

## Postconditions

Guaranteed states after operations:

### POST-001: Project Has Directory After Creation
- **Guaranteed result**: Project directory exists at `{SettingsDirectory}/{shortName}`
- **Source**: `ProjectPropertiesUtils.UpdateScrText` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectPropertiesUtils.cs:285`

### POST-002: Settings.xml Exists After Creation
- **Guaranteed result**: Settings.xml file written to project directory
- **Source**: `ScrText.Save` called in `ProjectPropertiesUtils.UpdateScrText`

### POST-003: Mercurial Repository Initialized
- **Guaranteed result**: .hg directory exists in project directory
- **Source**: `VersionedText.ctor` at `/Users/martijnbartelson/code/paratext/Paratext/ParatextData/Repository/VersionedText.cs:73`

### POST-004: Project Has GUID After Creation
- **Guaranteed result**: scrText.Guid is non-null
- **Source**: `VersioningManager.EnsureHasGuid` called in `ProjectPropertiesUtils.UpdateScrText`

### POST-005: Project In Collection After Creation
- **Guaranteed result**: Project visible via ScrTextCollection.Get(name)
- **Source**: `ScrTextCollection.Add` called in `ProjectPropertiesUtils.UpdateScrText`

### POST-006: Study Bible Has Copied Books
- **Guaranteed result**: All base project books are copied to study Bible project
- **Source**: `ProjectPropertiesUtils.MakeCopyOfBase` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectPropertiesUtils.cs:88`

### POST-007: Derived Project Has License Copy
- **Guaranteed result**: License file copied from base if project shares license with parent
- **Source**: `ProjectPropertiesUtils.UpdateScrText` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectPropertiesUtils.cs:345`

## State Transitions

### State: Project Existence

| From State | Event/Action | To State | Conditions |
|------------|--------------|----------|------------|
| Not Created | User clicks OK | Created | All validations pass |
| Not Created | User clicks Cancel | Not Created | Always |
| Created | Project deleted | Not Created | Admin permission |

### State: Project Properties Dialog

| From State | Event/Action | To State | Conditions |
|------------|--------------|----------|------------|
| Closed | Menu click | Open (New) | User not guest |
| Open (New) | OK click | Closed (Success) | Validation passes |
| Open (New) | Cancel click | Closed (Cancelled) | Always |
| Open (Edit) | OK click | Closed (Saved) | Validation passes |
| Open (Edit) | Cancel click | Closed (Discarded) | Always |

### State: Derived Project Validation

| From State | Event/Action | To State | Conditions |
|------------|--------------|----------|------------|
| Standard Type | Select derived type | Base Required | Project type is derived |
| Base Required | Select base project | Valid | Base project selected |
| Valid | Clear base project | Base Required | Derived type still selected |
| Valid | Change to Standard | Standard Type | Non-derived type selected |

## Domain Constraints

Business logic constraints from the domain:

### CON-001: Project Types
- **Rule**: Only specific project types are allowed for user creation
- **Rationale**: Resource types are system-managed, not user-created
- **Source**: `ProjectPropertiesForm.LoadProjectTypeCombo` (not shown in reads)
- **Related features**: Resource management

### CON-002: Derived Type Relationships
- **Rule**: Certain project types can only derive from specific base types
- **Rationale**: Back translations need standard/daughter base, Study Bible needs scripture
- **Source**: `ProjectType` and `TranslationInformation` classes
- **Related features**: All derived project workflows

### CON-003: Versification Inheritance
- **Rule**: Derived projects inherit versification from base project (cannot change)
- **Rationale**: Ensures chapter/verse alignment with base
- **Source**: `ProjectPropertiesUtils.UpdateScrText` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectPropertiesUtils.cs:340`
- **Related features**: Scripture references, Send/Receive

### CON-004: License Sharing
- **Rule**: Back translations, Auxiliary, and Transliteration projects share license with parent
- **Rationale**: These are derivative works under same license
- **Source**: `ProjectTypeExtensions.SharesProjectLicenseWithParent` at `/Users/martijnbartelson/code/paratext/Paratext/ParatextData/ProjectType.cs:178`
- **Related features**: Project registration, permissions

### CON-005: Study Bible Stylesheet
- **Rule**: Study Bible projects use "usfm_sb.sty" stylesheet
- **Rationale**: Study Bible specific styles needed
- **Source**: `ProjectTypeExtensions.StandardStyleSheetName` at `/Users/martijnbartelson/code/paratext/Paratext/ParatextData/ProjectType.cs:205`
- **Related features**: Stylesheet management

### CON-006: Consultant Notes Auto-Correct
- **Rule**: Consultant Note projects get special auto-correct file copied
- **Rationale**: Standard abbreviations for consultant workflow
- **Source**: `ProjectPropertiesUtils.UpdateScrText` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectPropertiesUtils.cs:402`
- **Related features**: Auto-correct feature

### CON-007: MinParatextDataVersion
- **Rule**: New projects set MinParatextDataVersion based on features used
- **Rationale**: Prevents older Paratext versions from corrupting data
- **Source**: `ProjectPropertiesUtils.UpdateScrText` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectPropertiesUtils.cs:376`
- **Related features**: Version compatibility

## Edge Cases

Special cases with specific handling:

### EDGE-001: Customized Versification
- **Scenario**: Base project has customized versification
- **Handling**: Custom versification is copied to new project via ProjectSettings.CopyCustomVersification
- **Source**: `ProjectPropertiesForm.SetupForInterlinearOutputProject` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ProjectMenu/ProjectPropertiesForm.cs:379`

### EDGE-002: Name Collides With Digits
- **Scenario**: User wants name "AB" but "AB" and "AB1" exist
- **Handling**: NextUnusedProjectName finds "AB2"
- **Source**: `ProjectPropertiesUtils.NextUnusedProjectName` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectPropertiesUtils.cs:461`

### EDGE-003: Project Name Has Trailing Digits
- **Scenario**: Input name is "Proj99" for auto-numbering
- **Handling**: Digits are trimmed first, then incrementing starts
- **Source**: `ProjectPropertiesUtils.NextUnusedProjectName` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectPropertiesUtils.cs:450`

### EDGE-004: Full Name Contains Backslash
- **Scenario**: User types backslash in full name
- **Handling**: Automatically converted to forward slash
- **Source**: `ProjectNameForm.txtFullName_TextChanged` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectNameForm.cs:131`

### EDGE-005: Base Project Missing After Selection
- **Scenario**: Selected base project is deleted/moved after dialog opens
- **Handling**: TranslationInformation.BaseScrText returns null
- **Source**: `TranslationInformation.BaseScrText` at `/Users/martijnbartelson/code/paratext/Paratext/ParatextData/ProjectSettingsAccess/TranslationInformation.cs:120`

### EDGE-006: Abbreviation Too Short
- **Scenario**: Full name creates abbreviation < 3 characters
- **Handling**: Padded with last valid character from full name
- **Source**: `ProjectNameForm.FormTextNameAbbrev` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectNameForm.cs:118`

### EDGE-007: Abbreviation Too Long
- **Scenario**: Full name creates abbreviation > 8 characters
- **Handling**: Truncated to 8 - (number of digit chars) to leave room for digits
- **Source**: `ProjectNameForm.FormTextNameAbbrev` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ToolsMenu/ProjectNameForm.cs:114`

### EDGE-008: Plugin Creates Project Without GUID
- **Scenario**: Plugin creation fails after directory created
- **Handling**: VersioningManager.RemoveVersionedText and ScrTextCollection.DeleteProject called for cleanup
- **Source**: `ParatextPluginHost.CreateNewProject` at `/Users/martijnbartelson/code/paratext/Paratext/ParatextBase/Plugins/ParatextPluginHost.cs:180`

### EDGE-009: Cancel After Registration Started
- **Scenario**: User cancels after project registration initiated
- **Handling**: CancelNewProject deletes registry entry before deleting project
- **Source**: `ProjectPropertiesForm.CancelNewProject` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ProjectMenu/ProjectPropertiesForm.cs:1265`

### EDGE-010: Interlinearizer Creates Output Project
- **Scenario**: Interlinearizer needs to create output project with fixed settings
- **Handling**: SetupForInterlinearOutputProject pre-configures form with disabled controls
- **Source**: `ProjectPropertiesForm.SetupForInterlinearOutputProject` at `/Users/martijnbartelson/code/paratext/Paratext/Paratext/ProjectMenu/ProjectPropertiesForm.cs:352`

## Test Coverage Reference

Existing PT9 tests that validate these rules:

| Test File | Test Method | Rules Validated |
|-----------|-------------|-----------------|
| `ProjectPropertiesUtilsTests.cs` | `CreateDefaultProject_ReturnsANonNullProject` | BHV-002 |
| `ProjectPropertiesUtilsTests.cs` | `NextUnusedProjectName` (multiple cases) | BHV-004, EDGE-002, EDGE-003 |
| `ProjectPropertiesUtilsTests.cs` | `UpdateScrText_MinimalDefaultValues_*` | BHV-007, POST-001, POST-002 |
| `ProjectPropertiesUtilsTests.cs` | `UpdateScrText_MovingAnExistingProject_ThrowsArgumentException` | VAL-011 |
| `ProjectPropertiesUtilsTests.cs` | `CalcFileNamePostPart_DefaultExtIsAppendedToShortName` | BHV-017 |
| `ProjectPropertiesUtilsTests.cs` | `InitializeScrTextWithDefaultValues` | BHV-003 |
| `ProjectNameFormTests.cs` | `FormTextNameAbbrev` (multiple cases) | BHV-006, EDGE-006, EDGE-007 |
| `ProjectNameFormTests.cs` | `ValidateShortName` (multiple cases) | VAL-001, VAL-002, VAL-003 |
