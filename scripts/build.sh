#!/bin/bash

set -e
set -o pipefail
set -x

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIRECTORY="${SCRIPT_DIRECTORY}/.."

cd "$ROOT_DIRECTORY"

xcodebuild -scheme SelectableCollectionView -showdestinations
xcodebuild -scheme SelectableCollectionView -destination "platform=macOS" clean build
xcodebuild -scheme SelectableCollectionView -destination "$DEFAULT_IPHONE_DESTINATION" clean build
