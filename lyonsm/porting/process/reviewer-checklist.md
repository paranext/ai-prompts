Here’s a **practical, operational Reviewer Checklist** tailored specifically for your migration workflow. It’s designed to be **copy/pasteable, actionable, and role-aligned**. This checklist is meant to be used by both **human reviewers and the AI Reviewer persona**.

It’s organized by **high-level category**, with specific yes/no questions or quick assessments. Any “No” should trigger further investigation.

---

# Reviewer Checklist – WinForms → Electron / paranext-core Migration

## 1. Constitution Compliance

| Question                                                                          | Pass / Fail / N/A | Notes |
| --------------------------------------------------------------------------------- | ----------------- | ----- |
| Does the code obey **layering rules**? (UI → ViewModel → Domain → Infrastructure) |                   |       |
| Does the ViewModel contain **no direct UI control references**?                   |                   |       |
| Is business logic **fully isolated from UI**?                                     |                   |       |
| Are legacy WinForms patterns **fully contained or removed**?                      |                   |       |
| Are any changes **outside the assigned role**?                                    |                   |       |
| Are any behavior changes **unsupported by tests or human approval**?              |                   |       |

---

## 2. Behavioral Preservation

| Question                                                  | Pass / Fail / N/A | Notes |
| --------------------------------------------------------- | ----------------- | ----- |
| Do all characterization and acceptance tests **pass**?    |                   |       |
| Do tests cover all critical edge cases noted in the spec? |                   |       |
| Are there any **unintended side-effects** in behavior?    |                   |       |
| Are invariants (from the spec) preserved?                 |                   |       |

---

## 3. Architecture & Structure

| Question                                                    | Pass / Fail / N/A | Notes |
| ----------------------------------------------------------- | ----------------- | ----- |
| Are functions / methods **reasonably sized** (< ~50 lines)? |                   |       |
| Are classes cohesive (single responsibility)?               |                   |       |
| Are there **no circular dependencies** between layers?      |                   |       |
| Does the refactor improve **testability and clarity**?      |                   |       |
| Are async boundaries, if any, **correctly implemented**?    |                   |       |

---

## 4. Code Quality & Metrics

| Question                                                           | Pass / Fail / N/A | Notes |
| ------------------------------------------------------------------ | ----------------- | ----- |
| Cyclomatic complexity acceptable? (< 15 per function is guideline) |                   |       |
| File size reasonable? (< 1,000 LOC per file preferred)             |                   |       |
| Naming is consistent and meaningful                                |                   |       |
| Dead code removed / commented clearly                              |                   |       |
| No temporary or “hack” constructs left in                          |                   |       |

---

## 5. Tests & Coverage

| Question                                                | Pass / Fail / N/A | Notes |
| ------------------------------------------------------- | ----------------- | ----- |
| Tests encode **intent, not implementation**             |                   |       |
| No tests assert **UI layout or control existence**      |                   |       |
| Tests are **readable and maintainable**                 |                   |       |
| Ported tests faithfully reproduce semantics of C# tests |                   |       |
| Any gaps in coverage are documented                     |                   |       |

---

## 6. Porting / Platform Alignment

| Question                                 | Pass / Fail / N/A | Notes |
| ---------------------------------------- | ----------------- | ----- |
| C# → paranext-core mapping documented    |                   |       |
| No leftover WinForms code / dependencies |                   |       |
| Ported code follows **platform idioms**  |                   |       |
| Any mismatches or compromises flagged    |                   |       |

---

## 7. Risk & Escalation

| Question                                              | Pass / Fail / N/A   | Notes |
| ----------------------------------------------------- | ------------------- | ----- |
| Are there unresolved ambiguities?                     |                     |       |
| Any known failure modes triggered? (see Constitution) |                     |       |
| Are there flagged areas requiring human review?       |                     |       |
| Overall confidence in merging this PR                 | High / Medium / Low |       |

---

### Usage Notes

- Any “Fail” should **require a written explanation** and ideally a human follow-up.
- AI Reviewers should **only flag items**, not fix them.
- Humans may treat “Medium / Low” confidence as a **blocker until resolved**.
- This checklist should accompany every PR or AI output review.

---
