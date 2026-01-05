# Cross-Cutting Decisions

This file contains architectural and implementation decisions that affect multiple features or the overall porting workflow.

## When to Use This File vs Feature-Specific Decisions

| Decision Type                       | Location                                 |
| ----------------------------------- | ---------------------------------------- |
| Affects multiple features           | This file (`.context/Decisions.md`)      |
| Affects single feature              | `.context/features/{feature}/decisions/` |
| Workflow-level patterns             | This file                                |
| Feature-specific API/implementation | Feature folder                           |

## Purpose

Decisions are recorded to:

- **Preserve context** - Why was this approach chosen?
- **Enable learning** - What worked, what didn't?
- **Support future work** - What constraints exist?
- **Facilitate reviews** - What tradeoffs were considered?

## Decision Record Format

Each decision should follow this template:

```markdown
## Decision {N}: {Title}

**Date**: YYYY-MM-DD
**Phase**: Phase {1-4} - {Phase Name} (or "Cross-Cutting")
**Agent**: {Agent that made the decision}
**Status**: {Proposed | Accepted | Deprecated | Superseded}

### Context

What is the situation that requires a decision? What problem are we trying to solve?

### Options Considered

#### Option 1: {Name}

- **Pros**: {benefits}
- **Cons**: {drawbacks}
- **Effort**: {Low/Medium/High}

#### Option 2: {Name}

- **Pros**: {benefits}
- **Cons**: {drawbacks}
- **Effort**: {Low/Medium/High}

### Decision

What was chosen and why?

### Consequences

- **Positive**: {benefits that follow}
- **Negative**: {costs or risks accepted}
- **Neutral**: {other implications}

### Related Decisions

- Links to related decisions if any
```

## When to Record a Decision

Record decisions when:

1. **Architecture choices** - Component structure, data flow patterns
2. **Technology choices** - Libraries, frameworks, tools
3. **API design** - Interface shapes, method signatures
4. **Testing strategy** - What to test, how to test
5. **Tradeoffs** - Performance vs. readability, scope vs. time
6. **Deviations** - When PT10 differs from PT9 intentionally
7. **Workarounds** - Temporary solutions with future cleanup needed

## Example Cross-Cutting Decision

```markdown
## Decision 1: Use React Query for All Data Fetching

**Date**: 2024-01-15
**Phase**: Cross-Cutting
**Agent**: Human
**Status**: Accepted

### Context

Multiple features need to fetch data from the C# backend via PAPI.
We need a consistent pattern across all features.

### Options Considered

#### Option 1: Raw fetch with useState per feature

- **Pros**: No dependencies, simple
- **Cons**: Inconsistent patterns, duplicated boilerplate
- **Effort**: High (repeated per feature)

#### Option 2: React Query as standard

- **Pros**: Built-in caching, retry, loading states, consistency
- **Cons**: Additional dependency, learning curve
- **Effort**: Low per feature

### Decision

Use React Query as the standard data fetching pattern across all features.
This aligns with existing Platform.Bible extensions.

### Consequences

- **Positive**: Consistent data fetching pattern, automatic cache invalidation
- **Negative**: Team needs familiarity with React Query
- **Neutral**: Establishes a pattern other features must follow
```

## Feature-Specific Decision Structure

For decisions within a feature, use this structure:

```
.context/features/{feature}/decisions/
├── phase-1-decisions.md    # Analysis phase decisions
├── phase-2-decisions.md    # Specification phase decisions
├── phase-3-decisions.md    # Implementation phase decisions
└── phase-4-decisions.md    # Verification phase decisions
```

### Decision Types by Phase

**Phase 1: Analysis**

- Classification decisions (Level A/B/C)
- Scope decisions (in/out of scope)
- Boundary decisions (where to split logic)

**Phase 2: Specification**

- API contract decisions
- Data model decisions
- Golden master scenario selection

**Phase 3: Implementation**

- Architecture patterns used
- Library/framework choices
- Code organization decisions
- Testing approach decisions
- Performance vs. clarity tradeoffs

**Phase 4: Verification**

- Test coverage decisions
- Equivalence tolerance decisions
- Known difference acceptances

## Maintenance

- Decisions are written by the orchestrator at the end of each phase
- Each subagent notes decisions in their output for consolidation
- Human review before finalizing
- Decisions can be updated with status changes (Deprecated, Superseded)

---

## Cross-Cutting Decisions Log

(Record cross-cutting decisions below)
