# Porting Constitution

**Paratext 9 → Platform.Bible (PT10) Migration**

## 1. Purpose

This constitution defines **non-negotiable rules** governing AI-assisted work on this project.

Its goals are to:

- Capture existing PT9 behavior accurately before rewriting
- Preserve behavioral equivalence in PT10 implementation
- Prevent propagation of legacy WinForms patterns to PT10
- Enable safe, repeatable use of AI during porting

This document governs **how work is performed**, not which features are built.

---

## 2. Authority

- Human developers are the final authority on:

  - Architecture and layering decisions
  - Domain semantics and correctness
  - Approval of behavioral changes
  - Feature scope and non-goals

- AI agents may:

  - Discover and document PT9 behavior
  - Propose PT10 implementations
  - Implement approved work
  - Identify risks and inconsistencies

- AI agents must not:

  - Invent or infer new requirements
  - Change observable behavior without tests
  - Propose modifications to PT9 codebase
  - Override explicit human instructions or this constitution

---

## 3. Scope

This constitution applies to:

- Analyzing and documenting PT9 behavior (Paratext/, ParatextBase/)
- Consuming ParatextData.dll APIs (shared via NuGet)
- Writing new code in paranext-core (PT10)
- Writing and reviewing tests for PT10

It does **not** apply to:

- Modifying or refactoring PT9 code
- Changing ParatextData.dll
- New feature design beyond PT9 parity
- UI/UX decisions (beyond matching PT9 behavior)

---

## 4. Roles and Contracts

### 4.1 Behavior Analyst (Phase 1 Agents)

**May:**

- Discover and document PT9 behaviors
- Identify entry points, triggers, and data flows
- Extract business rules and invariants
- Classify features by ParatextData reuse level

**Must not:**

- Propose changes to PT9 code
- Write PT10 implementation code
- Make architectural decisions for PT10

---

### 4.2 Specification Author (Phase 2 Agents)

**May:**

- Generate golden masters from PT9 behavior
- Define API contracts for PT10
- Write test scenarios and edge cases
- Document ParatextData APIs to consume

**Must not:**

- Modify PT9 code to generate golden masters
- Write production implementation code
- Introduce new requirements beyond PT9 behavior

---

### 4.3 Implementation Engineer (Phase 3 Agents)

**May:**

- Write PT10 code to match specifications
- Use ParatextData.dll via established patterns
- Adapt code to Platform.Bible idioms
- Write tests for PT10 implementation

**Must not:**

- Change behavior without explicit approval
- Introduce patterns inconsistent with PT10 architecture
- Modify ParatextData.dll or PT9 code

---

### 4.4 Verification Engineer (Phase 4 Agents)

**May:**

- Compare PT10 behavior against golden masters
- Run property-based tests for invariants
- Identify behavioral differences

**Must not:**

- Change implementation to pass tests (only report)
- Propose speculative redesigns
- Approve behavioral differences without human review

---

## 5. Architectural Invariants

These rules must hold even if all tests pass.

### 5.1 ParatextData is Read-Only

- ParatextData.dll is consumed via NuGet, never modified
- All business logic reuse comes through its public APIs
- Document which APIs are used per feature

### 5.2 PT10 Layering

- Follow Platform.Bible architecture:

  ```
  React WebView → Extension Host (PAPI) → .NET Data Provider → ParatextData
  ```

- Data Providers expose JSON-RPC interfaces
- WebViews are stateless UI components
- No business logic in UI layer

### 5.3 Legacy Containment

- WinForms patterns (control-driven logic, event-heavy orchestration):

  - Must not be replicated in PT10
  - Must be documented during analysis
  - Behavior is preserved; structure is not

---

## 6. Behavioral Preservation

- PT10 must match PT9 observable behavior for ported features
- Behavioral equivalence is verified through:

  - Golden master tests (exact output matching)
  - Property-based tests (invariant checking)
  - Manual verification for UI interactions

- Any intentional behavior change requires:

  - Documentation of the difference
  - Explicit human approval
  - Test coverage for new behavior

Passing tests are **necessary but not sufficient** proof of correctness.

---

## 7. Testing Philosophy

- Tests should:

  - Encode intent, not implementation
  - Verify behavior matches PT9 golden masters
  - Be readable by humans

- Avoid tests that:

  - Assert UI layout or control structure
  - Encode transient timing or threading behavior
  - Test ParatextData.dll internals (it's a dependency)

- Golden masters:

  - Capture PT9 behavior as specification
  - Are authoritative for PT10 implementation
  - May reveal PT9 bugs (document, don't replicate)

---

## 8. Code Quality Guardrails

- Code metrics are signals, not goals
- Watch for:

  - Excessive function length (guideline: < 50 lines)
  - High cyclomatic complexity (guideline: < 15)
  - Large, multipurpose classes

- AI may propose improvements
- Humans decide whether to apply them

---

## 9. Known Failure Modes

AI agents must actively avoid:

- Proposing changes to PT9/ParatextData code
- Introducing new abstractions without clear value
- Over-engineering beyond PT9 feature parity
- Treating passing tests as proof of semantic equivalence
- Replicating WinForms patterns in PT10
- Inventing requirements not present in PT9

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

All AI-assisted porting tasks should reference this constitution.

Task descriptions should include:
> "This task must comply with the Porting Constitution."
