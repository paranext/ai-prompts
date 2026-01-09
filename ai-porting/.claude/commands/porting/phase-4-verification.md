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
- [ ] Branches active:
  - ai-prompts: `feature/{feature-name}` (Phase 3-4 artifacts)
  - paranext-core: `feature/{feature-name}` (tests and implementation)

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

### Commit Checkpoint

Commit the equivalence report (in ai-prompts repo):
```bash
git add .context/features/{feature}/equivalence/
git commit -m "Phase 4: Equivalence Checker complete for {feature}"
```

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

### Commit Checkpoint

Commit the invariant report (in ai-prompts repo):
```bash
git add .context/features/{feature}/verification/
git commit -m "Phase 4: Invariant Checker complete for {feature}"
```

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

### Commit Checkpoint

Commit the validation report (in ai-prompts repo):
```bash
git add .context/features/{feature}/
git commit -m "Phase 4: Validator complete for {feature}"
```

---

## Step 4: Update GitHub Issue (Verification Results)

Update the GitHub issue created in Phase 1 with verification results.

### Update GitHub Issue Content

Update `.context/features/{feature}/github-issue.md` with final status:

```markdown
# {Feature Name} - Verification Complete (Phase 4)

> **Status**: Phase 4 Verification complete - awaiting Implementation Approval (G10)

## Quick Reference

| Attribute | Value |
|-----------|-------|
| Classification | Level {A/B/C} |
| ParatextData Reuse | {X}% |
| Effort | {Low/Medium/High} |
| Strategy | {Full TDD / Hybrid / Component-First} |

## Verification Results

| Check | Status |
|-------|--------|
| Equivalence Tests | ✅ {X/Y} scenarios pass |
| Property Tests | ✅ {N} invariants verified |
| Integration Tests | ✅ All pass |
| Mutation Score | {X}% (if applicable) |

## Quality Gates

All gates passed - see [validation-report.md](./implementation/validation-report.md) for details.

## PRs

- **paranext-core PR**: #{pr-number} - Implementation PR for review

## Next Steps

- [ ] Review and approve implementation PR
- [ ] Merge to main
- [ ] Close this issue

---
> 🤖 Auto-generated by Phase 4 Verification workflow
```

### Update the GitHub Issue

```bash
gh issue edit {issue-number} \
  --body-file .context/features/{feature}/github-issue.md
```

### Commit the updated GitHub Issue file

```bash
git add .context/features/{feature}/github-issue.md
git commit -m "Phase 4: GitHub issue updated with verification results for {feature}"
```

---

## Step 5: Implementation Approval Gate (G10)

**⚠️ FINAL BLOCKING GATE**: The implementation PR must be approved before the feature is complete.

### Create Pull Request in paranext-core

Create a PR from the feature branch to main in the paranext-core repository:

```bash
gh pr create \
  --title "Port: {Feature Name}" \
  --body "## Summary

Implementation of {Feature Name} ported from PT9.

## Classification

- **Level**: {A/B/C}
- **Strategy**: {Full TDD / Hybrid / Component-First}

## Artifacts

See ai-prompts repo for full specification and verification:
- GitHub Issue: #{issue-number}
- [behavior-catalog.md](link-to-ai-prompts)
- [data-contracts.md](link-to-ai-prompts)
- [validation-report.md](link-to-ai-prompts)

## Quality Gates

All gates passed:
- G1-G3.5: Discovery and Specification ✅
- G4-G5: TDD Tests ✅
- G6-G8: Verification ✅
- G10: Implementation PR (this PR)

## Test Results

- Unit tests: {X} tests, all passing
- Property tests: {N} invariants verified
- Equivalence tests: {X/Y} scenarios match PT9

## Changes

### C# (paranext-core/c-sharp/)
- {list of C# files}

### TypeScript (paranext-core/extensions/)
- {list of TypeScript files}

### Tests
- {list of test files}

🤖 Generated with porting workflow" \
  --base main
```

### What Reviewers Should Check

- [ ] Implementation follows PT10 patterns
- [ ] Tests are comprehensive and meaningful
- [ ] No security vulnerabilities introduced
- [ ] Code quality is acceptable
- [ ] Verification reports show all gates passed

### Approval Process

1. Reviewers review the PR in paranext-core
2. Comments/questions are addressed
3. PR is approved
4. PR is merged to main
5. GitHub issue is closed
6. **Feature port is complete!**

### Close GitHub Issue

After the PR is merged:
```bash
gh issue close {issue-number} --comment "Feature ported successfully! PR #{pr-number} merged."
```

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
