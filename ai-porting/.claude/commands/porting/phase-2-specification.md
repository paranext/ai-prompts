# Phase 2: Specification

Create specifications for feature: **$ARGUMENTS**

## Overview

This phase creates the formal specifications that PT10 must implement: extracted logic docs, golden masters, and API contracts.

## Context

Before proceeding, read `.context/AI-Porting-Workflow.md` for overall workflow context, quality gates, and how this phase fits into the 4-phase process.

## Prerequisites

- [ ] Phase 1 complete
- [ ] `task-description.md` exists (original scope)
- [ ] `behavior-catalog.md` exists
- [ ] `README.md` has classification

## Subagents in this Phase

| # | Agent | Purpose | When | Output |
|---|-------|---------|------|--------|
| 1 | **UI Logic Extractor** | Document UI-embedded logic | Level B only | ui-logic-extraction.md |
| 2 | **Spec Generator** | Create test specs (Level A) or golden masters (Level B/C) | All levels | test-specifications/ or golden-masters/ |
| 3 | **Contract Writer** | Define API types & signatures | All levels | data-contracts.md |

## Workflow

I will run each subagent sequentially. After each subagent completes, I'll show you the output and ask if you want to continue.

---

## Subagent 1: UI Logic Extractor (Level B Only)

**Skip this agent for Level A or Level C features.**

**Mission**: Document all UI-embedded business logic that should be implemented in PT10.

**Running ui-logic-extractor agent...**

[Delegate to ui-logic-extractor subagent with:
- Feature name: {feature}
- Feature directory: `.context/features/{feature}/`
- Required reading FIRST: task-description.md (scope/non-goals), behavior-catalog.md, README.md (for Level B confirmation), test-scenarios.json]

### Output Artifacts
- `.context/features/{feature}/implementation/ui-logic-extraction.md`

### Review Checkpoint

Please review the extraction plan:
- [ ] **All embedded logic identified** - Did we find everything?
- [ ] **Proposed signatures** - Are the pure functions well-designed?
- [ ] **Test coverage** - Are extraction scenarios covered?

**Ready to proceed to Golden Master Generator?** (yes / no / need edits)

---

## Subagent 2: Spec Generator

**Mission**: Create level-appropriate specifications for PT10 implementation.

**Running spec-generator agent...**

[Delegate to spec-generator subagent with:
- Feature name: {feature}
- Feature directory: `.context/features/{feature}/`
- Required reading FIRST: task-description.md (scope), test-scenarios.json, README.md (for classification), ui-logic-extraction.md (if Level B)]

### Output Artifacts

**For Level A (80%+ ParatextData reuse):**
```
.context/features/{feature}/test-specifications/
├── spec-001-{name}.json      # Structured test specification with assertions
├── spec-002-{name}.json
└── ...
```
Note: Level A does NOT create golden-masters/ - ParatextData.dll is the oracle.

**For Level B/C:**
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

**For Level B/C**, review golden masters:
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
- Required reading FIRST: task-description.md (scope/non-goals), behavior-catalog.md, boundary-map.md, golden-masters/, ui-logic-extraction.md (if Level B)]

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

## Step 4: Specification Summary & GitHub Issue

After all agents complete, generate stakeholder-friendly deliverables.

### Generate Spec Summary

Create `.context/features/{feature}/spec-summary.md`:

**IMPORTANT**: This summary should LINK to detailed artifacts, not duplicate their content. README.md is the single source of truth for classification, scope, and strategy.

```markdown
# Specification Summary: {Feature Name}

> **Single Source of Truth**: See [README.md](./README.md) for complete feature details.

## Quick Reference

| Attribute | Value | Details |
|-----------|-------|---------|
| Classification | Level {A/B/C} | [README.md#classification](./README.md#classification) |
| Effort | {Low/Medium/High} | [README.md#effort](./README.md#effort) |
| Strategy | {Full TDD / Hybrid / Component-First} | [README.md#implementation-strategy](./README.md#implementation-strategy) |

## Counts

| Artifact | Count |
|----------|-------|
| Behaviors | {N} |
| Test Scenarios | {N} |
| Test Specifications | {N} (Level A) |
| Golden Masters | {N} (Level B/C) |
| API Methods | {N} |

## Detailed Artifacts

| Artifact | Description |
|----------|-------------|
| [README.md](./README.md) | **Canonical source** - classification, scope, strategy |
| [Behavior Catalog](./behavior-catalog.md) | All discovered behaviors |
| [Boundary Map](./boundary-map.md) | Architecture boundaries |
| [Data Contracts](./data-contracts.md) | API specifications |
| [Test Scenarios](./characterization/test-scenarios.json) | Test coverage |
| [Test Specifications](./test-specifications/) | Assertions for Level A |
| [Golden Masters](./golden-masters/) | Captured outputs for Level B/C |

## Stakeholder Questions

[Any open questions needing input before Phase 3]
```

