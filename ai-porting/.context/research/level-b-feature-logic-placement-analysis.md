# Level B Feature Logic Placement Analysis

**Date:** January 2025
**Status:** Analysis Complete
**Scope:** Strategy for UI-embedded business logic in Level B feature porting

## Executive Summary

This analysis addresses a key architectural question for porting Level B features from Paratext 9 to Platform.Bible (PT10): **Where should UI-embedded business logic be placed?**

Level B features (e.g., S/R Conflict Resolution, Parallel Passages) have significant business logic currently embedded in PT9's Windows Forms UI layer (`Paratext/` and `ParatextBase/` folders). This logic needs a new home in PT10's architecture.

**Recommendation:** Place extracted logic in PT10's **.NET Data Provider layer** (`c-sharp/Features/`), not in TypeScript or upstream to ParatextData.dll.

---

## Background

### What Are Level B Features?

Per the AI-Porting-Workflow classification system:

| Level | Description | ParatextData Reuse | Examples |
|-------|-------------|-------------------|----------|
| **A** | ParatextData-Heavy | 80%+ | Creating Projects, USB Syncing |
| **B** | Mixed Logic | 40-70% | S/R Conflict Resolution, Parallel Passages |
| **C** | Pure UI | <10% | Checklists, Translation Resources |

Level B features have:
- **Core algorithms in ParatextData.dll** (merge, diff, versification)
- **Significant business logic in PT9's UI layer** (decision workflows, state management, data transformations)
- **Need for extraction and re-implementation** in PT10

### The Challenge

PT9's UI-embedded business logic cannot be directly reused because:
1. It's tightly coupled to Windows Forms
2. It's in the `Paratext/` and `ParatextBase/` folders, not in ParatextData.dll
3. PT10 uses React/TypeScript for UI, not Windows Forms

**Question:** Where should this extracted logic live in PT10?

---

## Options Analyzed

### Option 1: .NET Data Provider Layer (`c-sharp/`)

Place extracted logic in PT10's C# backend alongside existing data providers.

**Architecture:**
```
React UI → TypeScript Extension → C# Feature Services → ParatextData.dll
```

### Option 2: TypeScript Extension Host Layer

Place extracted logic in TypeScript within the extension host or extensions.

**Architecture:**
```
React UI → TypeScript Extension (with business logic) → C# Data Provider → ParatextData.dll
```

### Option 3: Upstream to ParatextData.dll

Refactor PT9 to move UI logic into ParatextData.dll, consumed by both PT9 and PT10.

**Architecture:**
```
React UI → TypeScript Extension → C# Data Provider → ParatextData.dll (enhanced)
```

---

## Analysis

### Option 1: .NET Data Provider Layer (Recommended)

**Advantages:**

| Factor | Benefit |
|--------|---------|
| **Direct ParatextData.dll access** | No JSON-RPC serialization for internal operations |
| **Existing patterns** | ParatextProjectDataProvider, CheckRunner demonstrate proven patterns |
| **Same language as PT9** | Easier to port; C# code can be adapted rather than rewritten |
| **Test infrastructure** | PapiTestBase, DummyScrText available |
| **Team expertise** | PT10 team has C# developers |

**Disadvantages:**
- JSON-RPC serialization overhead at TypeScript boundary
- Requires C# build pipeline maintenance

**Existing Pattern Examples:**
- `c-sharp/Projects/ParatextProjectDataProvider.cs` (1400+ lines) - Comprehensive ParatextData integration
- `c-sharp/Checks/CheckRunner.cs` - Job-based async patterns
- `c-sharp/Checks/InventoryDataProvider.cs` - Stateful job management

### Option 2: TypeScript Extension Host Layer

**Advantages:**

| Factor | Benefit |
|--------|---------|
| **Hot reload** | Faster development iteration |
| **UI proximity** | Logic closer to the UI it serves |
| **TypeScript tooling** | Strong IDE support, refactoring |

**Disadvantages:**
- Every ParatextData.dll call requires JSON-RPC round-trip
- Performance concerns for complex algorithms
- Potential code duplication if logic needs ParatextData types

**When to Use:**
- UI-specific data transformations
- State coordination between multiple data providers
- Caching and subscription management
- Logic that doesn't need ParatextData.dll access

### Option 3: Upstream to ParatextData.dll

**Advantages:**

| Factor | Benefit |
|--------|---------|
| **Single source of truth** | Same code in PT9 and PT10 |
| **Bug fixes benefit both** | One fix location |
| **Long-term maintainability** | No logic divergence |

**Disadvantages:**

| Factor | Risk |
|--------|------|
| **Timeline** | 24-46 weeks realistically per feature |
| **PT9 team constraints** | Limited budget and manpower |
| **PT9 stability risk** | Refactoring active codebase |
| **Coordination overhead** | Cross-team alignment meetings, reviews |

**When to Use:**
- Complex, critical algorithms that both products need
- When PT9 team has capacity and interest
- After PT10 logic is proven (contribute back later)

---

## Recommendation

### Primary Strategy: .NET Data Provider Layer

Place extracted UI business logic in `c-sharp/Features/{FeatureName}/`.

**Rationale:**
1. Direct ParatextData.dll access without serialization overhead
2. Proven patterns exist (ParatextProjectDataProvider, CheckRunner)
3. Same language as PT9 source code being ported
4. PT10 team has C# expertise available
5. Independent from PT9 team timeline

