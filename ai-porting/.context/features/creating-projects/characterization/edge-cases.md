# Edge Cases: Creating Projects

## Summary

- Total edge cases identified: 18
- By severity: Critical (3), High (6), Medium (7), Low (2)

---

## Edge Case: EC-001 - Name Collision with Trailing Digits

### Scenario
User wants to create a project with name "Proj99" but that name already exists. The algorithm must handle trailing digits gracefully.

### Current Behavior
The `NextUnusedProjectName` algorithm:
1. Strips trailing digits from the base name ("Proj99" becomes "Proj")
2. Attempts to find unused name starting from "Proj1", "Proj2", etc.
3. Returns first available numbered variant

If "Proj" doesn't exist, returns "Proj1" (not "Proj").

### Source
Code location: `ProjectPropertiesUtils.cs:450-461`
Method: `NextUnusedProjectName()`

### Test Coverage
- Scenario ID: TS-041
- Golden master candidate: No
- Automated test feasibility: High

### Risk Assessment
- Likelihood of occurrence: Medium
- Impact if behavior changes: Medium - could result in unexpected project names

### Notes
This is documented as EDGE-003 in business-rules.md. The digit-stripping behavior may be unexpected to users.

---

## Edge Case: EC-002 - Abbreviation Too Short

### Scenario
Full name generates an abbreviation with fewer than 3 characters (e.g., "A B" generates "AB").

### Current Behavior
`FormTextNameAbbrev` pads short abbreviations:
1. If result is less than 3 characters
2. Repeatedly appends the last valid character from the full name
3. Until length reaches 3

Example: "A B" -> "AB" -> "ABB" (padding with last valid char 'B')

### Source
Code location: `ProjectNameForm.cs:118`
Method: `FormTextNameAbbrev()`

### Test Coverage
- Scenario ID: TS-015
- Golden master candidate: No
- Automated test feasibility: High

### Risk Assessment
- Likelihood of occurrence: Low
- Impact if behavior changes: Low - primarily cosmetic

### Notes
EDGE-006 in business-rules.md. The padding character selection could produce odd results with certain inputs.

---

## Edge Case: EC-003 - Abbreviation Too Long

### Scenario
Full name with many words or digits generates abbreviation exceeding 8 characters.

### Current Behavior
`FormTextNameAbbrev` truncates long abbreviations:
1. Extracts first letter of each word plus all digits
2. If combined length exceeds 8, truncates letters portion
3. Leaves room for last 2 digits if digits present
4. Maximum result is 8 characters

### Source
Code location: `ProjectNameForm.cs:114`
Method: `FormTextNameAbbrev()`

### Test Coverage
- Scenario ID: TS-016
- Golden master candidate: No
- Automated test feasibility: High

### Risk Assessment
- Likelihood of occurrence: Medium
- Impact if behavior changes: Low

### Notes
EDGE-007 in business-rules.md.

---

## Edge Case: EC-004 - Full Name Contains Backslash

### Scenario
User enters a backslash character in the full name (e.g., "Test\Project").

### Current Behavior
The `txtFullName_TextChanged` handler automatically converts backslashes to forward slashes:
- "Test\Project" becomes "Test/Project"
- Conversion happens immediately in text change event

### Source
Code location: `ProjectNameForm.cs:131`
Method: `txtFullName_TextChanged()`

### Test Coverage
- Scenario ID: TS-040
- Golden master candidate: No
- Automated test feasibility: High

### Risk Assessment
- Likelihood of occurrence: Low
- Impact if behavior changes: Medium - could cause file system issues on Windows

### Notes
EDGE-004 in business-rules.md. Backslashes are path separators on Windows and would cause problems.

---

## Edge Case: EC-005 - Base Project Missing After Selection

### Scenario
User selects a base project in the dialog, but that project is deleted or moved by another process before the user clicks OK.

### Current Behavior
`TranslationInformation.BaseScrText` property:
1. Looks up project by name in ScrTextCollection
2. Returns null if project no longer exists
3. UI may allow creation to proceed with null base

### Source
Code location: `TranslationInformation.cs:120`
Property: `BaseScrText`

