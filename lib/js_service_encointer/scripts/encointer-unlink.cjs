#!/usr/bin/env node
// Copyright 2017-2021 @encointer authors & contributors
// SPDX-License-Identifier: Apache-2.0

const { execSync } = require('child_process');
const { encointerPackages } = require('./helpers.cjs');

console.log('$ encointer-link', process.argv.slice(2).join(' '));

async function main () {
  for (const p of encointerPackages) {
    console.log(`...unlinking ${p}`);
    const e = '@encointer/' + p;
    execSync(`yarn unlink ${e}`);
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(-1);
});
