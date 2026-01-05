# Scenario: Words/Phrases Checklist

## What This Tests

- Word/phrase search and matching
- Highlighting of matched text
- Morphological matching option
- Biblical Terms integration

## Expected Behavior

1. **Search Format**: Multiple strings separated by newlines
2. **Matching**: Uses WordOrPhraseMatcher
3. **Highlighting**: Matched text marked with ||m3tch marker
4. **Morphology**: Optional LexicalAnalyser for word variants

## Edge Cases Covered

- Multiple search strings
- Morphological variants

## Known Quirks

- Can be launched from BiblicalTermsForm with pre-configured search
- ||m3tch marker is internal, converted to highlighting in display
- Morphology requires LexicalAnalyser support

## Invariants Verified

- **INV-001**: Row cell count equals column count

## Verification Notes

When comparing PT10 output:

1. **Search parsing**: Multiple strings from newlines
2. **Match detection**: Verify matching algorithm
3. **Highlighting**: Check highlight marker handling

## PT10 Implementation Guidance

- Use WordOrPhraseMatcher for search
- Use LexicalAnalyser when morphologyMatching=true
- Implement WordOrPhraseSettingsForm equivalent
- Support launch from Biblical Terms feature
