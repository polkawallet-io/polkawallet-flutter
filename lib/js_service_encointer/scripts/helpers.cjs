const execSync = require('./execSync.cjs');

const PROJECT_PARENT_DIRECTORY = '../../../';

function findEncointerJSInProjectParent () {
  const stdout = execSync(`find ${PROJECT_PARENT_DIRECTORY} -name encointer-js`, { stdio: null })
    .toString()
    .trim();

  if (stdout === '') {
    throw Error('encointer-js project not found');
  }
  return stdout;
}

const encointerPackages = ['util', 'types', 'node-api', 'worker-api'];

exports.findEncointerJSInProjectParent = findEncointerJSInProjectParent;
exports.encointerPackages = encointerPackages;
