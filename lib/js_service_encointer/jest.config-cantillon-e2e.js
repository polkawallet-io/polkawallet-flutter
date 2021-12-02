import config from './jest.config.js';

export default {
  ...config,
  testMatch: ['**/?(*.)+(cantillon.test-e2e).[jt]s?(x)'],
};