### Generate GitHub Issue

Create `.context/features/{feature}/github-issue.md`:

**IMPORTANT**: GitHub issue should link to artifacts, not duplicate content.

```markdown
## Feature Port: {Feature Name}

**Classification:** Level {A/B/C} | **Effort:** {Low/Medium/High}

### Summary
[1-2 sentence description of the feature]

### Quick Links
- 📄 [Full Specification (README.md)](./README.md)
- 📋 [Behavior Catalog](./behavior-catalog.md)
- 🔌 [API Contracts](./data-contracts.md)
- 🧪 [Test Scenarios](./characterization/test-scenarios.json)

### Acceptance Criteria
- [ ] All PT9 behaviors preserved
- [ ] Golden master / test specification tests pass
- [ ] Property tests pass
- [ ] Human review approved

### Implementation Phases
- [ ] Phase 3: Implementation
- [ ] Phase 4: Verification
- [ ] Final Review

---
🤖 Auto-generated by porting workflow
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
- [ ] `spec-summary.md` - Stakeholder summary
- [ ] `github-issue.md` - Issue body
- [ ] GitHub Issue #{number} created

**Ready to create the GitHub issue?** (yes / no / edit summaries first)

---

## Step 5: Consolidate Decisions

After all subagents complete, consolidate the decisions they noted into a permanent record.

### Gather Decisions from Subagents

Review the "Decisions Made" section from each subagent's output:
- UI Logic Extractor decisions (if Level B)
- Golden Master Generator decisions
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
| UI Logic Extractor | ✅/N/A | ui-logic-extraction.md |
| Spec Generator | ✅ | test-specifications/ (Level A) or golden-masters/ (Level B/C) |
| Contract Writer | ✅ | data-contracts.md |
| Spec Summary | ✅ | spec-summary.md |
| GitHub Issue | ✅ | Issue #{number} |

### Artifacts Created

```
.context/features/{feature}/
├── task-description.md          # Human-defined scope (input)
├── implementation/
│   └── ui-logic-extraction.md   # (Level B only)
├── test-specifications/         # (Level A) Structured test specs
│   ├── spec-001-{name}.json
│   └── ...
├── golden-masters/              # (Level B/C) Captured PT9 outputs
│   ├── gm-001-{name}/
│   └── ...
├── data-contracts.md            # API contracts (with {TBD:*} placeholders)
├── spec-summary.md              # Stakeholder summary (links to README.md)
└── github-issue.md              # Issue body
```

### Quality Gates

- **G2: API Contract** - ✅ Documented
- **G3: Logic Extraction** - ✅ Complete (Level B) / N/A

### Stakeholder Review

GitHub Issue #{number} created for stakeholder review.

**Next steps:**
1. Stakeholders review the GitHub issue
2. Address any questions/feedback
3. Once approved, proceed to Phase 3:

```
/porting/phase-3-implementation {feature}
```

---

## Progress Tracking

Update `.context/features/{feature}/implementation/phase-status.md`:

```markdown
## Phase 2: Specification
| Step | Status | Completed | Artifacts |
|------|--------|-----------|-----------|
| UI Logic Extractor | ✅/N/A | {date} | ui-logic-extraction.md |
| Golden Master Gen | ✅ | {date} | golden-masters/ |
| Contract Writer | ✅ | {date} | data-contracts.md |
| Spec Summary | ✅ | {date} | spec-summary.md |
| GitHub Issue | ✅ | {date} | Issue #{number} |

## Stakeholder Review
- GitHub Issue: #{number}
- Status: ⏳ Awaiting Review

## Current: Phase 2 Complete - Awaiting Stakeholder Approval
## Next: Phase 3 - Implementation
```
