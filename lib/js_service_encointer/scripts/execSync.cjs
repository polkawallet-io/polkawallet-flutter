// Copyright 2017-2021 @polkadot/dev authors & contributors
// SPDX-License-Identifier: Apache-2.0

const { execSync } = require('child_process');

module.exports = function execute (cmd, options, noLog) {
  !noLog && console.log(`$ ${cmd}`);

  try {
    return execSync(cmd, { stdio: 'inherit', ...options });
  } catch (error) {
    console.log(error);
    process.exit(-1);
  }
};
