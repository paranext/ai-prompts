# Phase 2: Specification

Create specifications for feature: **$ARGUMENTS**

## Overview

This phase creates the formal specifications that PT10 must implement: test scenarios, extraction plans (Level B), golden masters, and API contracts.

**Purpose**: Define what PT10 must do. Create testable specifications.

## Context

Before proceeding, read `.context/AI-Porting-Workflow.md` for overall workflow context, quality gates, and how this phase fits into the 4-phase process.

## Prerequisites

- [ ] Phase 1 (Discovery) complete
- [ ] `task-description.md` exists (original scope)
- [ ] `behavior-catalog.md` exists
- [ ] `logic-distribution.md` exists
- [ ] `README.md` has classification

## Subagents in this Phase

| # | Agent | Purpose | When | Output |
|---|-------|---------|------|--------|
| 1 | **Test Scenario Writer** | Create test scenarios from behaviors | All levels | test-scenarios.json, edge-cases.md, requirements.md |
| 2 | **Spec Generator** | Create test specs (A), extraction plans + golden masters (B), or golden masters (C) | All levels | test-specifications/, extraction-plan.md, golden-masters/ |
| 3 | **Contract Writer** | Define API types & signatures | All levels | data-contracts.md |

## Workflow

I will run each subagent sequentially. After each subagent completes, I'll show you the output and ask if you want to continue.

---

## Subagent 1: Test Scenario Writer

**Mission**: Generate test scenarios that define what PT10 must implement, based on discovered behaviors.

**Running test-scenario-writer agent...**

[Delegate to test-scenario-writer subagent with:
- Feature name: {feature}
- Feature directory: `.context/features/{feature}/`
- Required reading FIRST: task-description.md, behavior-catalog.md, logic-distribution.md, README.md (classification), business-rules.md]

### Output Artifacts
- `.context/features/{feature}/characterization/test-scenarios.json`
- `.context/features/{feature}/characterization/edge-cases.md`
- `.context/features/{feature}/characterization/requirements.md`
- `.context/features/{feature}/golden-masters/CAPTURE-CHECKLIST.md`

### Review Checkpoint

Please review the test scenarios:
- [ ] **Test scenarios** - Are key behaviors covered? Is `logicLayer` field set correctly?
- [ ] **Edge cases** - Are unusual cases documented?
- [ ] **Requirements** - Non-functional requirements, error messages, accessibility noted?
- [ ] **Capture checklist** - Can PT9 captures be completed from this?
- [ ] **Coverage** - Any gaps in the behavior catalog?

**Ready to proceed to Spec Generator?** (yes / no / need edits)

---

## Subagent 2: Spec Generator

**Mission**: Create level-appropriate specifications for PT10 implementation.

**Running spec-generator agent...**

[Delegate to spec-generator subagent with:
- Feature name: {feature}
- Feature directory: `.context/features/{feature}/`
- Required reading FIRST: task-description.md (scope), test-scenarios.json, logic-distribution.md, README.md (for classification)]

### Output Artifacts

**For Level A (80%+ ParatextData reuse):**
```
.context/features/{feature}/test-specifications/
├── spec-001-{name}.json      # Structured test specification with assertions
├── spec-002-{name}.json
└── ...
```
Note: Level A does NOT create golden-masters/ - ParatextData.dll is the oracle.

**For Level B (Mixed Logic):**
```
.context/features/{feature}/
├── test-specifications/          # For ParatextData scenarios
│   ├── spec-001-{name}.json
│   └── ...
├── implementation/
│   └── extraction-plan.md        # Function signatures, contracts for UI logic
└── golden-masters/               # For UI scenarios
    ├── gm-001-{name}/
    │   ├── input.json
    │   ├── expected-output.json
    │   ├── metadata.json
    │   └── notes.md
    └── ...
```

**For Level C (Pure UI):**
```
.context/features/{feature}/golden-masters/
├── gm-001-{name}/
│   ├── input.json
│   ├── expected-output.json
│   ├── metadata.json
│   └── notes.md
└── ...
```

### Review Checkpoint

**For Level A**, review test specifications:
- [ ] **Assertions defined** - Are expected values and operators clear?
- [ ] **ParatextData APIs identified** - Do we know what to test against?
- [ ] **Invariants documented** - Property tests defined?

