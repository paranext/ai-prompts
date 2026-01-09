# Scenario: Punctuation Checklist

## What This Tests

- Punctuation detection using CharacterCategorizer
- Filter settings for specific punctuation
- Punctuation sequence comparison

## Expected Behavior

1. **Detection**: Uses CharacterCategorizer.IsPunctuation
2. **Empty Filter**: Shows all punctuation
3. **Filter**: Restricts to specific characters
4. **Comparison**: Compares punctuation sequences between projects

## Known Quirks

- Spaces in filter string are removed
- Filter can be any punctuation characters

## Invariants Verified

- **INV-001**: Row cell count equals column count

## Verification Notes

When comparing PT10 output:

1. **Detection**: Use CharacterCategorizer
2. **Filtering**: Test with and without filter
3. **Spaces removal**: Verify spaces stripped from filter

## PT10 Implementation Guidance

- Use ParatextData CharacterCategorizer.IsPunctuation
- Implement PunctuationSettingsForm equivalent for filter
- Strip spaces from filter before applying
