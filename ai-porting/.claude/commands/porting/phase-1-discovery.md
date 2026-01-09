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

- [ ] **G0 Gate Passed**: `.context/features/{feature}/task-description.md` exists AND approved by PO/Stakeholder

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

### Step 0: Create Feature Branch

Create a feature branch in the ai-prompts repository:

```bash
git checkout -b feature/{feature-name}
```

This branch will contain all Phase 1-2 artifacts. It will be merged via PR after Phase 2 (G3.5 gate).

### Step 1: Create Directory Structure

Ensure the feature directory exists:

```bash
mkdir -p .context/features/{feature}/characterization
mkdir -p .context/features/{feature}/implementation
mkdir -p .context/features/{feature}/golden-masters
mkdir -p .context/features/{feature}/decisions
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

### Commit Checkpoint

After approval, commit the Archaeologist artifacts:
```bash
git add .context/features/{feature}/
git commit -m "Phase 1: Archaeologist complete for {feature}"
```

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

### Commit Checkpoint

After approval, commit the Logic Locator artifacts:
```bash
git add .context/features/{feature}/
git commit -m "Phase 1: Logic Locator complete for {feature}"
```

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

### Commit Checkpoint

After approval, commit the Classifier artifacts:
```bash
git add .context/features/{feature}/
git commit -m "Phase 1: Classifier complete for {feature}"
```

---

## Step 4: Create GitHub Issue (Discovery Findings)

After all subagents complete, create a GitHub issue to document the discovery findings for PO/Stakeholder review.

### Generate GitHub Issue Content

Create `.context/features/{feature}/github-issue.md` with discovery findings:

```markdown
# {Feature Name} - Discovery Complete (Phase 1)

> **Status**: Phase 1 Discovery complete - awaiting Scope Validation (G1.5)

## Quick Reference

| Attribute | Value |
|-----------|-------|
| Classification | Level {A/B/C} |
| ParatextData Reuse | {X}% |
| Effort | {Low/Medium/High} |

## Discovery Artifacts

| Artifact | Purpose |
|----------|---------|
| [behavior-catalog.md](./behavior-catalog.md) | {N} discovered behaviors |
| [boundary-map.md](./boundary-map.md) | ParatextData vs UI boundaries |
| [business-rules.md](./business-rules.md) | Invariants and validations |
| [logic-distribution.md](./logic-distribution.md) | Logic layer assignments |
| [README.md](./README.md) | Classification and rationale |

## Summary

{2-3 sentence summary of what was discovered about this feature}

## Key Findings

1. {Key finding 1}
2. {Key finding 2}
3. {Key finding 3}

## Questions for PO/Stakeholder

{Any questions needing clarification before proceeding to specification}

## Next Steps

- [ ] PO/Stakeholder reviews discovery findings
- [ ] Approve scope to proceed to Phase 2 (Specification)

---
> 🤖 Auto-generated by Phase 1 Discovery workflow
```

### Create the GitHub Issue

```bash
gh issue create \
  --title "Port: {Feature Name} - Discovery Complete" \
  --body-file .context/features/{feature}/github-issue.md \
  --label "porting,phase-1"
