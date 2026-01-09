# Strategic Analysis: AI-Assisted Porting Workflow Goals & Measurement

**Date**: 2026-01-07
**Author**: Claude Code (AI-assisted analysis)
**Status**: Draft for discussion

## The Core Question

**Can we find a repeatable pattern for porting Paratext 9 features to paranext-core that is significantly faster than manual porting while retaining at least the same quality we would get by doing it by hand?**

---

## 1. Goals of This Effort

Based on analysis of AI-Porting-Workflow.md, the goals are:

### Primary Goal
Port PT9 features to PT10 (Platform.Bible) with **behavioral equivalence** - PT10 must do exactly what PT9 does for the same inputs.

### Secondary Goals
1. **Speed**: Complete porting faster than manual development
2. **Quality**: Match or exceed manual development quality (fewer defects, better test coverage)
3. **Repeatability**: Establish a pattern that works across all 6+ target features
4. **Knowledge Capture**: Document PT9 behavior systematically (valuable even if porting fails)

### Success Criteria (Implicit)
- All 10 quality gates (G1-G10) pass for each feature
- Behavioral equivalence proven via golden master tests
- Test coverage ≥90% line, ≥80% branch
- Human reviewers approve with confidence

---

## 2. How to Measure Quality

### Currently Defined Quality Metrics

