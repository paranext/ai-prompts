# paranext-core Implementation Patterns

This document describes the established patterns in the paranext-core codebase. It serves as a reference for the Alignment Agent when mapping abstract Phase 2 contracts to PT10-specific implementation details.

---

## C# Patterns

### Namespaces

- **Root namespace:** `Paranext.DataProvider`
- **By directory:** `Paranext.DataProvider.{Directory}`
  - `Paranext.DataProvider.Projects` - Project data providers
  - `Paranext.DataProvider.Services` - Static services
  - `Paranext.DataProvider.Checks` - Inventory and check functionality
  - `Paranext.DataProvider.JsonUtils` - JSON serialization converters
  - `Paranext.DataProvider.NetworkObjects` - Base classes for network objects
  - `Paranext.DataProvider.Users` - User/registration services

### Directory Structure

```
c-sharp/
├── Projects/              # Project data providers and factories
├── Services/              # Static service classes
├── Checks/                # Inventory and check management
├── JsonUtils/             # JSON serialization utilities
├── NetworkObjects/        # DataProvider/NetworkObject base classes
├── ParatextUtils/         # Paratext integration utilities
├── Users/                 # User management
├── Program.cs             # Entry point
└── PapiClient.cs          # Core PAPI communication client
```

### Service Patterns

#### 1. Static Services (Stateless Operations)

Use for one-time operations that don't require ongoing state or subscriptions.

**Location:** `c-sharp/Services/`

**Pattern:**
```csharp
public static class MyService
{
    public static async Task<T> MethodNameAsync(PapiClient client, params...)
    {
        // Implementation
    }
}
```

**Examples:**
- `AppService.GetAppInfo(client)` - Retrieves app metadata
- `SettingsService.GetSetting<T>(client, key)` - Gets settings
- `SettingsService.SetSetting(client, key, value)` - Sets settings

**When to use:**
- Stateless utility calls
- One-time operations (create, validate, etc.)
- Operations that don't need to notify subscribers

#### 2. DataProvider Classes (Stateful, Subscribable Data)

Use for data that needs to be subscribed to or updated over time.

**Location:** `c-sharp/Projects/` or `c-sharp/NetworkObjects/`

**Inheritance:**
```
NetworkObject (base)
  └── DataProvider (abstract)
        ├── ProjectDataProvider (abstract)
        │   └── ParatextProjectDataProvider
        ├── InventoryDataProvider
        └── TimeDataProvider
```

**Key methods:**
- `RegisterDataProviderAsync()` - Registers on PAPI network
- `GetFunctions()` - Returns callable functions as `(string name, Delegate func)[]`
- `SendDataUpdateEvent()` - Notifies network of data changes
- `StartDataProviderAsync()` - Starts the provider after registration

**When to use:**
- Data that changes over time
- Data that multiple consumers need to subscribe to
- Project-specific data providers

#### 3. Factory Pattern

For creating data providers dynamically based on project/context.

**Location:** `c-sharp/Projects/`

**Pattern:**
```csharp
public abstract class ProjectDataProviderFactory : NetworkObject
{
    public abstract IReadOnlyList<ProjectDetails> GetAvailableProjects(JsonElement options);
    public abstract Task<string> GetProjectDataProviderID(string projectID);
}
```

### Test Infrastructure

- **Framework:** NUnit 4.0.1
- **Test SDK:** Microsoft.NET.Test.Sdk v17.9.0
- **Location:** `c-sharp-tests/{FeatureArea}/`

**Base Classes:**
- `PapiTestBase` - For tests needing PAPI client simulation
  - Provides `CreateDummyProject()`, `CreateProjectDetails()`
  - Provides `VerifyUsfmSame()`, `VerifyUsxSame()` for text comparison

**Mock/Dummy Objects:**
- `DummyScrText` - In-memory Paratext ScrText (315 lines, complete file manager)
- `DummyPapiClient` - Simulates PAPI client, tracks sent events
- `DummyLocalParatextProjects` - Allows fake project addition
- `DummyParatextProjectDataProvider` - In-memory file storage

**Fixture Setup Pattern:**
```csharp
[SetUpFixture]
public class FixtureSetup
{
    [OneTimeSetUp]
    public void RunBeforeAnyTests() => ParatextGlobals.Initialize(testFolder);

    [OneTimeTearDown]
    public void RunAfterAnyTests() => Directory.Delete(testFolder, true);
}
```

**Test Parameterization:**
```csharp
[TestCase(1, 1, 0, @"\id GEN \ip intro \c 1 ")]
[TestCase(1, 2, 1, @"\v 1 verse one ")]
public void TestMethod(int bookNum, int chapterNum, int verseNum, string expected)
{
    // Test implementation
}
```

---

## TypeScript Patterns

### Command Naming

- **Pattern:** `'{extensionName}.{commandName}'`
- **Convention:** Lowercase extension name, camelCase command name

