# Test Specifications: Creating Projects

## Overview

This directory contains **test specifications** for the Creating Projects feature. Because this is a **Level A** feature (95% ParatextData reuse), we use test specifications instead of golden masters.

### Why Test Specifications (Not Golden Masters)?

For Level A features, **ParatextData.dll is the oracle**. The same binary runs in both PT9 and PT10, so:

1. **No need to capture PT9 outputs** - ParatextData behavior is identical
2. **Test directly against APIs** - Define assertions against ParatextData contracts
3. **Property-based testing** - Verify invariants hold for generated inputs
4. **Specifications guide TDD** - Test writers use these to create red tests

### Comparison: Test Specifications vs Golden Masters

| Aspect | Test Specifications (Level A) | Golden Masters (Level B/C) |
|--------|------------------------------|---------------------------|
| Source of truth | ParatextData API contract | Captured PT9 output |
| What we test | API assertions and invariants | Output equivalence |
| How we verify | Call API, check properties | Compare against captured data |
| When useful | ParatextData-heavy features | UI-layer logic features |

## Specification Files

| File | Description | Behaviors Covered | Scenarios |
|------|-------------|-------------------|-----------|
| `spec-001-project-creation.json` | Core project creation flow | BHV-001, BHV-002, BHV-007-010 | 7 specs, 3 property tests |
| `spec-002-name-validation.json` | Name validation rules | BHV-004, BHV-005, BHV-006, BHV-020 | 21 specs, 5 property tests |
| `spec-003-derived-projects.json` | Derived project types | BHV-003, BHV-011-013 | 13 specs, 3 property tests |
| `spec-004-project-types.json` | ProjectType enum behaviors | BHV-011 | 10 specs, 2 property tests |
| `spec-005-versioning.json` | Mercurial and GUID assignment | BHV-008, BHV-009 | 9 specs, 4 property tests |
| `spec-006-settings-persistence.json` | Settings.xml persistence | BHV-002, BHV-016-018 | 15 specs, 3 property tests |
| `spec-007-plugin-api.json` | Plugin API project creation | BHV-019 | 10 specs, 3 property tests |

## Specification Format

Each specification file contains:

```json
{
  "id": "spec-XXX",
  "name": "Descriptive name",
  "description": "What this specification covers",
  "targetApis": ["ParatextData classes being tested"],
  "relatedBehaviors": ["BHV-XXX"],
  "relatedInvariants": ["INV-XXX"],
  "specifications": [
    {
      "id": "spec-XXX-YY",
      "name": "Specific test case",
      "scenarioRefs": ["TS-XXX"],
      "paratextDataApi": {
        "class": "ClassName",
        "method": "MethodName",
        "signature": "Full method signature",
        "namespace": "Namespace"
      },
      "preconditions": ["Required state"],
      "inputs": { "parameter": "value" },
      "expectedBehavior": ["What should happen"],
      "assertions": [
        {
          "type": "assertion-type",
          "target": "what to check",
          "expected": "expected value",
          "description": "why this matters"
        }
      ],
      "invariants": ["INV-XXX"],
      "priority": "critical|high|medium|low"
    }
  ],
  "propertyTests": [
    {
      "id": "prop-XXX-YY",
      "name": "Property test name",
      "invariantRef": "INV-XXX",
      "property": "What must always hold",
      "generator": { "type": "...", "constraints": {} },
      "iterations": 1000,
      "assertions": ["What to verify"],
      "priority": "critical|high|medium|low"
    }
  ]
}
```

## Assertion Types

| Type | Description | Example |
|------|-------------|---------|
| `equals` | Exact equality | `"expected": "English"` |
| `not-null` | Value is not null | - |
| `isNull` | Value is null | - |
| `isTrue` / `isFalse` | Boolean check | - |
| `contains` | String/array contains | `"expected": "substring"` |
| `matches` | Regex pattern | `"expected": "^[a-f0-9]{40}$"` |
| `greaterThan` / `lessThan` | Numeric comparison | `"expected": 0` |
| `throws` | Exception expected | `"expected": "ArgumentException"` |
| `file-exists` | File exists on disk | - |
| `directory-exists` | Directory exists | - |
| `valid-xml` | XML is well-formed | - |
| `property` | Generic property check | Uses `operator` field |

