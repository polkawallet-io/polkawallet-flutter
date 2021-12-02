import config from './jest.config.js';

export default {
  ...config,
  testMatch: ['**/?(*.)+(gesell.test-e2e).[jt]s?(x)'],
};
