# Requirements: Creating Projects

## Non-Functional Requirements

### Performance

| Operation | Expected Latency | Notes |
|-----------|------------------|-------|
| Dialog open | < 500ms | Initial form load |
| Name validation | < 100ms | Per keystroke validation |
| Abbreviation generation | < 50ms | Real-time as user types |
| Unique name generation | < 200ms | Depends on collection size |
| Project creation (no books) | < 2s | Directory, Settings.xml, Mercurial init |
| Project creation (Study Bible) | 5-60s | Depends on number of books to copy |
| GUID assignment | < 1s | Includes initial commit |

**Data Volume Expectations**:
- Typical: 1-50 projects per user
- Maximum tested: ~200 projects in collection
- Settings.xml size: 2-10 KB typical
- Project directory initial size: < 100 KB (before books)

**Memory Constraints**:
- ScrTextCollection holds all projects in memory
- Each ScrText: ~50-200 KB depending on settings
- Dialog should not leak memory on cancel

### Accessibility

**Keyboard Navigation**:
- Tab order must follow logical flow through form fields
- All form controls accessible via keyboard
- OK/Cancel buttons accessible via Enter/Escape
- Combo boxes navigable with arrow keys

**Screen Reader Support**:
- All form labels properly associated with inputs
- Error messages announced when validation fails
- Progress updates announced for long operations (book copying)
- Focus management during async operations

**Color Contrast**:
- Error messages must have sufficient contrast (WCAG AA minimum)
- Validation indicators visible to colorblind users
- Do not rely solely on color for error indication

**Focus Management**:
- Focus moves to first invalid field on validation failure
- Focus returns to triggering control after dialogs close
- Modal dialogs trap focus appropriately

### Localization

**Translatable Strings** (estimated):
- Dialog titles: 5
- Field labels: 20-25
- Button labels: 5-10
- Error messages: 15-20
- Help text/tooltips: 10-15
- Progress messages: 5
- Total: ~60-75 strings

**RTL Support**:
- Dialog layout must support RTL languages
- Text input fields must handle RTL input
- Lists and dropdowns must display correctly in RTL

**Date/Number Formatting**:
- Not heavily used in project creation
- Any displayed dates should use locale format
- Numeric version numbers displayed as-is (not localized)

**String Formatting**:
- Error messages use positional parameters: "Another project exists ({0})..."
- Must support parameter reordering for different languages

### Platform Considerations

**PT9 Windows-Specific Features**:
| Feature | PT9 Implementation | PT10 Alternative |
|---------|-------------------|------------------|
| WinForms dialogs | System dialogs | React components |
| File dialog integration | System file picker | Electron dialog API |
| Registry for settings | Windows Registry | Cross-platform config files |
| Path handling | Windows paths | Node.js path module |

**PT10 Electron Considerations**:
- File system access through Node.js APIs
- Mercurial invocation via child_process
- Dialog windows are BrowserWindow instances
- IPC required for main/renderer communication

**Cross-Platform Path Handling**:
- Use path.join() for directory construction
- Normalize path separators
- Handle case-sensitivity differences (macOS/Windows vs Linux)
- Windows reserved filenames only apply on Windows but validated universally

## Error Handling Requirements

### User-Facing Error Messages

| Error Condition | PT9 Message (English) | Localization Key (if known) |
|-----------------|----------------------|----------------------------|
| Short name < 3 chars | "Short name must not be less than 3 or more than 8 characters in length" | TBD |
| Short name > 8 chars | "Short name must not be less than 3 or more than 8 characters in length" | TBD |
| Short name has spaces | "Short name must not contain spaces" | TBD |
| Short name invalid chars | "Short name can only contain letters A-Z, digits 0-9, and underscores." | TBD |
| Reserved filename | "Project Short Name is a reserved file name on Windows and cannot be used." | TBD |
| Duplicate name (exact) | "A project already exists with that short name." | TBD |
| Duplicate name (case diff) | "Another project exists ({0}) with the same name, but a different case. You will need to use a different short name for this project." | TBD |
| Folder exists | "A folder exists ({0}) with the same name. You will need to use a different short name for this project." | TBD |
| Empty full name | "You must enter a full name" | TBD |
| Invalid language ID | "Language ID '{0}' is not a valid language tag." | TBD |
| Derived without base | Internal error (should not reach user) | N/A |
| Resource versioning | Internal error "Versioning a Resource is forbidden." | N/A |

### Error Message Guidelines

1. **Be Specific**: Tell user exactly what is wrong
2. **Be Actionable**: Tell user how to fix the problem
3. **Reference Context**: Include the problematic value when helpful
4. **Consistent Tone**: Use same voice/style across all messages
5. **Avoid Technical Jargon**: "short name" is acceptable Paratext terminology

### Exception Handling Strategy

| Exception Type | Scenario | User Experience |
|----------------|----------|-----------------|
| ArgumentNullException | Missing required parameter | Should not reach user (programming error) |
| ArgumentException | Invalid parameter value | Convert to user-friendly error message |
| InvalidOperationException | Invalid state transition | Convert to user-friendly error message |
| ParatextPluginException | Plugin API error | Return to plugin with error details |
| IOException | File system error | Show error with retry option |
| UnauthorizedAccessException | Permission denied | Show error explaining needed permissions |

### Help Text & Tooltips

