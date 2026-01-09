# Translation Resources - Task Description

> This task must comply with the [Porting Constitution](../../Constitution.md).

## 1. Feature Overview

| Field              | Value            |
| ------------------ | ---------------- |
| Feature Name       | Translation Resources (Older Style) |
| Level              | B/C              |
| ParatextData Reuse | 80%              |
| Priority           | 3 (Medium effort)|

## 2. Goals & Non-Goals

### Goals

- Display read-only zipped Scripture reference materials
- Support both old-style (root figures) and new-style (figures/ subfolder) resources
- Enable BCV and Dictionary navigation schemes

### Non-Goals (Explicit)

- Resource editing or modification
- Creating new resource packages
- DBL resource downloading (handled by existing `DblResourcesDataProvider`)

## 3. Legacy Context

| Field                 | Value                                  |
| --------------------- | -------------------------------------- |
| PT9 Code Files        | `ParatextData/ResourceScrText.cs`, `ParatextData/ProjectFileAccess/ResourceProjectFileManager.cs`, `Paratext/XmlResource/XmlResourceWindow.cs` |
| ParatextData APIs     | `ResourceScrText`, `XmlResourceScrText`, `ResourceProjectFileManager`, `InstallableResource` |
| Known Anti-Patterns   | Firefox-based HTML viewer, XPath navigation |
| Existing PT9 Tests    | TBD by Archaeologist |

## 4. PT10 Target

| Field                   | Value                              |
| ----------------------- | ---------------------------------- |
| Target Location         | `c-sharp/Projects/`, `extensions/src/` |
| Existing Infrastructure | `DblResourcesDataProvider` (DBL download/install) |
| Integration Points      | PAPI commands, `platform-scripture` extension patterns, Electron webview |

## 5. Edge Cases & Constraints

- Old vs new style figure location detection (transparent to caller)
- Resource types: DBL, EnhancedResource, XmlResource, SourceLanguageResource
- Encrypted `.p8z` files vs `.xml1z` XML resources

## 6. Test & Verification Notes

- Golden masters: Resource content extraction, figure path resolution
- Property tests: Old/new style detection logic
- Manual verification: HTML/media rendering, BCV navigation, dictionary lookup

## 7. Reviewer Notes

| Field                   | Value |
| ----------------------- | ----- |
| Human Reviewer          |       |
| Priority                | 3     |
| Additional Instructions |       |