### Test Coverage
- Scenario ID: TS-047
- Golden master candidate: No
- Automated test feasibility: Medium (requires race condition setup)

### Risk Assessment
- Likelihood of occurrence: Very Low
- Impact if behavior changes: High - could create corrupted derived project

### Notes
EDGE-005 in business-rules.md. The UI should ideally re-validate before proceeding.

---

## Edge Case: EC-006 - Plugin Creates Project Without GUID

### Scenario
Plugin API project creation fails after directory is created but before GUID can be assigned.

### Current Behavior
`ParatextPluginHost.CreateNewProject` performs cleanup:
1. Catches any exception after directory creation
2. Calls `VersioningManager.RemoveVersionedText()`
3. Calls `ScrTextCollection.DeleteProject()`
4. Returns null to caller

### Source
Code location: `ParatextPluginHost.cs:180`
Method: `CreateNewProject()`

### Test Coverage
- Scenario ID: TS-048
- Golden master candidate: No
- Automated test feasibility: Medium

### Risk Assessment
- Likelihood of occurrence: Low
- Impact if behavior changes: High - could leave orphan directories

### Notes
EDGE-008 in business-rules.md. Cleanup sequence is important.

---

## Edge Case: EC-007 - Cancel After Registration Started

### Scenario
User initiates project registration with the registry server, then cancels the dialog.

### Current Behavior
`CancelNewProject` handles registered projects specially:
1. Deletes registry entry first (if project was registered)
2. Then removes versioned text
3. Finally deletes project directory

### Source
Code location: `ProjectPropertiesForm.cs:1265`
Method: `CancelNewProject()`

### Test Coverage
- Scenario ID: TS-032
- Golden master candidate: No
- Automated test feasibility: Medium (requires registry server)

### Risk Assessment
- Likelihood of occurrence: Low
- Impact if behavior changes: Medium - orphan registry entries

### Notes
EDGE-009 in business-rules.md.

---

## Edge Case: EC-008 - Interlinearizer Creates Output Project

### Scenario
Interlinearizer workflow creates an output project with pre-configured, non-editable settings.

### Current Behavior
`SetupForInterlinearOutputProject`:
1. Pre-fills form with values from source project
2. Disables certain controls (project type, versification)
3. Forces specific settings that match source project

### Source
Code location: `ProjectPropertiesForm.cs:352`
Method: `SetupForInterlinearOutputProject()`

### Test Coverage
- Scenario ID: TS-049
- Golden master candidate: No
- Automated test feasibility: Medium

### Risk Assessment
- Likelihood of occurrence: Medium (whenever interlinearizer used)
- Impact if behavior changes: High - interlinearizer output could be incorrect

### Notes
EDGE-010 in business-rules.md. Versification must match source for proper alignment.

---

## Edge Case: EC-009 - Customized Versification in Base Project

### Scenario
Base project has a customized (non-standard) versification scheme.

### Current Behavior
When creating derived project from customized base:
1. `ProjectSettings.CopyCustomVersification()` is called
2. Custom versification files are copied to new project
3. Versification setting references the custom scheme

### Source
Code location: `ProjectPropertiesForm.cs:379`
Method: `SetupForInterlinearOutputProject()` (and similar setup methods)

### Test Coverage
- Scenario ID: TS-046
- Golden master candidate: No
- Automated test feasibility: High

### Risk Assessment
- Likelihood of occurrence: Medium
- Impact if behavior changes: Critical - verse references would not align

### Notes
EDGE-001 in business-rules.md. Custom versification is critical for proper scripture references.

---

## Edge Case: EC-010 - Resource Project Versioning Attempt

### Scenario
Code attempts to create a VersionedText for a resource (copyrighted, read-only) project.

### Current Behavior
`VersionedText` constructor:
1. Checks if ScrText is a resource project
2. Throws `ArgumentException` with message "Versioning a Resource is forbidden."
3. No partial state changes occur

### Source
Code location: `VersionedText.cs:62`
Method: Constructor

### Test Coverage
- Scenario ID: TS-019
- Golden master candidate: No
- Automated test feasibility: High

### Risk Assessment
- Likelihood of occurrence: Very Low (system-managed)
- Impact if behavior changes: High - resource data integrity

