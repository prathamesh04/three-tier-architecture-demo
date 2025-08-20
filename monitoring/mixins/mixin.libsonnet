(import 'config.libsonnet') + {
  // Main mixin entry point with TSDB defaults
  
  // Import dashboard definitions
  grafanaDashboards: {
    'loki-overview.json': (import 'dashboards/loki-overview.libsonnet').dashboard($._config),
  } + if $._config.tsdb then {
    // TSDB-specific dashboards
    'loki-tsdb.json': (import 'dashboards/loki-tsdb.libsonnet').dashboard($._config),
  } else {
    // BoltDB-specific dashboards  
    'loki-boltdb.json': (import 'dashboards/loki-boltdb.libsonnet').dashboard($._config),
  },
  
  // Alerts
  prometheusAlerts: (import 'alerts/loki.libsonnet').alerts($._config),
  
  // Recording rules
  prometheusRules: (import 'rules/loki.libsonnet').rules($._config),
}