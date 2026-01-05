# Phase 3: Implementation

Implement feature in PT10: **$ARGUMENTS**

## Overview

This phase implements the feature in PT10. The implementation strategy depends on the feature's classification level:

| Level | Strategy | Path |
|-------|----------|------|
| **A** | Full TDD | TDD Test Writer → Implementer → Refactorer |
| **B** | Hybrid | TDD for extracted logic + Component Builder for UI |
| **C** | Component-First | Component Builder → Snapshot Tests |

## Context

Before proceeding, read `.context/AI-Porting-Workflow.md` for overall workflow context, quality gates, and how this phase fits into the 4-phase process.

## Prerequisites

- [ ] Phase 2 complete
- [ ] `task-description.md` exists (original scope)
- [ ] `data-contracts.md` approved (G2)
- [ ] `golden-masters/` created
- [ ] Feature classification known (check `README.md`)
- [ ] Working in PT10 codebase (paranext-core)

---

## Step 0: PT10 Alignment

Before implementation planning, run the Alignment Agent to map abstract Phase 2 contracts to paranext-core-specific patterns.

### Why This Step

Phase 1 & 2 artifacts use PT9 naming conventions. The Alignment Agent explores paranext-core to discover the correct:
- C# namespaces and file locations
- TypeScript command naming and extension placement
- Test infrastructure patterns (base classes, mocks)

### Run Alignment Agent

**Running alignment-agent...**

[Delegate to alignment-agent subagent with:
- Feature name: {feature}
- Feature directory: `.context/features/{feature}/`
- Required reading: README.md, data-contracts.md, boundary-map.md, `.context/standards/paranext-core-patterns.md`]

### Output Artifacts

The agent will update:
- `data-contracts.md` - Fill in "PT10 Implementation Alignment" section
- `README.md` - Fill in "PT10 Integration Notes" section
- `implementation/alignment-decisions.md` - Document rationale

### Review Checkpoint

Please review the alignment:
- [ ] **Namespaces correct** - Follow `Paranext.DataProvider.{Area}` pattern?
- [ ] **Command names correct** - Follow `'{extensionName}.{commandName}'` pattern?
- [ ] **File locations valid** - Match existing directory structure?
- [ ] **Test patterns identified** - Base class and mocks specified?
- [ ] **Extension placement** - Appropriate extension identified?

**Approve alignment and proceed to implementation planning?** (yes / no / revise)

⚠️ **Do not proceed to implementation planning until alignment is approved.**

---

## Step 1: Strategic Planning (Orchestrator Step)

> **Note**: This step is performed by the Phase 3 orchestrator, NOT delegated to a subagent.
> The strategic plan must be created and approved BEFORE any TDD or Component Builder agents run.

After alignment is complete, create a strategic plan that will guide all subagents.

### Why the Orchestrator Creates This

1. The orchestrator has full context from Phase 1 & 2 artifacts
2. Strategic decisions affect ALL subsequent subagents
3. Subagents need a stable plan to reference - they shouldn't modify it
4. Human approval happens once here, not repeatedly per-agent

### Review Phase 1 & 2 Artifacts

Read and analyze all artifacts from `.context/features/{feature}/`:

- [ ] `task-description.md` - Original scope, goals, non-goals, constraints
- [ ] `README.md` - Feature classification (Level A/B/C) and implementation strategy
- [ ] `behavior-catalog.md` - All behaviors to implement (incl. user stories, UI/UX)
- [ ] `boundary-map.md` - ParatextData vs UI split (incl. settings, integrations)
- [ ] `business-rules.md` - Invariants and constraints
- [ ] `data-contracts.md` - API signatures and types
- [ ] `golden-masters/` - Reference outputs to match
- [ ] `characterization/test-scenarios.json` - Test cases to cover
- [ ] `characterization/requirements.md` - Non-functional requirements, error messages, accessibility
- [ ] `implementation/ui-logic-extraction.md` - Logic to extract (Level B only)
- [ ] `implementation/pt10-alignment.md` - PT10 patterns from Alignment Agent (namespaces, file paths, test infrastructure)

### Create Strategic Plan (Orchestrator Action)

