import { defaults } from 'jest-config';

export default {
  moduleFileExtensions: [...defaults.moduleFileExtensions, 'ts', 'tsx'],
  testMatch: ['**/__tests__/**/*.[jt]s?(x)', '**/?(*.)+(spec|test).[jt]s?(x)'],
  moduleNameMapper: {},
  modulePathIgnorePatterns: [
    '<rootDir>/dist'
  ],
  transform: {},
  transformIgnorePatterns: [],
  verbose: true,
};