**For Level B**, review all outputs:
- [ ] **Test specifications** - ParatextData scenarios covered?
- [ ] **Extraction plan** - Function signatures well-designed? Contracts clear?
- [ ] **Golden masters** - UI scenarios captured?
- [ ] **Input specs complete** - Can scenarios be reproduced?

**For Level C**, review golden masters:
- [ ] **Key scenarios covered** - Are the important cases captured?
- [ ] **Input specs complete** - Can scenarios be reproduced?
- [ ] **Comparison config** - Are normalizations appropriate?

**Ready to proceed to Contract Writer?** (yes / no / need edits)

---

## Subagent 3: Contract Writer

**Mission**: Define the formal API contracts between layers AND determine the implementation strategy.

**Running contract-writer agent...**

[Delegate to contract-writer subagent with:
- Feature name: {feature}
- Feature directory: `.context/features/{feature}/`
- Required reading FIRST: task-description.md (scope/non-goals), behavior-catalog.md, boundary-map.md, golden-masters/, extraction-plan.md (if Level B)]

### Output Artifacts
- `.context/features/{feature}/data-contracts.md`

### Implementation Strategy Determination

Based on the feature classification and code distribution, determine the Phase 3 strategy:

| Classification | Code Distribution | Strategy |
|---------------|-------------------|----------|
| Level A | 80%+ ParatextData | **Full TDD** |
| Level B | Mixed | **Hybrid** (TDD for logic + Component-First for UI) |
| Level C | 90%+ UI | **Component-First** |

Add to `README.md`:
```markdown
## Implementation Strategy
**Strategy**: [Full TDD / Hybrid / Component-First]
**Rationale**: [Why this strategy fits the code distribution]

### Phase 3 Path
- [ ] TDD for: [list components if applicable]
- [ ] Component-First for: [list components if applicable]
```

### Review Checkpoint

Please review the contracts:
- [ ] **Types complete** - All input/output types defined?
- [ ] **Methods documented** - All API methods specified?
- [ ] **Error handling** - All error cases covered?
- [ ] **TypeScript & C# aligned** - Types compatible?
- [ ] **Implementation strategy** - Documented in README.md?

---

## Step 4: Stakeholder Summary (GitHub Issue)

After all agents complete, generate a stakeholder-friendly summary.

**Note**: We eliminated the separate `spec-summary.md` file. The GitHub issue IS the stakeholder summary - it's where review and approval happen. Having both creates duplication pressure.

### Generate GitHub Issue (serves as summary)

Create `.context/features/{feature}/github-issue.md`:

**IMPORTANT**: This serves as BOTH the stakeholder summary AND the GitHub issue body. It should LINK to detailed artifacts, not duplicate content. README.md is the single source of truth.

```markdown
# {Feature Name} - Stakeholder Review

> **Single Source of Truth**: See [README.md](./README.md) for complete specification.

## Quick Reference

| Attribute | Value |
|-----------|-------|
| Classification | Level {A/B/C} |
| ParatextData Reuse | {X}% |
| Effort | {Low/Medium/High} |
| Strategy | {Full TDD / Hybrid / Component-First} |

## Artifact Links

| Artifact | Purpose |
|----------|---------|
| [README.md](./README.md) | Full specification (canonical) |
| [behavior-catalog.md](./behavior-catalog.md) | {N} discovered behaviors |
| [data-contracts.md](./data-contracts.md) | API types and signatures |
| [test-scenarios.json](./characterization/test-scenarios.json) | {N} test scenarios |
| [test-specifications/](./test-specifications/) | {N} test specs (Level A/B) |
| [extraction-plan.md](./implementation/extraction-plan.md) | Extraction plan (Level B only) |
| [golden-masters/](./golden-masters/) | {N} golden masters (Level B/C) |

## Summary

{2-3 sentence summary of what this feature does and the key implementation approach}

## Key Decisions Requiring Approval

1. {Decision 1 - e.g., API design choice}
2. {Decision 2 - e.g., State management approach}

## Open Questions

{Any questions needing stakeholder input before Phase 3}

## Acceptance Criteria

- [ ] All PT9 behaviors preserved
- [ ] Golden master / test specification tests pass
- [ ] Property tests pass (invariants)
- [ ] Human review approved

## Next Steps

- [ ] Stakeholder review of this summary
- [ ] Complete PT9 captures from [CAPTURE-CHECKLIST.md](./golden-masters/CAPTURE-CHECKLIST.md)
- [ ] Approve to proceed to Phase 3

---
> **Full details**: See [README.md](./README.md) for complete specification
>
> 🤖 Auto-generated by porting workflow
```

