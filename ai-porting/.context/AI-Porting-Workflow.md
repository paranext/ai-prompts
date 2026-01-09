# AI-Assisted Porting Workflow

## Overview

This document defines the workflow for porting features from Paratext 9 (PT9) to Platform.Bible (PT10) using AI-assisted development.

### Key Principles

- **Task descriptions** define human-provided scope, goals, and constraints before AI agents begin work
- **Feature classification** drives the testing and implementation strategy (Level A/B/C based on ParatextData reuse)
- **ParatextData.dll is shared** between PT9 and PT10, providing a stable business logic layer
- **Specifications vary by level**: Level A uses structured test specifications; Level B/C uses golden masters
- **Implementation strategy** varies by level (TDD for logic, Component-First for UI)
- **Phase 1-2 run in PT9 codebase**, Phase 3+ run in PT10 (paranext-core) codebase
- **4-phase process** with specialized AI agents and human review gates
- **Proof over testing** - Every agent delivers verifiable evidence that their work is correct. Testing is the mechanism; proof is the outcome.

### Workflow Summary

```
Phase 0: Task Description → Developer creates task-description.md (G0 gate)
Phase 1: Discovery        → Discover PT9 behaviors, classify feature → GitHub issue → Scope Validation (G1.5) [PT9]
Phase 2: Specification    → Test scenarios, specs/golden masters, contracts → PR Approval (G3.5) [PT9]
Phase 3: Implementation   → Align to PT10, TDD or Component-First (based on level) [PT10]
Phase 4: Verification     → Equivalence, property tests → PR Approval (G10) → Merge [PT10]
```

---

## 1. Phase Commands + Specialized Agents

### Architecture

We use **4 phase commands** that orchestrate **specialized subagents**:

- **Phase commands** (in `.claude/commands/porting/`) - User invokes these
- **Specialized agents** (in `.claude/agents/`) - Phase commands delegate to these
- **Human review** after each agent before proceeding

### Command Structure

```
.claude/
├── commands/porting/
│   ├── phase-1-discovery.md         # Agents: archaeologist → logic-locator → classifier
│   ├── phase-2-specification.md     # Agents: test-scenario-writer → spec-generator → contract-writer
│   │                                # + Spec summary + GitHub issue creation
│   ├── phase-3-implementation.md    # Agents: alignment → TDD path OR component-builder (based on level)
│   └── phase-4-verification.md      # Agents: equivalence-checker → invariant-checker → validator
│
└── agents/
    ├── archaeologist.md             # Discover behaviors, entry points, invariants
    ├── logic-locator.md             # Identify WHERE logic lives (ParatextData vs UI)
    ├── feature-classifier.md        # Determine Level A/B/C
    ├── test-scenario-writer.md      # Generate test scenarios (Phase 2)
    ├── spec-generator.md            # Create test specs (A), extraction plans + golden masters (B/C)
    ├── contract-writer.md           # Define API types (with {TBD:*} placeholders for PT10)
    ├── alignment-agent.md           # Map Phase 2 contracts to PT10 patterns (Phase 3 Step 0)
    ├── tdd-test-writer.md           # Write failing tests (RED)
    ├── traceability-validator.md    # Validate test→spec coverage (Level A/B)
    ├── tdd-implementer.md           # Minimal code (GREEN)
    ├── tdd-refactorer.md            # Clean up (REFACTOR)
    ├── component-builder.md         # Build UI components (Level B/C)
    ├── equivalence-checker.md       # Compare PT9 vs PT10 outputs
    ├── invariant-checker.md         # Property tests
    └── validator.md                 # Quality gate check
```

### Visual Workflow

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PHASE 0: TASK DESCRIPTION                  Human/PO Input              │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  Developer creates .context/features/{feature}/task-description.md   │
│  │  PO/Stakeholder approves task description (G0 gate)              │   │
│  │  (prerequisite before workflow begins)                           │   │
│  └──────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  PHASE 1: DISCOVERY                         Codebase: PT9               │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  Creates feature/{feature-name} branch in ai-prompts repo        │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│  ┌──────────────────┐  ┌──────────────────┐  ┌────────────────────┐     │
│  │  Archaeologist   │→ │  Logic Locator   │→ │    Classifier      │     │
│  └──────────────────┘  └──────────────────┘  └────────────────────┘     │
│                                   │                                     │
│                   ┌───────────────┴───────────────┐                     │
│                   │  Create GitHub Issue          │                     │
│                   │  (Discovery Findings)         │                     │
│                   └───────────────────────────────┘                     │
│                                   │                                     │
│           ════════ SCOPE VALIDATION GATE (G1.5) ════════                │
│           PO/Stakeholder reviews GitHub issue                           │
│           Approves scope before specification begins                    │
└─────────────────────────────────────────────────────────────────────────┘
                                   │
                      [PO/Stakeholder Approval]
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  PHASE 2: SPECIFICATION                     Codebase: PT9               │
│  ┌──────────────────┐  ┌──────────────────┐  ┌────────────────────┐     │
│  │Test Scenario     │→ │  Spec Generator  │→ │ Contract Writer    │     │
│  │   Writer         │  │                  │  │                    │     │
│  └──────────────────┘  └──────────────────┘  └────────────────────┘     │
│                                   │                                     │
│                   ┌───────────────┴───────────────┐                     │
│                   │  Update GitHub Issue          │                     │
│                   │  (Add Specification Details)  │                     │
│                   └───────────────────────────────┘                     │
│                                   │                                     │
│         ════════ SPECIFICATION APPROVAL GATE (G3.5) ════════            │
│         PR: feature/{feature-name} → main in ai-prompts                 │
│         Reviews specifications before implementation                    │
└─────────────────────────────────────────────────────────────────────────┘
                                   │
                       [PR Approved & Merged]
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  PHASE 3: IMPLEMENTATION                    Codebase: PT10              │
│                                                                         │
│  ┌──────────────────┐                                                   │
│  │ Alignment Agent  │ (Step 0: Maps contracts to PT10 patterns)         │
│  │   [commits]      │                                                   │
│  └────────┬─────────┘                                                   │
│           │                                                             │
│           ▼                                                             │
│  ┌──────────────────┐                                                   │
│  │ Strategic Plan   │ (Step 1: Capability decomposition)                │
│  │   [commits]      │                                                   │
│  └────────┬─────────┘                                                   │
│           │                                                             │
│           ▼                                                             │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    Level A / B Logic Path                       │    │
│  │  ┌─────────────┐  ┌─────────────┐  ┌───────────┐  ┌───────────┐ │    │
│  │  │ Test Writer │→ │ Traceability│→ │Implementer│→ │ Refactorer│ │    │
│  │  │   (RED)     │  │  Validator  │  │  (GREEN)  │  │           │ │    │
│  │  │  [commits]  │  │             │  │ [commits] │  │ [commits] │ │    │
│  │  └─────────────┘  └─────────────┘  └───────────┘  └───────────┘ │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    Level B UI / C Path                          │    │
│  │  ┌───────────────────────────────────────────────────────────┐  │    │
│  │  │              Component Builder                            │  │    │
│  │  │         (iterative visual verification)                   │  │    │
│  │  │                    [commits]                              │  │    │
│  │  └───────────────────────────────────────────────────────────┘  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  Branches:                                                              │
│  • ai-prompts: feature/{feature-name} (alignment, plans, proofs)        │
│  • paranext-core: feature/{feature-name} (tests, implementation)        │
└─────────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  PHASE 4: VERIFICATION                      Codebase: PT10              │
│  ┌──────────────────┐  ┌──────────────────┐  ┌────────────────────┐     │
│  │  Equivalence     │→ │   Invariant      │→ │    Validator       │     │
│  │   Checker        │  │    Checker       │  │                    │     │
│  └──────────────────┘  └──────────────────┘  └────────────────────┘     │
│                                   │                                     │
│         ════════ IMPLEMENTATION APPROVAL GATE (G10) ════════            │
│         PR: feature/{feature-name} → main in paranext-core              │
│         Includes: tests, implementation, verification reports           │
│         Links to: ai-prompts artifacts for context                      │
└─────────────────────────────────────────────────────────────────────────┘
                                   │
                       [PR Approved & Merged]
                                   │
                                   ▼
                         Human Review Complete