**Examples:**
- `'platformScripture.openCharactersInventory'`
- `'platformScripture.openFind'`
- `'helloRock3.helloRock3'`
- `'helloSomeone.helloSomeone'`

### Command Registration

```typescript
const commandPromise = papi.commands.registerCommand(
  'extensionName.commandName',
  asyncFunctionHandler,
  {
    method: {
      summary: 'Command description',
      params: [
        {
          name: 'paramName',
          required: false,
          summary: 'Parameter description',
          schema: { type: 'string' },
        },
      ],
      result: {
        name: 'return value',
        summary: 'Return value description',
        schema: { type: 'string' },
      },
    },
  },
);

context.registrations.add(await commandPromise);
```

### Type Declarations

**Location:** `extensions/src/{extension}/src/types/{extension}.d.ts`

**Pattern:**
```typescript
declare module '{extension-name}' {
  // Import shared types
  import type { DataProviderDataType, IDataProvider } from '@papi/core';

  // Define data types
  export type MyDataTypes = {
    DataTypeName: DataProviderDataType<Selector, ReturnType, SetType>;
  };

  // Define provider interface
  export type IMyProvider = IDataProvider<MyDataTypes> & {
    methodName(param: Type): Promise<Result>;
  };
}

declare module 'papi-shared-types' {
  // Extend global interfaces
  export interface CommandHandlers {
    'extensionName.commandName': (param: Type) => Promise<Result>;
  }

  export interface DataProviders {
    'extensionName.dataName': IMyProvider;
  }

  export interface SettingTypes {
    'extensionName.settingName': SettingType;
  }
}
```

### Extension Structure

```
extensions/src/{extension}/
├── src/
│   ├── main.ts                    # Entry point with activate/deactivate
│   ├── types/
│   │   └── {extension}.d.ts       # Type declarations
│   ├── web-views/
│   │   ├── *.web-view.tsx         # React web view components
│   │   └── *.web-view.scss        # Web view styles
│   ├── models/
│   │   └── *-provider-engine.model.ts  # Data provider implementations
│   └── services/
│       └── *.service.ts           # Business logic services
├── contributions/                  # JSON contribution files
├── assets/                        # Icons and static assets
├── manifest.json                  # Extension metadata
└── package.json                   # npm package metadata
```

### Extension Activate Function

```typescript
export async function activate(context: ExecutionActivationContext): Promise<void> {
  // Register commands, validators, web views, data providers, etc.

  // All registrations must be added to context.registrations:
  context.registrations.add(
    await commandPromise,
    await webViewProviderPromise,
    // ... all other registrations
  );
}

export async function deactivate(): Promise<boolean> {
  return true;
}
```

### DataProviderDataType Format

```typescript
DataProviderDataType<Selector, ReturnType, SetType>
```

- **Selector:** Type of the get/subscribe selector (use `undefined` if no selector)
- **ReturnType:** What `get` returns (can include `undefined` for missing data)
- **SetType:** What `set` accepts (`never` if read-only)

**Examples:**
```typescript
// Read-write with number selector
RandomNumber: DataProviderDataType<number, number, number>;

// Read-only with no selector
Names: DataProviderDataType<undefined, string[], never>;

// Scripture data
BookUSFM: DataProviderDataType<SerializedVerseRef, string | undefined, string>;
```

---

## Naming Conventions Summary

| Category | Pattern | Example |
|----------|---------|---------|
| C# Namespace | `Paranext.DataProvider.{Area}` | `Paranext.DataProvider.Projects` |
| C# Service | `{Name}Service` | `AppService`, `SettingsService` |
| C# DataProvider | `{Name}DataProvider` | `ParatextProjectDataProvider` |
| TS Command | `'{extensionName}.{commandName}'` | `'platformScripture.openFind'` |
| TS Setting | `'{extensionName}.{settingName}'` | `'helloRock3.personName'` |
| TS DataProvider | `'{extensionName}.{dataName}'` | `'helloSomeone.people'` |
| TS WebView | `'{extensionName}.{viewName}'` | `'helloRock3.projectWebView'` |
| Test File | `{Feature}Tests.cs` | `ProjectServiceTests.cs` |

---

## Key Files Reference

### C# Entry Points
- `c-sharp/Program.cs` - Application entry point
- `c-sharp/PapiClient.cs` - Core PAPI communication

### Base Classes
- `c-sharp/NetworkObjects/DataProvider.cs` - Abstract data provider base
- `c-sharp/NetworkObjects/NetworkObject.cs` - Abstract network object base
- `c-sharp/Projects/ProjectDataProvider.cs` - Abstract project data provider

### Test Base
- `c-sharp-tests/PapiTestBase.cs` - Base class for integration tests
- `c-sharp-tests/DummyScrText.cs` - In-memory ScrText mock
- `c-sharp-tests/Projects/FixtureSetup.cs` - Global test fixture

### TypeScript Core
- `src/declarations/papi-shared-types.ts` - Global type extensions
- `extensions/src/platform-scripture/src/main.ts` - Example extension