| Metric | Threshold | Evidence |
|--------|-----------|----------|
| **Code Coverage** | ≥90% line, ≥80% branch | vitest/coverlet reports |
| **Mutation Score** | ≥70% (critical paths) | Stryker reports |
| **Property Tests** | 100-1000 iterations per invariant | test-evidence-invariants.log |
| **Behavioral Equivalence** | 100% golden master match | test-evidence-equivalence.log |
| **Traceability** | 100% BHV→TS→Test coverage | traceability-report.md |
| **Visual Verification** | Screenshots for all features | visual-evidence/*.png |

### Quality Gates Checklist (G1-G10)

| Gate | Pass Criteria | Blocking? |
|------|---------------|-----------|
| G1 | test-scenarios.json exists | Yes |
| G2 | Human sign-off on data-contracts.md | Yes |
| G3 | ui-logic-extraction.md complete (Level B) | Yes |
| G4 | Tests compile and FAIL (RED) | Yes |
| G4.5 | Test quality verified (no anti-patterns) | Yes |
| G5 | Tests PASS (GREEN) | Yes |
| G6 | Golden master tests pass | Yes |
| G7 | Property tests pass with iteration counts | Yes |
| G8 | Integration tests pass | Yes |
| G9 | Mutation score ≥70% | Advisory→Blocking |
| G10 | Human review approved | Yes |

### Gaps in Quality Measurement

1. **Coverage thresholds not enforced** - vitest.config.ts has all thresholds at 0
2. **No defect tracking** - No way to compare defects found in AI vs manual porting
3. **No comparison baseline** - No record of PT9 manual development defect rates
4. **E2E testing absent** - Cross-process integration untested

### Recommended Quality Scorecard

For each feature, track:
```
Feature: {name}
Level: {A|B|C}

QUALITY METRICS:
├── Coverage: {line}% / {branch}% (target: 90/80)
├── Mutation: {score}% (target: 70%)
├── Traceability: {behaviors}/{scenarios}/{tests} (100% mapped)
├── Property Tests: {count} invariants × {iterations} iterations
├── Golden Masters: {passed}/{total} (100% match)
└── Defects Found: {count} (before vs after human review)

GATES PASSED: G1 ✓ G2 ✓ G3 ✓ ... G10 ✓
```

---

## 3. How to Measure Velocity

### Current Tracking Mechanisms

1. **Audit Logs**: Session timestamps, tool counts per session
2. **Phase Status**: Completion dates per phase (not durations)
3. **Artifact Counts**: Behaviors, scenarios, golden masters documented

### What's Missing

| Missing Metric | Why It Matters |
|----------------|----------------|
| **Phase duration** | How long does Analysis take vs Implementation? |
| **Human review time** | Bottleneck identification |
| **Rework cycles** | How often does work get rejected? |
| **Agent time vs total time** | What % is AI work vs human review? |
| **Comparison baseline** | How long would manual porting take? |

### Recommended Velocity Metrics

**Per-Feature Tracking:**
```
Feature: {name}
Start Date: {date}
End Date: {date}
Total Duration: {days}

PHASE BREAKDOWN:
├── Phase 1 (Analysis): {hours} AI + {hours} review = {hours} total
├── Phase 2 (Specification): {hours} AI + {hours} review = {hours} total
├── Phase 3 (Implementation): {hours} AI + {hours} review = {hours} total
└── Phase 4 (Verification): {hours} AI + {hours} review = {hours} total

REWORK:
├── Gate failures: {count}
├── Rejections: {count}
└── Total rework hours: {hours}

EFFICIENCY:
├── AI work time: {hours}
├── Human review time: {hours}
└── Ratio: {AI}:{Human}
```

**Cross-Feature Comparison:**
```
| Feature | Level | Total Days | AI Hours | Review Hours | Rework % |
|---------|-------|------------|----------|--------------|----------|
| Creating Projects | A | ? | ? | ? | ? |
| Checklists | C | ? | ? | ? | ? |
```

### How to Compare AI vs Manual

**Manual Baseline Estimate:**
- Survey team: "How long would Creating Projects take to port manually?"
- Include: discovery, design, implementation, testing, review, debugging
- Capture: defects found during development, post-release defects

**AI Velocity Formula:**
```
Speedup = Manual_Total_Time / AI_Total_Time
Quality_Parity = (Manual_Defects - AI_Defects) / Manual_Defects
```

**Target Hypothesis:**
- AI should be **2-3x faster** than manual porting
- AI should have **equal or fewer defects** (due to comprehensive testing)

---

## 4. How to Ensure Repeatability

### Current Repeatability Mechanisms

| Mechanism | Standardization Level |
|-----------|----------------------|
| **Artifact Templates** | 95% - Explicit structures for all outputs |
| **Agent Prompts** | 85% - Detailed but some subjectivity |
| **Quality Gates** | 80% - G4.5 depends on human judgment |
| **Classification System** | 100% - A/B/C levels clearly defined |
| **Traceability IDs** | 100% - BHV/TS/INV patterns enforced |

### Sources of Variability

1. **Test scenario volume** - No saturation criteria (65 vs 85 scenarios)
2. **Golden master adequacy** - No "enough" definition
3. **Alignment decisions** - Subjective PT10 pattern choices
4. **Component-First convergence** - Visual match is subjective
5. **Human review standards** - Varies by reviewer

### Recommendations to Improve Repeatability

**1. Define Saturation Criteria:**
```
Test Scenarios Complete When:
- Every behavior has ≥1 scenario
- Every edge case documented in edge-cases.md has ≥1 scenario
- ≥3 scenarios per high-complexity behavior
```

**2. Golden Master Adequacy Checklist:**
```
Golden Masters Sufficient When:
- ≥1 master per behavior cluster
- All edge cases have masters
- Error states captured
```

**3. Automated G4.5 Validation:**
- Script that counts mocks per test (reject if >3)
- Detect implementation-mirroring patterns
- Verify Revert Test compliance

**4. Explicit Alignment Templates:**
- Decision trees for common PT10 choices
- "Extension X vs new extension" criteria

**5. Reviewer Calibration:**
- Standard review checklist
- Cross-reviewer consistency checks

---

## 5. Summary: Goals Framework

| Dimension | Goal | How to Measure | Current Gap |
|-----------|------|----------------|-------------|
| **Quality** | Match or exceed manual | Coverage, mutation, gates, defects | No defect baseline, thresholds not enforced |
| **Velocity** | 2-3x faster than manual | Phase durations, total time, rework % | No time tracking, no manual baseline |
| **Repeatability** | Same pattern for all features | Variance across features, gate pass rates | No saturation criteria, subjective reviews |

---

## 6. Open Questions for Discussion

1. **What is the manual baseline?** How long did similar PT9 features take to develop originally? This is critical for measuring speedup.

2. **What defect rate is acceptable?** Is "zero defects after human review" the bar, or some other threshold?

3. **How do we track time?** Should we add timestamps to phase-status.md? Require human review time logging?

4. **What's the minimum viable measurement?** Full metrics dashboard vs lightweight tracking for first features?

5. **How do we handle feature variation?** Level A (Creating Projects) vs Level C (Checklists) will have very different profiles - should we track separately?

---

## 7. Recommended Next Steps

1. **Document manual baseline estimate** for Creating Projects (Level A)
2. **Add time tracking fields** to phase-status.md template
3. **Create feature velocity tracker** (spreadsheet or simple file)
4. **Run first full cycle** on Creating Projects with measurement
5. **Retrospective** after first feature to calibrate expectations

---

## References

- [AI-Porting-Workflow.md](../AI-Porting-Workflow.md) - Master workflow document
- [Testing-Guide.md](../standards/Testing-Guide.md) - Testing standards and patterns
- [creating-projects/](../features/creating-projects/) - Level A feature example (Phase 2 complete)
- [checklists/](../features/checklists/) - Level C feature example (Phase 2 complete)
