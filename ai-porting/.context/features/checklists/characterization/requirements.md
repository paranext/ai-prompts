# Requirements: Checklists Feature

## Non-Functional Requirements

### Performance

#### Response Time
| Operation | Expected Latency | Notes |
|-----------|------------------|-------|
| Single project, single book | < 1 second | Typical use case |
| Single project, whole Bible | < 5 seconds | With progress dialog |
| Multi-project (3+), single book | < 3 seconds | Comparative analysis |
| Multi-project (3+), whole Bible | < 15 seconds | Shows progress, may hit max rows |
| Relatively Long/Short Verses (whole Bible) | < 10 seconds | Score calculation overhead |
| Words/Phrases with morphology | < 20 seconds | LexicalAnalyser is expensive |

#### Data Volume
| Metric | Expected Scale | Constraint |
|--------|---------------|------------|
| Maximum displayed rows | 5000 | Hard limit (INV-002) |
| Maximum comparative projects | No hard limit | Practical limit ~5-6 for usability |
| Maximum verse range | Entire Bible | ~31,000 verses |
| Typical row count per book | 50-1500 | Varies by book and checklist type |

#### Memory Constraints
- Checklist data held in memory during display
- Large comparisons (5+ projects, whole Bible) may use significant memory
- HTML rendering adds memory overhead
- No streaming/virtualization in PT9 implementation

### Accessibility

#### Keyboard Navigation
| Action | PT9 Implementation | Notes |
|--------|-------------------|-------|
| Focus checklist window | Standard Windows | Alt+Tab or window activation |
| Navigate toolbar | Tab key | Standard toolbar navigation |
| Navigate table rows | Arrow keys | Via HTML table in XmlDisplayControl |
| Activate link | Enter key | Standard link activation |
| Close dialog | Escape | Standard dialog behavior |
| Copy selection | Ctrl+C | Via Copy button or context menu |

#### Screen Reader Support
| Element | Accessibility | Notes |
|---------|--------------|-------|
| Window title | Announced | Includes project name and range |
| Table headers | HTML th elements | Column headers for projects |
| Cell content | HTML td elements | Scripture text readable |
| Reference links | Anchor elements | "goto:" and "edit:" prefixes |
| Error messages | Inline text | Read as cell content |

#### Color Contrast
- PT9 uses system Windows colors
- No custom color theming in checklist display
- Match highlighting in Words/Phrases uses bold, not color alone
- PT10 must respect platform-bible-react theming

#### Focus Management
- Modal dialogs (settings, verse range) return focus to main window
- Navigation from checklist maintains checklist focus
- Edit dialog returns focus to checklist on close

### Localization

#### Translatable Strings
| Category | Approximate Count | Location |
|----------|------------------|----------|
| Window titles | 13 | One per checklist type |
| Toolbar buttons | 8 | Standard toolbar items |
| Settings dialogs | ~30 per dialog | 4 settings dialogs |
| Error messages | ~10 | Various validation errors |
| Labels | ~20 | Match count, excluded count, etc. |

**Total estimated translatable strings: ~120**

#### RTL Support
- PT9 has limited RTL support
- Table layout should work with RTL content
- Scripture text direction determined by project settings
- Toolbar and UI chrome follow Windows locale
- PT10: Full RTL support required for Arabic, Hebrew translators

#### Date/Number Formatting
| Type | Format | Notes |
|------|--------|-------|
| Row counts | Localized numbers | "5,000" vs "5.000" |
| Percentages | N/A | Not used in checklists |
| Dates | N/A | Not used in checklists |
| Verse references | Project-specific | Book abbreviations from project |

### Platform Considerations

#### PT9 Windows-Specific Features
| Feature | PT9 Implementation | PT10 Alternative |
|---------|-------------------|------------------|
| XmlDisplayControl | WebBrowser control | React table component |
| XSLT transformation | XslCompiledTransform | Direct React rendering |
| CSS generation | CSSCreator class | Tailwind CSS |
| Print support | Windows print dialog | Browser print or PDF export |
| Clipboard | Windows Clipboard | Electron clipboard API |
| Drag selection | HTML selection | Native selection in table |

#### PT10 Electron Considerations
- Cross-platform file paths for Save HTML
- Print functionality via browser print API
- Keyboard shortcuts may conflict with browser defaults
- WebView rendering for checklist display
- IPC for navigation commands to main window