```

### Phase Commands

| Command                                  | Purpose                              | Outputs                                                                                                                            |
| ---------------------------------------- | ------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------- |
| `/porting/phase-1-discovery {name}`      | Discover PT9 behaviors               | behavior-catalog.md, boundary-map.md, business-rules.md, logic-distribution.md, README.md (classification)                         |
| `/porting/phase-2-specification {name}`  | Define specs + PO/Stakeholder review | test-scenarios.json, test-specifications/ (A/B), extraction-plan.md (B), golden-masters/ (B/C), data-contracts.md, github-issue.md |
| `/porting/phase-3-implementation {name}` | Build feature                        | Test files, implementation (strategy varies by level)                                                                              |
| `/porting/phase-4-verification {name}`   | Verify correctness                   | equivalence-report.md, invariant-report.md, validation-report.md                                                                   |

### Agent Summary

| Phase | Agent                  | Responsibility                                | Output                                                        |
| ----- | ---------------------- | --------------------------------------------- | ------------------------------------------------------------- |
| 1     | Archaeologist          | Discover behaviors, entry points, invariants  | behavior-catalog.md, boundary-map.md, business-rules.md       |
| 1     | Logic Locator          | Identify WHERE logic lives (ParatextData/UI)  | logic-distribution.md                                         |
| 1     | Classifier             | Determine Level A/B/C                         | README.md classification (with TBD PT10 integration notes)    |
| 2     | Test Scenario Writer   | Generate test scenarios from behaviors        | test-scenarios.json, edge-cases.md, requirements.md           |
| 2     | Spec Generator         | Create specs (A/B), extraction plans (B), GMs | test-specifications/, extraction-plan.md (B), golden-masters/ |
| 2     | Contract Writer        | Define API types with `{TBD:*}` placeholders  | data-contracts.md                                             |
| 3     | Alignment Agent        | Map Phase 2 contracts to PT10 patterns        | pt10-alignment.md, fills TBD sections                         |
| 3     | TDD Test Writer        | Write failing tests (RED) - Level A/B logic   | Test files in PT10                                            |
| 3     | Traceability Validator | Validate test→spec coverage - Level A/B       | traceability-report.md                                        |
| 3     | TDD Implementer        | Minimal code (GREEN) - Level A/B logic        | Implementation code                                           |
| 3     | TDD Refactorer         | Clean up (REFACTOR) - Level A/B logic         | Refactored code                                               |
| 3     | Component Builder      | Build UI iteratively - Level B UI/C           | React components, snapshot tests                              |
| 4     | Equivalence Checker    | Compare PT9 vs PT10 outputs                   | equivalence-report.md                                         |
| 4     | Invariant Checker      | Property tests                                | invariant-report.md                                           |
| 4     | Validator              | Quality gate check                            | validation-report.md                                          |

### Agent Handoff

Agents communicate via **artifacts in `.context/features/{feature}/`**:

- Each agent reads artifacts from previous agents
- Each agent writes its own artifacts
- Human reviews artifacts between agents
- Progress tracked in `phase-status.md`

---

## 2. Feature Classification System

### Classification Levels

| Level                     | Description                            | Testing Focus                      | Examples                                   |
| ------------------------- | -------------------------------------- | ---------------------------------- | ------------------------------------------ |
| **A: ParatextData-Heavy** | 80%+ logic in shared DLL               | API contract tests, golden masters | Creating Projects, USB Syncing             |
| **B: Mixed Logic**        | Significant UI-embedded business logic | Extract logic, characterize, TDD   | S/R Conflict Resolution, Parallel Passages |
| **C: Pure UI**            | 90%+ UI, data from existing APIs       | Component-First, snapshot tests    | Checklists, Translation Resources          |

### Implementation Strategy by Level

| Level | Strategy        | Agents Used                                        | Rationale                              |
| ----- | --------------- | -------------------------------------------------- | -------------------------------------- |
| **A** | Full TDD        | tdd-test-writer → tdd-implementer → tdd-refactorer | Clear APIs, logic in ParatextData      |
| **B** | Hybrid          | TDD for extracted logic + component-builder for UI | Business logic testable, UI visual     |
| **C** | Component-First | component-builder → snapshot tests                 | 90%+ UI, visual verification effective |

### Feature Classification

| Feature                 | Level | ParatextData Reuse | Effort      |
| ----------------------- | ----- | ------------------ | ----------- |
| Creating Projects       | A     | 95%                | Low         |
| USB Syncing             | A     | 90%                | Medium      |
| Translation Resources   | B/C   | 80%                | Medium      |
| Parallel Passages       | B     | 40%                | Medium-High |
| Checklists              | C     | 5%                 | High        |
| S/R Conflict Resolution | B     | 70%                | High        |

---

## 3. Testing Strategy by Type

This section defines the test types used in feature porting.

### TDD as Non-Negotiable Discipline

For Level A and B features, TDD is **mandatory**. We follow the [Testing Trophy model](standards/Testing-Guide.md#test-strategy-the-testing-trophy): favor integration tests at service boundaries over excessive unit tests.

| Phase   | Agent           | TDD Requirement                                   |
| ------- | --------------- | ------------------------------------------------- |
| Phase 3 | TDD Test Writer | Write tests FIRST, verify they FAIL (Revert Test) |
| Phase 3 | TDD Implementer | Write MINIMUM code to pass tests                  |
| Phase 3 | TDD Refactorer  | Clean up while tests stay GREEN                   |

**The Revert Test**: Every test must fail when implementation is absent. Tests that pass without implementation are worthless.

### Outside-In TDD (Double Loop)

Phase 3 uses [Outside-In TDD](https://outsidein.dev/concepts/outside-in-tdd/) (London School) to constrain AI agents:

```
┌─────────────────────────────────────────────────────────────┐
│  OUTER LOOP (Acceptance Test from Phase 2 Specs)            │
│                                                             │
│  Test Writer: Write integration/acceptance test from        │
│               test-specification (Level A/B) or             │
│               golden-master (Level B/C)                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  INNER LOOP (Unit Tests)                             │   │
│  │                                                      │   │
│  │  Test Writer: Write unit tests for components        │   │
│  │  Implementer: Write minimal code to pass unit tests  │   │
│  │  (Repeat until outer test passes)                    │   │
│  │                                                      │   │
│  └─────────────────────────────────────────────────────┘   │
│  Refactorer: Clean up while keeping all tests green         │
└─────────────────────────────────────────────────────────────┘
```

**Why Outside-In TDD for AI Agents:**

| Benefit                  | How It Helps                                                             |
| ------------------------ | ------------------------------------------------------------------------ |
| **Tests as constraints** | The outer test acts as a "fence" - agent can't deviate from PT9 behavior |
| **Clear done signal**    | When outer test passes, capability is complete                           |
| **User-facing focus**    | Tests come from Phase 2 specs, not implementation guesses                |
| **Emergent design**      | Internal structure emerges from passing tests, not upfront design        |

**Outer Test Sources by Strategy:**

| Strategy                  | Outer Test Source        | Done Signal            |
| ------------------------- | ------------------------ | ---------------------- |
| TDD (Level A/B)           | test-specification JSON  | Acceptance test passes |
| Component-First (Level C) | golden-master screenshot | Visual match confirmed |

### Capability-Based Work Units

Features are decomposed into **capabilities** - fine-grained units of work that each have their own acceptance test and implementation strategy.

**What is a Capability:**

- One API method OR one distinct UI component
- Has one outer acceptance test (from test-specification or golden-master)
- Uses TDD (default for Level A/B logic) or Component-First (default for Level C/UI)
- Can be implemented independently with clear success criteria

**Capability Granularity:**

| Right-Sized                        | Too Small              | Too Large                 |
| ---------------------------------- | ---------------------- | ------------------------- |
| Maps to 1 API method or user story | < 1 test spec          | > 10 test specs           |
| 2-7 test specifications            | < 1 hour to implement  | > 3 days to implement     |
| Can be demoed independently        | No user-visible change | Spans multiple UI screens |

**Per-Capability Strategy Assignment:**

Each capability gets its own strategy based on its nature:

| Capability Type  | Default Strategy | Examples                          |
| ---------------- | ---------------- | --------------------------------- |
| Data Provider    | TDD              | C# service wrapping ParatextData  |
| Business Logic   | TDD              | Extracted algorithms, validation  |
| Visual Component | Component-First  | Grid, form, dialog (layout-heavy) |
| Integration Glue | TDD              | PAPI commands, type definitions   |

**Hybrid Capabilities:** When a capability genuinely needs both TDD and Component-First, split it:

```
Settings Dialog (Hybrid)
├── settings-validation (TDD) - validation logic
├── settings-state (TDD) - state management
└── settings-ui (Component-First) - visual rendering
```

The strategic plan (created in Phase 3 Step 1) documents all capabilities, their strategies, dependencies, and execution order.

### Unit Tests (TDD)

- **Purpose**: Drive implementation through RED→GREEN→REFACTOR cycle
- **Scope**: Single functions, methods, or classes in isolation
- **Location**: Colocated with source (`*.test.ts`) or in `c-sharp-tests/`
- **Tools**: Vitest (TypeScript), NUnit (C#)
- **When to use**: All features (Level A, B, C)

### Integration Tests

- **Purpose**: Verify multiple components work together correctly
- **Scope**: Service interactions, data provider chains, cross-module behavior
- **Location**: `c-sharp-tests/` with `[Category("Integration")]`
- **Tools**: NUnit with real (not mocked) dependencies
- **When to use**: Level A/B features with complex component interactions

### Golden Master Tests

- **Purpose**: Byte-for-byte or semantic comparison of PT10 output against PT9
- **Scope**: Entire operation outputs captured from PT9
- **Location**: `c-sharp-tests/GoldenMasters/{Feature}/`
- **Pattern**: Load input → Run system → Compare to stored PT9 output
- **When to use**: Level B/C for UI-layer behavior; Level A only if ParatextData behavior needs verification

### Property-Based Tests

- **Purpose**: Verify invariants hold for ALL possible inputs
- **Scope**: Business rules that must always be true
- **Location**: `*PropertyTests.cs` files
- **Tools**: FsCheck (C#), fast-check (TypeScript)
- **When to use**: **Mandatory** for Level A/B features with defined invariants

**Iteration Requirements:**

| Invariant Criticality      | Minimum Iterations |
| -------------------------- | ------------------ |
| Critical (data integrity)  | 1000               |
| Important (business logic) | 500                |
| Standard                   | 100                |

**Evidence format:** Include iteration counts in proof files:

```
INV-001: ProjectGuid_AlwaysUnique - 1000/1000 passed
```

### Characterization Tests

- **Purpose**: Capture what PT9 ACTUALLY does (before porting)
- **Scope**: Document existing behavior, including edge cases and quirks
- **Location**: `.context/features/{f}/characterization/`
- **Pattern**: Run PT9 code → Serialize output → Store as reference
- **When to use**: Phase 1 (Analysis) for all features

### Mutation Testing

- **Purpose**: Verify test quality by checking if tests catch code mutations
- **Scope**: Critical business logic (not UI code)
- **Tools**: Stryker.NET (C#), Stryker (TypeScript)
- **Target**: >= 70% mutation score for critical logic
- **When to use**: Phase 4 verification for Level A/B features

### Snapshot/Visual Tests

- **Purpose**: Verify UI rendering matches expected output
- **Scope**: React components, visual layouts
- **Location**: Storybook stories with play functions
- **Tools**: Storybook + Playwright
- **When to use**: Level B UI portions, Level C features

### E2E Tests

- **Purpose**: Test complete user workflows across all processes
- **Status**: NOT IMPLEMENTED - identified gap in paranext-core
- **Tools**: Playwright (when implemented)
- **When to use**: Critical user journeys (future consideration)

---

## 4. Quality Gates

| Gate   | Criteria                              | Phase | Applies To       | Blocking   | Proof Evidence Required                                 |
| ------ | ------------------------------------- | ----- | ---------------- | ---------- | ------------------------------------------------------- |
| G0     | Task description approved             | 0     | All              | Yes        | task-description.md created and PO/Stakeholder approved |
| G1     | Characterization tests complete       | 1     | All              | Yes        | test-scenarios.json exists                              |
| G1.5   | **Scope Validation**                  | 1     | All              | Yes        | PO/Stakeholder approves GitHub issue                    |
| G2     | API contract approved                 | 2     | All              | Yes        | Human sign-off on data-contracts.md                     |
| G3     | Logic extraction complete             | 2     | Level B          | Yes        | ui-logic-extraction.md complete                         |
| G3.5   | **Specification Approval**            | 2     | All              | Yes        | PR approved in ai-prompts repo                          |
| G4     | TDD tests written (failing)           | 3     | Level A, B logic | Yes        | `test-evidence-red.log` showing RED state               |
| G4.5   | Test quality verified                 | 3     | Level A, B logic | Yes        | Quality checklist in evidence + no anti-patterns        |
| G5     | TDD tests passing                     | 3     | Level A, B logic | Yes        | `test-evidence-green.log` + `visual-evidence/*.png`     |
| G4-alt | Snapshot tests created                | 3     | Level B UI, C    | Yes        | Snapshot files committed                                |
| G5-alt | Visual match to golden masters        | 3     | Level B UI, C    | Yes        | Side-by-side screenshots in `visual-evidence/`          |
| G6     | Golden master tests pass              | 4     | All              | Yes        | `test-evidence-equivalence.log`                         |
| G7     | Property tests pass                   | 4     | All              | Yes        | `test-evidence-invariants.log` with iteration counts    |
| G8     | Integration tests pass                | 4     | All              | Yes        | `test-evidence-final.log`                               |
| G9     | Mutation score ≥ 70% (critical paths) | 4     | Level A, B logic | Advisory\* | Stryker report in evidence                              |
| G10    | **Implementation Approval**           | 4     | All              | Yes        | PR approved in paranext-core repo                       |

\*G9 starts advisory for first 2-3 features to establish baselines, then becomes blocking.

### New Approval Gates

**G0 - Task Description Gate (Phase 0):**

- Developer creates task-description.md defining scope, goals, and non-goals
- PO/Stakeholder reviews and approves the task description
- Ensures alignment on what will be ported before discovery begins
- Approval required before Phase 1 can start

**G1.5 - Scope Validation Gate (after Phase 1):**

- PO/Stakeholder reviews the GitHub issue created after discovery
- Validates the behavior catalog, classification, and logic distribution
- Ensures the team understands the feature correctly before investing in detailed specifications
- Approval required before proceeding to Phase 2

**G3.5 - Specification Approval Gate (after Phase 2):**

- Pull Request from `feature/{feature-name}` → `main` in ai-prompts repository
- Reviewers validate test scenarios, specifications, and API contracts
- Ensures specifications are complete and correct before implementation begins
- PR must be approved and merged before proceeding to Phase 3

**G10 - Implementation Approval Gate (after Phase 4):**

- Pull Request from `feature/{feature-name}` → `main` in paranext-core repository
- Includes all tests, implementation code, and verification reports
- PR description links to ai-prompts artifacts for context
- Final human review before code is merged to main

### Gate Verification

The Validator agent verifies that proof evidence exists for each applicable gate. A gate cannot be marked as passed without its corresponding proof artifact.

### Gate G4.5: Test Quality Verification

**Purpose:** Prevent low-quality AI-generated tests from proceeding to implementation.

**Verification Criteria:**

- All tests pass The Revert Test (fail without implementation)
- No implementation-mirroring assertions (tests use known values, not computed expected)
- Mock count ≤3 per test (or exception documented and justified)
- All tests are deterministic (time, random, network controlled)
- No trivial tests (simple accessors, constructor assignments)
- Quality Report present in test-writer-plan.md

**Blocking:** Implementation CANNOT begin until G4.5 passes.

See [AI Agent Test Quality Guardrails](standards/Testing-Guide.md#ai-agent-test-quality-guardrails) for details.

---

## 5. Test Quality and Traceability

### Rationale

In AI-assisted development, agents write code faster than humans can review. Comprehensive testing ensures:

- Bugs are caught early before they compound
- Code changes can be made with confidence
- Structural refactoring is safe
- Tests run constantly during development

### Test Quality Verification

For Level A and B features, verify test effectiveness:

| Metric          | Threshold | Timing                      | Status             |
| --------------- | --------- | --------------------------- | ------------------ |
| Line coverage   | >= 90%    | End of Phase 3 (Refactorer) | Blocking           |
| Branch coverage | >= 80%    | End of Phase 3 (Refactorer) | Blocking           |
| Mutation score  | >= 70%    | Phase 4 (Validator)         | Advisory initially |

**Mutation testing graduation**: G9 starts advisory for first 2-3 features to establish baselines, then becomes blocking at 70% threshold.

**Tools**:

- TypeScript: Stryker (`npx stryker run`)
- C#: Stryker.NET (`dotnet stryker`)

### Traceability Requirements

Every test must trace to a specification:

| ID Type | Format           | Source              | Purpose                 |
| ------- | ---------------- | ------------------- | ----------------------- |
| BHV-XXX | Behavior ID      | behavior-catalog.md | What the system does    |
| TS-XXX  | Test Scenario ID | test-scenarios.json | How to test a behavior  |
| INV-XXX | Invariant ID     | business-rules.md   | Property that must hold |

**Validation**: The Traceability Validator agent (Phase 3, after Test Writer) ensures:

- Every BHV-XXX has at least one TS-XXX
- Every TS-XXX has at least one test
- Every test references a valid scenario ID

**Test Attribute Examples**:

```csharp
// C# - Use [Property] attributes for traceability
[Test]
[Category("Contract")]
[Property("ScenarioId", "TS-001")]
[Property("BehaviorId", "BHV-001")]
public void CreateProject_WithValidSettings_ReturnsSuccess() { }
```

```typescript
// TypeScript - Use JSDoc comments
/**
 * @scenario TS-001
 * @behavior BHV-001
 */
