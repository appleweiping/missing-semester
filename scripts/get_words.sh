#!/usr/bin/env bash
# Download the classic /usr/share/dict/words (BSD web2 list, ~99k entries,
# includes possessive "'s" forms) into 04-data-wrangling/data/words.
# The file is .gitignored — this script fetches it at runtime.
set -euo pipefail

DEST_DIR="$(cd "$(dirname "$0")/.." && pwd)/04-data-wrangling/data"
DEST="$DEST_DIR/words"
mkdir -p "$DEST_DIR"

if [ -f "$DEST" ]; then
    echo "words already present: $DEST ($(wc -l < "$DEST") lines)"
    exit 0
fi

URL="https://gist.githubusercontent.com/wchargin/8927565/raw/d9783627c731268fb2935a731a618aa8e95cf465/words"
echo "downloading dictionary -> $DEST"
curl -fsSL --retry 3 -o "$DEST" "$URL"
echo "done: $(wc -l < "$DEST") lines"