## Error Handling Requirements

### User-Facing Error Messages

| Error Condition | PT9 Message | Localization Key | Recovery Action |
|-----------------|-------------|------------------|-----------------|
| Reference settings not reviewed | "In order to check cross references for the {0} project, you must first enter or verify the punctuation, abbreviations, and short names used in your {0} project." | TBD | User opens settings |
| Quote settings incomplete | "In order to run this check, go to {setup command}..." | TBD | User opens settings |
| Invalid cross reference | "There is an error in the reference" | TBD | User edits source |
| Missing book title | "No Book Title Present" | TBD | User adds title |
| Max rows exceeded | Warning about truncated results | TBD | User narrows range |
| Second text required | "Second text required for comparison" | TBD | User adds comparative |
| Progress cancelled | (No message - silent abort) | N/A | N/A |
| Project removed | (Window closes) | N/A | N/A |

### Error Recovery Patterns

1. **Settings Validation Errors**
   - Show error message with guidance
   - Allow user to cancel or fix settings
   - Don't show partial results

2. **Data Extraction Errors**
   - Continue processing other data
   - Show error inline in affected cell
   - Log detailed error for support

3. **Navigation Errors**
   - Cancel navigation silently
   - Log error for debugging
   - Don't crash or show dialog

4. **External Resource Errors**
   - Handle missing comparative projects gracefully
   - Filter out unavailable resources
   - Continue with available projects

### Help Text & Tooltips

| UI Element | Help Text | Notes |
|------------|-----------|-------|
| Comparative Texts button | "Choose texts to compare against" | Toolbar tooltip |
| Verse Range button | "Limit to a range of verses" | Toolbar tooltip |
| Hide Matches checkbox | "Hide rows where all texts match" | Toolbar tooltip |
| Show Verse Text checkbox | "Include verse text with references" | For Cross Refs/Markers |
| Settings button | "Configure checklist options" | Type-specific |
| Print button | "Print checklist" | Standard print |
| Save button | "Save as HTML file" | Export functionality |
| Copy button | "Copy selection to clipboard" | Text copy |

### Validation Feedback

| Validation | Timing | Feedback Method |
|------------|--------|-----------------|
| Empty search strings (Words/Phrases) | On OK click | Dialog validation |
| Invalid verse range | On OK click | Dialog validation |
| Punctuation filter with spaces | Auto-corrected | Spaces removed silently |
| Marker filter with invalid markers | On display | Filtered out silently |

## Migration Requirements

### Existing User Data

#### Data Location
| Data Type | PT9 Location | Storage Method |
|-----------|--------------|----------------|
| Checklist memento | Project folder | XML serialization |
| Comparative text selection | Memento | String list |
| Verse range | Memento | VerseRef pair |
| Hide matches state | Memento | Boolean |
| Show verse text state | Memento | Boolean |
| Type-specific settings | Memento | Dictionary |

#### Migration Needed
- **Memento data**: PT10 must decide whether to migrate PT9 mementos
- **Settings format**: May differ between WinForms and React implementations
- **Recommendation**: Start fresh with PT10 defaults, don't migrate settings

#### Backwards Compatibility
- PT9 and PT10 may run side-by-side
- Checklist settings are per-installation, not synced
- No shared state concerns

### Breaking Changes

#### Intentional Changes from PT9
1. **Rendering technology**: XSLT/HTML replaced with React components
2. **Table virtualization**: PT10 should support more than 5000 rows via virtual scrolling
3. **Export formats**: PT10 may add CSV export, not just HTML
4. **Keyboard navigation**: Enhanced accessibility patterns
5. **Theme support**: Dark mode and custom themes

#### Behavioral Equivalence Required
1. All 13 checklist types must produce equivalent output
2. Versification alignment must match exactly
3. Hide matches filtering must be identical
4. Score calculations (relative length, long sentences) must match
5. Edit/navigation links must work identically

## Integration Requirements

### PAPI Integration Points

| Integration | Direction | Data |
|-------------|-----------|------|
| Open checklist | Extension -> PAPI | Project ID, checklist type |
| Navigate to verse | Extension -> PAPI | Verse reference |
| Edit scripture | Extension -> PAPI | Verse reference, project |
| Project change subscription | PAPI -> Extension | Change events |
| Project list | Extension <- PAPI | Available projects |
| Scripture data | Extension <- PAPI | USFM tokens via ParatextData |

