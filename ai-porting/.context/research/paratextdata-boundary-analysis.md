# ParatextData Integration Boundary Analysis

**Date:** 2026-01-06
**Author:** Claude Code Analysis
**Scope:** Analysis of test coverage at the ParatextData.dll integration boundary

---

## Executive Summary

The Platform.Bible C# codebase wraps the ParatextData NuGet package to expose scripture and project data via data providers. While the wrapper code is tested, the tests use in-memory mocks that don't exercise the real ParatextData behavior. This creates a gap where behavioral changes in ParatextData could go undetected.

---

## 1. Architecture Overview

### Data Flow

```
TypeScript/React UI
        │
        │ JSON-RPC over WebSocket (port 8876)
        ▼
┌─────────────────────────────────────────────────────────────┐
│                    .NET Process                              │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  ParatextProjectDataProvider.cs                      │   │
│  │  - GetBookUsfm(), SetBookUsfm()                      │   │
│  │  - GetComments(), SetComments()                      │   │
│  │  - GetChapterUsx(), SetChapterUsx()                  │   │
│  │  - etc.                                              │   │
│  └───────────────────────┬──────────────────────────────┘   │
│                          │                                   │
│                          │ Direct method calls               │
│                          ▼                                   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  ParatextData.dll (NuGet package)                    │   │
│  │  - ScrText (project representation)                  │   │
│  │  - CommentManager (notes/comments)                   │   │
│  │  - ProjectSettings                                   │   │
│  │  - USFM/USX parsing and conversion                   │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### Key Integration Points

| Platform.Bible Code | ParatextData Class | Namespace |
|---------------------|-------------------|-----------|
| `ParatextProjectDataProvider.cs` | `ScrText` | `Paratext.Data` |
| `ParatextProjectDataProvider.cs` | `CommentManager` | `Paratext.Data.ProjectComments` |
| `ParatextProjectDataProvider.cs` | `CommentThread` | `Paratext.Data.ProjectComments` |
| `ParatextProjectDataProvider.cs` | `ProjectSettings` | `Paratext.Data.ProjectSettingsAccess` |
| `LocalParatextProjects.cs` | `ScrTextCollection` | `Paratext.Data` |

---

## 2. Current Test Infrastructure

### Test Files

| File | Purpose |
|------|---------|
| `c-sharp-tests/Projects/ParatextDataProviderTests.cs` | Tests Get/Set USFM, USX, extension data |
| `c-sharp-tests/Projects/ParatextProjectDataProviderCommentTests.cs` | Tests comment operations |
| `c-sharp-tests/Projects/LocalParatextProjectsTests.cs` | Tests project discovery |

### Mock/Dummy Infrastructure

| File | What it mocks |
|------|---------------|
| `c-sharp-tests/DummyScrText.cs` | `ScrText` - uses `InMemoryFileManager` |
| `c-sharp-tests/DummyPapiClient.cs` | Network client |
| `c-sharp-tests/DummyParatextProjectDataProvider.cs` | Data provider for testing |
| `c-sharp-tests/DummyScrStylesheet.cs` | Stylesheet handling |
| `c-sharp-tests/DummyScrLanguage.cs` | Language settings |

### How DummyScrText Works

```csharp
internal class DummyScrText : ScrText
{
    // Inherits from REAL ScrText but overrides file manager
    protected override ProjectFileManager CreateFileManager()
    {
        return new InMemoryFileManager(this);  // No disk I/O
    }
}
```

**Important:** `DummyScrText` inherits from the real `ScrText` class, so some ParatextData code paths are exercised. However, the `CommentManager` and other services that depend on file-based state are not fully tested.

---

## 3. Test Boundary Analysis

### What IS Tested

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         TEST BOUNDARY                                    │
│                                                                          │
│  ✅ ParatextProjectDataProvider method logic                            │
│  ✅ Input validation and error handling                                  │
│  ✅ Correct API calls to ParatextData                                   │
│  ✅ Data transformation (selectors, scopes)                             │
│  ✅ Update event emission                                                │
│  ⚠️  ScrText basic operations (via inheritance)                         │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### What is NOT Tested

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      OUTSIDE TEST BOUNDARY                               │
│                                                                          │
│  ❌ CommentManager internal behavior                                     │
│  ❌ Real file format parsing (USFM, USX, XML)                           │
│  ❌ Versification edge cases                                             │
│  ❌ Character encoding handling                                          │
│  ❌ Concurrent access behavior                                           │
│  ❌ Project file corruption handling                                     │
│  ❌ Cross-version compatibility                                          │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Risk Assessment

### Risk Matrix

| Risk | Likelihood | Impact | Detection | Overall |
|------|------------|--------|-----------|---------|
| Method signature changes | Low | High | ✅ Compile error | Low |
| Return type changes | Low | High | ⚠️ Maybe | Medium |
| **Behavioral changes (same API)** | Medium | High | ❌ No | **High** |
| USFM parsing changes | Medium | High | ❌ No | **High** |
| Comment format changes | Medium | High | ❌ No | **High** |
| New required parameters | Low | Medium | ⚠️ Maybe | Medium |
| Performance regressions | Medium | Medium | ❌ No | Medium |

### Concrete Risk Examples

#### Example 1: Comment Ordering Change

```csharp
// ParatextProjectDataProvider.cs line 187
public List<Comment> GetComments(CommentSelector selector)
{
    List<Comment> comments = _commentManager.AllComments.ToList();
    // ...
}
```

If ParatextData changes how `AllComments` orders results (e.g., by date vs. by position), the UI could display comments in unexpected order. Current tests would not catch this.

#### Example 2: USFM Whitespace Handling

```csharp
// Test expectation
[TestCase(1, 2, 1, @"\v 1 verse one ")]
```

If ParatextData changes whitespace normalization in USFM output, tests might fail for cosmetic reasons, or worse, pass while actual behavior differs from Paratext 9.

#### Example 3: Verse Reference Parsing

```csharp
var verseRef = new VerseRef(bookNum, chapterNum, verseNum);
```

If `VerseRef` changes how it handles edge cases (verse ranges, partial verses), scripture retrieval could silently return wrong data.

---

## 5. Recommended Testing Strategies

### Strategy 1: Golden Master Tests

**Purpose:** Capture expected ParatextData outputs and detect any changes.

**Implementation:**

```csharp
[TestFixture]
public class ParatextDataGoldenMasterTests
{
    private static readonly string GoldenMasterPath = "TestData/GoldenMasters/";