test('CreateProject with valid settings returns success', () => {});
```

### AI-Generated Test Quality Standards

AI agents can generate many tests quickly, but quantity ≠ quality. Apply these standards:

**Prohibited Patterns:**

| Pattern                  | Problem                     | Detection                               |
| ------------------------ | --------------------------- | --------------------------------------- |
| Implementation-mirroring | Test duplicates code logic  | Expected value is computed, not literal |
| Over-mocking             | Hides integration issues    | >3 mocks per test                       |
| Trivial tests            | Zero defect-detection value | Tests simple accessors/constructors     |
| Non-deterministic        | Flaky tests                 | Uses real time/random/network           |

**Mocking Hierarchy:**

| Level | What to Mock                        | Notes                       |
| ----- | ----------------------------------- | --------------------------- |
| 0     | **Never**: ParatextData.dll         | It's the shared oracle      |
| 1     | Rarely: Business logic modules      | Use real code when possible |
| 2     | Sometimes: Cross-feature services   | For isolation in unit tests |
| 3     | Usually: External APIs, file system | Control side effects        |
| 4     | Always: Time, random, network       | Ensure determinism          |

**Test Curation Protocol:**

Before accepting tests, verify:

1. **Volume check**: ~3-5 tests per public method (not 15+)
2. **Value check**: Each test catches a potential defect
3. **Uniqueness check**: No duplicate coverage
4. **Brittleness check**: Tests only fail when behavior changes

### Continuous Testing During Agent Work

Agents should run tests constantly, not just at phase checkpoints:

| Agent                 | Testing Requirement                                                          |
| --------------------- | ---------------------------------------------------------------------------- |
| **TDD Implementer**   | Run feature tests after each change                                          |
| **TDD Refactorer**    | Run full suite before/after each refactoring; zero tolerance for regressions |
| **Component Builder** | Run snapshot tests after visual changes                                      |

**Test Categories for Fast Feedback** (applies to NEW ported features):

| Category    | When to Run     | Time Target |
| ----------- | --------------- | ----------- |
| Smoke       | After each edit | < 10s       |
| Critical    | Every 5 edits   | < 60s       |
| Full        | Before handoff  | < 5min      |
| Integration | CI only         | No limit    |

_Note: Test categories apply to new ported features. Existing test categorization will be addressed separately._

### Phase 3 Flow

For Level A and B features, Phase 3 includes traceability validation:

```
Alignment → Test Writer → Traceability Validator → Implementer → Refactorer
                                  ↑
                         Validates scenario→test coverage
                         before implementation begins
