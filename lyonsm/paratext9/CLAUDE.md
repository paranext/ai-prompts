# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Paratext is a Bible translation and scripture editing application developed by UBS (United Bible Societies) and SIL International. It provides scripture text editing with USFM support, biblical terms management, translation checking tools, project collaboration via Send/Receive (Mercurial), and publishing capabilities.

## Build and Test Commands

### Building

**Build main Paratext application (Debug):**
```bash
nuget restore AllProjects.sln
msbuild /t:Build /property:Configuration=Debug /property:Platform=x64 /property:AllowUnsafeBlocks=true AllProjects.sln
```

**Build specific configuration:**
```bash
msbuild /t:Build /property:Configuration=Release /property:Platform=x64 Paratext.sln
```

**Quick development build and test:**
```bash
./RunDevBuild.bat  # Restores packages, builds Debug x64, runs ResourceCreator, runs tests
```

**Build Publishing Assistant:**
```bash
cd PA
msbuild /t:Build /property:Configuration=Debug PublishingAssistant.sln
```

### Testing

**Run all tests:**
```bash
./RunAllTests.bat Debug  # or x64\Debug depending on build configuration
```

This runs NUnit 3 console runner on all `*.Tests` projects, excluding tests marked with `cat != Unstable`.

**Run tests for a specific project:**
```bash
cd BiblicalTerms.Tests/bin/x64/Debug
../../../../packages/NUnit.ConsoleRunner.3.10.0/tools/nunit3-console --labels=All BiblicalTerms.Tests.dll
```

### Other Useful Commands

**Register COM components:**
```bash
./registerCOM.bat
```

**Build installer (NAnt-based):**
```bash
./nantBuild.bat [target]
```

## Architecture

### Layered Architecture

```
Paratext (Main Application - .NET 4.8 WinExe)
    ↓
ParatextBase (Shared UI Framework - .NET 4.8)
    ↓
BiblicalTerms | ParatextChecks | HelpSystem (Feature Modules)
    ↓
ParatextInternalShared (Shared Logic)
    ↓
ParatextData (Core Data Layer - .NET Standard 2.0)
    ↓
PtxUtils | NetLoc | SIL Libraries
```

### Key Projects

