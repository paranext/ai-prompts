# USB Syncing - Task Description

> This task must comply with the [Porting Constitution](../../Constitution.md).

## 1. Feature Overview

| Field              | Value            |
| ------------------ | ---------------- |
| Feature Name       | USB Syncing      |
| Level              | A                |
| ParatextData Reuse | 90%              |
| Priority           | 2 (Medium effort)|

## 2. Goals & Non-Goals

### Goals

- Enable project synchronization via removable USB drives
- Support Mercurial push/pull operations to USB repositories
- Enumerate available USB drives cross-platform

### Non-Goals (Explicit)

- WiFi Direct syncing (separate feature)
- ChorusHub server integration (separate feature)
- Android/PT Lite USB sync paths

## 3. Legacy Context

| Field                 | Value                                  |
| --------------------- | -------------------------------------- |
| PT9 Code Files        | `ParatextData/Repository/FileSharedRepositorySource.cs`, `ParatextData/Repository/SharingLogic.cs`, `PtxUtils/PathUtils.cs` |
| ParatextData APIs     | `USBSharedRepositorySource`, `SharedRepositorySource`, `SendReceiveMemento`, `Hg` |
| Known Anti-Patterns   | WinForms drive selection dropdown |
| Existing PT9 Tests    | TBD by Archaeologist |

## 4. PT10 Target

| Field                   | Value                              |
| ----------------------- | ---------------------------------- |
| Target Location         | `c-sharp/Services/`, `extensions/src/` |
| Existing Infrastructure | None specific to USB |
| Integration Points      | PAPI commands, Node.js `drivelist` for USB detection, Main Process IPC |

## 5. Edge Cases & Constraints

- `PathUtils.GetUsbDevices()` is platform-specific (Windows WMI, Linux DBus/UDisks2)
- macOS USB detection may need Electron/Node.js approach
- Android fallback path: `Android/data/org.paratext.ptlite/files/Shared Paratext 8 Projects`

## 6. Test & Verification Notes

- Golden masters: USB directory structure, `SharedRepositoryInfoPT8.xml` format
- Property tests: Repository source type handling, sync state persistence
- Manual verification: Drive enumeration, push/pull operations

## 7. Reviewer Notes

| Field                   | Value |
| ----------------------- | ----- |
| Human Reviewer          |       |
| Priority                | 2     |
| Additional Instructions |       |