```

The Traceability Validator blocks implementation if:

- Any BHV-XXX lacks test coverage
- Any test lacks a scenario reference
- Orphan tests exist (except Infrastructure category)

---

## 6. Proof of Work Requirements

### The Fundamental Contract

**Each agent's job is to deliver code they have proven to work.**

This is not the same as "code that has been tested." Testing is an activity; proof is a deliverable. Every AI agent in this workflow must provide verifiable evidence that their work is correct before handoff.

### What Constitutes Proof

Proof requires TWO complementary steps - neither is optional:

| Step                       | Definition                                | Evidence Required                                           |
| -------------------------- | ----------------------------------------- | ----------------------------------------------------------- |
| **Manual Verification**    | See the code do the right thing yourself  | Screenshots, console output, live demonstration             |
| **Automated Verification** | Bundled tests that prove the change works | Tests that PASS when code is correct and FAIL when reverted |

### The Revert Test

If you revert the implementation and the tests still pass, you have not proven anything. The proof must be falsifiable - the tests must detect when the implementation is wrong.

### Human Accountability

The human provides the accountability. AI agents provide the proof; humans provide the judgment.

- **Agents demonstrate**, humans verify
- **Agents document**, humans approve
- **Agents propose**, humans decide

No agent may self-certify completion. Every phase ends with human review of proof artifacts.

### Proof vs. Testing: The Critical Distinction

| "I tested it"        | "I proved it"                                                    |
| -------------------- | ---------------------------------------------------------------- |
| I ran the test suite | I watched the tests fail, implemented the fix, watched them pass |
| Tests are green      | I can show you the before/after output                           |
| The build passes     | I visually confirmed the UI matches the golden master            |
| No errors in console | I recorded what correct behavior looks like                      |

### The Proof Burden

Every agent deliverable must answer this question:

> "What evidence can the human reviewer examine to verify this work is correct?"

If you cannot point to specific, examinable evidence, you have not finished.

### Required Evidence by Agent

All agents must produce proof artifacts in `.context/features/{feature}/proofs/`:

| Agent               | Evidence File                   | Content                                     |
| ------------------- | ------------------------------- | ------------------------------------------- |
| TDD Test Writer     | `test-evidence-red.log`         | Tests compile + FAIL (RED state)            |
| TDD Implementer     | `test-evidence-green.log`       | Tests PASS with counts (GREEN state)        |
| TDD Implementer     | `visual-evidence/*.png`         | Screenshots showing feature works in app    |
| TDD Refactorer      | `test-evidence-refactor.log`    | Tests still PASS after cleanup              |
| Component Builder   | `visual-evidence/*.png`         | Screenshots + console output                |
| Equivalence Checker | `test-evidence-equivalence.log` | Golden master test results                  |
| Invariant Checker   | `test-evidence-invariants.log`  | Property test results with iteration counts |
| Validator           | `test-evidence-final.log`       | Full test suite results                     |

**Visual Evidence Required for ALL Features**: Even Level A (backend-heavy) features must include screenshots demonstrating the feature works in the running application. Use the `app-runner` and `chrome-browser` skills.

### Cross-Agent Verification

Each agent must verify the previous agent's proof before starting work:

| Current Agent   | Must Verify                                             |
| --------------- | ------------------------------------------------------- |
| TDD Implementer | Test Writer's tests actually fail (RED state confirmed) |
| TDD Refactorer  | Implementer's tests pass (GREEN state confirmed)        |
| Validator       | All evidence files exist and match claims               |

### Evidence File Format

Evidence files use a simple, human-readable format:

```
=== TEST EVIDENCE ===
Timestamp: 2025-01-03T14:30:00Z
Agent: tdd-implementer
Phase: GREEN (tests should PASS)
Command: dotnet test --filter "CreateProject"

--- OUTPUT START ---
[full test output here]
--- OUTPUT END ---

Summary: 15 passed, 0 failed
```

### Audit Trail for Agent Actions

Claude Code hooks automatically log all tool calls to `.context/audit-logs/sessions/`. This provides an audit trail for verifying agent exploration coverage.

**Log Format:**

```
TIMESTAMP|SESSION_ID|EVENT|AGENT|TOOL|INPUT_SUMMARY
```

**What's Tracked:**

| Tool       | Logged Details                    |
| ---------- | --------------------------------- |
| Read       | File path, full/partial indicator |
| Glob       | Pattern, search path              |
| Grep       | Search pattern, path              |
| Task       | Subagent type, prompt summary     |
| Bash       | Command executed                  |
| Edit/Write | File path modified                |

**Reviewing Phase 1 Coverage:**

After `/porting/phase-1-analysis {feature}`, verify the archaeologist explored comprehensively:

```bash
# Files read by archaeologist
grep "|archaeologist|Read|" .context/audit-logs/sessions/*.log

# Search patterns used
grep "|archaeologist|Glob\|Grep|" .context/audit-logs/sessions/*.log
```

**When to Commit Audit Logs:**

- Commit important trails as documentation (e.g., Phase 1 analysis of critical features)
- Leave routine session logs uncommitted

Scripts: `.claude/scripts/audit-*.sh`

---

## 7. Verification Strategy (Golden Masters + Documentation)

### Why No Oracle MCP Server

ParatextData.dll is **already available in PT10 via NuGet**. The AI agent can directly test against it:

```csharp
// In paranext-core/c-sharp/ - ParatextData is already here
var merger = new BookFileMerger();
var result = merger.Merge(mine, theirs, parent);
```

An Oracle would only be valuable for UI-layer code (`Paratext/`, `ParatextBase/`) that ISN'T in ParatextData. For that, we use **golden masters + thorough documentation** instead.

### Verification by Feature Level

| Level                      | Code Location                 | Strategy                                                |
| -------------------------- | ----------------------------- | ------------------------------------------------------- |
| **A** (ParatextData-heavy) | `ParatextData/`               | Test directly in PT10 against ParatextData.dll          |
| **B** (Mixed)              | `ParatextData/` + `Paratext/` | ParatextData direct tests + golden masters for UI logic |
| **C** (Pure UI)            | `Paratext/`                   | Golden masters + comprehensive behavior docs            |

### Golden Master Workflow

1. **Generate in PT9**: Run old code, serialize outputs
2. **Store in `.context/`**: Save as JSON/XML with input specs
3. **Port to PT10**: Copy golden masters to test projects
4. **Test against**: New implementation must match golden output

### When to Use Each Approach

| Scenario                     | Approach                          |
| ---------------------------- | --------------------------------- |
| ParatextData method behavior | Direct test in PT10               |
| UI data transformation       | Golden master                     |
| Complex algorithm            | Golden master + property tests    |
| Edge cases discovery         | Behavior catalog + manual testing |
| Regression prevention        | Golden masters in CI              |

### Golden Master Strategy by Level

The purpose of golden masters varies significantly by feature classification level:

| Level | Golden Master Purpose        | Captured PT9 Outputs? | Rationale                                                                                              |
| ----- | ---------------------------- | --------------------- | ------------------------------------------------------------------------------------------------------ |
| **A** | TDD test specifications      | No                    | ParatextData.dll IS the oracle - same binary in PT9 and PT10. Test directly against ParatextData APIs. |
| **B** | Specs for extracted UI logic | UI-layer only         | ParatextData logic tested directly. Golden masters needed only for UI-layer transformations and state. |
| **C** | Visual/behavioral reference  | Yes                   | UI rendering, state transitions, and visual behavior must be captured since no shared code exists.     |

**Key Insight for Level A Features**: Since ParatextData.dll is shared between PT9 and PT10 via NuGet, it serves as its own oracle. Capturing PT9 outputs would be redundant - they would just reflect what ParatextData returns, which PT10 can call directly. Instead, golden masters for Level A features document **test specifications** (inputs and expected behaviors) rather than captured outputs.

**For Level B Features**: Only capture golden masters for the UI-embedded logic being extracted. The ParatextData portions are tested directly. Focus golden master efforts on:

- UI data transformations
- State transitions in UI code
- Display formatting logic
- User interaction flows

**For Level C Features**: Comprehensive golden masters are essential since most logic lives in the UI layer. Capture:

- All data transformation outputs
- Visual rendering states
- User input processing results
- Error message formatting

---

## 8. Artifacts Structure

### Directory Structure

```
.context/features/{feature}/
├── task-description.md          # Human-defined scope and requirements (before agents start)
├── README.md                    # CANONICAL SOURCE: classification, scope, strategy (single source of truth)
├── behavior-catalog.md          # All behaviors: entry points, triggers, inputs/outputs, UI/UX details
├── business-rules.md            # Invariants, validations, preconditions, state transitions
├── boundary-map.md              # ParatextData vs UI split, reuse estimate, settings, integrations
├── logic-distribution.md        # WHERE logic lives: ParatextData vs UI (Phase 1 - Logic Locator)
├── data-contracts.md            # TypeScript/C# types with {TBD:*} placeholders (Phase 2)
├── phase-status.md              # Progress tracking (dates/status only, links to README for details)
├── github-issue.md              # PO/Stakeholder summary + GitHub issue body (links to README, not duplicating)
│
├── decisions/                   # Feature-specific architectural decisions (per phase)
│   ├── phase-1-decisions.md     # Discovery phase decisions
│   ├── phase-2-decisions.md     # Specification phase decisions
│   ├── phase-3-decisions.md     # Implementation phase decisions
│   └── phase-4-decisions.md     # Verification phase decisions
│
├── test-specifications/         # Level A/B: Structured test specs with assertions (Phase 2)
│   ├── spec-001-{name}.json     # Assertions against ParatextData APIs
│   └── ...
│
├── golden-masters/              # Level B/C: Captured PT9 outputs (Phase 2)
│   ├── CAPTURE-CHECKLIST.md     # Guide for manual PT9 captures
│   ├── gm-001-{name}/
│   │   ├── input.json
│   │   ├── expected-output.json
│   │   └── metadata.json
│   └── ...
│
├── characterization/            # Phase 2 test scenario artifacts
│   ├── test-scenarios.json      # Structured test cases with inputs, expected outputs, logicLayer tags
│   ├── requirements.md          # Non-functional: performance, accessibility, localization, errors
│   └── edge-cases.md            # Unusual scenarios with risk assessment and test coverage
│
├── proofs/                      # Phase 3-4 proof artifacts (see Section 0)
│   ├── test-evidence-red.log    # TDD Test Writer: tests compile + FAIL
│   ├── test-evidence-green.log  # TDD Implementer: tests PASS
│   ├── test-evidence-refactor.log # TDD Refactorer: tests still PASS
│   ├── test-evidence-equivalence.log # Equivalence Checker: golden master results
│   ├── test-evidence-invariants.log  # Invariant Checker: property test results
│   ├── test-evidence-final.log  # Validator: full test suite results
│   └── visual-evidence/         # Screenshots demonstrating feature works
│       ├── {feature}-initial.png
│       ├── {feature}-action.png
│       └── {feature}-result.png
│
└── implementation/              # Phase 2-3 implementation artifacts
    ├── extraction-plan.md       # Level B only: function signatures and contracts (Phase 2 - Spec Generator)
    ├── pt10-alignment.md        # PT10 patterns: namespace, file paths, test infrastructure (Phase 3 Step 0)
    ├── alignment-decisions.md   # PT10 pattern decisions and rationale (Phase 3 Step 0)
    ├── implementation-plan.md   # Approved plan before coding begins (Phase 3 Step 1)
    └── quality-gates.md         # Checklist of G1-G10 gates for this feature
```

### Artifact Templates

Each feature folder includes standardized templates for:

- **task-description.md**: Human-defined scope, goals, non-goals, and constraints (created before Phase 1, template in `.context/features/task-description-template.md`)
- **behavior-catalog.md**: Exhaustive list of behaviors with source references (created by Archaeologist)
- **logic-distribution.md**: Where logic lives - ParatextData vs UI (created by Logic Locator)
- **business-rules.md**: Invariants suitable for property-based tests (created by Archaeologist)
- **data-contracts.md**: TypeScript/C# types for API boundaries (created by Contract Writer)

---

## 9. Implementation Sequence

### Recommended Order

1. **Creating Projects** (Level A) - Foundational, low risk
2. **USB Syncing** (Level A) - Similar pattern
3. **Translation Resources** (Level B/C) - DBL infrastructure exists
4. **Parallel Passages** (Level B) - Well-defined data model
5. **Checklists** (Level C) - Highest UI effort
6. **S/R Conflict Resolution** (Level B) - Most complex logic

### Per-Feature Workflow

```
Phase 1: Analysis
├── /porting/phase-1-analysis {name}
└── Review & approve behavior catalog

Phase 2: Specification
├── /porting/phase-2-specification {name}
└── PO/Stakeholder review of contracts

Phase 3: Implementation
├── /porting/phase-3-implementation {name}
└── Tests passing (TDD or snapshot based on level)

Phase 4: Verification
├── /porting/phase-4-verification {name}
├── All quality gates pass
├── Human review
└── Merge to main
```

---

## 10. Critical Files Reference

### For Test Infrastructure

- `ParatextData.Tests/DummyScrTextTestBase.cs` - Base test class pattern
- `ParatextData.Tests/DummyScrText.cs` - In-memory ScrText fixture
- `ParatextData.Tests/TempScrText.cs` - Zip-based test projects

### For Feature Logic

- `ParatextData/Repository/Mergers/BookFileMerger.cs` - S/R merge logic
- `Paratext/Checklists/CLDataSource.cs` - Checklist data extraction
- `ParatextData/ParallelPassages/ParallelPassageStatus.cs` - Status persistence
- `ParatextData/Repository/FileSharedRepositorySource.cs` - USB sync

### For Golden Master Patterns

- `Paratext.Tests/Checklists/CLDataSourceTests.cs` - XML serialization with normalization
- `ParatextData.Tests/StudyBibleTests/RegressionTests/` - Existing golden master pattern

---

## 11. Codebase Context

**Critical**: Agents run in different codebases depending on the phase:

| Phase                   | Codebase                 | Access                          |
| ----------------------- | ------------------------ | ------------------------------- |
| Phase 1: Analysis       | **PT9** (Paratext)       | Full access to PT9 source code  |
| Phase 2: Specification  | **PT9** (Paratext)       | Full access to PT9 source code  |
| Phase 3: Implementation | **PT10** (paranext-core) | Full access to PT10 source code |
| Phase 4: Verification   | **PT10** (paranext-core) | Full access to PT10 source code |

**Implications**:

- Phase 1-2 agents CANNOT explore paranext-core patterns (no access to `c-sharp/`, `extensions/src/`)
- Phase 2 contracts use `{TBD:*}` placeholders for PT10-specific values
- The Alignment Agent (Phase 3 Step 0) is the first point with PT10 access
- The Alignment Agent fills all `{TBD:*}` placeholders with actual PT10 patterns

---

## 12. Branch Strategy

### ai-prompts Repository

- **Main branch**: Approved specifications and completed feature artifacts
- **Feature branches**: `feature/{feature-name}`
  - Created at start of Phase 1 (Discovery)
  - Prerequisite: Developer has created `.context/features/{feature}/task-description.md` on main
  - Used through Phases 1-2 for discovery and specification artifacts
  - PR to main after Phase 2 (Specification Approval Gate - G3.5)
  - Recreated/continued in Phases 3-4 for implementation artifacts (proofs, plans)

### paranext-core Repository

- **Main branch**: Production code
- **Feature branches**: `feature/{feature-name}`
  - Created in Phase 3 (Implementation)
  - Contains tests and implementation code
  - PR to main after Phase 4 (Implementation Approval Gate - G10)

### Commit Discipline

Agents MUST commit their work after completing each step:

| Phase | Agent/Step           | Commit Required                   |
| ----- | -------------------- | --------------------------------- |
| 1     | Archaeologist        | After behavior catalog complete   |
| 1     | Logic Locator        | After logic distribution complete |
| 1     | Classifier           | After classification complete     |
| 2     | Test Scenario Writer | After test scenarios complete     |
| 2     | Spec Generator       | After specifications complete     |
| 2     | Contract Writer      | After contracts complete          |
| 3     | Alignment Agent      | After PT10 alignment complete     |
| 3     | Strategic Plan       | After capability decomposition    |
| 3     | Test Writer          | After tests written (RED)         |
| 3     | Implementer          | After implementation (GREEN)      |
| 3     | Refactorer           | After refactoring complete        |
| 3     | Component Builder    | After each visual iteration       |
| 4     | Equivalence Checker  | After equivalence report          |
| 4     | Invariant Checker    | After invariant report            |
| 4     | Validator            | After validation report           |

### GitHub Issue Lifecycle

1. **Created in Phase 1** (after Classifier completes):

   - Contains discovery findings: behavior catalog summary, classification, logic distribution
   - Used for Scope Validation Gate (G1.5) review
   - Links to detailed artifacts in the feature branch

2. **Updated in Phase 2** (after Contract Writer completes):

   - Adds specification details: test scenarios summary, contracts, golden master references
   - Links to PR for Specification Approval Gate (G3.5)

3. **Updated in Phase 4** (after Validator completes):
   - Adds verification results and implementation PR link
   - Closed when Implementation Approval Gate (G10) PR is merged

---

## 13. Decisions Made

1. **Hybrid Dual-Track approach**: Features are classified by complexity (A/B/C), allowing parallel characterization and TDD work while tailoring testing strategy to each feature's ParatextData reuse percentage
2. **Implementation strategy by level**: TDD for Level A and extracted logic; Component-First for Level B UI and Level C features where visual verification is more effective than test-first
3. **Verification approach**: Golden Masters + Documentation (no Oracle MCP so agents can talk with Paratext 9 application - ParatextData already available in PT10 via NuGet)
4. **Artifact storage**: `.context/` and `.claude/` folders and `CLAUDE.md` files will live in separate git repo
5. **Agent orchestration**: Manual Claude commands that trigger specialized subagents with human review gates
6. **Mutation testing**: Critical paths only (merge logic, conflict resolution, data persistence)
7. **PT10 Alignment step**: Phase 1 & 2 artifacts use abstract naming with `{TBD:*}` placeholders. The Alignment Agent (Phase 3 Step 0) maps these to paranext-core-specific patterns by exploring the PT10 codebase. It creates `implementation/pt10-alignment.md` with concrete namespaces, file paths, and test infrastructure. Reference patterns are documented in `.context/standards/paranext-core-patterns.md`.
8. **Specification strategy by level**: For Level A features, create structured test specifications in `test-specifications/` (ParatextData.dll is the oracle). For Level B/C, create golden masters in `golden-masters/` capturing UI-layer behavior.
9. **Single source of truth**: README.md is the canonical source for feature classification, scope, and strategy. Other artifacts (github-issue.md, phase-status.md) link to README sections rather than duplicating content. The github-issue.md file serves as both the PO/Stakeholder summary AND the GitHub issue body - we eliminated spec-summary.md to reduce duplication pressure.
10. **Test quality graduation**: G9 (mutation testing) starts advisory to establish baselines, then becomes blocking after 2-3 features.
11. **Traceability validation**: Every test must trace to a specification ID (BHV-XXX, TS-XXX, INV-XXX).
12. **Proof of work artifacts**: Agents must capture test output and screenshots as proof their code works (see Section 6). Evidence files use a simple human-readable format stored in `proofs/`. Each agent verifies the previous agent's proof before starting. Visual evidence (screenshots) is required for ALL features, including backend-heavy Level A features. The Validator agent verifies all evidence files exist before approving G10.
13. **Testing Trophy model**: Adopt Testing Trophy/Honeycomb for AI-assisted development - favor integration tests at service boundaries over excessive unit tests. This enables fearless refactoring.
14. **Quality Gate G4.5**: New blocking gate between G4 (tests written) and G5 (tests passing) verifies test quality before implementation. Prevents low-quality AI-generated tests from proceeding.
15. **Coverage threshold recommendations**: 70% line coverage, 60% branch coverage (documented as recommendations; actual config changes are separate).
16. **The Revert Test**: Mandatory verification that tests fail without implementation. Tests that pass without implementation are worthless.
17. **Audit trail hooks**: Claude Code hooks log all tool calls to `.context/audit-logs/` for verifying agent exploration coverage. Logs track file reads (full/partial), search patterns, and subagent transitions. Important trails can be committed as documentation.
18. **Outside-In TDD for AI constraints**: Phase 3 uses Outside-In TDD (London School) where each capability has an outer acceptance test from Phase 2 specs. This constrains AI agents - the outer test acts as a "fence" preventing deviation from PT9 behavior. When the outer test passes, the capability is complete.
19. **Capability-based work units**: Features are decomposed into fine-grained capabilities (one per API method or UI component). Each capability has its own strategy (TDD or Component-First) based on its nature. Level defaults apply (A→TDD, C→Component-First) with per-capability overrides allowed.
20. **Component-First acceptance**: For Component-First capabilities, visual verification against golden master screenshots IS the acceptance test. No redundant programmatic tests needed. Snapshot/interaction tests are added AFTER visual matching is confirmed.
21. **Three approval gates**: G1.5 (Scope Validation) after Phase 1 for PO/Stakeholder to approve discovery before specification; G3.5 (Specification Approval) after Phase 2 via PR in ai-prompts repo; G10 (Implementation Approval) after Phase 4 via PR in paranext-core repo. These gates ensure human oversight at key workflow transitions.
22. **Branch strategy**: Feature branches `feature/{feature-name}` in ai-prompts (Phases 1-4 artifacts) and paranext-core (Phase 3-4 code). PRs gate the transitions: ai-prompts PR after Phase 2, paranext-core PR after Phase 4.
23. **Commit discipline**: Agents MUST commit after completing each step to enable incremental review and provide clear audit trail. This applies to all phases and all agents.
24. **GitHub issue lifecycle**: Issue created in Phase 1 (discovery findings), updated in Phase 2 (specification details), updated and closed in Phase 4 (verification results). Single issue tracks the entire feature migration.