```

### Commit the GitHub Issue file

```bash
git add .context/features/{feature}/github-issue.md
git commit -m "Phase 1: GitHub issue created for {feature}"
```

---

## Step 5: Scope Validation Gate (G1.5)

**⚠️ BLOCKING GATE**: PO/Stakeholder must approve the GitHub issue before proceeding to Phase 2.

### What PO/Stakeholder Reviews

- [ ] Behavior catalog is complete and accurate
- [ ] Classification level (A/B/C) is appropriate
- [ ] Logic distribution makes sense
- [ ] Scope aligns with task-description.md
- [ ] No major gaps or concerns

### Approval Process

1. PO/Stakeholder reviews the GitHub issue
2. Comments/questions are addressed
3. PO/Stakeholder approves by commenting "Approved" or similar
4. **Only then** can Phase 2 begin

---

## Phase 1 Complete

### Summary

| Step | Status | Key Findings |
|------|--------|--------------|
| Archaeologist | ✅ | X behaviors, Y entry points |
| Logic Locator | ✅ | X% ParatextData, Y% UI |
| Classifier | ✅ | Level {A/B/C} |
| GitHub Issue | ✅ | Issue #{number} created |
| **G1.5 Scope Validation** | ⏳ | Awaiting PO/Stakeholder approval |

### Artifacts Created

```
.context/features/{feature}/
├── task-description.md          # Human-defined scope (input - created before Phase 1)
├── README.md                    # Feature overview & classification
├── behavior-catalog.md          # All behaviors discovered (incl. user stories, UI/UX)
├── boundary-map.md              # ParatextData vs UI split (incl. settings, integrations)
├── business-rules.md            # Invariants, validations, constraints
├── logic-distribution.md        # WHERE logic lives (ParatextData vs UI)
└── github-issue.md              # Discovery summary for PO/Stakeholder review
```

### Quality Gates

- **G0 Task Description**: ✅ Approved before Phase 1 started
- **G1 Discovery Complete**: ✅ All artifacts created
- **G1.5 Scope Validation**: ⏳ Awaiting PO/Stakeholder approval on GitHub issue

### Next Steps

**⚠️ WAIT FOR G1.5 APPROVAL before proceeding!**

Once PO/Stakeholder approves the GitHub issue:
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
- **Branch**: feature/{feature-name} (ai-prompts)
- **GitHub Issue**: #{number}

## Quality Gates Summary
| Gate | Description | Status |
|------|-------------|--------|
| G0 | Task description approved | ✅ |
| G1 | Discovery complete | ✅ |
| G1.5 | Scope Validation (PO/Stakeholder) | ⏳ |
| G2 | API contract approved | ⏳ |
| G3 | Logic extraction complete (Level B) | ⏳/N/A |
| G3.5 | Specification PR approved | ⏳ |
| G4/G4-alt | Tests written | ⏳ |
| G5/G5-alt | Tests passing | ⏳ |
| G6-G9 | Verification gates | ⏳ |
| G10 | Implementation PR approved | ⏳ |

## Phase 1: Discovery
| Step | Status | Completed | Artifacts |
|------|--------|-----------|-----------|
| Archaeologist | ✅ | {date} | behavior-catalog.md, boundary-map.md, business-rules.md |
| Logic Locator | ✅ | {date} | logic-distribution.md |
| Classifier | ✅ | {date} | README.md |
| GitHub Issue | ✅ | {date} | github-issue.md, Issue #{number} |

**G0 Task Description Approved**: ✅
**G1 Discovery Complete**: ✅
**G1.5 Scope Validation**: ⏳ Awaiting PO/Stakeholder approval

## Phase 2: Specification
| Step | Status | Completed | Artifacts |
|------|--------|-----------|-----------|
| Test Scenario Writer | ⏳ | | test-scenarios.json, edge-cases.md, requirements.md |
| Spec Generator | ⏳ | | test-specifications/ or golden-masters/, extraction-plan.md (Level B) |
| Contract Writer | ⏳ | | data-contracts.md |
| Update GitHub Issue | ⏳ | | Updated github-issue.md |
| Create PR | ⏳ | | PR to main |

**G2 API Contract Approved**: ⏳
**G3 Extraction Plan Complete** (Level B): ⏳/N/A
**G3.5 Specification PR Approved**: ⏳

## Phase 3: Implementation
| Step | Status | Completed | Artifacts |
|------|--------|-----------|-----------|
| Alignment Agent | ⏳ | | pt10-alignment.md |
| Strategic Plan | ⏳ | | strategic-plan.md |
| TDD Test Writer | ⏳/N/A | | Test files |
| TDD Implementer | ⏳/N/A | | Implementation |
| TDD Refactorer | ⏳/N/A | | Refactored code |
| Component Builder | ⏳/N/A | | React components |

**G4/G4-alt Tests Written**: ⏳
**G4.5 Test Quality Verified**: ⏳
**G5/G5-alt Tests Passing**: ⏳

## Phase 4: Verification
| Step | Status | Completed | Artifacts |
|------|--------|-----------|-----------|
| Equivalence Checker | ⏳ | | equivalence-report.md |
| Invariant Checker | ⏳ | | invariant-report.md |
| Validator | ⏳ | | validation-report.md |
| Update GitHub Issue | ⏳ | | Final update |
| Create PR | ⏳ | | PR to main (paranext-core) |

**G6 Golden Master Tests Pass**: ⏳
**G7 Property Tests Pass**: ⏳
**G8 Integration Tests Pass**: ⏳
**G9 Mutation Score ≥70%**: ⏳/N/A
**G10 Implementation PR Approved**: ⏳
```
