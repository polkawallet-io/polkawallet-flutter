#!/usr/bin/env bash

# This scripts expects to be called from the project root.

set -exuo pipefail

# init env vars needed for scripts
source ./scripts/init_env.sh

source ./scripts/install_flutter.sh

# update node.js version and build main.js before flutter build
./scripts/install_node.sh && ./scripts/build_js.sh
