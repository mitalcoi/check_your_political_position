#!/bin/sh
# Builds the public page from the readable sources in src/ (src/ is not committed).
# The scenario script is wrapped so nothing is reachable from the console, then obfuscated.
set -e
cd "$(dirname "$0")"
TMP=$(mktemp -d)
{ printf '(() => {\n'; cat src/app.js; printf '\n})();\n'; } > "$TMP/app.js"
npx --yes javascript-obfuscator@4.1.1 "$TMP/app.js" --output "$TMP/app.min.js" \
  --compact true --string-array true --string-array-encoding rc4 --string-array-threshold 1 \
  --split-strings true --split-strings-chunk-length 12 --identifier-names-generator hexadecimal \
  --rename-globals true --self-defending false --control-flow-flattening false \
  --unicode-escape-sequence false --transform-object-keys true >/dev/null
HASH=$(shasum "$TMP/app.min.js" | cut -c1-10)
rm -f app.*.js
cp "$TMP/app.min.js" "app.$HASH.js"
sed "s#<script src=\"app.js\"></script>#<script src=\"app.$HASH.js\"></script>#" src/index.html > index.html
rm -rf "$TMP"
echo "built app.$HASH.js"