    [Test]
    public void GetBookUsfm_MatchesGoldenMaster()
    {
        // Use a known test project with fixed content
        var scrText = LoadTestProject("StandardTestProject");
        var result = scrText.GetText(new VerseRef("GEN", 1, 0), false, false);

        var expected = File.ReadAllText(Path.Combine(GoldenMasterPath, "gen_book_usfm.txt"));
        Assert.That(NormalizeWhitespace(result), Is.EqualTo(NormalizeWhitespace(expected)));
    }

    [Test]
    public void CommentManager_AllComments_MatchesGoldenMaster()
    {
        var scrText = LoadTestProject("ProjectWithComments");
        var commentManager = CommentManager.Get(scrText);
        var comments = commentManager.AllComments.ToList();

        var expected = JsonConvert.DeserializeObject<List<CommentSnapshot>>(
            File.ReadAllText(Path.Combine(GoldenMasterPath, "all_comments.json")));

        AssertCommentsMatch(comments, expected);
    }
}
```

**Benefits:**
- Detects behavioral changes automatically
- Easy to update when intentional changes occur
- Documents expected behavior

**Maintenance:**
- Golden masters need updating when ParatextData is intentionally upgraded
- Store in version control with clear documentation

---

### Strategy 2: Integration Tests with Real Project Files

**Purpose:** Test against actual Paratext project structure.

**Implementation:**

```csharp
[TestFixture]
[Category("Integration")]
public class ParatextDataIntegrationTests
{
    private string _testProjectPath;

    [OneTimeSetUp]
    public void SetupTestProject()
    {
        // Copy a real test project to temp directory
        _testProjectPath = TestProjectManager.CreateTestProject("IntegrationTestProject");
    }

    [Test]
    public void RoundTrip_SetAndGetChapterUsfm_PreservesContent()
    {
        var scrText = new ScrText(_testProjectPath);
        var originalUsfm = @"\c 1 \v 1 Test verse content.";

        scrText.PutText(1, 1, false, originalUsfm, null);
        var retrieved = scrText.GetText(new VerseRef(1, 1, 0), false, false);

        Assert.That(retrieved, Does.Contain("Test verse content"));
    }

