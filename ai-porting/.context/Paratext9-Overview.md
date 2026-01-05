# Paratext Codebase Overview for Porting to Paratext 10 (Electron)

## Executive Summary

Paratext is a professional Bible translation and publishing desktop application built on:
- **Primary Framework**: .NET Framework 4.8 with Windows Forms UI
- **91 C# projects** organized in a layered architecture
- **3,942+ source files** across multiple functional domains

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                           │
│  Paratext (MainForm, Windows Forms, MDI, WeifenLuo Docking)    │
├─────────────────────────────────────────────────────────────────┤
│                    APPLICATION LAYER                            │
│  ParatextBase (UI Controls, Common Forms, Theme Engine)        │
├─────────────────────────────────────────────────────────────────┤
│                    BUSINESS LOGIC LAYER                         │
│  ParatextData (.NET Standard 2.0 - portable library)           │
│  ParatextChecks (Validation and checking logic)                │
├─────────────────────────────────────────────────────────────────┤
│                    INFRASTRUCTURE LAYER                         │
│  DataAccessServer (Nancy REST API with JWT auth)               │
│  Repository (Mercurial version control integration)            │
│  PTLive (Real-time collaboration: WCF, AMQP, REST)            │
├─────────────────────────────────────────────────────────────────┤
│                    UTILITIES                                    │
│  PtxUtils, CBUtilities, SIL Libraries                          │
└─────────────────────────────────────────────────────────────────┘
```

---

## Key Projects and Their Purpose

### Core Application
| Project | Purpose | Portability Notes |
|---------|---------|-------------------|
| **Paratext** | Main WinForms app (MainForm.cs - 5143 lines) | UI needs complete rewrite for Electron |
| **ParatextData** | Core data layer (.NET Standard 2.0) | **Most portable** - already cross-platform |
| **ParatextBase** | UI controls & common forms | Windows Forms - needs rewrite |
| **ParatextChecks** | Validation/checking logic | Portable business logic |

### Backend/Services
| Project | Purpose | Portability Notes |
|---------|---------|-------------------|
| **DataAccessServer** | REST API (Nancy 2.0) | Could run as C# backend process |
| **PTLiveServer/PTLiveBase** | Real-time collaboration | WCF/AMQP - may need adaptation |
| **Repository** | Mercurial integration | Portable - command-line based |

### Plugin System
| Project | Purpose | Portability Notes |
|---------|---------|-------------------|
| **PluginFramework** | MAF-based plugin system | Windows-specific - needs redesign |
| **PluginInterfaces** | Plugin contracts | Interface definitions - portable |

---

## Communication Patterns (Critical for Electron Integration)

### Current IPC/Communication Methods:

1. **REST API (DataAccessServer)**
   - Nancy-based REST server
   - JWT authentication (RS256)
   - Endpoints: `/api8/projects`, `/api8/text/{projectId}`, etc.
   - **Good candidate for Electron ↔ C# communication**

2. **WCF Services (PTLive)**
   - Windows Communication Foundation for real-time sync
   - Session-based collaboration
   - **Windows-specific - needs alternative for Electron**

3. **AMQP (Message Queue)**
   - Asynchronous messaging for project sync
   - Queue-based communication
   - **Could work with Electron via message broker**

4. **Direct HTTP (RESTClient.cs)**
   - HTTP/HTTPS communication
   - Proxy support (HTTP & SOCKS5)
   - **Easily usable from Electron**

---

## Key Functional Modules

### Scripture Editing
- `/Paratext/TextWindow/` - Text editing UI
- `/ParatextData/` - Core text handling (USFM format)
- `/FormattedEditor/` - Rich text with markers

### Checking & Validation
- `/ParatextChecks/` - Check implementations
- `/ParatextData/Checking/` - Check logic
- `/Paratext/Checking/` - Check UI

### Collaboration
- `/Paratext/PTLive/` - Real-time editing
- `/ParatextData/Repository/` - Mercurial sync
- `/Paratext/Repository/` - Send/Receive UI

### Biblical Terms & References
- `/BiblicalTerms/` - Terms database
- `/Paratext/ParallelPassages/` - Cross-references
- `/Paratext/Interlinear/` - Word alignment

### Publishing
- `/PA/` - Publishing Assistant
- `/Paratext/ScriptureBurrito/` - Modern bundle format
- `/DblUploader/` - Digital Bible Library

---

## State Management

### Global State (Singletons)
- `ScrTextCollection` - Scripture collection manager
- `MainForm.Current` - Current window reference
- `VersioningManager` - Mercurial integration
- `Program.Logger` - Logging

### Dependency Injection
```csharp
DependencyLookup.Set<IModSLT>()
DependencyLookup.Set<IParatextAccess>()
DependencyLookup.Set<IBiblicalTermsAccess>()
```

### Settings Persistence
- `Settings.cs` - User settings via .NET ApplicationSettings
- XML-based project settings
- Windows Registry (some settings)

---

## Data Formats

- **USFM**: Primary scripture text format
- **USX**: XML-based scripture format
- **Scripture Burrito**: Modern packaging format
- **XML**: Project settings and metadata
- **JSON**: REST API payloads

---

## External Dependencies

### SIL Libraries
- SIL.Scripture - Biblical text utilities
- SIL.WritingSystems - Language support
- SIL.Keyboarding - Input handling
- SIL.IO - File operations

### Third-Party
- WeifenLuo.WinFormsUI.Docking - Window docking
- Newtonsoft.Json - JSON serialization
- Nancy - REST framework (DataAccessServer)
- Mercurial - Version control

---

## Porting Considerations for Electron + C# Backend

### What Can Be Reused (C# Backend)
1. **ParatextData** - Already .NET Standard 2.0, cross-platform
2. **ParatextChecks** - Business logic, portable
3. **Repository layer** - Mercurial integration
4. **DataAccessServer pattern** - REST API architecture

### What Needs Rewriting (Electron Frontend)
1. **All Windows Forms UI** - Complete rewrite in web technologies
2. **Plugin Framework** - MAF is Windows-specific
3. **WCF Services** - Replace with WebSocket or HTTP

### Recommended Communication Pattern
```
┌──────────────┐         HTTP/REST         ┌──────────────┐
│   Electron   │ ◄─────────────────────────► │  C# Process  │
│   (React?)   │         WebSocket          │ (.NET 8?)    │
│              │ ◄─────────────────────────► │              │
└──────────────┘                            └──────────────┘
```

---

## Questions for Your Porting Project

To provide more targeted guidance, I need to understand:

1. **Scope**: Which features/modules are you planning to port?
2. **C# Process**: Will it be .NET 8 or stick with .NET Framework?
3. **Communication**: Preference for Electron ↔ C# IPC method?
4. **Frontend**: What UI framework in Electron (React, Vue, etc.)?
5. **Timeline**: Is this a gradual migration or fresh start?
