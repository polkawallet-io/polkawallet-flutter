#!/bin/bash
set -euo pipefail

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew tap wix/brew
brew install applesimutils