**ParatextData/** - Core data access layer (.NET Standard 2.0)
- Cross-platform library that can be used standalone by third-party applications
- `ScrText.cs` - Main class representing a Scripture project
- `ScrTextCollection.cs` - Project factory/repository
- `Repository/` - Mercurial version control integration
- `Terms/` - Biblical terms data structures
- `Plugins/` - Plugin wrapper implementations
- `Linguistics/` - Morphological analysis and lexicon integration

**Paratext/** - Main desktop application (.NET Framework 4.8)
- Windows-only executable
- Main window, text editor, menu/ribbon UI
- Window orchestration and management
- `Plugins/Legacy/` - Legacy plugin system support

**ParatextBase/** - Shared UI infrastructure (.NET Framework 4.8)
- Reusable WinForms controls and dialogs
- Plugin framework base classes (`PluginManager`, `PluginAnnotationSource`)
- Window management abstractions
- Theme support

**BiblicalTerms/** - Biblical terms module
- Grid controls for term management
- Term rendering and filtering
- `NameAdaptor/` - Name adaptation tools
- `RenderingDifferences/` - Rendering comparison

**PA/PublishingAssistant/** - Desktop publishing tool
- Separate application for typesetting and print layout
- InDesign integration
- `PAScripting/` - C# scripting support for automation

**ParatextChecks/** - Scripture validation framework
- Extensible checking engine (capitalization, punctuation, quotations, etc.)
- Individual check implementations inherit from `ScriptureCheckBase`

### Plugin Architecture

Paratext supports two plugin models:

**1. Modern Plugin System (CorePluginInterfaces/)**
- `IPluginHost` - Main entry point to Paratext functionality
- `IProject` - Scripture project access (read/write USFM, notes, settings)
- `IBiblicalTermsWindow`, `IReferenceListWindow` - Access to Paratext tools
- `IParatextWindowPlugin` - Creates embedded child windows

**2. Legacy Plugin System (PluginFramework/)**
- Uses .NET Add-In framework with AppDomain isolation
- Contract-based communication with adapters

### Data Access Patterns

**Central Classes:**
- `ScrText` - Represents a single Scripture project (implements `IGetText`, `IPutText`)
- `ScrTextCollection` - Static factory for finding and enumerating projects
- `IWriteLock` - Request write locks to safely modify project data
- `ProjectFileManager` - Abstracts file system access

**Data Formats:**
- **USFM** - Unified Standard Format Markers (text storage)
- **USX** - XML version of USFM
- **UsfmToken** - Parsed USFM representation
- **ProjectSettings** - XML project configuration
- **Biblical Terms** - XML term lists with localizations

**Repository Pattern:**
- Mercurial integration via `Repository/Hg.cs`
- Custom merge strategies for USFM, biblical terms, and notes
- `SharedRepositorySource` abstractions for Internet/USB Send/Receive

### Key Architectural Patterns

**Lazy Initialization:**
```csharp
private readonly LazyInitHelper<ScrStylesheet> cachedStylesheet;
```
Defers expensive operations until needed. Used extensively throughout ParatextData.

**Event-Driven:**
```csharp
public event ScriptureDataChangedHandler ScriptureDataChanged;
```
Components communicate via events for loose coupling.

**Factory Pattern:**
```csharp
ScrTextCollection.ScrTexts(IncludeProjects.AllAccessible)
```
Centralized object creation for projects and resources.

## Development Guidelines

### Platform Considerations

- **Windows-only:** Main Paratext, PA, and all UI components require Windows and .NET Framework 4.8
- **Cross-platform:** ParatextData (.NET Standard 2.0) can run on Linux/Mac
- **64-bit only:** Native dependencies (ICU, TECkit) require x64 platform
- **HTML rendering:** Uses Gecko/Firefox engine (see HtmlEditor/)

### Testing Infrastructure

**Test Organization:**
- 22 test projects organized by layer (Data, UI, Features)
- All use NUnit 3 framework
- `UserInterfaceTests/` - End-to-end UI automation using WinAppDriver

**Test Patterns:**
```csharp
// Common base class pattern
public class ScrTextTestsBase
{
    protected ScrText CreateTestProject();
}

// Use dummy implementations for isolation
public class DummyScrTextCollection : ScrTextCollection { }
```

### Common Development Scenarios

**Adding a new scripture check:**
1. Create new class in `ParatextChecks/Checks/` inheriting from `ScriptureCheckBase`
2. Implement check logic in `Check()` method
3. Use `RecordError()` to report issues
4. Register check in `RunBasicChecks.cs`

**Adding a new plugin interface:**
1. Define interface in `CorePluginInterfaces/` (stable API)
2. Implement wrapper in `ParatextData/Plugins/`
3. Expose through `IPluginHost` in `ParatextData/Plugins/Host.cs`
4. Update plugin documentation

**Modifying USFM parsing:**
1. Update `ScrParser.cs` in `ParatextData/`
2. Ensure USX conversion consistency in `UsxFragmenter.cs`
3. Update `usfm.sty` stylesheet if adding new markers
4. Add tests in `ParatextData.Tests/`

**Working with project data:**
```csharp
// Always get project through ScrTextCollection
var project = ScrTextCollection.Find("ProjectName");

// Request write lock before modifying
var writeLock = project.RequestWriteLock(pluginObj, OnReleaseRequested, bookNum, chapterNum);
try {
    string usfm = project.GetUSFM(bookNum, chapterNum);
    // Modify USFM...
    project.PutUSFM(writeLock, modifiedUsfm, bookNum);
} finally {
    writeLock.Dispose();
}
```

### File Locations

- **Project data:** `My Paratext Projects/` or `My Paratext 9 Projects/`
- **Resources:** `_Resources/` subdirectory in projects folder
- **User settings:** AppData/Local/United_Bible_Societies/
- **Repository data:** `.hg/` directories in each project
- **Build output:** `Output/Debug/` and `Output/Release/`

### External Dependencies

- **SIL Libraries:** Scripture references, writing systems, IO utilities
- **ICU:** Unicode and language support
- **Mercurial:** Distributed version control (Python-based, bundled)
- **Gecko/XULRunner:** HTML rendering engine
- **InDesign:** Required for Publishing Assistant integration

### Localization

- NetLoc framework manages UI strings
- `LocalizationCrowdInCmd/` - CrowdIn integration for community translation
- Help system also localized via CrowdIn

### Solution Files

- `AllProjects.sln` - Main solution with all projects
- `AllProjectsExceptDataAccess.sln` - Excludes DataAccessServer
- `Paratext.sln` - Core Paratext only (subset for faster builds)
- `PA/PublishingAssistant.sln` - Publishing Assistant standalone
- `PluginInterfaces.sln` - Plugin interfaces only

## Important Notes

### Build Requirements

- Visual Studio 2019 or 2022 with:
  - .NET desktop development workload
  - .NET Framework 4.6.2-4.7.1 development tools
  - .NET Framework 4.8.1 development tools
- ReSharper recommended (team uses shared settings in `.sln.DotSettings`)
- 64-bit build required for most scenarios due to native dependencies

### Repository Notes

- Uses Mercurial (Hg) for version control internally
- Send/Receive functionality critical - don't break merge strategies
- Custom mergers in `ParatextData/Repository/Mergers/` for USFM, terms, notes

### Performance Considerations

- Weak reference caching for parsers and resources
- Lazy initialization throughout to defer expensive operations
- File operations wrapped in `BackupFileUtils` for safety
- Large projects benefit from 64-bit build with more memory

### Security

- User authentication via Paratext Registry (cloud service)
- Project permissions: Administrator, Translator, Observer, etc.
- Write locks prevent concurrent modification conflicts
- Plugin sandboxing via Add-In framework (legacy plugins)

### Code Style

- Team uses ReSharper with shared settings (`.sln.DotSettings` files)
- C# 8 language features in ParatextData
- Older C# versions in Framework 4.8 projects
- XML documentation comments on public APIs (especially in CorePluginInterfaces)
