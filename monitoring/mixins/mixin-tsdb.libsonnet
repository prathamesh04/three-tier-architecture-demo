(import 'mixin.libsonnet') + {
  // TSDB-specific configuration override
  // This follows the pattern of mixin-ssd.libsonnet mentioned in the issue
  _config+:: {
    // Ensure TSDB is enabled for this specific mixin
    tsdb: true,
    enableStructuredMetadata: true,
    boltdb: false,
    
    // TSDB-specific dashboard configuration
    dashboard+: {
      prefix: 'Loki TSDB / ',
      tags: ['loki', 'tsdb'],
    },
  },
}