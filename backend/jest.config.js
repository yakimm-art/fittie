module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/functions'],
  testMatch: ['**/__tests__/**/*.test.ts'],
  collectCoverageFrom: [
    'functions/**/*.ts',
    '!functions/**/__tests__/**',
    '!functions/**/node_modules/**',
    '!functions/**/dist/**',
  ],
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
  transform: {
    '^.+\\.ts$': 'ts-jest',
  },
  coverageThreshold: {
    global: {
      branches: 0,
      functions: 0,
      lines: 0,
      statements: 0,
    },
  },
};
