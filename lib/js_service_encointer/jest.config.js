const config = require('@polkadot/dev/config/jest.cjs');

module.exports = Object.assign({}, config, {
  moduleNameMapper: {
    '@encointer/node-api(.*)$': '<rootDir>/../../../encointer-js/packages/node-api/src/$1',
    '@encointer/util(.*)$': '<rootDir>../../../encointer-js/packages/util/src/$1',
    '@encointer/types(.*)$': '<rootDir>../../../encointer-js/packages/types/src/$1',
    '@encointer/worker-api(.*)$': '<rootDir>/../../../encointer-js/packages/worker-api/src/$1'
  },
  modulePathIgnorePatterns: [
    '<rootDir>/build',
    '<rootDir>/packages/worker-api/build',
    '<rootDir>/packages/util/build'
  ],
  resolver: '@polkadot/dev/config/jest-resolver.cjs'
});
