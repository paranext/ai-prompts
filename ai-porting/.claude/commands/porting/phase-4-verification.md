# Phase 4: Verification

Verify feature implementation: **$ARGUMENTS**

## Overview

This phase verifies that PT10 behaves identically to PT9 and passes all quality gates.

## Context

Before proceeding, read `.context/AI-Porting-Workflow.md` for overall workflow context, quality gates, and how this phase fits into the 4-phase process.

## Prerequisites

- [ ] Phase 3 complete
- [ ] `task-description.md` exists (original scope for validation)
- [ ] All TDD tests passing (G5)
- [ ] Implementation code complete

## Subagents in this Phase

| # | Agent | Purpose | Output |
|---|-------|---------|--------|
| 1 | **Equivalence Checker** | Compare PT9 vs PT10 outputs | equivalence-report.md |
| 2 | **Invariant Checker** | Verify property-based tests | invariant-report.md |
| 3 | **Validator** | Final quality gate check | validation-report.md |

## Workflow

I will run each subagent sequentially. After each agent completes, I'll show you the output and ask if you want to continue.

---

## Subagent 1: Equivalence Checker

**Mission**: Verify PT10 produces the same results as PT9 for all golden master scenarios.

**Running equivalence-checker agent...**

[Delegate to equivalence-checker subagent with:
- Feature name: {feature}
- Feature directory: `.context/features/{feature}/`
- Required reading FIRST: golden-masters/, test-scenarios.json, README.md (classification)
- Required: Run unit tests to verify implementation complete]

> **Note**: The Equivalence Checker agent commits its report before returning. Check the agent's output for the commit hash.

### Output Artifacts
- `.context/features/{feature}/equivalence/equivalence-report.md`

### Review Checkpoint

Please review the equivalence report:
- [ ] **All scenarios tested** - Complete coverage?
- [ ] **Differences explained** - Acceptable or bugs?
- [ ] **No regressions** - PT9 behavior preserved?

**Equivalence Status:**
- ✅ All scenarios pass, OR
- ⚠️ Acceptable differences documented, OR
- ❌ Bugs found - need fixes before proceeding

**Ready to proceed to Invariant Checker?** (yes / no / need fixes)

---

## Subagent 2: Invariant Checker

**Mission**: Verify all invariants hold through property-based testing.

**Running invariant-checker agent...**

[Delegate to invariant-checker subagent with:
- Feature name: {feature}
- Feature directory: `.context/features/{feature}/`
- Required reading FIRST: business-rules.md (for invariants), property test files from Test Writer]

> **Note**: The Invariant Checker agent commits its report before returning. Check the agent's output for the commit hash.

### Output Artifacts
- `.context/features/{feature}/verification/invariant-report.md`

### Review Checkpoint

Please review the invariant report:
- [ ] **All invariants tested** - Complete coverage?
- [ ] **No failures** - All properties hold?
- [ ] **Edge cases discovered** - Documented appropriately?

**Invariant Status:**
- ✅ All invariants verified, OR
- ❌ Counterexamples found - need fixes

**Ready to proceed to Validator?** (yes / no / need fixes)

---

## Subagent 3: Validator

**Mission**: Final quality gate check - comprehensive validation before human review.

**Running validator agent...**

[Delegate to validator subagent with:
- Feature name: {feature}
- Feature directory: `.context/features/{feature}/`
- Required reading FIRST: task-description.md (original scope/goals), phase-status.md, equivalence-report.md, invariant-report.md, README.md, behavior-catalog.md, data-contracts.md]

> **Note**: The Validator agent commits its report before returning. Check the agent's output for the commit hash.

### Output Artifacts
- `.context/features/{feature}/implementation/validation-report.md`

### Review Checkpoint

Please review the validation report:
- [ ] **All gates pass** - G1-G8 verified?
- [ ] **Test coverage** - Adequate?
- [ ] **Documentation complete** - All artifacts present?

---

## Phase 4 Complete

### Summary

| Agent | Status | Key Findings |
|-------|--------|--------------|
| Equivalence Checker | ✅ | X/Y scenarios match |
| Invariant Checker | ✅ | X invariants verified |
| Validator | ✅ | All gates pass |

### Quality Gate Status

| Gate | Criteria | Status |
|------|----------|--------|
| G1 | Characterization complete | ✅ |
| G2 | Contract approved | ✅ |
| G3 | Logic extraction (Level B) | ✅/N/A |
| G4 | TDD tests written | ✅ |
| G5 | TDD tests passing | ✅ |
| G6 | Golden master tests pass | ✅ |
| G7 | Property tests pass | ✅ |
| G8 | Integration tests pass | ✅ |
| G9 | Mutation score ≥80% | ⚠️ Optional |
| G10 | Human review | ⏳ Pending |

### Final Recommendation

**Status: READY FOR HUMAN REVIEW**

All automated validation complete. Feature is ready for:
1. Code review by team member
2. Manual testing if needed
3. Merge approval

---

## Complete Artifact Summary

```
.context/features/{feature}/
├── task-description.md          # Human-defined scope (input)
├── README.md                    # Overview & classification
├── behavior-catalog.md          # All behaviors
├── boundary-map.md              # Layer boundaries
├── data-contracts.md            # API contracts
│
├── characterization/
│   ├── test-scenarios.json
│   └── edge-cases.md
│
├── golden-masters/
│   └── scenario-XXX/
│
├── equivalence/
│   └── equivalence-report.md
│
├── verification/
│   └── invariant-report.md
│
└── implementation/
    ├── ui-logic-extraction.md      # (Level B)
    ├── phase-status.md
    └── validation-report.md
```

---

## Next Steps

### For Human Reviewer

1. Read `validation-report.md` for summary
2. Review implementation code in PT10
3. Run manual tests if needed
4. Approve or request changes

### Commit History

All work has been committed incrementally by each subagent during Phases 3-4:

| Phase | Agent | Purpose | Commit |
|-------|-------|---------|--------|
| P3 | Test Writer | Failing tests | {from agent output} |
| P3 | Implementer | Implementation | {from agent output} |
| P3 | Refactorer | Refactored code | {from agent output} |
| P4 | Equivalence Checker | Equivalence report | {from agent output} |
| P4 | Invariant Checker | Invariant report | {from agent output} |
| P4 | Validator | Validation report | {from agent output} |

> **Note**: For Level B/C features, Component Builder commits replace the TDD agent commits.

### After Human Review Approval

1. **Create branch** (if not already on feature branch):
   ```bash
   git checkout -b feature/{feature}-port  # if needed
   ```

2. **Push the branch**:
   ```bash
   git push -u origin feature/{feature}-port
   ```

3. **Create PR** targeting `main` branch

> All code is already committed by the subagents - no additional commit needed.

---

## Progress Tracking

Update `.context/features/{feature}/implementation/phase-status.md`:

```markdown
## Phase 4: Verification
| Agent | Status | Completed | Artifacts |
|-------|--------|-----------|-----------|
| Equivalence Checker | ✅ | {date} | equivalence-report.md |
| Invariant Checker | ✅ | {date} | invariant-report.md |
| Validator | ✅ | {date} | validation-report.md |

## Quality Gates
- G6: Golden Master Tests - ✅
- G7: Property Tests - ✅
- G8: Integration Tests - ✅
- G10: Human Review - ⏳ Pending

## Current: READY FOR HUMAN REVIEW
## Status: All automated verification complete
```