    [Test]
    public void CommentRoundTrip_CreateAndRetrieve_Succeeds()
    {
        var scrText = new ScrText(_testProjectPath);
        var commentManager = CommentManager.Get(scrText);

        // Create a comment using real ParatextData
        var thread = commentManager.CreateThread(scrText,
            new ScriptureSelection(new VerseRef("GEN", 1, 1), "selected text", 0),
            NoteStatus.Todo);

        // Retrieve and verify
        var retrieved = commentManager.FindThread(thread.Id);
        Assert.That(retrieved, Is.Not.Null);
        Assert.That(retrieved.VerseRef.ToString(), Is.EqualTo("GEN 1:1"));
    }

    [OneTimeTearDown]
    public void CleanupTestProject()
    {
        TestProjectManager.DeleteTestProject(_testProjectPath);
    }
}
```

**Benefits:**
- Tests real file I/O behavior
- Catches format-related issues
- Verifies actual ParatextData behavior

**Considerations:**
- Slower than unit tests
- Requires test project files
- May need CI/CD configuration for file access

---

### Strategy 3: Contract Tests

**Purpose:** Define explicit contracts for ParatextData behavior that Platform.Bible depends on.

**Implementation:**

```csharp
[TestFixture]
public class ParatextDataContractTests
{
    /// <summary>
    /// Contract: CommentManager.AllComments returns comments in chronological order by Date
    /// </summary>
    [Test]
    public void Contract_AllComments_ReturnsChronologicalOrder()
    {
        var scrText = CreateProjectWithComments();
        var commentManager = CommentManager.Get(scrText);

        var comments = commentManager.AllComments.ToList();

        for (int i = 1; i < comments.Count; i++)
        {
            Assert.That(comments[i].Date, Is.GreaterThanOrEqualTo(comments[i-1].Date),
                "CONTRACT VIOLATION: AllComments must return comments in chronological order");
        }
    }

    /// <summary>
    /// Contract: GetText with chapter=0 returns entire book
    /// </summary>
    [Test]
    public void Contract_GetText_ChapterZero_ReturnsEntireBook()
    {
        var scrText = CreateProjectWithMultipleChapters();

        var result = scrText.GetText(new VerseRef("GEN", 0, 0), false, false);

        Assert.That(result, Does.Contain(@"\c 1"), "CONTRACT: Chapter 0 must include chapter 1");
        Assert.That(result, Does.Contain(@"\c 2"), "CONTRACT: Chapter 0 must include chapter 2");
        Assert.That(result, Does.Contain(@"\id GEN"), "CONTRACT: Chapter 0 must include book ID");
    }

    /// <summary>
    /// Contract: VerseRef correctly parses standard references
    /// </summary>
    [TestCase("GEN 1:1", 1, 1, 1)]
    [TestCase("MAT 5:3", 40, 5, 3)]
    [TestCase("REV 22:21", 66, 22, 21)]
    public void Contract_VerseRef_ParsesStandardReferences(
        string reference, int expectedBook, int expectedChapter, int expectedVerse)
    {
        var verseRef = new VerseRef(reference);

        Assert.That(verseRef.BookNum, Is.EqualTo(expectedBook));
        Assert.That(verseRef.ChapterNum, Is.EqualTo(expectedChapter));
        Assert.That(verseRef.VerseNum, Is.EqualTo(expectedVerse));
    }
}
```

**Benefits:**
- Documents assumptions about ParatextData
- Clear failure messages when contracts break
- Helps ParatextData team understand dependencies

---

### Strategy 4: Version Compatibility Tests

**Purpose:** Ensure Platform.Bible works with specific ParatextData versions.

**Implementation:**

```csharp
[TestFixture]
public class ParatextDataVersionTests
{
    [Test]
    public void MinimumVersion_IsSupported()
    {
        var minVersion = new Version(9, 4, 0, 0);
        var actualVersion = typeof(ScrText).Assembly.GetName().Version;

        Assert.That(actualVersion, Is.GreaterThanOrEqualTo(minVersion),
            $"ParatextData version {actualVersion} is below minimum supported {minVersion}");
    }