The Phase 3 orchestrator writes the strategic plan to `.context/features/{feature}/implementation/strategic-plan.md`.

This is NOT delegated to a subagent. The orchestrator:
1. Reads all Phase 1 & 2 artifacts (listed above)
2. Creates the strategic plan based on the template below
3. Presents it for human approval
4. Only then proceeds to spawn subagents

**Template:**

```markdown
# Strategic Plan: {Feature}

## Classification & Strategy
- **Level**: {A / B / C}
- **Path**: {TDD / Hybrid / Component-First}
- **Date**: {date}

## Implementation Units

Break down the feature into logical units. Each unit will be assigned to subagents.

### Unit 1: {Name}
- **Path**: TDD / Component-First
- **Contracts**: {list from data-contracts.md}
- **Golden Masters**: {list from golden-masters/}
- **Location**: {target directory in paranext-core}
- **Dependencies**: None / {list of prerequisite units}
- **Success Criteria**: {specific measurable outcome}

### Unit 2: {Name}
...

## Implementation Order

Based on dependencies:
1. **{Unit}** - {why first}
2. **{Unit}** - {depends on #1}
...

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| {description} | High/Med/Low | {approach} |

## Subagent Assignments

| Unit | Subagent | Contracts Assigned | Golden Masters Assigned |
|------|----------|-------------------|------------------------|
| {unit} | Test Writer | {list} | {list} |
| {unit} | Implementer | {list} | {list} |
| {unit} | Component Builder | {list} | {list} |
```

### Review Checkpoint

Please review the strategic plan:
- [ ] **Units correctly identified** - Logical breakdown of work?
- [ ] **Order respects dependencies** - Can build in this sequence?
- [ ] **Strategy matches classification** - TDD for Level A, Hybrid for B, Component-First for C?
- [ ] **Risks addressed** - Major unknowns have mitigations?
- [ ] **Subagent assignments clear** - Each agent knows its scope?

**Approve this strategic plan?** (yes / no / revise)

⚠️ **Do not proceed to subagents until strategic plan is approved.**

---

## Step 2: Determine Implementation Strategy

Check the feature's classification in `.context/features/{feature}/README.md`:

| If Classification | Then Use |
|-------------------|----------|
| Level A | **Path A: Full TDD** (below) |
| Level B | **Path B: Hybrid** - TDD for logic, then Component Builder for UI |
| Level C | **Path C: Component-First** (skip to Component Builder section) |

---

# Path A: Full TDD (Level A Features)

Use this path for ParatextData-heavy features with clear APIs.

## Subagents in TDD Path

| # | Agent | Purpose | TDD Phase | Output |
|---|-------|---------|-----------|--------|
| 1 | **TDD Test Writer** | Write failing tests | RED | Test files |
| 2 | **TDD Implementer** | Minimal code to pass | GREEN | Implementation |
| 3 | **TDD Refactorer** | Clean up code | REFACTOR | Improved code |

## TDD Subagents in Order

For Level A and B features, the TDD path now includes a Traceability Validator:

```
Test Writer → Traceability Validator → Implementer → Refactorer
                      ↑
             Validates all scenarios have tests
             before implementation begins
```

---

## TDD Subagent 1: Test Writer (RED)

**Mission**: Write tests that define expected behavior. Tests will FAIL initially.

**Running tdd-test-writer agent...**

[Delegate to tdd-test-writer subagent with:
- Feature name: {feature}
- Feature directory: `.context/features/{feature}/`
- Strategic plan: `implementation/strategic-plan.md`
- PT10 alignment: `implementation/pt10-alignment.md`
- Assigned unit(s): {unit names from strategic plan}
- Assigned contracts: {contracts for this agent from strategic plan}
- Assigned golden masters: {golden masters for this agent from strategic plan}
- Output plan to: `implementation/test-writer-plan.md`
- Required: Create plan file and present for approval before executing]

> **Note**: The Test Writer agent will first create its tactical plan for human approval, then execute and commit its test files. Check the agent's output for the commit hash.

### Output Artifacts

