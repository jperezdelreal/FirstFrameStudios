import type { SquadConfig } from '@bradygaster/squad';

/**
 * Squad Configuration for First Frame Studios
 * 
 */
const config: SquadConfig = {
  version: '1.0.0',
  
  models: {
    defaultModel: 'claude-sonnet-4.5',
    defaultTier: 'standard',
    fallbackChains: {
      premium: ['claude-opus-4.6', 'claude-opus-4.6-fast', 'claude-opus-4.5', 'claude-sonnet-4.5'],
      standard: ['claude-sonnet-4.5', 'gpt-5.2-codex', 'claude-sonnet-4', 'gpt-5.2'],
      fast: ['claude-haiku-4.5', 'gpt-5.1-codex-mini', 'gpt-4.1', 'gpt-5-mini']
    },
    preferSameProvider: true,
    respectTierCeiling: true,
    nuclearFallback: {
      enabled: false,
      model: 'claude-haiku-4.5',
      maxRetriesBeforeNuclear: 3
    }
  },
  
  routing: {
    rules: [
      {
        workType: 'feature-dev',
        agents: ['@solo', '@chewie', '@lando'],
        confidence: 'high'
      },
      {
        workType: 'bug-fix',
        agents: ['@chewie', '@lando'],
        confidence: 'high'
      },
      {
        workType: 'testing',
        agents: ['@ackbar'],
        confidence: 'high'
      },
      {
        workType: 'documentation',
        agents: ['@scribe'],
        confidence: 'high'
      }
    ],
    governance: {
      eagerByDefault: true,
      scribeAutoRuns: true,
      allowRecursiveSpawn: false
    }
  },
  
  casting: {
    allowlistUniverses: [
      'Star Wars'
    ],
    overflowStrategy: 'generic',
    universeCapacity: {}
  },
  
  platforms: {
    vscode: {
      disableModelSelection: false,
      scribeMode: 'sync'
    }
  },

  hooks: {
    allowedWritePaths: ['games/**', '.squad/**', 'tools/**', 'docs/**'],
    blockedCommands: ['rm -rf', 'DROP TABLE', 'format c:'],
    scrubPii: true,
  }
};

export default config;
