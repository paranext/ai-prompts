# Platform.Bible Test Suite Analysis

**Date:** January 2026
**Purpose:** Comprehensive analysis of testing coverage, infrastructure, and recommendations for improvement.

---

## Executive Summary

Platform.Bible has a **moderately developed test suite** with solid coverage in utility libraries and UI components, but **significant gaps in critical infrastructure** including the main Electron process, network layer, and data provider services. The testing infrastructure is modern and well-configured, but coverage thresholds are not enforced.

---

## Test Coverage Overview

### By Technology Stack

| Area | Test Files | Source Files | Estimated Coverage |
|------|-----------|--------------|-------------------|
| TypeScript (src/) | 20 | ~150+ | ~13% |
| TypeScript (lib/) | 29 | ~100+ | ~29% |
| Extensions | 2 | ~50+ | ~4% |
| C# (.NET) | 26 | 98 | ~26% |
| Storybook Stories | 69 | - | UI visual testing |

### By Directory

#### TypeScript - Core Platform (`src/`)

| Directory | Test Files | Notes |
|-----------|-----------|-------|
| `src/shared/` | 8 | Document combiners, utilities, project lookup |
| `src/extension-host/` | 5 | Storage, settings, localization services |
| `src/node/` | 4 | Execution tokens, crypto, command-line utils |
| `src/renderer/` | 3 | Minimal - only app component and docking utils |
| `src/main/` | **0** | **No tests for Electron main process** |

#### TypeScript - Libraries (`lib/`)

| Library | Test Files | Notes |
|---------|-----------|-------|
| platform-bible-utils | 21 | Well tested - utilities, events, i18n, scripture |
| platform-bible-react | 8 | Component utilities + 67 Storybook stories |
| papi-dts | 0 | Type definitions only (no runtime code) |

#### C# (.NET)

| Directory | Test Files | Notes |
|-----------|-----------|-------|
| Checks/ | 5 | Input ranges, USFM locations, check results |
| Projects/ | 5 | Project data providers, factories |
| JsonUtils/ | 2 | Comment converter, inventory options |
| Services/ | 1 | Basic settings get/set only |
| NetworkObjects/ | 0 | **No tests** |

---

## Well-Tested Components

### TypeScript

| Component | Location | Test Count | Notes |
|-----------|----------|------------|-------|
| Document Combiners | `src/shared/utils/` | 4 | Menu, settings, project settings, localized strings |
| Platform Bible Utils | `lib/platform-bible-utils/` | 21 | Array utils, events, serialization, scripture refs |
| Async Variable | `src/shared/utils/` | 1 | Promise-based state management |
| Extension Storage | `src/extension-host/services/` | 1 | File-based storage with mocking |
| Settings Service Host | `src/extension-host/services/` | 1 | Settings validation and storage |

### C#

| Component | Location | Test Count | Notes |
|-----------|----------|------------|-------|
| Input Ranges | `Checks/` | 2 | 22+ parameterized test cases for verse filtering |
| Check Results | `Checks/` | 1 | Value equality and hashing |
| Project Data Provider | `Projects/` | 3 | Verse/chapter retrieval, comments |
| JSON Converters | `JsonUtils/` | 2 | Null handling, inventory conversion |

### Storybook Visual Testing

**67 component stories** in `lib/platform-bible-react/src/stories/`:

- **shadcn-ui components** (26): button, dialog, dropdown, input, select, table, etc.
- **Advanced components** (17): book-chapter-control, inventory, marketplace, scripture-results-viewer
- **Basic components** (8): checklist, combo-box, search-bar, spinner, tabs
- **Guide/demo stories** (6): theming, direction, RTL support

---

## Critical Test Gaps

### High Priority - Untested Infrastructure

