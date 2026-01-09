# Batch Testing Approach for AI-Assisted Porting

**Date**: 2025-01-09
**Status**: Analysis Complete
**Related**: Phase 3 Implementation Workflow, Outside-In TDD

## Context

During the design of the Phase 3 implementation workflow, a question arose about whether our "batch testing" approach (Test Writer writes all tests upfront before Implementer runs) aligns with true Outside-In TDD, which is traditionally iterative.

## The Question

> In our current workflow do we practice Outside-In TDD like it's supposed to be done? The TDD Test Writer writes all tests first, right? In real TDD this should be a gradual process.

> In our case, are the inner tests not already clear? Because we are porting the feature, we already captured the requirements in previous phases. But we want to make sure that the code written in PT10 has good architecture, and normal TDD helps with this. Does batch testing still help with this?

## Analysis

### What TDD's Iterative Approach Provides

The key architectural benefit of iterative TDD comes from **design pressure**:

1. **Hard to test → Bad design signal** - If you struggle to write a test, it reveals coupling issues
2. **Incremental emergence** - Design evolves one test at a time, avoiding over-engineering
3. **Just enough abstraction** - You only add abstractions when tests demand them

### What Batch Testing Preserves vs. Loses

| Aspect | Preserved? | Explanation |
|--------|------------|-------------|
| Tests as specification | ✅ Yes | Tests still define WHAT to build |
| Tests constrain scope | ✅ Yes | Agent can't add unrequested features |
| Design pressure from test difficulty | ⚠️ Partial | Test Writer doesn't feel implementation pain |
| Incremental design emergence | ❌ No | Implementer sees all tests at once, may over-design |
| Just enough abstraction | ⚠️ Partial | May create abstractions for all tests at once |

### The Real Risk of Batch Testing

The risk isn't incorrect behavior (tests ensure that), it's **premature abstraction**:

- Implementer sees 10 tests → might create a general solution upfront
- True TDD: sees 1 test → simple solution → sees 2nd test → refactor if needed

### Why Batch Testing Is Acceptable for AI Porting

Our situation is unique. For AI-assisted porting, **batch testing is acceptable** because:

1. **Porting to an established architecture, not discovering one**
   - PT10 (paranext-core) has established patterns
   - We're not doing greenfield design discovery

2. **The Alignment Agent provides design direction**
   - Alignment Agent maps contracts to PT10 patterns before implementation
   - Architectural decisions are made in Step 0, not discovered through TDD

3. **The Refactorer agent handles cleanup**
   - Post-implementation refactoring phase catches over-engineering
   - Code quality issues are addressed after tests pass

4. **Requirements are already captured in Phase 2 specs**
   - Test specifications and golden masters come from PT9 behavior
   - The "what" is completely defined before Phase 3 starts
   - Inner tests are effectively "already clear" from the spec

5. **The outer acceptance test still constrains scope**
   - Even with batch inner tests, the outer test acts as a "fence"
   - Agent knows when it's done (outer test passes)

## Conclusion

**The iterative benefit of TDD (design discovery) is less important when porting to a known architecture.**

For classical TDD on new features, iterative test-implementation cycles help discover the right design. But for porting:

- The source architecture already exists (PT9)
- The target architecture already exists (PT10 patterns)
- The mapping is done by the Alignment Agent

Batch testing is a pragmatic trade-off that:
- ✅ Preserves behavioral correctness guarantees
- ✅ Preserves scope constraint benefits
- ⚠️ Trades design emergence for efficiency
- ✅ Compensates via Alignment Agent + Refactorer

## Recommendation

Keep the current batch workflow for AI-assisted porting:

```
Test Writer → [all tests for capability] → Implementer → Refactorer
```

This is appropriate because:
1. Requirements are pre-defined (Phase 2 specs)
2. Architecture is pre-defined (PT10 patterns via Alignment Agent)
3. Code quality is post-verified (Refactorer agent)

For greenfield features (not porting), consider a more iterative approach where appropriate.

## References

- [Outside-In TDD](https://outsidein.dev/concepts/outside-in-tdd/) - London School TDD
- Phase 3 Implementation Workflow: `.claude/commands/porting/phase-3-implementation.md`
- AI Porting Workflow: `.context/AI-Porting-Workflow.md`
