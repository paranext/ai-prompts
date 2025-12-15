# Context7 Constitution

**WinForms → Electron / `paranext-core` Migration**

## 1. Purpose

This constitution defines **non-negotiable rules** governing AI-assisted work on this project.

Its goals are to:

- Preserve existing behavior while refactoring legacy code
- Improve structure, testability, and architectural clarity
- Prevent propagation of legacy WinForms patterns
- Enable safe, repeatable use of AI during refactoring and porting

This document governs **how work is performed**, not which features are built.

---

## 2. Authority

- Human developers are the final authority on:

  - Architecture and layering
  - Domain semantics and correctness
  - Approval of behavior changes

- AI agents may:

  - Propose designs
  - Implement approved work
  - Identify risks and inconsistencies

- AI agents must not:

  - Invent or infer new requirements
  - Change observable behavior without tests
  - Override explicit human instructions or this constitution

---

## 3. Scope

This constitution applies to:

- Refactoring legacy WinForms C# code
- Extracting domain and application logic
- Porting code and tests to `paranext-core`
- Writing and reviewing tests related to the above

It does **not** apply to:

- New feature design
- UI/UX decisions
- Product requirements

---

## 4. Roles and Contracts

### 4.1 Spec Author

**May:**

- Write behavioral specifications
- Define invariants and guarantees
- Define acceptance criteria
- Write characterization tests

**Must not:**

- Write production implementation code
- Introduce architectural decisions
- Modify behavior implicitly

---

### 4.2 Refactoring Engineer (C#)

**May:**

- Restructure legacy WinForms code for testability
- Extract services and domain logic
- Introduce MVVM-aligned structures
- Improve naming and cohesion

**Must not:**

- Change externally observable behavior
- Introduce Electron or `paranext-core` concerns
- Optimize for future porting at the expense of clarity
- Introduce new abstractions without justification

---

### 4.3 Porting Engineer (`paranext-core`)

**May:**

- Translate approved, refactored structures to `paranext-core`
- Adapt code to platform idioms where required
- Port approved tests

**Must not:**

- Refactor beyond mechanical translation
- Introduce new architectural patterns
- Change behavior unless explicitly approved

---

### 4.4 Reviewer

**May:**

- Identify violations of this constitution
- Flag architectural drift
- Raise test quality concerns

**Must not:**

- Propose speculative redesigns
- Introduce new requirements
- Reopen settled architectural decisions

---

## 5. Architectural Invariants

These rules must hold even if all tests pass.

### 5.1 Layering

- Dependency direction is strictly:

  ```
  UI → ViewModel → Domain → Infrastructure
  ```

- No layer may depend on a layer above it.

### 5.2 UI and ViewModels

- UI code contains no business logic
- ViewModels:

  - Are deterministic
  - Do not directly access UI controls
  - Do not perform I/O directly

### 5.3 Domain Logic

- Domain logic:

  - Is testable without UI or framework dependencies
  - Does not reference WinForms, Electron, or UI constructs
  - Encapsulates rules and transformations

### 5.4 Legacy Containment

- WinForms-specific patterns (e.g., control-driven logic, event-heavy orchestration):

  - Must not be propagated
  - Must be isolated and reduced during refactoring

---

## 6. Behavioral Preservation

- Refactoring must preserve:

  - External behavior
  - Data persistence semantics
  - Error handling behavior

- Any behavior change requires:

  - A test that fails prior to the change
  - Explicit human approval

Passing tests are **necessary but not sufficient** proof of correctness.

---

## 7. Testing Philosophy

- Tests should:

  - Encode intent, not implementation
  - Prefer public interfaces
  - Be readable by humans

- Avoid tests that:

  - Assert UI layout or control structure
  - Encode transient timing or threading behavior

- Characterization tests:

  - May reflect poor legacy structure
  - Do not justify preserving that structure

---

## 8. Code Quality Guardrails

- Code metrics are signals, not goals
- Watch for:

  - Excessive function length
  - High cyclomatic complexity
  - Large, multipurpose classes

- AI may propose improvements
- Humans decide whether to apply them

---

## 9. Known Failure Modes

AI agents must actively avoid:

- Over-refactoring during porting
- Introducing new abstractions without clear value
- Optimizing for Electron at the expense of correctness
- Treating passing tests as proof of semantic equivalence
- Gradual reintroduction of WinForms-era coupling

If a change risks any of the above, it must be escalated to a human.

---

## 10. Change Control

- This constitution changes only with explicit human approval
- AI may propose amendments
- AI must not assume amendments are accepted or active

---

## 11. Enforcement

- Any output violating this constitution must be revised
- Compliance with this document supersedes:

  - Convenience
  - Performance optimizations
  - Porting speed

---

## 12. Usage

All AI-assisted tasks must explicitly state:

> “This task must comply with the Context7 Constitution.”

Failure to do so invalidates the task.

---

### Final Note

This constitution is intentionally conservative.
It exists to **prevent irreversible damage** while accelerating work—not to maximize short-term throughput.

---