### Related Features

| Feature | Integration Type | Notes |
|---------|-----------------|-------|
| Biblical Terms | Launches Words/Phrases | Pre-configured search |
| Main editor window | Navigation target | GotoReference |
| Edit dialog | Modal editor | EditScrTextForm replacement |
| Project settings | Settings validation | Quote marks, reference settings |

### Data Provider Requirements

| Data | Provider | Method |
|------|----------|--------|
| USFM tokens | ParatextData | ScrText.Parser.GetUsfmTokens() |
| Versification | ParatextData | ScrVers, VerseRef |
| Character categorization | ParatextData | CharacterCategorizer |
| Stylesheet | ParatextData | ScrStylesheet, ScrTag |
| Cross-reference parsing | ParatextData | CrossReferenceScanner |
| Quote settings | ParatextData | QuotationMarkInfo |
| Morphology | ParatextData | LexicalAnalyser |

## UI Component Requirements

### Table Component

| Requirement | Priority | Notes |
|-------------|----------|-------|
| Variable column count | High | 1-N projects |
| Fixed reference column | High | First column |
| Cell HTML rendering | High | Scripture formatting |
| Row selection | Medium | For copy/navigation |
| Virtual scrolling | Medium | For >5000 rows |
| Column resizing | Low | User preference |
| Column reordering | Low | User preference |
| Sort by column | Low | Not in PT9 |
| Filter by column | Low | Not in PT9 |

### Settings Dialogs

| Dialog | Controls Required | Complexity |
|--------|------------------|------------|
| VerseSettingsForm | 2 checkboxes | Low |
| MarkerSettingsForm | 2 text inputs | Medium |
| WordOrPhraseSettingsForm | Text area, checkbox | Medium |
| PunctuationSettingsForm | Text input | Low |
| VerseRangeDialog | Verse picker, button | Medium |
| ComparativeTextsDialog | Multi-select list | Medium |

### Toolbar

| Button | Icon | Action | Visibility |
|--------|------|--------|------------|
| Comparative Texts | List icon | Open selection dialog | Always |
| Verse Range | Range icon | Open range dialog | Always |
| Hide Matches | Toggle icon | Toggle filter | When comparative texts exist |
| Show Verse Text | Toggle icon | Toggle display | CrossReferences, Markers only |
| Settings | Gear icon | Open settings dialog | Type-specific |
| Print | Print icon | Open print preview | Always |
| Save | Save icon | Open save dialog | Always |
| Copy | Copy icon | Copy selection | Always |

## Security Requirements

### Input Validation
- Verse references validated before navigation
- Search strings sanitized for display (prevent XSS in HTML rendering)
- File paths validated for save operation
- Project names validated against ScrTextCollection

### Resource Access
- Read-only access to scripture data (no direct modification)
- Edit operations go through EditScrTextForm with permission checks
- No network access required for checklist functionality
- File save requires user confirmation of path

### Sensitive Data
- No credentials or authentication data handled
- Project content may be sensitive (permissions respected)
- Clipboard data is user-initiated
- Print/save operations are user-initiated

## Testing Infrastructure Requirements

### Test Data Requirements
1. **Multi-versification test projects**: At least 2 projects with different versifications
2. **Incomplete projects**: Projects with missing verses, chapters, books
3. **Malformed content**: Projects with invalid cross-references, missing titles
4. **Poetry content**: Psalms-like content with section headings and stanza breaks
5. **Verse bridges**: Projects with bridged verses (e.g., v.1-2)
6. **Quotation patterns**: Projects with various quotation mark structures
7. **Footnotes and cross-refs**: Projects with rich apparatus

### Golden Master Test Setup
1. Create reference test projects with controlled content
2. Generate expected output for each checklist type
3. Store as JSON for comparison
4. Version control test data

### Property-Based Test Requirements
1. Row count invariant (INV-001): Verify cell count matches project count
2. Max rows invariant (INV-002): Verify truncation at 5000
3. Reference ordering (POST-003): Verify rows in verse order
4. Versification consistency (INV-004): Verify reference normalization