| Component | Location | Lines | Risk |
|-----------|----------|-------|------|
| **Main Process** | `src/main/` | ~2,000+ | App lifecycle, window management untested |
| **Network Service** | `src/shared/services/network.service.ts` | ~500 | All IPC communication untested |
| **Data Provider Service** | `src/shared/services/data-provider.service.ts` | ~800 | Core PAPI pattern untested |
| **Network Object Service** | `src/shared/services/network-object.service.ts` | ~400 | Cross-process objects untested |
| **RPC Server** | `src/main/services/rpc-server.ts` | ~300 | WebSocket server untested |
| **PapiClient (C#)** | `c-sharp/PapiClient.cs` | 1,300+ | .NET RPC client untested |

### Medium Priority - Under-tested Services

| Component | Location | Current Tests | Gap |
|-----------|----------|--------------|-----|
| Extension Service | `src/extension-host/services/extension.service.ts` | 0 | Extension loading/lifecycle |
| Command Service | `src/shared/services/command.service.ts` | 0 | Command registration/dispatch |
| Web View Provider Service | `src/shared/services/` | 0 | WebView management |
| C# Services | `c-sharp/Services/` | 1 | Only basic get/set tested |
| C# Checks System | `c-sharp/Checks/` | 5 | 25+ classes with minimal coverage |

### Low Coverage Areas

| Area | Files | Tests | Notes |
|------|-------|-------|-------|
| Renderer Components | 63+ | 3 | React UI largely untested |
| Extensions | 50+ | 2 | Only lexical tools and scripture checks |
| C# JSON Utils | 10+ | 2 | Most converters untested |

---

## Testing Infrastructure

### Frameworks and Tools

#### TypeScript
```json
{
  "vitest": "^3.2.4",
  "@testing-library/react": "^16.2.0",
  "@testing-library/dom": "^10.4.0",
  "@testing-library/jest-dom": "^6.6.3",
  "fast-check": "^4.5.3",
  "@fast-check/vitest": "^0.2.4",
  "@stryker-mutator/core": "^9.4.0"
}
```

#### C#
```xml
<PackageReference Include="NUnit" Version="4.0.1" />
<PackageReference Include="FsCheck" Version="3.0.0" />
<PackageReference Include="FsCheck.NUnit" Version="3.0.0" />
<PackageReference Include="coverlet.collector" Version="6.0.0" />
```

### Test Configuration

#### Vitest (`vitest.config.ts`)
- **Environment:** jsdom
- **Coverage:** v8 provider
- **Reports:** text, HTML, lcov
- **Thresholds:** All set to 0 (not enforced)

#### Storybook Testing
- **Addon:** `@storybook/addon-vitest`
- **Browser:** Chromium via Playwright
- **Features:** Accessibility testing, interactive controls, RTL support

#### Mutation Testing (Stryker)
- **TypeScript:** `stryker.config.json`
- **C#:** `c-sharp-tests/stryker-config.json`
- **Thresholds:** High 80%, Low 70%, Break 0%

### CI/CD Pipeline (`.github/workflows/test.yml`)

| Step | Description |
|------|-------------|
| 1 | Build TypeScript and .NET |
| 2 | Type checking |
| 3 | C# unit tests (`dotnet test`) |
| 4 | Install Playwright browsers |
| 5 | TypeScript tests (`npm test`) |
| 6 | Format and lint checks |
| 7 | Package application |
| 8 | Upload artifacts |

**Platforms:** Windows, macOS, Ubuntu

---

## Testing Patterns

### TypeScript Mocking

```typescript
// Vitest mocking pattern
vi.mock('@shared/services/network.service', () => ({
  createNetworkEventEmitter: vi.fn(),
  getNetworkEvent: vi.fn(),
  request: vi.fn(),
}));

// Manual mock file
// src/shared/services/__mocks__/logger.service.ts
```

### C# Test Utilities

| Utility | Purpose |
|---------|---------|
| `PapiTestBase` | Base class with setup/teardown, JSON helpers |
| `DummyPapiClient` | In-memory PAPI client mock |
| `DummyParatextProjectDataProvider` | In-memory project data |
| `DummyScrText` | Mock ScrText without file I/O |
| `TestLocalParatextProjectsInTempDir` | Temp directory test isolation |

**Note:** C# uses hand-written mocks, not a mocking framework (Moq/NSubstitute).

---

## Strengths

1. **Modern tooling:** Vitest, React Testing Library, Storybook 9.x
2. **Multi-layered approach:** Unit + visual + mutation testing
3. **Cross-platform CI:** Tests on Windows, macOS, Linux
4. **Excellent UI visual coverage:** 67 Storybook stories with browser testing
5. **Property-based testing available:** fast-check and FsCheck installed
6. **Mutation testing configured:** Stryker for both TypeScript and C#
7. **Security scanning:** CodeQL analysis in CI

---

## Weaknesses

1. **No E2E tests:** Playwright installed but not used for integration testing
2. **Coverage not enforced:** All thresholds set to 0
3. **Critical infrastructure untested:** Main process, network layer, data providers
4. **No snapshot testing:** Could catch UI regressions
5. **Property-based testing unused:** Packages installed but barely utilized
6. **Hand-written C# mocks:** Increases maintenance burden
7. **Renderer almost untested:** 3 tests for 63+ files

---

## Recommendations

### Immediate Priorities

1. **Add tests for core infrastructure:**
   - `src/shared/services/data-provider.service.ts` - The heart of PAPI
   - `src/shared/services/network.service.ts` - All communication
   - `src/shared/services/command.service.ts` - Command dispatch

2. **Enable coverage thresholds:**
   ```typescript
   // vitest.config.ts
   coverage: {
     thresholds: {
       statements: 50,
       branches: 50,
       functions: 50,
       lines: 50,
     }
   }
   ```

3. **Add E2E tests with Playwright:**
   - Test critical user flows end-to-end
   - Verify processes communicate correctly

### Medium-Term Improvements

4. **Utilize property-based testing:**
   - Data transformations (USFM parsing, serialization)
   - Document combiners
   - Scripture reference handling

5. **Add C# mocking framework:**
   - Install Moq or NSubstitute
   - Reduce hand-written mock maintenance

6. **Increase C# service coverage:**
   - PapiClient needs comprehensive tests
   - Network object creation/disposal
   - Settings service edge cases

### For Feature Porting

7. **Write tests alongside ports:**
   - TDD approach for new features
   - Golden master testing to verify PT9 behavior equivalence
   - Focus on data provider pattern tests

8. **Create test utilities:**
   - Shared test fixtures for common scenarios
   - Factory functions for test data
   - Network service mock with configurable responses

---

## Test Commands Reference

```bash
# TypeScript unit tests
npm test

# TypeScript tests with watch
npm test -- --watch

# C# unit tests
cd c-sharp-tests && dotnet test

# C# tests with watch
cd c-sharp-tests && dotnet watch test

# Mutation testing (TypeScript)
npm run test:mutation

# Mutation testing (C#)
npm run test:mutation:csharp

# Storybook
npm run storybook

# Coverage report
npm test -- --coverage
```

---

## Key Files Reference

| Purpose | File |
|---------|------|
| Vitest config (root) | `vitest.config.ts` |
| Vitest config (react lib) | `lib/platform-bible-react/vitest.config.ts` |
| Stryker config (TS) | `stryker.config.json` |
| Stryker config (C#) | `c-sharp-tests/stryker-config.json` |
| CI workflow | `.github/workflows/test.yml` |
| C# test project | `c-sharp-tests/c-sharp-tests.csproj` |
| Test base class (C#) | `c-sharp-tests/PapiTestBase.cs` |
| Logger mock | `src/shared/services/__mocks__/logger.service.ts` |

---

## Conclusion

Platform.Bible has a **solid foundation** for testing with modern tools and good coverage in utility code and UI components. However, **critical infrastructure remains untested**, creating risk as the platform grows. The team should prioritize:

1. Testing the data provider and network services
2. Enforcing coverage thresholds
3. Adding E2E tests for critical flows

For developers porting features from PT9, writing tests alongside implementation using TDD and golden master patterns will help ensure behavioral equivalence while improving overall test coverage.