### Notes
INV-005 invariant. Resources are copyrighted materials that cannot be modified.

---

## Edge Case: EC-011 - Case-Insensitive Name Collision

### Scenario
User attempts to create project "TESTPRJ" when "TestPrj" already exists.

### Current Behavior
`ValidateShortName` performs case-insensitive comparison:
1. Iterates through all projects in ScrTextCollection
2. Compares names using `OrdinalIgnoreCase`
3. Returns specific error: "Another project exists (TestPrj) with the same name, but a different case."

### Source
Code location: `ParatextUtils.cs:183`
Method: `ValidateShortName()`

### Test Coverage
- Scenario ID: TS-011
- Golden master candidate: No
- Automated test feasibility: High

### Risk Assessment
- Likelihood of occurrence: Medium
- Impact if behavior changes: Critical - file system issues on case-insensitive systems

### Notes
INV-001 / VAL-005. Windows and macOS have case-insensitive file systems by default.

---

## Edge Case: EC-012 - Orphan Directory Exists

### Scenario
User attempts to create project "OrphanDir" but a folder with that name already exists in the projects directory (not as a valid project).

### Current Behavior
`ValidateShortName`:
1. Checks if folder exists at path
2. Checks if folder is a valid project (has Settings.xml)
3. If folder exists but is not valid project, returns error: "A folder exists (OrphanDir) with the same name."

### Source
Code location: `ParatextUtils.cs:191`
Method: `ValidateShortName()`

### Test Coverage
- Scenario ID: TS-012
- Golden master candidate: No
- Automated test feasibility: High

### Risk Assessment
- Likelihood of occurrence: Low
- Impact if behavior changes: Medium - could overwrite orphan data

### Notes
VAL-006 validation rule. Protects against accidental data loss.

---

## Edge Case: EC-013 - Reserved Windows Filename

### Scenario
User attempts to use a Windows reserved filename as project short name (CON, PRN, AUX, NUL, COM1-9, LPT1-9).

### Current Behavior
`ValidateShortName`:
1. Checks name against list of reserved names (case-insensitive)
2. Returns error: "Project Short Name is a reserved file name on Windows and cannot be used."

### Source
Code location: `ParatextUtils.cs:199`
Method: `ValidateShortName()`

### Test Coverage
- Scenario IDs: TS-010, TS-054, TS-055, TS-056
- Golden master candidate: No
- Automated test feasibility: High

### Risk Assessment
- Likelihood of occurrence: Low
- Impact if behavior changes: Critical on Windows - cannot create directories with these names

### Notes
VAL-004 validation rule. These names are reserved at the OS level on Windows.

---

## Edge Case: EC-014 - Unicode Characters in Short Name

### Scenario
User attempts to include non-ASCII characters in the short name (e.g., accented letters, CJK characters).

### Current Behavior
`ValidateShortName`:
1. Regex check for valid characters: `[^A-Za-z0-9_]`
2. Any character outside this set fails validation
3. Error: "Short name can only contain letters A-Z, digits 0-9, and underscores."

### Source
Code location: `ParatextUtils.cs:174`
Method: `ValidateShortName()`

### Test Coverage
- Scenario ID: TS-063
- Golden master candidate: No
- Automated test feasibility: High

### Risk Assessment
- Likelihood of occurrence: Medium (international users)
- Impact if behavior changes: Medium - cross-platform file system compatibility

### Notes
VAL-002 validation rule. ASCII-only ensures maximum compatibility.

---

## Edge Case: EC-015 - Whitespace-Only Full Name

### Scenario
User enters a full name consisting only of spaces or tabs.

### Current Behavior
`ValidateForm` in ProjectNameForm:
1. Trims whitespace from full name
2. Checks if trimmed length >= 1
3. Returns error: "You must enter a full name"

### Source
Code location: `ProjectNameForm.cs:157`
Method: `ValidateForm()`

### Test Coverage
- Scenario ID: TS-064
- Golden master candidate: No
- Automated test feasibility: High

### Risk Assessment
- Likelihood of occurrence: Very Low
- Impact if behavior changes: Low

### Notes
VAL-007 validation rule.

---

