# Testing Infrastructure Guide for Paranext-Core

This document provides a comprehensive overview of the testing infrastructure in the paranext-core codebase, intended to guide AI-assisted porting work from Paratext 9.

---

## Table of Contents

### Principles & Strategy
1. [Overview](#overview)
2. [TDD Discipline](#tdd-discipline)
3. [Test Strategy: The Testing Trophy](#test-strategy-the-testing-trophy)
4. [AI Agent Test Quality Guardrails](#ai-agent-test-quality-guardrails)
5. [Quality Gate G4.5](#quality-gate-g45)
6. [General Style Guidelines](#general-style-guidelines)

### Frameworks & Infrastructure
7. [TypeScript/JavaScript Testing](#typescriptjavascript-testing)
8. [C# Testing](#c-testing)
9. [Component Testing with Storybook](#component-testing-with-storybook)
10. [CI/CD Pipeline](#cicd-pipeline)

### Patterns & Techniques
11. [Test Patterns and Examples](#test-patterns-and-examples)
12. [Property-Based Testing](#property-based-testing)
13. [Mutation Testing](#mutation-testing)
14. [Mocking Strategies](#mocking-strategies)

### Porting-Specific Testing
15. [Test Categorization](#test-categorization)
16. [Traceability Requirements](#traceability-requirements)
17. [Golden Master Testing](#golden-master-testing)
18. [Characterization Testing](#characterization-testing)
19. [Proof of Work Artifacts](#proof-of-work-artifacts)

### Porting Guide
20. [Testing Recommendations for Porting](#testing-recommendations-for-porting)

---

## Overview

Paranext-core uses a **layered testing approach** rather than comprehensive end-to-end testing:

| Layer                 | Framework                | Location            | Purpose                      |
| --------------------- | ------------------------ | ------------------- | ---------------------------- |
| TypeScript Unit Tests | Vitest                   | `src/**/*.test.ts`  | Services, utilities, hooks   |
| React Component Tests | Vitest + Testing Library | `lib/**/*.test.tsx` | UI components                |
| C# Unit Tests         | NUnit                    | `c-sharp-tests/`    | Data providers, services     |
| Component Stories     | Storybook + Playwright   | `**/*.stories.tsx`  | Visual testing, interactions |

---

## TDD Discipline

For Level A and B features in the AI porting workflow, **Test-Driven Development is mandatory**, not optional.

### The RED-GREEN-REFACTOR Cycle

| Phase        | Action                          | Commit Convention                 |
| ------------ | ------------------------------- | --------------------------------- |
| **RED**      | Write ONE failing test          | `[RED] feature: test description` |
| **GREEN**    | Write MINIMUM code to pass      | `[GREEN] feature: implementation` |
| **REFACTOR** | Clean up while tests stay green | `[REFACTOR] feature: cleanup`     |

### Verifying Tests Can Fail

Every test must be capable of failing when the implementation is broken. How you verify this depends on context:

| Context | Verification Method |
| ------- | ------------------- |
| **TDD (test-first)** | RED phase proves it - test fails before implementation exists |
| **Adding tests to existing code** | Revert Test required (see below) |
| **Bug fix verification** | Revert Test required - prove test catches the bug |

#### The Revert Test (for non-TDD contexts)

When adding tests to code that already exists:

```bash
# 1. Comment out or revert the implementation
git stash  # or comment out the code

# 2. Run the test - it MUST fail
npm test -- path/to/test.ts  # or: dotnet test --filter "TestName"

# 3. Verify it failed for the RIGHT reason (assertion, not compilation)

# 4. Restore implementation
git stash pop

# 5. Run test again - it MUST pass
```

**If a test passes without implementation, it proves nothing and must be rewritten.**

> **Note:** In Phase 3 TDD workflow, the Test Writer agent's RED phase evidence (`test-evidence-red.log`) serves as proof that all tests fail before implementation. The explicit Revert Test is unnecessary when practicing strict TDD.

### Continuous Testing Frequency

| Trigger               | Scope                   | Time Budget |
| --------------------- | ----------------------- | ----------- |
| After every file save | Current test            | < 5s        |
| Every 3-5 edits       | Feature tests           | < 30s       |
| Before any commit     | Full suite              | < 5 min     |
| Before push           | Full + lint + typecheck | < 10 min    |

---

## Test Strategy: The Testing Trophy

For AI-assisted development, we adopt the **Testing Trophy** model instead of the traditional Test Pyramid.

### Why Not the Traditional Pyramid?

The Test Pyramid (many unit tests, fewer integration, few E2E) fails for AI-assisted development:

- AI generates many unit tests that assert implementation details
- These tests break on every refactor (opposite of fearless refactoring)
- Over-mocking hides integration issues, giving false confidence

### The Testing Trophy Model

```
        ▲ E2E (few, high-value critical journeys)
       ╱ ╲
      ╱   ╲
     ╱     ╲ Integration tests (MOST VALUABLE)
    ╱       ╲ Test at service boundaries
   ╱─────────╲
  ╱           ╲ Unit tests (complex algorithms, pure functions only)
 ╱─────────────╲
╱               ╲ Static analysis (TypeScript, linting)
```

| Test Type       | When to Use                        | Coverage Focus               |
| --------------- | ---------------------------------- | ---------------------------- |
| **Integration** | Service boundaries, API contracts  | Behavior, not implementation |
| **Unit**        | Complex algorithms, pure functions | Edge cases, calculations     |
| **E2E**         | Critical user journeys             | Smoke tests only             |

### Key Principle: Test Behavior, Not Implementation

> "If a refactor breaks the test but not the behavior, the test is wrong."

**Good test:** Calls public API, verifies output matches expected value
**Bad test:** Verifies internal method was called with specific arguments

### Prefer Real Dependencies

| Approach           | Use When                                             |
| ------------------ | ---------------------------------------------------- |
| Real ParatextData  | Always for Level A features (it's the shared oracle) |
| In-memory database | Integration tests needing data persistence           |
| Real services      | When feasible and fast enough                        |
| Mocks              | Only for external APIs, network, slow dependencies   |

This enables **fearless refactoring**: change internals without updating tests.

---

## AI Agent Test Quality Guardrails

These guardrails prevent common anti-patterns when AI agents generate tests.

### What NOT to Test

| Category                | Examples                                 | Why Prohibited                 |
| ----------------------- | ---------------------------------------- | ------------------------------ |
| Trivial accessors       | Getter/setter, `getName()` returns name  | Zero defect-detection value    |
| Implementation details  | Internal variables, private method calls | Couples test to implementation |
| Framework behavior      | `Array.push()` adds items                | Testing someone else's code    |
| Constructor assignments | `new User(name).name === name`           | Tautological                   |

### Prohibited Test Patterns

#### 1. Implementation-Mirroring Tests

```typescript
// BAD: Mirrors implementation logic
test('calculateTotal sums items', () => {
  const items = [{ price: 10 }, { price: 20 }];
  const expected = items.reduce((sum, i) => sum + i.price, 0); // This IS the implementation
  expect(calculateTotal(items)).toBe(expected);
});

// GOOD: Tests behavior with known values
test('calculateTotal returns sum of item prices', () => {
  expect(calculateTotal([{ price: 10 }, { price: 20 }, { price: 5 }])).toBe(35);
});
```

#### 2. Over-Mocking

If you need >3 mocks for a test, reconsider:

- Is the unit too large? Split it.
- Is this actually an integration test? Use real dependencies.
- Are mocks hiding real issues?

#### 3. Non-Deterministic Tests

| Source        | Required Mitigation                      |
| ------------- | ---------------------------------------- |
| System time   | Use `vi.useFakeTimers()` or inject clock |
| Random values | Seed RNG or mock `Math.random()`         |
| Network calls | Mock all HTTP/WebSocket calls            |
| GUIDs         | Inject generator or use fixed values     |

### Mocking Decision Matrix

| Dependency       | Unit Tests    | Integration Tests |
| ---------------- | ------------- | ----------------- |
| ParatextData.dll | **Keep real** | **Keep real**     |
| Network services | Mock          | Mock or real      |
| File system      | Mock          | Temp files        |
| External APIs    | Mock          | Mock              |
| System time      | Mock          | Mock              |

**ParatextData Exception:** For Level A features, NEVER mock ParatextData. It's the shared oracle between PT9 and PT10.

### Test Quality Curation Checklist

Before accepting AI-generated tests, verify:

- [ ] **Falsifiable:** Test fails when implementation is broken (Revert Test)
- [ ] **Independent:** Passes/fails independently of other tests
- [ ] **Behavior-focused:** Tests WHAT, not HOW
- [ ] **Meaningful assertions:** Checks business value, not artifacts
- [ ] **Deterministic:** Same result on every run
- [ ] **Traceable:** References specification (BHV-XXX, TS-XXX)

### Stop and Ask Triggers

AI agents must pause and ask humans when:

1. **Ambiguous behavior** - Specification is unclear or contradictory
2. **Domain-specific rules** - Bible versification, USFM semantics, Paratext conventions
3. **Architecture decisions** - Creating new utilities, modifying test infrastructure
4. **Multiple interpretations** - Edge case handling is undefined

---

## Quality Gate G4.5

Quality Gate G4.5 is a **blocking gate** between test writing (G4) and implementation (G5) that verifies test quality before any implementation begins. See [AI-Porting-Workflow.md](../AI-Porting-Workflow.md) for the full gate definitions.

### Purpose

Prevent low-quality AI-generated tests from proceeding to implementation. Tests that mirror implementation or fail to catch defects waste development time and provide false confidence.

### Verification Criteria

Before implementation can begin, verify all tests meet these criteria:

| Criterion | Verification |
|-----------|--------------|
| **Revert Test passes** | All tests fail when implementation is removed |
| **No implementation-mirroring** | Expected values are literals, not computed |
| **Mock count ≤ 3** | Or exception documented with justification |
| **Deterministic** | Time, random, network are all controlled |
| **No trivial tests** | No simple accessor or constructor tests |
| **Quality Report present** | Documented in test-writer-plan.md |

### Enforcement

- **Who verifies:** Human reviewer or Traceability Validator agent
- **When:** After TDD Test Writer completes, before TDD Implementer starts
- **Blocking:** Implementation CANNOT begin until G4.5 passes
- **Evidence:** Quality checklist in `test-writer-plan.md`

---

## General Style Guidelines

### Making Tests Readable

- **DO** make it obvious what the SUT (Software Under Test) is.
  - If the test is not too complicated, the 3 sections of setup (arrange), SUT (act), and checks (assert) can be separated by new lines.
  - Another option is to comment above the line where the SUT is called with `// SUT`.

### Best Practices

- **DO** follow [Unit testing best practices](https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-best-practices).
  - Although written for C#, the principles apply to any language.

### Naming Conventions

- **C# unit tests**: Use the [naming conventions](https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-best-practices#naming-your-tests) from the best practices link above.
- **TypeScript unit tests**: Use Jest/Vitest `test` blocks for simple tests and `describe` and `it/test` blocks for tests that need more organizational structure. See [when to use each](https://webtips.dev/webtips/jest/describe-vs-test-vs-it) and [naming conventions](https://prowe214.medium.com/unit-tests-more-readable-describe-it-statements-in-protractor-jasmine-3810b07a6ac5).

### Test Verification

Every test must be capable of failing. See [Verifying Tests Can Fail](#verifying-tests-can-fail) for when to use TDD's RED phase vs. the explicit Revert Test.

### When to Add Tests

- **DO** add unit tests if it speeds up your development or makes a critical part of the code more robust.

---

## TypeScript/JavaScript Testing

### Framework: Vitest (v3.2.4)

Vitest is a Jest-compatible test runner optimized for Vite projects.

### Configuration Files

| File                                        | Purpose                  |
| ------------------------------------------- | ------------------------ |
| `vitest.config.ts`                          | Root configuration       |
| `lib/platform-bible-react/vitest.config.ts` | Component library config |

**Root Configuration:**

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig(async () => {
  const tsconfigPaths = (await import('vite-tsconfig-paths')).default;
  return {
    plugins: [tsconfigPaths()],
    test: {
      globals: true,
      environment: 'jsdom',
      include: ['src/**/*.test.ts', 'src/**/*.test.tsx'],
    },
  };
});
```

### Key Dependencies

```json
{
  "vitest": "^3.2.4",
  "@testing-library/react": "^16.2.0",
  "@testing-library/jest-dom": "^6.6.3",
  "@testing-library/dom": "^10.4.0",
  "jsdom": "^26.0.0"
}
```

### Test File Locations

```
src/
├── shared/
│   ├── utils/papi-util.test.ts
│   └── services/shared-store.service.test.ts
├── node/
│   └── services/*.test.ts
├── extension-host/
│   └── services/extension-storage.service.test.ts
└── renderer/
    └── components/*.test.tsx

lib/
├── platform-bible-utils/
│   └── src/*.test.ts
└── platform-bible-react/
    └── src/components/**/*.test.ts

extensions/
└── src/platform-scripture/
    └── src/*.test.ts
```

### Running TypeScript Tests

```bash
# Run all tests (non-watch mode)
npm test

# Run core tests in watch mode
npm run test:core

# Run tests for specific workspace
npm run test --workspace=lib/platform-bible-react

# Run tests with coverage
npm run test:core -- --coverage
```

---

## C# Testing

### Framework: NUnit 4.0.1

### Project Configuration

**File:** `c-sharp-tests/c-sharp-tests.csproj`

```xml
<ItemGroup>
  <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.9.0" />
  <PackageReference Include="NUnit" Version="4.0.1" />
  <PackageReference Include="NUnit3TestAdapter" Version="4.5.0" />
  <PackageReference Include="coverlet.collector" Version="6.0.0" />
  <PackageReference Include="ParatextData" Version="9.5.0.18" />
</ItemGroup>
```

### Test Directory Structure

```
c-sharp-tests/
├── Checks/
│   ├── CheckRunResultTests.cs
│   ├── CheckRunnerCheckDetailsTests.cs
│   ├── InputRangeTests.cs
│   ├── InputRangesFilterTests.cs
│   └── UsfmLocationTests.cs
├── JsonUtils/
│   ├── CommentConverterTests.cs
│   └── InventoryOptionValueConverterTests.cs
├── Projects/
│   ├── FixtureSetup.cs              # Assembly-level setup
│   ├── LocalParatextProjectsTests.cs
│   ├── ParatextDataProviderTests.cs
│   ├── ParatextDataProviderCommentTests.cs
│   └── ParatextProjectDataProviderFactoryTests.cs
├── Services/
│   └── SettingsServiceTests.cs
├── NetworkObjects/
│   └── DummySettingsService.cs
├── PapiTestBase.cs                  # Base class for tests
├── DummyPapiClient.cs               # Mock PAPI client
├── DummyParatextProjectDataProvider.cs
├── DummyScrText.cs
└── DummyLocalParatextProjects.cs
```

### Running C# Tests

```bash
# Run all C# tests
dotnet test c-sharp-tests/c-sharp-tests.csproj

# Run with verbose output
dotnet test c-sharp-tests/c-sharp-tests.csproj --verbosity=detailed

# Run specific test class
dotnet test c-sharp-tests/c-sharp-tests.csproj --filter "FullyQualifiedName~ParatextDataProviderTests"

# Run with code coverage
dotnet test c-sharp-tests/c-sharp-tests.csproj /p:CollectCoverage=true
```

### Base Test Class

**File:** `c-sharp-tests/PapiTestBase.cs`

```csharp
[TestFixture]
[ExcludeFromCodeCoverage]
internal abstract class PapiTestBase
{
    private DummyPapiClient? _client;
    private DummyLocalParatextProjects? _projects;

    [SetUp]
    public virtual Task TestSetupAsync()
    {
        _projects = new DummyLocalParatextProjects();
        _client = new DummyPapiClient();
        return Task.CompletedTask;
    }

    [TearDown]
    public virtual void TestTearDown()
    {
        // Clean up ScrTextCollection
        List<ScrText> projects = ScrTextCollection
            .ScrTexts(IncludeProjects.Everything)
            .ToList();
        foreach (ScrText project in projects)
            ScrTextCollection.Remove(project, false);

        _client?.Dispose();
    }

    protected DummyPapiClient Client => _client!;
    protected DummyLocalParatextProjects ParatextProjects => _projects!;

    // Helper methods for test data creation
    protected static JsonNode CreateVerseRefNode(int bookNum, int chapterNum, int verseNum);
    protected static JsonElement CreateRequestMessage(string function, params object[] parameters);
    protected static void VerifyUsfmSame(string usfm1, string usfm2, ScrText scrText, int bookNum);
}
```

### Assembly-Level Setup

**File:** `c-sharp-tests/Projects/FixtureSetup.cs`

```csharp
[SetUpFixture]
[ExcludeFromCodeCoverage]
public class FixtureSetup
{
    private static readonly string s_testFolder = Path.Combine(
        Path.GetTempPath(),
        "Platform.Bible.Tests"
    );

    public static string TestFolderPath => s_testFolder;

    [OneTimeSetUp]
    public void RunBeforeAnyTests()
    {
        if (!Directory.Exists(s_testFolder))
            Directory.CreateDirectory(s_testFolder);
        ParatextGlobals.Initialize(s_testFolder);
    }

    [OneTimeTearDown]
    public void RunAfterAnyTests()
    {
        if (Directory.Exists(s_testFolder))
            Directory.Delete(s_testFolder, true);
    }
}
```

---

## Component Testing with Storybook

### Configuration

**Location:** `lib/platform-bible-react/.storybook/`

### Features

- **70+ component stories** with visual documentation
- **Interactive play functions** for automated interaction testing
- **Accessibility testing** via axe-playwright
- **Vitest browser integration** with Playwright
- **Visual evidence capture** for proof of work artifacts

### Vitest + Storybook Integration

**File:** `lib/platform-bible-react/vitest.config.ts`

```typescript
projects: [
  {
    // Unit tests
    test: {
      name: 'unit',
      include: ['src/**/*.{test,spec}.{js,ts,jsx,tsx}'],
      globals: true,
      environment: 'jsdom',
    },
  },
  {
    // Storybook browser tests
    plugins: [storybookTest()],
    test: {
      name: 'storybook',
      setupFiles: ['.storybook/vitest.setup.ts'],
      browser: {
        enabled: true,
        provider: 'playwright',
        instances: [{ browser: 'chromium', headless: true }],
      },
    },
  },
];
```

### Story with Play Function Example

```typescript
// book-chapter-control.stories.tsx
import { expect, fn, userEvent, within } from 'storybook/test';

export const Default: Story = {
  args: {
    scrRef: { book: 'GEN', chapterNum: 1, verseNum: 1 },
    handleSubmit: fn(),
  },
  play: async ({ canvasElement, args }) => {
    const canvas = within(canvasElement);

    // Click the control to open popover
    await userEvent.click(canvas.getByRole('button'));

    // Verify popover opened
    await expect(canvas.getByRole('dialog')).toBeInTheDocument();

    // Select a book
    await userEvent.click(canvas.getByText('Exodus'));

    // Verify callback was called
    await expect(args.handleSubmit).toHaveBeenCalled();
  },
};
```

### Visual Evidence for Porting

When porting features, use Storybook and Playwright to capture visual evidence:

```bash
# Capture screenshots for proof artifacts
npx playwright screenshot http://localhost:6006/iframe.html?id=component--story proofs/visual-evidence/component.png
```

Visual evidence is **required for ALL feature levels** (A, B, C) to prove the implementation works in the running application. Store screenshots in `.context/features/{feature}/proofs/visual-evidence/`.

---

## CI/CD Pipeline

### GitHub Actions Workflow

**File:** `.github/workflows/test.yml`

```yaml
jobs:
  test:
    steps:
      # C# Tests
      - name: dotnet unit tests
        run: dotnet test c-sharp-tests/c-sharp-tests.csproj

      # Install Playwright for Storybook tests
      - name: Install Playwright Browsers
        run: npx playwright install --with-deps

      # TypeScript/JavaScript Tests
      - name: npm unit tests
        run: npm test
```

---

## Test Patterns and Examples

### TypeScript: Service Testing with Mocks

```typescript
// shared-store.service.test.ts
import { vi, describe, it, expect, beforeEach } from 'vitest';
import * as networkService from '@shared/services/network.service';

vi.mock('@shared/services/network.service', () => ({
  createNetworkEventEmitter: vi.fn(),
  getNetworkEvent: vi.fn(),
  request: vi.fn(),
}));

vi.mock('@shared/services/logger.service', () => ({
  logger: { debug: vi.fn(), info: vi.fn(), warn: vi.fn(), error: vi.fn() },
}));

describe('sharedStoreService', () => {
  const mockEmitter = {
    emit: vi.fn(),
    subscribe: vi.fn(),
    dispose: vi.fn(),
  };

  beforeEach(() => {
    vi.resetAllMocks();
    vi.mocked(networkService.createNetworkEventEmitter).mockReturnValue(mockEmitter);
  });

  it('should initialize with network event emitter', async () => {
    await initializeSharedStore(networkService);
    expect(networkService.createNetworkEventEmitter).toHaveBeenCalledWith('shared-store:change');
  });
});
```

### TypeScript: React Hook Testing

```typescript
// book-chapter-control.navigation.test.ts
import { renderHook, act } from '@testing-library/react';
import { vi } from 'vitest';
import { useQuickNavButtons } from './book-chapter-control.navigation';

vi.mock('./book-chapter-control.utils', () => ({
  fetchEndChapter: vi.fn(),
}));

describe('useQuickNavButtons', () => {
  const mockHandleSubmit = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
  });

  test('Returns correct number of navigation buttons', () => {
    const { result } = renderHook(() =>
      useQuickNavButtons(
        { book: 'GEN', chapterNum: 1, verseNum: 1 },
        availableBooks,
        'ltr',
        mockHandleSubmit,
      ),
    );

    expect(result.current).toHaveLength(4);
  });

  test('Navigates to previous chapter', () => {
    const { result } = renderHook(() =>
      useQuickNavButtons(
        { book: 'GEN', chapterNum: 2, verseNum: 1 },
        availableBooks,
        'ltr',
        mockHandleSubmit,
      ),
    );

    act(() => {
      result.current[0].onClick(); // Previous chapter button
    });

    expect(mockHandleSubmit).toHaveBeenCalledWith({
      book: 'GEN',
      chapterNum: 1,
      verseNum: 1,
    });
  });
});
```

### C#: Parameterized Data Provider Tests

```csharp
// ParatextDataProviderTests.cs
internal class ParatextDataProviderTests : PapiTestBase
{
    private ScrText _scrText = null!;

    [SetUp]
    public override async Task TestSetupAsync()
    {
        await base.TestSetupAsync();
        _scrText = CreateDummyProject();
        ParatextProjects.FakeAddProject(CreateProjectDetails(_scrText), _scrText);
    }

    [TestCase(1, 1, 0, @"\id GEN \ip intro \c 1 ")]
    [TestCase(1, 2, 1, @"\v 1 verse one ")]
    [TestCase(1, 2, 6, @"\v 6 verse six ")]
    [TestCase(1, 2, 10, "")]  // Missing verse
    [TestCase(1, 6, 1, "")]   // Missing chapter
    public void GetVerseUsfm_ValidResults(int bookNum, int chapterNum, int verseNum, string expected)
    {
        _scrText.PutText(1, 0, false, TestUsfmContent, null);

        var provider = new DummyParatextProjectDataProvider(
            "test", Client, CreateProjectDetails(_scrText), ParatextProjects
        );

        var verseRef = new VerseRef(bookNum, chapterNum, verseNum);
        var result = provider.GetVerseUsfm(verseRef);

        VerifyUsfmSame(result, expected, _scrText, bookNum);
    }
}
```

### C#: JSON Serialization Tests

```csharp
// CommentConverterTests.cs
[TestFixture]
public class CommentConverterTests
{
    private JsonSerializerOptions _options = null!;

    [SetUp]
    public void Setup()
    {
        _options = SerializationOptions.CreateSerializationOptions();
    }

    [Test]
    public void Deserialize_NullContents_ProducesEmptyContentsElement()
    {
        var json = "{\"contents\": null, \"user\": \"tester\", \"thread\": \"t1\"}";

        var result = JsonSerializer.Deserialize<Comment>(json, _options);

        Assert.That(result, Is.Not.Null);
        Assert.That(result!.Contents, Is.Not.Null);
        Assert.That(result.Contents!.InnerXml, Is.EqualTo(string.Empty));
    }

    [Test]
    public void Deserialize_InvalidContents_ThrowsInvalidDataException()
    {
        var json = "{\"contents\": \"<p>unclosed\", \"user\": \"tester\"}";

        Assert.Throws<InvalidDataException>(
            () => JsonSerializer.Deserialize<Comment>(json, _options)
        );
    }

    [Test]
    public void Deserialize_ValidContents_PreservesInnerXml()
    {
        var json = "{\"contents\": \"<p>content</p>\", \"user\": \"tester\"}";

        var result = JsonSerializer.Deserialize<Comment>(json, _options);

        Assert.That(result!.Contents!.InnerXml, Is.EqualTo("<p>content</p>"));
    }
}
```

---

## Property-Based Testing

Property-based testing verifies that **invariants hold for all possible inputs**, not just cases you imagined. This is high-leverage for AI-assisted development: humans define invariants, tools generate inputs.

### When to Use Property Tests

| Scenario                | Example Property                      |
| ----------------------- | ------------------------------------- |
| Data transformations    | `Deserialize(Serialize(x)) == x`      |
| Business rules          | "Project GUID is always unique"       |
| Mathematical operations | "Result is always within valid range" |
| Parsing/formatting      | "Round-trip preserves content"        |

### C# with FsCheck

FsCheck is configured in `c-sharp-tests/c-sharp-tests.csproj`.

```csharp
using FsCheck;
using FsCheck.NUnit;

[TestFixture]
public class VerseRefPropertyTests
{
    [Property(MaxTest = 500)]
    [Category("Property")]
    public Property VerseRef_ComponentsAlwaysValid()
    {
        return Prop.ForAll(
            Gen.Choose(1, 66),   // bookNum
            Gen.Choose(1, 150),  // chapterNum
            Gen.Choose(0, 176),  // verseNum
            (book, chapter, verse) =>
            {
                var verseRef = new VerseRef(book, chapter, verse);
                return verseRef.BookNum >= 1 && verseRef.BookNum <= 66
                    && verseRef.ChapterNum >= 0
                    && verseRef.VerseNum >= 0;
            });
    }
}
```

### TypeScript with fast-check

```typescript
import fc from 'fast-check';

describe('VerseRef Properties', () => {
  test.prop([fc.nat({ max: 65 }), fc.nat({ max: 149 }), fc.nat({ max: 175 })])(
    'verse reference components are always non-negative',
    (book, chapter, verse) => {
      const ref = createVerseRef(book + 1, chapter + 1, verse);
      expect(ref.bookNum).toBeGreaterThanOrEqual(1);
      expect(ref.chapterNum).toBeGreaterThanOrEqual(0);
      expect(ref.verseNum).toBeGreaterThanOrEqual(0);
    },
  );
});
```

### Iteration Requirements

| Invariant Criticality      | Minimum Iterations |
| -------------------------- | ------------------ |
| Critical (data integrity)  | 1000               |
| Important (business logic) | 500                |
| Standard                   | 100                |

---

## Mutation Testing

Mutation testing verifies **test quality** by checking if tests detect small code changes (mutations). A high mutation score means tests catch real defects.

### When to Use

- **Critical business logic** - Merge algorithms, conflict resolution, data persistence
- **Quality Gate G9** - Required for Level A/B features (see [AI-Porting-Workflow.md](../AI-Porting-Workflow.md))
- **Threshold:** ≥70% mutation score for critical paths

### Tools

| Language | Tool | Config File |
|----------|------|-------------|
| TypeScript | Stryker | `stryker.config.json` |
| C# | Stryker.NET | `c-sharp-tests/stryker-config.json` |

### Running Mutation Tests

```bash
# TypeScript mutation tests
npm run test:mutation

# C# mutation tests
npm run test:mutation:csharp
```

### Score Thresholds

| Threshold | Score | Meaning |
|-----------|-------|---------|
| High | 80% | Excellent test quality |
| Low | 70% | Minimum acceptable |
| Break | 0% | Build failure threshold (advisory initially) |

### Interpreting Results

- **Survived mutants** - Code changes not caught by tests (bad)
- **Killed mutants** - Code changes caught by tests (good)
- **Timeout/Error** - Mutant caused infinite loop or crash

### CI/CD Integration

Mutation testing is **advisory** for the first 2-3 ported features to establish baselines, then becomes **blocking** at 70% threshold. See G9 in [AI-Porting-Workflow.md](../AI-Porting-Workflow.md).

---

## Mocking Strategies

### TypeScript (Vitest)

| Method               | Use Case                  |
| -------------------- | ------------------------- |
| `vi.mock()`          | Module-level mocking      |
| `vi.fn()`            | Individual function mocks |
| `vi.mocked()`        | Type-safe mock access     |
| `vi.spyOn()`         | Spy on existing methods   |
| `vi.useFakeTimers()` | Control time in tests     |

**Example:**

```typescript
// Module mock
vi.mock('@shared/services/network.service', () => ({
  request: vi.fn(),
}));

// Function mock with implementation
const mockFn = vi.fn().mockImplementation((x) => x * 2);

// Spy on method
vi.spyOn(console, 'log');

// Fake timers
vi.useFakeTimers();
vi.advanceTimersByTime(1000);
vi.useRealTimers();
```

### C# (Custom Test Doubles)

The project uses **hand-crafted test doubles** instead of mocking frameworks like Moq:

| Test Double                        | Purpose                             |
| ---------------------------------- | ----------------------------------- |
| `DummyPapiClient`                  | Simulates JSON-RPC WebSocket client |
| `DummyParatextProjectDataProvider` | In-memory project data              |
| `DummyScrText`                     | Mock scripture text                 |
| `DummySettingsService`             | Mock settings service               |
| `DummyLocalParatextProjects`       | Mock project collection             |

**DummyPapiClient Example:**

```csharp
internal class DummyPapiClient : PapiClient
{
    private readonly Queue<(string eventType, object? eventParameters)> _sentEvents = [];

    public override Task<bool> ConnectAsync() => Task.FromResult(true);
    public override Task DisconnectAsync() => Task.CompletedTask;

    public override Task SendEventAsync(string eventType, object? eventParameters)
    {
        _sentEvents.Enqueue((eventType, eventParameters));
        return Task.CompletedTask;
    }

    public int SentEventCount => _sentEvents.Count;
    public (string eventType, object? eventParameters) NextSentEvent => _sentEvents.Dequeue();
}
```

---

## Test Categorization

Test categorization enables fast feedback during development by running subsets of tests based on speed requirements. See [AI-Porting-Workflow.md](../AI-Porting-Workflow.md) Section 5 for workflow integration.

### Categories

| Category | Time Budget | When to Run | Scope |
|----------|-------------|-------------|-------|
| **Smoke** | < 10s | After each edit | Core functionality |
| **Critical** | < 60s | Every 3-5 edits | Feature tests |
| **Full** | < 5 min | Before commit | Complete suite |
| **Integration** | No limit | CI only | Cross-process tests |

### Tagging Tests

**C# (NUnit):**
```csharp
[Test]
[Category("Smoke")]
public void BasicOperation_Works() { }

[Test]
[Category("Critical")]
public void ImportantFeature_HandlesEdgeCase() { }
```

**TypeScript (Vitest):**
```typescript
describe.concurrent('Smoke tests', () => {
  test('basic operation works', () => { });
});

// Or use file naming: feature.smoke.test.ts, feature.critical.test.ts
```

### Running by Category

```bash
# C# - run only smoke tests
dotnet test --filter "Category=Smoke"

# TypeScript - run specific test file pattern
npm test -- --testNamePattern="Smoke"
```

---

## Traceability Requirements

Every test must trace back to a specification to ensure complete coverage and enable impact analysis. See [AI-Porting-Workflow.md](../AI-Porting-Workflow.md) Section 5 for the complete traceability system.

### ID Types

| ID | Format | Source | Purpose |
|----|--------|--------|---------|
| BHV-XXX | Behavior ID | behavior-catalog.md | What the system does |
| TS-XXX | Test Scenario ID | test-scenarios.json | How to test a behavior |
| INV-XXX | Invariant ID | business-rules.md | Property that must always hold |

### Adding Traceability to Tests

**C# (NUnit):**
```csharp
[Test]
[Category("Contract")]
[Property("ScenarioId", "TS-001")]
[Property("BehaviorId", "BHV-001")]
public void CreateProject_WithValidSettings_ReturnsSuccess() { }
```

**TypeScript (Vitest):**
```typescript
/**
 * @scenario TS-001
 * @behavior BHV-001
 */
test('CreateProject with valid settings returns success', () => { });
```

### Validation Rules

- Every BHV-XXX must have at least one TS-XXX
- Every TS-XXX must have at least one test
- Every test must reference a valid scenario ID
- Orphan tests (except Infrastructure category) are flagged

The Traceability Validator agent enforces these rules in Phase 3.

---

## Golden Master Testing

Golden master tests compare PT10 output against captured PT9 output to verify behavioral equivalence. The strategy varies by feature classification level.

### Strategy by Level

| Level | Golden Master Purpose | What to Capture |
|-------|----------------------|-----------------|
| **A** (ParatextData-heavy) | Test specifications only | Nothing - ParatextData.dll is the oracle |
| **B** (Mixed) | UI-layer behavior | Data transformations, state transitions |
| **C** (Pure UI) | Comprehensive behavioral reference | All outputs, visual states, error messages |

For Level A features, ParatextData.dll is shared between PT9 and PT10 via NuGet, so capturing outputs is redundant. See [AI-Porting-Workflow.md](../AI-Porting-Workflow.md) Section 7.

### Directory Structure

```
.context/features/{feature}/golden-masters/
├── gm-001-create-project/
│   ├── input.json           # Test input data
│   ├── expected-output.json # Captured PT9 output
│   └── metadata.json        # Test context and notes
└── gm-002-validation-error/
    ├── input.json
    ├── expected-output.json
    └── metadata.json
```

### Metadata Format

```json
{
  "id": "gm-001",
  "name": "create-project-success",
  "capturedFrom": "PT9.4.0.123",
  "capturedDate": "2025-01-04",
  "scenarioId": "TS-001",
  "notes": "Standard project creation with default settings"
}
```

### Normalization

For non-deterministic data, normalize before comparison:
- **Timestamps** - Replace with placeholder or ignore
- **GUIDs** - Replace with stable identifiers
- **File paths** - Normalize separators and base paths

---

## Characterization Testing

Characterization tests capture what PT9 **actually does** before porting, including edge cases and quirks. This is a Phase 1 (Analysis) activity.

### Purpose

- Document existing behavior as ground truth
- Discover undocumented edge cases
- Identify quirks that must be preserved (or intentionally changed)
- Create test scenarios for TDD

### Difference from Unit Tests

| Aspect | Unit Test | Characterization Test |
|--------|-----------|----------------------|
| **Timing** | Written for new code | Written for existing code |
| **Purpose** | Verify intended behavior | Discover actual behavior |
| **Expected values** | Known upfront | Captured from system |
| **Failures** | Bug in implementation | Difference from PT9 |

### Location

```
.context/features/{feature}/characterization/
├── test-scenarios.json  # Structured test cases
├── edge-cases.md        # Unusual scenarios with notes
└── requirements.md      # Non-functional requirements discovered
```

### Process

1. Identify behavior to characterize from behavior-catalog.md
2. Run PT9 code with various inputs
3. Capture outputs as expected values
4. Document any surprising behavior in edge-cases.md
5. Create test-scenarios.json for TDD phase

---

## Proof of Work Artifacts

AI agents must provide **verifiable evidence** that their work is correct. Testing is the mechanism; proof is the deliverable. See [AI-Porting-Workflow.md](../AI-Porting-Workflow.md) Section 6 for the complete proof framework.

### Key Distinction

> "Testing is an activity; proof is a deliverable."

Every agent deliverable must answer: *"What evidence can the human reviewer examine to verify this work is correct?"*

### Evidence Files by Agent

| Agent | Evidence File | Content |
|-------|---------------|---------|
| TDD Test Writer | `test-evidence-red.log` | Tests compile and FAIL |
| TDD Implementer | `test-evidence-green.log` | Tests PASS with counts |
| TDD Implementer | `visual-evidence/*.png` | Screenshots of feature |
| TDD Refactorer | `test-evidence-refactor.log` | Tests still PASS |
| Equivalence Checker | `test-evidence-equivalence.log` | Golden master results |
| Invariant Checker | `test-evidence-invariants.log` | Property tests with iteration counts |
| Validator | `test-evidence-final.log` | Full suite results |

### Evidence File Format

```
=== TEST EVIDENCE ===
Timestamp: 2025-01-04T14:30:00Z
Agent: tdd-implementer
Phase: GREEN (tests should PASS)
Command: dotnet test --filter "CreateProject"

--- OUTPUT START ---
[full test output here]
--- OUTPUT END ---

Summary: 15 passed, 0 failed
```

### Visual Evidence

**Required for ALL features**, including Level A (backend-heavy):
- Screenshots demonstrating feature works in running app
- Use `app-runner` and `chrome-browser` skills
- Store in `proofs/visual-evidence/`

### Cross-Agent Verification

Each agent verifies the previous agent's proof before starting:

| Current Agent | Must Verify |
|---------------|-------------|
| TDD Implementer | Test Writer's tests actually FAIL |
| TDD Refactorer | Implementer's tests PASS |
| Validator | All evidence files exist and match claims |

---

## Testing Recommendations for Porting

### 1. Write Tests First (TDD Approach)

When porting features from Paratext 9:

1. Identify the expected behavior from PT9 code
2. Write failing tests that capture that behavior
3. Implement the feature to make tests pass

### 2. C# Backend Testing

For new data providers:

- Extend `PapiTestBase` for common infrastructure
- Use `DummyPapiClient` to test without real WebSocket connection
- Create parameterized tests with `[TestCase]` for edge cases
- Add JSON serialization tests for new Paratext types

```csharp
// Template for new data provider test
internal class NewFeatureDataProviderTests : PapiTestBase
{
    [SetUp]
    public override async Task TestSetupAsync()
    {
        await base.TestSetupAsync();
        // Setup test data
    }

    [TestCase("input1", "expected1")]
    [TestCase("input2", "expected2")]
    public void NewFunction_ReturnsExpectedResult(string input, string expected)
    {
        // Arrange
        var provider = CreateProvider();

        // Act
        var result = provider.NewFunction(input);

        // Assert
        Assert.That(result, Is.EqualTo(expected));
    }
}
```

### 3. React Component Testing

For new UI components:

- Use Testing Library's `render` and `screen` utilities
- Test user interactions with `userEvent`
- Create Storybook stories for visual testing

```typescript
// Template for new component test
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { vi } from 'vitest';

describe('NewComponent', () => {
  it('renders correctly', () => {
    render(<NewComponent />);
    expect(screen.getByRole('button')).toBeInTheDocument();
  });

  it('handles user interaction', async () => {
    const onAction = vi.fn();
    render(<NewComponent onAction={onAction} />);

    await userEvent.click(screen.getByRole('button'));

    expect(onAction).toHaveBeenCalled();
  });
});
```

### 4. JSON Serialization Testing

For new Paratext types that need JSON conversion:

```csharp
[TestFixture]
public class NewTypeConverterTests
{
    private JsonSerializerOptions _options = null!;

    [SetUp]
    public void Setup()
    {
        _options = SerializationOptions.CreateSerializationOptions();
    }

    [Test]
    public void RoundTrip_PreservesData()
    {
        var original = new NewType { /* properties */ };

        var json = JsonSerializer.Serialize(original, _options);
        var result = JsonSerializer.Deserialize<NewType>(json, _options);

        Assert.That(result, Is.EqualTo(original));
    }
}
```

### 5. Testing Gaps to Address

| Gap                                | Opportunity                                      |
| ---------------------------------- | ------------------------------------------------ |
| No E2E tests                       | Add Playwright tests for critical user workflows |
| No cross-process integration tests | Test Electron + Extension Host + .NET together   |
| No contract tests                  | Add tests for JSON-RPC API contracts             |
| Limited visual regression          | Expand Storybook coverage                        |

### 6. Key Test Files to Reference

| Purpose                     | File                                                                                                            |
| --------------------------- | --------------------------------------------------------------------------------------------------------------- |
| C# test base class          | `c-sharp-tests/PapiTestBase.cs`                                                                                 |
| Mock PAPI client            | `c-sharp-tests/DummyPapiClient.cs`                                                                              |
| Data provider test example  | `c-sharp-tests/Projects/ParatextDataProviderTests.cs`                                                           |
| JSON converter test example | `c-sharp-tests/JsonUtils/CommentConverterTests.cs`                                                              |
| TS service test example     | `src/shared/services/shared-store.service.test.ts`                                                              |
| React hook test example     | `lib/platform-bible-react/src/components/advanced/book-chapter-control/book-chapter-control.navigation.test.ts` |
| Storybook story example     | `lib/platform-bible-react/src/stories/advanced/book-chapter-control.stories.tsx`                                |

---

## Quick Reference

### Run All Tests

```bash
# TypeScript
npm test

# C#
dotnet test c-sharp-tests/c-sharp-tests.csproj
```

### Run Specific Tests

```bash
# TypeScript - specific file
npm run test:core -- src/shared/services/shared-store.service.test.ts

# C# - specific class
dotnet test c-sharp-tests/c-sharp-tests.csproj --filter "FullyQualifiedName~ParatextDataProviderTests"
```

### Watch Mode

```bash
# TypeScript
npm run test:core

# C# (requires dotnet-watch)
dotnet watch test --project c-sharp-tests/c-sharp-tests.csproj
```

### Coverage Reports

```bash
# TypeScript
npm run test:core -- --coverage

# C#
dotnet test c-sharp-tests/c-sharp-tests.csproj /p:CollectCoverage=true
```
