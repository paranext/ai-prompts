## Usage Instructions

1. Populate all sections before starting AI work. Missing context should be flagged immediately.
2. Attach or link code snippets for AI to process — keep them minimal to reduce hallucination.
3. Reference the Context7 Constitution and Reviewer Checklist in the intake.
4. Feed this template verbatim to the appropriate AI role prompt (Spec Author, Refactoring Engineer, Porting Engineer).
5. Review the AI output against this intake before approving refactors or ports.

## Template

1. Feature Overview
   | Field | Description |
   | ------------------- | ------------------------------------------------------------ |
   | Feature Name | Short descriptive name of the feature |
   | Feature ID / Ticket | Reference to project tracking system |
   | Description | Concise explanation of what the feature does (1–3 sentences) |
   | Business Importance | High / Medium / Low |
   | Scope | Explicit boundaries of what is included/excluded |

2. Goals & Non-Goals
   | Field | Description |
   | ----------------- | -------------------------------------------------- |
   | Goal | What this feature must achieve (behavioral intent) |
   | Non-Goals | What this feature explicitly does NOT cover |
   | Known Constraints | Time, technical, or platform constraints |
   | Success Criteria | Objective criteria for completion / tests passing |

3. Legacy Context
   | Field | Description |
   | ------------------------------------- | ---------------------------------------------------- |
   | Relevant WinForms Code Files | List of files or paths |
   | Relevant Classes / Methods | Key classes or functions involved |
   | Known Legacy Patterns / Anti-Patterns | Any problematic patterns to be refactored or avoided |
   | Existing Tests | Names / paths of characterization tests |

4. Inputs for AI
   | Field | Description |
   | ----------------------- | ----------------------------------------------------- |
   | Spec Input | Behavioral expectations, edge cases, invariants |
   | Refactor Constraints | Layering, MVVM principles, testability notes |
   | Porting Constraints | Target platform rules, mapping notes, API differences |
   | Excluded Code / Modules | Parts of the codebase not relevant to this feature |

5. Edge Cases & Special Notes
   | Field | Description |
   | -------------------------- | ----------------------------------------------- |
   | Edge Cases | Any known tricky behavior or uncommon paths |
   | Data Constraints | Expected ranges, formats, or validations |
   | Error Handling | Expected behavior under invalid inputs |
   | Performance Considerations | Timing, async behavior, or computational limits |

6. Test & Verification Notes
   | Field | Description |
   | ----------------------------- | ------------------------------------------- |
   | Characterization Tests Needed | Tests capturing legacy behavior |
   | Acceptance Tests Needed | Tests capturing intended behavior |
   | Test Dependencies | Any special setup required to run tests |
   | Manual Verification Steps | Steps the human reviewer or dev must follow |

7. Reviewer / Dev Notes
   | Field | Description |
   | ----------------------- | ----------------------------------------- |
   | Human Reviewer Assigned | Name of reviewer for this feature |
   | Dev Lead Assigned | Name of lead developer overseeing AI work |
   | Priority | High / Medium / Low |
   | Additional Instructions | Anything else AI or dev needs to know |
