{
  // Configuration for Loki monitoring dashboards
  _config+:: {
    // Default to TSDB as the preferred index format for Loki
    tsdb: true,
    
    // Enable structured metadata display by default when TSDB is enabled
    enableStructuredMetadata: self.tsdb,
    
    // BoltDB fallback configuration
    boltdb: !self.tsdb,
    
    // Cluster configuration
    cluster: '',
    namespace: 'loki',
    
    // Dashboard configuration
    dashboard: {
      prefix: 'Loki / ',
      tags: ['loki'],
    },
    
    // SSD/Scalable deployment configuration 
    ssd: false,
  }
}