### Secondary: TypeScript for UI Concerns

Use TypeScript extension layer for:
- Display transformations
- Multi-provider state coordination
- Caching
- Subscription management

### Future: Optional Upstream Path

After PT10 logic is battle-tested:
1. Document extracted logic with clear interfaces
2. Propose to PT9 team as contribution
3. If accepted, PT10 consumes from ParatextData.dll

This "implement first, upstream later" approach:
- Doesn't block PT10 development
- Proves design before proposing upstream
- Reduces risk to PT9 stability

---

## Recommended Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  React UI (WebViews)                                        │
│  • Display only, no business logic                          │
└────────────────────────────┬────────────────────────────────┘
                             │ useData hooks
┌────────────────────────────▼────────────────────────────────┐
│  TypeScript Extension (Extension Host)                      │
│  • UI state coordination                                    │
│  • Caching layer                                            │
│  • Light transformations for display                        │
└────────────────────────────┬────────────────────────────────┘
                             │ JSON-RPC over WebSocket
┌────────────────────────────▼────────────────────────────────┐
│  C# Feature Services (c-sharp/Features/{Feature}/)          │
│  • Extracted UI business logic (ported from PT9)            │
│  • Coordinates with ParatextData.dll                        │
│  • Exposed via DataProvider pattern                         │
└────────────────────────────┬────────────────────────────────┘
                             │ Direct method calls
┌────────────────────────────▼────────────────────────────────┐
│  ParatextData.dll (NuGet, shared with PT9)                  │
│  • Core algorithms (merge, diff, versification)             │
│  • Project data access (ScrText, CommentManager)            │
│  • Unchanged - same binary as PT9                           │
└─────────────────────────────────────────────────────────────┘
```

---

## Implementation Guidelines

### File Structure

```
c-sharp/
├── Features/                          # NEW: Feature-specific logic
│   ├── ParallelPassages/
│   │   ├── ParallelPassageService.cs      # Pure business logic
│   │   ├── ParallelPassageDataProvider.cs # PAPI-exposed wrapper
│   │   ├── ParallelPassageResult.cs       # DTOs
│   │   └── README.md                      # Feature documentation
│   ├── ConflictResolution/
│   │   ├── ConflictResolutionService.cs
│   │   ├── ConflictResolutionDataProvider.cs
│   │   ├── ConflictInfo.cs
│   │   └── ResolutionStrategy.cs
│   └── [OtherLevelBFeatures]/
```

### Service Patterns

**Pattern A: Stateless Query Service**

For simple lookups (e.g., finding parallel passages):

```csharp
internal class ParallelPassageDataProvider : DataProvider
{
    protected override List<(string, Delegate)> GetFunctions()
    {
        return [
            ("findParallelPassages", FindParallelPassages),
        ];
    }

    private List<ParallelPassageResult> FindParallelPassages(
        string projectId,
        SerializedVerseRef verseRef)
    {
        var scrText = LocalParatextProjects.GetParatextProject(projectId);
        return ParallelPassageService.FindPassages(scrText, verseRef);
    }
}
```

**Pattern B: Stateful Job Service**

For long-running operations (e.g., S/R conflict resolution):

```csharp
internal sealed class ConflictResolutionDataProvider : DataProvider
{
    private readonly ConcurrentDictionary<string, ConflictResolutionJob> _activeJobs = new();

    protected override List<(string, Delegate)> GetFunctions()
    {
        return [
            ("beginConflictScan", BeginConflictScan),
            ("retrieveConflictScanUpdate", RetrieveConflictScanUpdate),
            ("resolveConflict", ResolveConflict),
            ("abandonConflictScan", AbandonConflictScan),
        ];
    }
}
```

### Testing Strategy

| Test Type | Purpose | Infrastructure |
|-----------|---------|----------------|
| **Unit tests** | Test service classes directly | DummyScrText, ParatextData.dll |
| **Integration tests** | Test DataProvider via PAPI | DummyPapiClient |
| **Golden master tests** | Verify PT10 matches PT9 | Captured PT9 outputs |

---

## Decision Summary

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Primary location** | `c-sharp/Features/` | Direct ParatextData access, existing patterns |
| **TypeScript role** | UI coordination only | Reserved for display concerns |
| **Upstream to ParatextData** | Not now, possible future | PT9 team constraints |
| **Pattern to follow** | DataProvider + Service | Matches CheckRunner, InventoryDataProvider |

---

## References

### Critical Files

1. `c-sharp/Projects/ParatextProjectDataProvider.cs` - Reference for ParatextData integration
2. `c-sharp/Checks/CheckRunner.cs` - Reference for job-based patterns
3. `c-sharp/NetworkObjects/DataProvider.cs` - Base class to extend
4. `c-sharp-tests/PapiTestBase.cs` - Test infrastructure
5. `c-sharp/Program.cs` - Where to register new data providers

### Related Documentation

- [AI-Porting-Workflow.md](../AI-Porting-Workflow.md) - Feature classification system
- [Paranext-Core-Patterns.md](../standards/Paranext-Core-Patterns.md) - C# coding patterns
- [Testing-Guide.md](../standards/Testing-Guide.md) - Test infrastructure