## Coverage Summary

### By Behavior

| Behavior | Specifications | Property Tests |
|----------|----------------|----------------|
| BHV-001: Create ScrText | spec-001-01 | - |
| BHV-002: Default settings | spec-001-02, spec-006 | prop-006-01 |
| BHV-003: Initialize from base | spec-003-01, spec-003-02 | prop-003-02 |
| BHV-004: Generate unique name | spec-002-16 through 002-18 | prop-002-05 |
| BHV-005: Validate short name | spec-002-01 through 002-11 | prop-002-01 through 002-03 |
| BHV-006: Generate abbreviation | spec-002-12 through 002-15 | prop-002-04 |
| BHV-007: Create directory | spec-001-03 | prop-001-01 |
| BHV-008: Init Mercurial | spec-005-01, spec-005-02 | prop-005-02 |
| BHV-009: Assign GUID | spec-005-03 through 005-05 | prop-005-01 |
| BHV-010: Add to collection | spec-001-06 | prop-001-03 |
| BHV-011: Set project type | spec-003, spec-004 | prop-003-01, prop-004-01 |
| BHV-012: Copy books | spec-003-09 | - |
| BHV-013: Copy license | spec-003-10 | prop-003-03 |
| BHV-016: Language settings | spec-006-03 | - |
| BHV-017: File naming | spec-006-02 | prop-006-03 |
| BHV-018: Planned books | spec-006-04 | - |
| BHV-019: Plugin API | spec-007 | prop-007-01 through 007-03 |
| BHV-020: Full name validation | spec-002-19 through 002-21 | - |

### By Invariant

| Invariant | Description | Specifications | Property Tests |
|-----------|-------------|----------------|----------------|
| INV-001 | Unique project names | spec-002-09, spec-002-16 | prop-002-01 |
| INV-002 | Unique GUIDs | spec-005-03 through 005-05 | prop-005-01 |
| INV-003 | Directory matches name | spec-001-03 | prop-001-01 |
| INV-004 | Derived require base | spec-003-07, spec-003-08 | prop-003-01 |
| INV-005 | Resources not versioned | spec-005-02 | prop-005-02 |
| INV-006 | Save before collection add | spec-006-01 | prop-001-03 |
| INV-007 | GUID before collection add | spec-001-06 | prop-001-03 |

## Using These Specifications

### For TDD Test Writers (Phase 3)

1. Select a specification file based on the area you're implementing
2. For each specification:
   - Create a test method with the specification ID
   - Set up preconditions as described
   - Call the ParatextData API with specified inputs
   - Assert all listed assertions
3. For property tests:
   - Use a property-based testing library (e.g., FsCheck for C#)
   - Implement the generator as described
   - Run for the specified number of iterations

### For Reviewers

1. Verify specifications match the behaviors in `behavior-catalog.md`
2. Check scenario references (TS-XXX) map to `test-scenarios.json`
3. Ensure invariant coverage is complete
4. Validate assertion types are implementable

## Traceability

| Source | ID Pattern | Location |
|--------|------------|----------|
| Behaviors | BHV-XXX | `behavior-catalog.md` |
| Test Scenarios | TS-XXX | `characterization/test-scenarios.json` |
| Invariants | INV-XXX | `business-rules.md` |
| Validation Rules | VAL-XXX | `business-rules.md` |

## Statistics

- **Total Specifications**: 85
- **Total Property Tests**: 23
- **Behaviors Covered**: 20/20 (100%)
- **Invariants Covered**: 7/7 (100%)
- **Test Scenarios Referenced**: 65/65 (100%)

## Next Steps

These specifications will be used by:

1. **Contract Writer Agent** - To define API contracts for PT10 implementation
2. **TDD Test Writer Agent** - To create failing tests before implementation
3. **Traceability Validator Agent** - To verify implementation coverage

The specifications define WHAT to test, not HOW to implement. The implementation will be done in Phase 3 by the TDD agents.