## Edge Case: EC-016 - Maximum Name Iteration (9999)

### Scenario
When generating unique names, all variants up to "Name9998" exist.

### Current Behavior
`NextUnusedProjectName`:
1. Iterates from 1 to 9999 looking for unused name
2. If all iterations exhausted, behavior is undefined (likely returns last attempted name)

### Source
Code location: `ProjectPropertiesUtils.cs:461`
Method: `NextUnusedProjectName()`

### Test Coverage
- Scenario ID: TS-042 (partial)
- Golden master candidate: No
- Automated test feasibility: Low (requires 9999 test projects)

### Risk Assessment
- Likelihood of occurrence: Extremely Low
- Impact if behavior changes: Low

### Notes
EDGE-002 variant. In practice, no user would have 9999 projects with same base name.

---

## Edge Case: EC-017 - GUID Calculation Timing

### Scenario
GUID must be calculated from first Mercurial commit, but timing of commit affects the hash.

### Current Behavior
`VersionedText.CalculateGuid`:
1. Checks if repository has any commits
2. If no commits, forces an initial commit
3. Calculates GUID from first commit's revision hash

### Source
Code location: `VersionedText.cs:142`
Method: `CalculateGuid()`

### Test Coverage
- Scenario ID: TS-020
- Golden master candidate: No
- Automated test feasibility: Medium

### Risk Assessment
- Likelihood of occurrence: Every project creation
- Impact if behavior changes: Critical - GUIDs must be deterministic and unique

### Notes
INV-002. The commit must happen before GUID can be calculated. Timing/ordering is critical.

---

## Edge Case: EC-018 - Concurrent Project Creation

### Scenario
Two users or processes attempt to create projects with the same name simultaneously.

### Current Behavior
No explicit locking in `ValidateShortName` or project creation:
1. Both processes could pass validation simultaneously
2. First to create directory wins
3. Second would fail at directory creation or file write

### Source
Code location: Multiple (validation and creation are separate)

### Test Coverage
- No specific scenario (race condition)
- Golden master candidate: No
- Automated test feasibility: Low (requires parallel execution)

### Risk Assessment
- Likelihood of occurrence: Very Low (rare in practice)
- Impact if behavior changes: Medium - could result in partial project

### Notes
Not documented in business-rules.md. This is a potential race condition. PT10 may need explicit locking in multi-user scenarios.

---

## Risk Matrix Summary

| Edge Case | Likelihood | Impact | Overall Risk |
|-----------|------------|--------|--------------|
| EC-001 Trailing Digits | Medium | Medium | Medium |
| EC-002 Abbreviation Short | Low | Low | Low |
| EC-003 Abbreviation Long | Medium | Low | Low |
| EC-004 Backslash | Low | Medium | Low |
| EC-005 Missing Base | Very Low | High | Medium |
| EC-006 Plugin GUID Fail | Low | High | Medium |
| EC-007 Cancel Registration | Low | Medium | Low |
| EC-008 Interlinearizer | Medium | High | High |
| EC-009 Custom Versification | Medium | Critical | High |
| EC-010 Resource Versioning | Very Low | High | Low |
| EC-011 Case Collision | Medium | Critical | High |
| EC-012 Orphan Directory | Low | Medium | Low |
| EC-013 Reserved Filename | Low | Critical | Medium |
| EC-014 Unicode Name | Medium | Medium | Medium |
| EC-015 Whitespace Name | Very Low | Low | Very Low |
| EC-016 Max Iteration | Extremely Low | Low | Very Low |
| EC-017 GUID Timing | Every creation | Critical | Critical |
| EC-018 Concurrent Creation | Very Low | Medium | Low |

## Recommendations for PT10

1. **Critical Priority**:
   - EC-017: Ensure GUID calculation timing is preserved exactly
   - EC-009: Custom versification handling must be exact
   - EC-011: Case-insensitive validation is essential

2. **High Priority**:
   - EC-008: Interlinearizer workflow must match
   - EC-005: Add validation before proceeding with missing base
   - EC-006: Plugin error handling must clean up completely

3. **Consider Enhancement**:
   - EC-018: Add explicit locking for concurrent creation scenarios (new requirement, not PT9 matching)
