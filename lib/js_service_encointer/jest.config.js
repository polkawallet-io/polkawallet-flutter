const { defaults } = require('jest-config');

module.exports = {
  moduleFileExtensions: [...defaults.moduleFileExtensions, 'ts', 'tsx'],
  testMatch: ['**/__tests__/**/*.[jt]s?(x)', '**/?(*.)+(spec|test).[jt]s?(x)'],
  moduleNameMapper: {
    '@encointer/node-api(.*)$': '<rootDir>/../../../encointer-js/packages/node-api/src/$1',
    '@encointer/util(.*)$': '<rootDir>../../../encointer-js/packages/util/src/$1',
    '@encointer/types(.*)$': '<rootDir>../../../encointer-js/packages/types/src/$1',
    '@encointer/worker-api(.*)$': '<rootDir>/../../../encointer-js/packages/worker-api/src/$1'
  },
  modulePathIgnorePatterns: [
    '<rootDir>/dist'
  ],
  transform: {
    '^.+\\.(js|jsx|ts|tsx)$': require.resolve('babel-jest')
  },
  // transform esm `@polkadot`, `@encointer` and `@babels` esm modules such that jest understands them.
  transformIgnorePatterns: ['/node_modules/(?!@polkadot|@encointer|@babel/runtime/helpers/esm/)'],
  verbose: true,
};
