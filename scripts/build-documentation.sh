#!/bin/bash

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIRECTORY="${SCRIPT_DIRECTORY}/.."

cd "$ROOT_DIRECTORY"

swift package \
    --allow-writing-to-directory _site \
    generate-documentation \
    --target Interact \
    --output-path _site \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path 'interact'
