// Example: Custom Loki mixin configuration
// This shows how to customize the mixin while keeping TSDB as default

(import 'mixin.libsonnet') + {
  _config+:: {
    // TSDB is enabled by default, but can be overridden
    // tsdb: false,  // Uncomment to disable TSDB and use BoltDB
    
    // Cluster and namespace configuration
    cluster: 'production',
    namespace: 'loki-system',
    
    // Custom dashboard settings
    dashboard+: {
      prefix: 'Production Loki / ',
      tags: ['loki', 'production', 'observability'],
    },
    
    // SSD configuration can be combined with TSDB
    ssd: true,
  },
}