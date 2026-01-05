# Scenario: Long Sentences Checklist

## What This Tests

- Sentence boundary detection
- Length-based sorting
- CharacterCategorizer usage for punctuation

## Expected Behavior

1. **Sentence Detection**: Uses CharacterCategorizer.IsSentenceFinalPunctuation
2. **Language Awareness**: Punctuation is determined by project language settings
3. **Scoring**: Score = sentence length (characters)
4. **Cell Structure**: Each sentence gets its own cell (no verse merging)
5. **Max Results**: 100 longest sentences

## Edge Cases Covered

- **DC-002**: Sentence final punctuation varies by language

## Known Quirks

- Sentences can span multiple verses
- Non-letter, non-whitespace after punctuation stays with sentence
- Reference is first verse where sentence starts

## Invariants Verified

- **INV-001**: Row cell count equals column count
- **POST-002**: Score-based sorting

## Verification Notes

When comparing PT10 output:

1. **Sentence splitting**: Use CharacterCategorizer
2. **Language handling**: Test with different language projects
3. **Sorting**: Longest first
4. **Cell independence**: Each sentence is separate row

## PT10 Implementation Guidance

- Use ParatextData CharacterCategorizer.IsSentenceFinalPunctuation
- Split text on sentence boundaries
- Calculate length of each sentence
- Sort descending and take top 100
