# AI-Assisted WinForms → Electron Porting Workflow

## Guiding Principles

- **Refactor before port**
- **Behavior before structure**
- **Structure before translation**
- **AI operates under explicit constraints**
- **Humans own architectural decisions**

---

## Roles (Stable Personas)

- **Dev** — Human development manager / reviewer
- **AI – Spec Author** — Defines behavior and invariants
- **AI – Refactoring Engineer** — Refactors C# only
- **AI – Porting Engineer** — Ports to `paranext-core` only
- **AI – Reviewer** — Checklist-driven review only

> Roles are conceptual and enforced via prompts; AI must not switch roles mid-step.

---

## Phase 0: Feature Intake (Human-Led)

- Dev:
  - Define feature boundary
  - Identify explicit **non-goals**
  - Identify UI → domain seams
  - Confirm feature suitability for AI-assisted work

---

## Phase 1: Context & Specification

- Dev:

  - Assemble **context packet**, including:
    - Relevant source files only
    - Architectural constraints (MVVM, layering, async rules)
    - Known edge cases and domain rules

- AI – Spec Author:

  - Produce:
    - Behavioral specification
    - Invariants and guarantees
    - Acceptance criteria

- Dev:
  - Review and approve specification

> No tests and no code in this phase.

---

## Phase 2: Characterization Tests (C#)

- AI – Spec Author:

  - Write **characterization tests** capturing current behavior

- Dev:

  - Review tests for:
    - Over-fitting to UI mechanics
    - Implicit UI flow assumptions

- Dev:
  - Lock tests as baseline

---

## Phase 3: Refactor Only (C#)

- AI – Refactoring Engineer:

  - Refactor legacy code toward MVVM and testable structure
  - Extract services and domain logic
  - **No porting considerations allowed**

- Dev:

  - Run tests
  - Review:
    - Architecture
    - Dependency direction
    - Metrics (function size, complexity, file size)

- AI – Refactoring Engineer:
  - Address review feedback

---

## Phase 4: Port Specification Alignment

- Dev:

  - Define conceptual mapping:
    - Refactored C# components → `paranext-core` equivalents

- AI – Spec Author:
  - Adapt specifications for `paranext-core` semantics

---

## Phase 5: Test Port

- AI – Porting Engineer:

  - Port approved tests to `paranext-core`

- Dev:
  - Review tests for semantic fidelity and intent preservation

---

## Phase 6: Code Port

- AI – Porting Engineer:

  - Port refactored implementation to `paranext-core`

- Dev:
  - Run tests
  - Perform targeted manual verification

---

## Phase 7: Review & Hardening

- AI – Reviewer:

  - Checklist-based review:
    - MVVM purity
    - Layering and dependency direction
    - Function length and complexity
    - Test clarity and intent

- Dev:

  - Decide which feedback to apply

- AI:
  - Implement approved changes

---

## Phase 8: PR & Human Review

- Dev:

  - Create pull request

- AI – Reviewer:

  - Diff-level review only (no architectural changes)

- Dev:

  - Apply selected feedback

- Dev:

  - Request human peer review

- Dev:
  - Merge PR

---

## Notes

- Context7 should store **architectural rules, invariants, and porting policies**, not large code excerpts.

- AI must never:
  - Invent requirements
  - Change behavior without tests
  - Combine refactoring and porting concerns

---
