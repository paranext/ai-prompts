# Phase 1: Discovery

Discover Paratext 9 feature: **$ARGUMENTS**

## Overview

This phase discovers and documents everything about the feature in PT9 before we start specifying what to build.

**Purpose**: Understand what exists in PT9. Pure observation and documentation.

## Context

Before proceeding, read:
- `.context/AI-Porting-Workflow.md` for overall workflow context, quality gates, and how this phase fits into the 4-phase process
- `.context/features/{feature}/task-description.md` for the human-defined scope, goals, non-goals, and constraints for this specific feature

## Prerequisites

- [ ] `.context/features/{feature}/task-description.md` exists (human-defined scope)

## Subagents in this Phase

| # | Agent | Purpose | Output |
|---|-------|---------|--------|
| 1 | **Archaeologist** | Discover behaviors, entry points, boundaries | behavior-catalog.md, boundary-map.md, business-rules.md |
| 2 | **Logic Locator** | Identify WHERE logic lives (ParatextData vs UI) | logic-distribution.md |
| 3 | **Feature Classifier** | Determine Level A/B/C classification | README.md with classification |

## Workflow

I will run each subagent sequentially. After each subagent completes, I'll show you the output and ask if you want to continue.

---

## Setup

First, ensure the feature directory exists:

```bash
mkdir -p .context/features/{feature}/characterization
mkdir -p .context/features/{feature}/implementation
mkdir -p .context/features/{feature}/golden-masters
```

---

## Subagent 1: Archaeologist

**Mission**: Discover all behaviors, entry points, and boundaries for this feature.

**Running archaeologist agent...**

[Delegate to archaeologist subagent with:
- Feature name: {feature}
- Feature directory: `.context/features/{feature}/`
- Required reading FIRST: task-description.md for scope, goals, non-goals, and constraints
- This is the FIRST agent - it will create the directory structure and initial artifacts]

### Output Artifacts
- `.context/features/{feature}/behavior-catalog.md`
- `.context/features/{feature}/boundary-map.md`
- `.context/features/{feature}/business-rules.md`

### Review Checkpoint

Please review the artifacts:
- [ ] **behavior-catalog.md** - Are all behaviors captured? User stories included?
- [ ] **boundary-map.md** - Is the ParatextData vs UI boundary accurate? Settings documented?
- [ ] **business-rules.md** - Are invariants and validation rules captured?

**Ready to proceed to Logic Locator agent?** (yes / no / need edits)

---

## Subagent 2: Logic Locator

**Mission**: Document WHERE logic exists - ParatextData (reusable) vs UI layer (needs work).

**Running logic locator agent...**

[Delegate to logic-locator subagent with:
- Feature name: {feature}
- Feature directory: `.context/features/{feature}/`
- Required reading FIRST: behavior-catalog.md, boundary-map.md from Archaeologist]

### Output Artifacts
- `.context/features/{feature}/logic-distribution.md`

### Review Checkpoint

Please review the logic distribution:
- [ ] **Logic blocks identified** - Are all logic blocks documented with locations?
- [ ] **Layer assignments** - Is ParatextData vs UI assignment correct?
- [ ] **Complexity hotspots** - Are complex areas noted?
- [ ] **Classification implication** - Does the suggested level seem reasonable?

**Ready to proceed to Feature Classifier agent?** (yes / no / need edits)

---

## Subagent 3: Feature Classifier

**Mission**: Determine Level A/B/C classification based on ParatextData reuse.

**Running feature classifier agent...**

[Delegate to feature classifier subagent with:
- Feature name: {feature}
- Feature directory: `.context/features/{feature}/`
- Required reading FIRST: behavior-catalog.md, boundary-map.md, business-rules.md, logic-distribution.md]

### Output Artifacts
- `.context/features/{feature}/README.md` (updated with classification)

### Review Checkpoint

Please review the classification:
- [ ] **Level assigned** - Does A/B/C seem correct given logic-distribution.md?
- [ ] **Rationale** - Is the reasoning sound?
- [ ] **Testing strategy** - Is the approach appropriate for this level?

---

## Phase 1 Complete

### Summary

| Agent | Status | Key Findings |
|-------|--------|--------------|
| Archaeologist | ✅ | X behaviors, Y entry points |
| Logic Locator | ✅ | X% ParatextData, Y% UI |
| Classifier | ✅ | Level {A/B/C} |

### Artifacts Created

```
.context/features/{feature}/
├── task-description.md          # Human-defined scope (input - created before Phase 1)
├── README.md                    # Feature overview & classification
├── behavior-catalog.md          # All behaviors discovered (incl. user stories, UI/UX)
├── boundary-map.md              # ParatextData vs UI split (incl. settings, integrations)
├── business-rules.md            # Invariants, validations, constraints
└── logic-distribution.md        # WHERE logic lives (ParatextData vs UI)
```

### Quality Gate: Discovery Complete

All behaviors, boundaries, logic locations, and classification documented.

### Next Steps

Phase 1 is complete. To continue:
```
/porting/phase-2-specification {feature}
```

---

## Progress Tracking

Update `.context/features/{feature}/phase-status.md`:

```markdown
# Phase Status: {feature}

## Overview
- **Feature**: {feature name}
- **Classification**: Level {A/B/C}
- **Started**: {date}
- **Current Phase**: 1

## Phase 1: Discovery
| Agent | Status | Completed | Artifacts |
|-------|--------|-----------|-----------|
| Archaeologist | ✅ | {date} | behavior-catalog.md, boundary-map.md, business-rules.md |
| Logic Locator | ✅ | {date} | logic-distribution.md |
| Classifier | ✅ | {date} | README.md |

**Discovery Complete**: ✅

## Phase 2: Specification
| Agent | Status | Completed | Artifacts |
|-------|--------|-----------|-----------|
| Test Scenario Writer | ⏳ | | test-scenarios.json, edge-cases.md, requirements.md |
| Spec Generator | ⏳ | | test-specifications/ or golden-masters/, extraction-plan.md (Level B) |
| Contract Writer | ⏳ | | data-contracts.md |

**G1 Test Scenarios Complete**: ⏳
**G2 API Contract Approved**: ⏳
**G3 Extraction Plan Complete** (Level B): ⏳/N/A

## Phase 3: Implementation
| Agent | Status | Completed | Artifacts |
|-------|--------|-----------|-----------|
| TDD Test Writer | ⏳/N/A | | Test files |
| TDD Implementer | ⏳/N/A | | Implementation |
| TDD Refactorer | ⏳/N/A | | Refactored code |
| Component Builder | ⏳/N/A | | React components |

**G4/G4-alt Tests Written**: ⏳
**G5/G5-alt Tests Passing**: ⏳

## Phase 4: Verification
| Agent | Status | Completed | Artifacts |
|-------|--------|-----------|-----------|
| Equivalence Checker | ⏳ | | equivalence-report.md |
| Invariant Checker | ⏳ | | invariant-report.md |
| Validator | ⏳ | | validation-report.md |

**G6 Golden Master Tests Pass**: ⏳
**G7 Property Tests Pass**: ⏳
**G8 Integration Tests Pass**: ⏳
**G9 Mutation Score ≥70%**: ⏳/N/A
**G10 Human Review Approved**: ⏳
```