```
paranext-core/
├── c-sharp-tests/
│   └── {Feature}Tests/
│       ├── {Feature}DataProviderTests.cs
│       ├── {Feature}GoldenMasterTests.cs
│       └── {Feature}PropertyTests.cs
└── extensions/
    └── src/{ext}/tests/
        └── {feature}.test.ts
```

### Verification

```bash
# Tests should compile but FAIL
dotnet test c-sharp-tests/{Feature}Tests/
# Expected: All tests fail (no implementation yet)
```

### Review Checkpoint

Please review the tests:
- [ ] **Contract coverage** - All methods have tests?
- [ ] **Golden master tests** - All scenarios covered?
- [ ] **Property tests** - Invariants tested?
- [ ] **Tests fail** - Confirmed RED state?

**Ready to proceed to Traceability Validator?** (yes / no / need edits)

---

## TDD Subagent 1.5: Traceability Validator

**Mission**: Validate that all test scenarios have corresponding tests before implementation begins.

**Running traceability-validator agent...**

[Delegate to traceability-validator subagent with:
- Feature name: {feature}
- Feature directory: `.context/features/{feature}/`
- Test files from Test Writer
- Required reading: test-scenarios.json, behavior-catalog.md, business-rules.md]

> **Note**: The Traceability Validator ensures complete coverage before implementation starts.
> This catches missing tests early, when they're cheap to add.

### Output Artifacts
- `.context/features/{feature}/implementation/traceability-matrix.json`
- `.context/features/{feature}/implementation/traceability-report.md`

### Review Checkpoint

Please review the traceability report:
- [ ] **All behaviors covered** - Every BHV-XXX has scenarios?
- [ ] **All scenarios have tests** - Every TS-XXX has test(s)?
- [ ] **All invariants tested** - Every INV-XXX has property test?
- [ ] **No orphan tests** - All tests reference valid IDs?

**Traceability Status:**
- ✅ All scenarios covered → proceed to Implementer
- ❌ Gaps found → return to Test Writer to add missing tests

**Ready to proceed to Implementer agent?** (yes / no / return to Test Writer)

---

## TDD Subagent 2: Implementer (GREEN)

**Mission**: Write MINIMUM code to make tests pass. No extras, no optimization.

**Running implementer agent...**

[Delegate to tdd-implementer subagent with:
- Feature name: {feature}
- Feature directory: `.context/features/{feature}/`
- Strategic plan: `implementation/strategic-plan.md`
- PT10 alignment: `implementation/pt10-alignment.md`
- Previous agent plan: `implementation/test-writer-plan.md`
- Assigned unit(s): {unit names from strategic plan}
- Assigned contracts: {contracts for this agent from strategic plan}
- Output plan to: `implementation/implementer-plan.md`
- Required: Create plan file and present for approval before executing]

> **Note**: The Implementer agent will first create its tactical plan for human approval, then execute and commit its implementation files. Check the agent's output for the commit hash.

### Output Artifacts

```
paranext-core/
├── c-sharp/
│   └── {extension}/
│       ├── {Feature}DataProvider.cs
│       ├── {Feature}Models.cs
│       └── {Feature}Service.cs
└── extensions/
    └── src/{ext}/
        ├── components/{Feature}.tsx
        └── services/{feature}-service.ts
```

### Verification

```bash
# All tests should now PASS
dotnet test c-sharp-tests/{Feature}Tests/
# Expected: All tests pass (GREEN state)
```

### Review Checkpoint

Please review the implementation:
- [ ] **All tests pass** - Confirmed GREEN state?
- [ ] **Minimal code** - No extra features added?
- [ ] **ParatextData used** - Leveraged where possible?

**Ready to proceed to Refactorer agent?** (yes / no / need edits)

---

## TDD Subagent 3: Refactorer (REFACTOR)

**Mission**: Improve code quality while keeping tests GREEN.

**Running refactorer agent...**

[Delegate to tdd-refactorer subagent with:
- Feature name: {feature}
- Feature directory: `.context/features/{feature}/`
- Strategic plan: `implementation/strategic-plan.md`
- PT10 alignment: `implementation/pt10-alignment.md`
- Previous agent plan: `implementation/implementer-plan.md`
- Output plan to: `implementation/refactorer-plan.md`
- Required: Create plan file and present for approval before executing]

