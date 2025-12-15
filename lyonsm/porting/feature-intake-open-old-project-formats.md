## Usage Instructions

1. Populate all sections before starting AI work. Missing context should be flagged immediately.
2. Attach or link code snippets for AI to process — keep them minimal to reduce hallucination.
3. Reference the Context7 Constitution and Reviewer Checklist in the intake.
4. Feed this template verbatim to the appropriate AI role prompt (Spec Author, Refactoring Engineer, Porting Engineer).
5. Review the AI output against this intake before approving refactors or ports.

## Template

1. Feature Overview
   Feature Name: Migrate old project formats
   Description: Prior to Paratext 9, project files were stored as a different set of files. Platform.Bible needs to be able to open those older project types, too.
   Business Importance: High
   Scope: We only need to be able to perform this migration within the scope classes that override ScrTextCollection.MigrateProjectsIfNeeded().

2. Goals & Non-Goals
   Goal: This feature is meant to allow opening old project file formats as if they are new project formats.
   Non-Goals: This feature is not meant to force migration on disk old project file formats. There are cases where the project files will be read-only.
   Known Constraints: None
   Success Criteria: All p8z files under ~/dbl-downloader can be opened successfully.

3. Legacy Context
   Relevant WinForms Code Files: Paratext/ParatextBase/ParatextScrTextCollection.cs, Paratext/ParatextData/ScrTextCollection.cs
   Relevant Classes: ParatextScrTextCollection, ScrTextCollection
   Known Legacy Patterns / Anti-Patterns: None
   Existing Tests: None - Use some p8z files from ~/dbl-downloader as sample inputs for new tests.

4. Inputs for AI
   Spec Input: None
   Refactor Constraints: All of the code should be handled as business logic. No UI should be involved in the transformation. All code should remain in C#. Functions in ParatextData.dll can be used, but no other DLLs in the Paratext project can be used directly.
   Porting Constraints: Target .NET 8.0. The PlatformScrTextCollection class under paranext-core/c-sharp/ParatextUtils/PlatformScrTextCollection.cs should be updated with the changes.
   Excluded Code/Modules: Only read from modules that are referenced by ParatextScrTextCollection.

5. Edge Cases & Special Notes
   Edge Cases: None
   Data Constraints: Not all project files are guaranteed to open properly. Projects can be rejected.
   Error Handling: If an incompatible project is found, `MigrateProjectIfNeeded()` should return `UnsupportedReason.CannotUpgrade`. The function should never hang. If a project cannot be opened, then something should be printed to the Console with details about why it failed to open.
   Performance Considerations: The function being overridden is synchronous, and it cannot be changed to be async.

6. Test & Verification Notes
   Characterization Tests Needed: None - Use some p8z files from ~/dbl-downloader as sample inputs for new tests.
   Acceptance Tests Needed: Some acceptance tests should be created with a few different project file formats.
   Test Dependencies: None
   Manual Verification Steps: Download projects from the DBL and ensure they open as expected.

7. Reviewer / Dev Notes
   Human Reviewer Assigned: Matt Lyons
   Dev Lead Assigned: Matt Lyons
   Priority: High
   Additional Instructions: None
