#!/usr/bin/env node
// Copyright 2017-2021 @encointer authors & contributors
// SPDX-License-Identifier: Apache-2.0
const path = require('path');

const { execSync } = require('child_process');
const {
  findEncointerJSInProjectParent,
  encointerPackages
} = require('./helpers.cjs');

console.log('$ encointer-link', process.argv.slice(2).join(' '));

async function main () {
  // using path.join() removes the need to care about '/'
  const dir = path.join(findEncointerJSInProjectParent(), 'packages');

  for (const p of encointerPackages) {
    console.log(`...creating link for ${p}`);
    const buildPath = path.join(dir, p, 'build');
    console.log(`path: ${buildPath}`);
    execSync('yarn link', { cwd: buildPath });

    const e = '@encointer/' + p;
    console.log(`...linking ${e}`);
    execSync(`yarn link ${e}`);
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(-1);
});
