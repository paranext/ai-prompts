# PT9 Capture Checklist: Creating Projects

**Feature**: Creating Projects
**Date**: 2026-01-05
**Status**: Pending capture from PT9 running on Windows

---

## Instructions

1. Run PT9 on the Windows machine
2. For each item below, capture and save to this directory
3. Check off items as completed
4. Screenshots: Save as PNG with the ID as filename (e.g., `UI-001.png`)
5. Settings.xml: Copy the file and rename with ID (e.g., `GM-001-Standard-Settings.xml`)
6. Directory listings: Save as text file (e.g., `DIR-001.txt`)

---

## Category A: UI Screenshots

| Done | ID | Description | Filename |
|------|----|-------------|----------|
| [ ] | UI-001 | New Project dialog - initial state (File > New Project) | `UI-001.png` |
| [ ] | UI-002 | Project Name tab - empty form | `UI-002.png` |
| [ ] | UI-003 | Project Name tab - validation error (type "AB" for too short) | `UI-003.png` |
| [ ] | UI-004 | Project Name tab - validation error (duplicate existing name) | `UI-004.png` |
| [ ] | UI-005 | Project Type dropdown expanded (show all options) | `UI-005.png` |
| [ ] | UI-006 | Base Project selector (select BackTranslation type first) | `UI-006.png` |
| [ ] | UI-007 | Language selection dialog | `UI-007.png` |
| [ ] | UI-008 | Versification dropdown expanded | `UI-008.png` |
| [ ] | UI-009 | Encoding selection dropdown | `UI-009.png` |
| [ ] | UI-010 | Books/Scope tab | `UI-010.png` |
| [ ] | UI-011 | Project creation progress dialog (if visible) | `UI-011.png` |

---

## Category B: Settings.xml Golden Masters (HIGH PRIORITY)

### GM-001: Standard Project
- [ ] Create new Standard translation project with these settings:
  - Short name: `GMSTD`
  - Full name: `Golden Master Standard`
  - Language: English (en)
  - Versification: English
- [ ] Copy `Settings.xml` from project folder
- [ ] Save as: `GM-001-Standard-Settings.xml`

### GM-002: Back Translation Project
- [ ] Create new Back Translation project with these settings:
  - Short name: `GMBT`
  - Full name: `Golden Master Back Translation`
  - Base project: (any existing project)
- [ ] Copy `Settings.xml` from project folder
- [ ] Save as: `GM-002-BackTranslation-Settings.xml`

### GM-003: Daughter Project
- [ ] Create new Daughter translation project with these settings:
  - Short name: `GMDTR`
  - Full name: `Golden Master Daughter`
  - Base project: (any existing project)
- [ ] Copy `Settings.xml` from project folder
- [ ] Save as: `GM-003-Daughter-Settings.xml`

### GM-004: Study Bible Additions
- [ ] Create new Study Bible Additions project with these settings:
  - Short name: `GMSBA`
  - Full name: `Golden Master Study Bible`
  - Base project: (any Scripture project)
- [ ] Copy `Settings.xml` from project folder
- [ ] Save as: `GM-004-StudyBible-Settings.xml`

### GM-005: Consultant Notes (Optional)
- [ ] Create new Consultant Notes project
- [ ] Copy `Settings.xml` from project folder
- [ ] Save as: `GM-005-ConsultantNotes-Settings.xml`

### GM-006: Custom Versification (Optional)
- [ ] Create project with non-English versification (e.g., Original, Vulgate)
- [ ] Copy `Settings.xml` from project folder
- [ ] Save as: `GM-006-CustomVersification-Settings.xml`

---

## Category C: Directory Structure

### DIR-001: Standard Project Directory
- [ ] After creating GM-001 (Standard), list the project folder contents
- [ ] Windows: `dir /b C:\My Paratext 9 Projects\GMSTD`
- [ ] Save output as: `DIR-001-Standard-listing.txt`

### DIR-002: .hg Directory Contents
- [ ] List contents of `.hg` folder in any project
- [ ] Windows: `dir /b C:\My Paratext 9 Projects\GMSTD\.hg`
- [ ] Save output as: `DIR-002-hg-listing.txt`

### DIR-003: Derived Project Directory
- [ ] After creating GM-002 (BackTranslation), list folder contents
- [ ] Note: Should include `license.json` if base project has one
- [ ] Save output as: `DIR-003-BackTranslation-listing.txt`

---

## Category D: Error Messages (Optional)

| Done | ID | Trigger | Filename |
|------|----|---------|----------|
| [ ] | ERR-001 | Enter "AB" as short name (too short) | `ERR-001.png` |
| [ ] | ERR-002 | Enter "ABCDEFGHI" as short name (too long) | `ERR-002.png` |
| [ ] | ERR-003 | Enter "Test-1" as short name (invalid hyphen) | `ERR-003.png` |
| [ ] | ERR-004 | Enter existing project name | `ERR-004.png` |
| [ ] | ERR-005 | Enter "CON" as short name (Windows reserved) | `ERR-005.png` |

---

## Cleanup

After capturing, you may delete the test projects created:
- GMSTD, GMBT, GMDTR, GMSBA, etc.

Or keep them for future reference.

---

## Sync to Mac

Once captures are complete, sync this folder to the Mac via:
- Shared folder
- Cloud storage (OneDrive/Dropbox)
- USB drive
- Or paste screenshots directly into Claude conversation

---

## Completion

When done, update the phase-status.md to note captures are complete.
