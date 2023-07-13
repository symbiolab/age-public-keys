#!/bin/env bash

set -e -o pipefail -u

if ! command -v sk &> /dev/null; then
    echo "The command 'sk' aka 'skim' is not installed."
    exit 1
fi

if ! command -v age &> /dev/null; then
    echo "The command 'age' is not installed."
    exit 1
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    CLIPBOARD="pbcopy"
else
    CLIPBOARD="xsel -b"
fi


trap cleanup EXIT
cleanup() {
  rm -f "$RECIPIENTS_FILE" "$MESSAGE_FILE"
}

PUBLIC_KEY_FILES=$(ls *.age.pub | sk -m -p "Select keys (tab for multi select)")
RECIPIENTS_FILE=$(mktemp /tmp/age_recipients_tempfile.XXXXXX)

echo $PUBLIC_KEY_FILES | xargs cat > $RECIPIENTS_FILE

MESSAGE_FILE=$(mktemp /tmp/age_encrypt_tempfile.XXXXXX)
$EDITOR $MESSAGE_FILE

[[ -s $MESSAGE_FILE ]] || {
    echo "Empty message"
    exit 1
}

ENCRYPTED_MESSAGE=$(age --encrypt --recipients-file $RECIPIENTS_FILE --armor < $MESSAGE_FILE)
echo "$ENCRYPTED_MESSAGE" | tee >($CLIPBOARD)

echo "Copied to clipboard"
