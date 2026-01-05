TODO and Questions:

Vladimir:

- example projects that show features to implement? Can you give a demo of the features?
- designs?
- requirements? In scope, out of scope, what is different in PT10?
- planning, when should features be ready?

- does output of phase 1 and 2 covers all feature details? everything we need for a rewrite in new project? able to recreate the UI?
- review phase 4
- review CLAUDE.md files
- let ai capture screenshots from old app, or use design new app? Or else dont compare to gold masters in component-builder. The design of new features must align with existing paranext design?
- find or ask for styling guide / design, add to standards and reference in relevant agent files

- Make sure skills and Claude Code Chrome Integration works (chrome extension) https://code.claude.com/docs/en/chrome
  Integrate in implementation phase
- move .context/standards to .claude/rules?

DONE:

- remove duplication in output of phase 1 and 2
- review architecture docs (align with implementation agents)
- review git pr review guide
- Create skill to create Git worktrees. create worktree in phase 3 (if working on features in parallel)?
- Do a dry run on phase 3 to identify gaps or missing artifacts (design,screenshots?). Are all artifacts relevant? Are all artifacts utilized in phase 3 or 4?
- Let ai browse the paratext wiki for useful context
- Let codex review the porting workflow
- Create relevant skills in .claude/skills folder. Mention skills in the specific sub agents definition files in .claude/agents folder (are there relevant skills to use in old code base?)
- Ask ai what skills to create (to help ai validate code)
- Make clear in skill description in what code base to run (paranext)
- Implementation sub agent should create and save plan to file first and ask for approval
- make sure sub agents write decicisions made to decisions folder
- Make sure ai validates / proofs its work in phase 3 implementation: tests, lint, typecheck, build should pass
- If not TDD, check if tests are created
- In Phase 3 and 4 work should be committed after each sub agent completes (at least). Also after iterations initiated by developers
- Review phase 1 and 2
- Generate artifacts for 1 or more feature to test phase 1 and 2
- make sure the claude folder and files in separate repo are working on local machine
- make it possible to copy AI porting (Claude files) to both Paratext and paranext-core repo (examples in readme)
- After pull rerun the setup script to create new symlinks etc
- Symlinks for Claude.md files should be optional (only for paranext core)
- Sub agents should also do research and make a plan first ? And ask for approval of the plan before implementation starts. Can this be done by running Claude code in plan mode or better make it explicit? Phase 3 (implementation) should have this, other phases?
- Store the plan in a file and let it also act as a scratchpad or checklist
- what tests are available in pt9 code base that we can use?
- Add explanation in ai porting strategy markdown for all the outputs we generate in phase 1 and 2, why are we creating them?
- check in phase 1 or 2 if it is suitable to practice tdd. If not, how to proceed with implementation?
- Make sure decisions or learnings made during agent implementation phase sessions are captured in .context/features/{feature}/decisions/ folder (or .context/Decisions.md for cross-cutting decisions)
- make sure AI-Porting-Workflow.md is read (mention in each phase command?)
- Make sure sub agents have the relevant output of previous agents in their context
- is paratext-data well tested and completely ready for usage in paratext 10 repo?
- Make sure agents write Typedoc comments (align with repo practices)
