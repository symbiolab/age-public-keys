#!/bin/env bash

set -e -o pipefail -u

if [[ "$OSTYPE" == "darwin"* ]]; then
    CLIPBOARD="pbcopy"
else
    CLIPBOARD="xsel -b"
fi

PUBLIC_KEY_FILES=$(ls *.age.pub | sk -m -p "Select keys (tab for multi select)")
RECIPIENTS_FILE=$(mktemp /tmp/age_encrypt_tempfile.XXXXXX)

trap cleanup EXIT
cleanup() {
  rm -f "$RECIPIENTS_FILE" "$MESSAGE_FILE"
}

echo $PUBLIC_KEY_FILES | xargs cat > $RECIPIENTS_FILE

MESSAGE_FILE=$(mktemp)
$EDITOR $MESSAGE_FILE

[[ -s $MESSAGE_FILE ]] || {
    echo "Empty message"
    exit 1
}

ENCRYPTED_MESSAGE=$(age --encrypt --recipients-file $RECIPIENTS_FILE --armor < $MESSAGE_FILE)
echo "$ENCRYPTED_MESSAGE" | tee >($CLIPBOARD)

echo "Copied to clipboard"
