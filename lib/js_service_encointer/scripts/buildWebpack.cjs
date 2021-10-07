#!/usr/bin/env node
// Copyright 2017-2021 @encointer authors & contributors
// SPDX-License-Identifier: Apache-2.0

const execute = require('./execSync.cjs');


async function main () {
  execute('node --version');

  // show targeted browsers
  execute('yarn browserslist');

  execute('webpack');
}

main().catch((error) => {
  console.error(error);
  process.exit(-1);
});