### Create GitHub Issue
We will create the Github Issue later when Github project is ready.
<!-- ```bash
gh issue create \
  --title "Port: {Feature Name}" \
  --body-file .context/features/{feature}/github-issue.md \
  --label "porting"
``` -->

### Review Checkpoint

**Artifacts created:**
- [ ] `github-issue.md` - Stakeholder summary (replaces spec-summary.md)
- [ ] GitHub Issue #{number} created (when ready)

**Ready to create the GitHub issue?** (yes / no / edit summary first)

---

## Step 5: Consolidate Decisions

After all subagents complete, consolidate the decisions they noted into a permanent record.

### Gather Decisions from Subagents

Review the "Decisions Made" section from each subagent's output:
- Test Scenario Writer decisions
- Spec Generator decisions
- Contract Writer decisions

### Create Decision Record

Create `.context/features/{feature}/decisions/phase-2-decisions.md`:

```markdown
# Specification Decisions: {Feature}

**Date**: {date}
**Phase**: Phase 2 - Specification

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

⚠️ **You MUST write the decision file before proceeding.** Use the Write tool to create `.context/features/{feature}/decisions/phase-2-decisions.md`.

---

## Phase 2 Complete

### Summary

| Step | Status | Output |
|------|--------|--------|
| Test Scenario Writer | ✅ | test-scenarios.json, edge-cases.md, requirements.md |
| Spec Generator | ✅ | test-specifications/ (A/B), extraction-plan.md (B), golden-masters/ (B/C) |
| Contract Writer | ✅ | data-contracts.md |
| GitHub Issue | ✅ | github-issue.md (serves as stakeholder summary) |

### Artifacts Created

```
.context/features/{feature}/
├── task-description.md          # Human-defined scope (input)
├── characterization/
│   ├── test-scenarios.json      # Test scenarios with logicLayer tags
│   ├── edge-cases.md            # Documented edge cases
│   └── requirements.md          # Non-functional requirements
├── implementation/
│   └── extraction-plan.md       # (Level B only) Function signatures, contracts
├── test-specifications/         # (Level A/B) Structured test specs
│   ├── spec-001-{name}.json
│   └── ...
├── golden-masters/              # (Level B/C) Captured PT9 outputs
│   ├── CAPTURE-CHECKLIST.md     # Guide for manual captures
│   ├── gm-001-{name}/
│   └── ...
├── data-contracts.md            # API contracts (with {TBD:*} placeholders)
└── github-issue.md              # Stakeholder summary + issue body (links to README.md)
```

### Quality Gates

- **G1: Test Scenarios** - ✅ Complete
- **G2: API Contract** - ✅ Documented
- **G3: Extraction Plan** - ✅ Complete (Level B) / N/A

### Stakeholder Review

GitHub Issue #{number} created for stakeholder review.

**Next steps:**
1. Stakeholders review the GitHub issue
2. Address any questions/feedback
3. Complete PT9 captures from CAPTURE-CHECKLIST.md
4. Once approved, proceed to Phase 3:

```
/porting/phase-3-implementation {feature}
```

---

## Progress Tracking

Update `.context/features/{feature}/phase-status.md`:

```markdown
## Phase 2: Specification
| Step | Status | Completed | Artifacts |
|------|--------|-----------|-----------|
| Test Scenario Writer | ✅ | {date} | test-scenarios.json, edge-cases.md, requirements.md |
| Spec Generator | ✅ | {date} | test-specifications/, extraction-plan.md, golden-masters/ |
| Contract Writer | ✅ | {date} | data-contracts.md |
| GitHub Issue | ✅ | {date} | github-issue.md (stakeholder summary) |

## Stakeholder Review
- GitHub Issue: #{number}
- Status: ⏳ Awaiting Review

## Current: Phase 2 Complete - Awaiting Stakeholder Approval
## Next: Phase 3 - Implementation
```