| Element | Text | Context |
|---------|------|---------|
| Short Name field | "3-8 characters, letters A-Z, digits, and underscores only" | Tooltip on text field |
| Full Name field | "The full descriptive name of your project" | Tooltip on text field |
| Project Type dropdown | "Select the type of translation project" | Tooltip on dropdown |
| Base Project selector | "Select the project this is based on" | Shown only for derived types |
| Versification dropdown | "Choose the verse numbering system" | Tooltip on dropdown |
| Language selector | "Select or enter the language code" | Tooltip on language field |
| Book Chooser | "Select which books you plan to translate" | Section header or tooltip |

## Security Considerations

### Input Validation

All user inputs must be validated before use:

1. **Short Name**: Regex validation `^[A-Za-z0-9_]{3,8}$` plus reserved name check
2. **Full Name**: Non-empty after trim, backslash sanitization
3. **Language ID**: BCP-47 format validation
4. **File Paths**: Prevent path traversal attacks
5. **Base Project Reference**: Validate project exists and user has access

### File System Security

- Projects created only in designated projects directory
- Cannot create projects outside configured path
- Validate short name does not contain path separators
- Prevent creation of symlinks or junctions as project directories

### Permission Verification

- Guest users cannot create projects (enforced at entry point)
- User must have write access to projects directory
- Derived projects require access to base project
- License inheritance requires read access to base project license

## Migration Requirements

### Existing User Data

**Data Location**:
- PT9: `{UserDocuments}/My Paratext 9 Projects/`
- PT10: Same directory (shared with PT9)

**Migration Needed**: No
- PT10 uses same ParatextData.dll and same project format
- Projects created by PT9 are directly usable by PT10
- Projects created by PT10 are usable by PT9 (with MinParatextDataVersion check)

**Backwards Compatibility**:
- MinParatextDataVersion field controls compatibility
- New projects set this to current version
- Older Paratext versions may refuse to open new projects
- Settings.xml format must remain compatible

### Breaking Changes

**Intentional Differences from PT9**:
1. UI framework change (WinForms to React) - workflow may differ slightly
2. Progress reporting style - React async patterns vs WinForms synchronous
3. Dialog modality - Electron window management differs from Windows forms

**Must NOT Change**:
1. Settings.xml format and content
2. Project directory structure
3. Mercurial repository format
4. GUID calculation method
5. File naming patterns
6. Validation rules (exactly match PT9)
7. TranslationInformation structure
8. ParatextData API contracts

## Concurrency Requirements

### Single-User Scenarios

- Project creation is typically single-threaded
- No concurrent creation from same PT instance
- Dialog is modal, preventing other operations

### Multi-User Scenarios (Future)

- Potential for concurrent creation in collaborative environments
- Name validation should use atomic check-and-create
- Consider file locking for project directory creation

## Data Integrity Requirements

### Required Files After Creation

| File | Required | Purpose |
|------|----------|---------|
| Settings.xml | Yes | Core project settings |
| .hg/ directory | Yes | Mercurial repository |
| license.json | Conditional | For license-sharing derived projects |
| CommentTags.xml | Conditional | For note projects |
| Custom versification files | Conditional | When base has custom versification |

### Atomicity

Project creation should be atomic:
- Either complete successfully with all required files
- Or clean up completely leaving no partial state
- Cancel must remove all created artifacts

### Recovery

If creation fails mid-process:
- Plugin API returns null and cleans up
- UI cleans up via CancelNewProject
- Orphan directories should be detectable and cleanable

## API Contract Requirements

### ParatextData APIs Used

| API | Purpose | Contract Notes |
|-----|---------|----------------|
| `ScrText.ctor(ParatextUser)` | Create new project | Returns new instance, no persistence |
| `ScrText.Save()` | Persist settings | Creates/updates Settings.xml |
| `ScrTextCollection.Add(ScrText)` | Register project | Requires GUID, adds to collection |
| `ScrTextCollection.FindByName(string)` | Check for duplicates | Returns null if not found |
| `VersioningManager.EnsureHasGuid(ScrText)` | Assign GUID | May create initial commit |
| `VersionedText.ctor(ScrText)` | Initialize repository | Calls Hg.Init if needed |
| `TranslationInformation.ctor(...)` | Set project type | Throws for invalid derived config |
| `ParatextUtils.ValidateShortName(...)` | Validate name | Returns error message or null |

### Return Value Contracts

These behaviors must be preserved exactly:
- `ValidateShortName` returns `null` for valid, error string for invalid
- `ScrTextCollection.FindByName` returns `null` when not found
- `TranslationInformation.BaseScrText` returns `null` when base missing
- Plugin API returns `null` on failure (after cleanup)

## Testing Strategy Alignment

Based on **Level A** classification:

### Primary: API Contract Tests

Focus test effort on verifying ParatextData API contracts are met:
- Inputs produce expected outputs
- Exceptions thrown for invalid inputs
- Side effects occur as expected

### Property-Based Tests

Test invariants with generated inputs:
- PT-001: Unique names
- PT-002: Unique GUIDs
- PT-003: Directory matches name
- PT-004: Derived projects have base
- PT-005 through PT-010: Validation properties

### Golden Masters (Minimal)

Only for critical format verification:
- Settings.xml structure for each project type
- File naming patterns

### Manual Verification Checklist

- [ ] UI flow matches expected workflow
- [ ] All validation messages display correctly
- [ ] Progress feedback during long operations
- [ ] Cancel properly cleans up
- [ ] Derived project linking works
- [ ] Study Bible book copying works
- [ ] Multiple consecutive creations work