> **Note**: The Refactorer agent will first create its tactical plan for human approval, then execute and commit its refactored code. Check the agent's output for the commit hash.

### Verification

```bash
# Tests should still PASS after refactoring
dotnet test c-sharp-tests/{Feature}Tests/
# Expected: All tests still pass
```

### Review Checkpoint

Please review the refactored code:
- [ ] **Tests still pass** - No regressions?
- [ ] **Code quality** - Follows PT10 patterns?
- [ ] **No duplication** - DRY principles applied?
- [ ] **Good names** - Clear and descriptive?

**TDD Path Complete** → Continue to "Consolidate Decisions" section

---

# Path B: Hybrid (Level B Features)

Use this path for mixed logic features. First TDD the extracted business logic, then use Component Builder for UI.

## Step B1: TDD for Extracted Logic

Run the **TDD path above** (Test Writer → Implementer → Refactorer) for:
- Data providers (C#)
- Services with business logic
- Data transformations
- State management logic

Focus on code identified in `ui-logic-extraction.md`.

## Step B2: Component Builder for UI

After logic is tested and implemented, run Component Builder for UI components.

[Continue to Path C below]

---

# Path C: Component-First (Level C Features / Level B UI)

Use this path for UI-heavy features where visual verification is more effective than test-first.

## Component Builder Agent

**Mission**: Build UI components iteratively with visual verification against PT9 golden masters.

**Running component-builder agent...**

[Delegate to component-builder subagent with:
- Feature name: {feature}
- Feature directory: `.context/features/{feature}/`
- Strategic plan: `implementation/strategic-plan.md`
- PT10 alignment: `implementation/pt10-alignment.md`
- Assigned unit(s): {unit names from strategic plan}
- Assigned contracts: {UI contracts for this agent from strategic plan}
- Assigned golden masters: {UI golden masters for this agent from strategic plan}
- Output plan to: `implementation/component-builder-plan.md`
- Required: Create plan file and present for approval before executing]

> **Note**: The Component Builder agent will first create its tactical plan for human approval, then execute and commit its component files. Check the agent's output for the commit hash.

### Approach

1. **Scaffold** - Create component structure from data contracts
2. **Build visually** - Match PT9 golden master screenshots
3. **Add interactions** - Implement behaviors from catalog
4. **Add tests** - Snapshot and interaction tests after stable

### Output Artifacts

```
extensions/src/{ext}/
├── components/
│   ├── {Feature}.tsx
│   └── {Feature}*.tsx           # Sub-components
├── hooks/
│   └── use{Feature}.ts          # If needed
└── tests/
    ├── {feature}.snapshot.test.ts
    └── {feature}.test.ts
```

### Verification

1. **Visual comparison**: Component matches PT9 golden masters
2. **Interaction testing**: All behaviors from catalog work
3. **Test execution**:
   ```bash
   npm test -- --testPathPattern={feature}
   # Expected: Snapshot and interaction tests pass
   ```

### Review Checkpoint

Please review the component:
- [ ] **Visual match** - Looks like PT9 golden masters?
- [ ] **Interactions work** - All behaviors functional?
- [ ] **Snapshot tests exist** - `{feature}.snapshot.test.ts` created?
- [ ] **Interaction tests exist** - `{feature}.test.ts` created?
- [ ] **Tests pass** - `npm test -- --testPathPattern={feature}` succeeds?

⚠️ **Component-Builder agent must create tests before completing.** If tests are missing or failing, the agent is not done.

**Component-First Path Complete** → Continue to "Consolidate Decisions"

---

## Step: Consolidate Decisions

After all subagents complete, consolidate the decisions they noted into a permanent record.

### Gather Decisions from Subagent Plan Files

Review the "Decisions Made" section from each subagent's plan file in `implementation/`:
- `test-writer-plan.md` - Test Writer decisions (if TDD path)
- `implementer-plan.md` - Implementer decisions (if TDD path)
- `refactorer-plan.md` - Refactorer decisions (if TDD path)
- `component-builder-plan.md` - Component Builder decisions (if Component-First path)

### Create Decision Record

Create `.context/features/{feature}/decisions/phase-3-decisions.md`:

```markdown
# Implementation Decisions: {Feature}

**Date**: {date}
**Phase**: Phase 3 - Implementation
**Strategy**: {TDD / Hybrid / Component-First}

## Decision 1: {Title from subagent}

**Agent**: {Which subagent made this decision}
**Context**: {Situation requiring decision}

**Options Considered**:
1. {Option A} - {tradeoffs}
2. {Option B} - {tradeoffs}

**Decision**: {What was chosen}
**Rationale**: {Why}
**Consequences**: {What this means going forward}

---

## Decision 2: {Title}
...
```

### Review Checkpoint

Before writing decisions to file:
- [ ] All significant decisions captured from subagent outputs?
- [ ] Context and rationale are clear for future readers?
- [ ] Consequences are documented?
- [ ] No trivial decisions included (focus on architectural/strategic choices)?

**Write decisions to file?** (yes / no / edit first)

⚠️ **You MUST write the decision file before proceeding.** Use the Write tool to create `.context/features/{feature}/decisions/phase-3-decisions.md` with the consolidated decisions.

---

## Phase 3 Complete

### Summary (TDD Path)

| Agent | Status | Key Metrics |
|-------|--------|-------------|
| Test Writer | ✅ | X tests written, all RED |
| Implementer | ✅ | X tests passing, all GREEN |
| Refactorer | ✅ | Code quality improved, still GREEN |

### Summary (Component-First Path)

| Step | Status | Key Metrics |
|------|--------|-------------|
| Scaffold | ✅ | Component structure created |
| Visual Match | ✅ | Matches PT9 golden masters |
| Interactions | ✅ | All behaviors implemented |
| Tests | ✅ | Snapshot + interaction tests added |

### Quality Gates

**For TDD Path (Level A, Level B logic):**
- **G4: TDD Tests Written** - ✅
- **G5: TDD Tests Passing** - ✅

**For Component-First Path (Level B UI, Level C):**
- **G4-alt: Tests Created** - Snapshot + interaction test files exist
- **G5-alt: Tests Pass + Visual Match** - All tests pass AND matches golden masters

### Files Created in PT10

```
paranext-core/
├── c-sharp/
│   └── {extension}/
│       ├── {Feature}DataProvider.cs
│       └── ...
├── c-sharp-tests/
│   └── {Feature}Tests/
│       └── ...
└── extensions/
    └── src/{ext}/
        ├── components/
        ├── services/
        └── tests/
```

### Next Steps

Proceed to verification:
```
/porting/phase-4-verification {feature}
```

---

## Progress Tracking

Update `.context/features/{feature}/phase-status.md`:

```markdown
## Phase 3: Implementation

### Strategy Used: [TDD / Hybrid / Component-First]

### Plan Files Created
| Plan | Status | Location |
|------|--------|----------|
| Strategic Plan | ✅ | implementation/strategic-plan.md |
| Test Writer Plan | ✅ | implementation/test-writer-plan.md |
| Implementer Plan | ✅ | implementation/implementer-plan.md |
| Refactorer Plan | ✅ | implementation/refactorer-plan.md |
| Component Builder Plan | ✅ | implementation/component-builder-plan.md |

### TDD Progress (if applicable)
| Agent | Plan Approved | Executed | Artifacts |
|-------|---------------|----------|-----------|
| Test Writer | ✅ {date} | ✅ {date} | X test files |
| Implementer | ✅ {date} | ✅ {date} | X implementation files |
| Refactorer | ✅ {date} | ✅ {date} | Code refactored |

### Component-First Progress (if applicable)
| Step | Plan Approved | Executed | Notes |
|------|---------------|----------|-------|
| Component Builder | ✅ {date} | ✅ {date} | Components + tests |

## Quality Gates
- G4/G4-alt: Tests Written - ✅
- G5/G5-alt: Tests Passing / Visual Match - ✅

## Current: Phase 3 Complete
## Next: Phase 4 - Verification
```
