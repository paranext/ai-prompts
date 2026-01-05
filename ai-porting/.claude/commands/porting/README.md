# Porting Commands

Claude commands for AI-assisted porting of Paratext 9 features to Platform.Bible (Paratext 10).

## Quick Start

To port a feature, run phase commands sequentially:

```bash
/porting/phase-1-analysis {feature-name}
/porting/phase-2-specification {feature-name}
/porting/phase-3-implementation {feature-name}
/porting/phase-4-verification {feature-name}
```

Each phase orchestrates specialized agents with **human review after each agent**.

## Workflow

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PHASE 1: ANALYSIS                          Codebase: PT9              │
│  ┌──────────────────┐  ┌──────────────────┐  ┌────────────────────┐    │
│  │  Archaeologist   │→ │   Classifier     │→ │  Characterizer     │    │
│  └──────────────────┘  └──────────────────┘  └────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  PHASE 2: SPECIFICATION                     Codebase: PT9              │
│  ┌──────────────────┐  ┌──────────────────┐  ┌────────────────────┐    │
│  │ UI Logic Extractor│→ │ Golden Master    │→ │ Contract Writer    │    │
│  │ (Level B only)   │  │    Generator     │  │                    │    │
│  └──────────────────┘  └──────────────────┘  └────────────────────┘    │
│                                   │                                    │
│                   ┌───────────────┴───────────────┐                    │
│                   │  Spec Summary + GitHub Issue  │                    │
│                   │   (Stakeholder Review Gate)   │                    │
│                   └───────────────────────────────┘                    │
└─────────────────────────────────────────────────────────────────────────┘
                                   │
                         [Stakeholder Approval]
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  PHASE 3: IMPLEMENTATION                    Codebase: PT10             │
│  ┌──────────────────┐  ┌──────────────────┐  ┌────────────────────┐    │
│  │  Test Writer     │→ │  Implementer     │→ │   Refactorer       │    │
│  │     (RED)        │  │    (GREEN)       │  │   (REFACTOR)       │    │
│  └──────────────────┘  └──────────────────┘  └────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  PHASE 4: VERIFICATION                      Codebase: PT10             │
│  ┌──────────────────┐  ┌──────────────────┐  ┌────────────────────┐    │
│  │  Equivalence     │→ │   Invariant      │→ │    Validator       │    │
│  │   Checker        │  │    Checker       │  │                    │    │
│  └──────────────────┘  └──────────────────┘  └────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
                         Human Review → Merge
```

## Example Usage

```bash
# Phase 1: Analyze the feature
/porting/phase-1-analysis creating-projects

# Phase 2: Create specs + GitHub issue for stakeholder review
/porting/phase-2-specification creating-projects

# Wait for stakeholder approval on GitHub issue...

# Phase 3: Implement with TDD
/porting/phase-3-implementation creating-projects

# Phase 4: Verify correctness
/porting/phase-4-verification creating-projects
```

## Full Documentation

For complete details on feature classification, testing strategies, quality gates, and artifact structure, see:

- [AI-Porting-Workflow.md](../../../.context/AI-Porting-Workflow.md) — Complete strategy and reference
