#!/bin/env bash

set -e -o pipefail -u

FILE_TO_ENCRYPT=${1:?Usage encrypt-file.sh file-to-encrypt encrytped-file-name}
ENCRYPTED_FILE=${2:?Usage encrypt-file.sh file-to-encrypt encrytped-file-name}

if ! command -v sk &> /dev/null; then
    echo "The command 'sk' aka 'skim' is not installed."
    exit 1
fi

if ! command -v age &> /dev/null; then
    echo "The command 'age' is not installed."
    exit 1
fi


trap cleanup EXIT
cleanup() {
  rm -f "$RECIPIENTS_FILE"
}

PUBLIC_KEY_FILES=$(ls *.age.pub | sk -m -p "Select keys (tab for multi select)")
RECIPIENTS_FILE=$(mktemp /tmp/age_recipients_tempfile.XXXXXX)

echo $PUBLIC_KEY_FILES | xargs cat | sed '/^#/d'  > $RECIPIENTS_FILE


age --encrypt --recipients-file $RECIPIENTS_FILE --output $ENCRYPTED_FILE $FILE_TO_ENCRYPT
