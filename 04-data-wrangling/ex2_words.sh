#!/usr/bin/env bash
# Ex2: Using /usr/share/dict/words, find the number of words that
#   (a) contain at least three 'a's, and
#   (b) don't have a "'s" ending.
# Then find the three most common last-two-letters of those words,
# how many distinct two-letter endings there are, and (challenge) which
# two-letter combinations never occur.
#
# The dictionary is downloaded by ../scripts/get_words.sh into ./data/words
# (classic BSD /usr/share/dict/words, which contains possessive "'s" forms).
set -euo pipefail

WORDS="${1:-$(dirname "$0")/data/words}"
[ -f "$WORDS" ] || { echo "words file not found: $WORDS (run scripts/get_words.sh)"; exit 1; }

echo "=== dictionary: $WORDS ($(wc -l < "$WORDS") lines) ==="

# The matching set: >=3 a's (case-insensitive), not ending in 's.
# grep -i for case-insensitive 'a'; the regex requires three a's separated by
# any non-a runs. Then drop the possessive "'s" endings.
matches() {
    grep -iE "^([^a]*a){3}" "$WORDS" | grep -v "'s$"
}

count=$(matches | wc -l)
echo "(a+b) words with >=3 a's and no \"'s\" ending: $count"

echo
echo "=== three most common last-two-letters (case-insensitive) ==="
# tr for case-insensitivity on the ending; grep -oE grabs the final two letters.
matches \
    | tr 'A-Z' 'a-z' \
    | grep -oE '..$' \
    | sort | uniq -c | sort -rn \
    | head -3

distinct=$(matches | tr 'A-Z' 'a-z' | grep -oE '..$' | sort -u | wc -l)
echo
echo "=== number of distinct two-letter endings: $distinct ==="

echo
echo "=== (challenge) two-letter combinations that NEVER occur as an ending ==="
# Build every possible aa..zz, subtract the ones that appear.
present=$(matches | tr 'A-Z' 'a-z' | grep -oE '..$' | sort -u)
all=$(for a in {a..z}; do for b in {a..z}; do echo "$a$b"; done; done)
missing=$(comm -23 <(echo "$all") <(echo "$present"))
echo "count of never-occurring endings: $(echo "$missing" | grep -c . )"
echo "first 20 of them:"
echo "$missing" | head -20 | tr '\n' ' '
echo