    [Test]
    public void RequiredAPIs_Exist()
    {
        // Verify critical APIs we depend on exist
        var scrTextType = typeof(ScrText);

        Assert.That(scrTextType.GetMethod("GetText"), Is.Not.Null,
            "Required API ScrText.GetText is missing");
        Assert.That(scrTextType.GetMethod("PutText"), Is.Not.Null,
            "Required API ScrText.PutText is missing");

        var commentManagerType = typeof(CommentManager);
        Assert.That(commentManagerType.GetProperty("AllComments"), Is.Not.Null,
            "Required API CommentManager.AllComments is missing");
    }
}
```

---

### Strategy 5: Behavioral Snapshot Tests

**Purpose:** Capture and compare complex behavior across ParatextData versions.

**Implementation:**

```csharp
[TestFixture]
public class ParatextDataBehaviorSnapshotTests
{
    [Test]
    public void UsfmToUsxConversion_BehaviorSnapshot()
    {
        var testCases = new[]
        {
            @"\id GEN \c 1 \v 1 Simple verse.",
            @"\id GEN \c 1 \v 1-3 Verse range.",
            @"\id GEN \c 1 \v 1 Verse with \nd LORD\nd* name.",
            @"\id GEN \c 1 \v 1 Verse with\f + \fr 1:1 \ft footnote\f* marker.",
        };

        var results = new Dictionary<string, string>();
        foreach (var usfm in testCases)
        {
            var usx = ConvertUsfmToUsx(usfm);
            results[usfm] = usx;
        }

        // Compare with stored snapshot
        var snapshotPath = "TestData/Snapshots/usfm_to_usx_behavior.json";
        if (File.Exists(snapshotPath))
        {
            var expected = JsonConvert.DeserializeObject<Dictionary<string, string>>(
                File.ReadAllText(snapshotPath));

            foreach (var kvp in results)
            {
                Assert.That(kvp.Value, Is.EqualTo(expected[kvp.Key]),
                    $"Behavior changed for USFM: {kvp.Key}");
            }
        }
        else
        {
            // First run: create snapshot
            File.WriteAllText(snapshotPath, JsonConvert.SerializeObject(results, Formatting.Indented));
            Assert.Inconclusive("Snapshot created. Run test again to verify.");
        }
    }
}
```

---

## 6. Implementation Recommendations

### Priority Order

1. **Golden Master Tests** (High priority)
   - Implement first
   - Covers most common risk scenarios
   - Relatively easy to set up

2. **Contract Tests** (High priority)
   - Documents assumptions
   - Helps catch breaking changes early
   - Good for CI/CD

3. **Integration Tests** (Medium priority)
   - More complex to set up
   - Valuable for round-trip testing
   - Requires test project infrastructure

4. **Version Compatibility Tests** (Medium priority)
   - Simple to implement
   - Catches API removal early

5. **Behavioral Snapshot Tests** (Lower priority)
   - Complex to maintain
   - Useful for specific high-risk areas

### Suggested Test Project Structure

```
c-sharp-tests/
├── Integration/
│   ├── ParatextDataIntegrationTests.cs
│   └── TestData/
│       └── Projects/
│           ├── StandardTestProject/
│           └── ProjectWithComments/
├── Contracts/
│   ├── ParatextDataContractTests.cs
│   └── CommentManagerContractTests.cs
├── GoldenMasters/
│   ├── ParatextDataGoldenMasterTests.cs
│   └── TestData/
│       └── GoldenMasters/
│           ├── gen_book_usfm.txt
│           ├── all_comments.json
│           └── usx_conversion.json
└── Version/
    └── ParatextDataVersionTests.cs
```

### CI/CD Considerations

- Run golden master and contract tests on every PR
- Run integration tests nightly or on release branches
- Store test projects in a separate repository or artifact storage
- Document the process for updating golden masters when ParatextData is upgraded

---

## 7. Conclusion

The current test infrastructure provides good coverage of Platform.Bible's wrapper code but leaves a significant gap at the ParatextData boundary. Implementing the recommended testing strategies would:

1. **Detect behavioral changes** in ParatextData before they reach production
2. **Document assumptions** about how ParatextData behaves
3. **Provide confidence** when upgrading ParatextData versions
4. **Reduce debugging time** by catching issues at the source

The golden master and contract test strategies offer the best cost/benefit ratio and should be prioritized for implementation.
