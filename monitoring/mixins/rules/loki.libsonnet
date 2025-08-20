{
  rules(config):: {
    groups: [
      {
        name: 'loki.rules',
        interval: '30s',
        rules: [
          {
            record: 'loki:request_rate',
            expr: 'sum(rate(loki_request_duration_seconds_count[5m])) by (cluster, namespace, route)',
          },
          {
            record: 'loki:request_error_rate',
            expr: 'sum(rate(loki_request_duration_seconds_count{status_code!~"2.."}[5m])) by (cluster, namespace, route)',
          },
          {
            record: 'loki:request_duration_99p',
            expr: 'histogram_quantile(0.99, sum(rate(loki_request_duration_seconds_bucket[5m])) by (cluster, namespace, route, le))',
          },
        ] + if config.tsdb then [
          {
            record: 'loki:tsdb_index_query_rate',
            expr: 'sum(rate(loki_tsdb_index_query_total[5m])) by (cluster, namespace)',
          },
          {
            record: 'loki:tsdb_index_query_duration_99p',
            expr: 'histogram_quantile(0.99, sum(rate(loki_tsdb_index_query_duration_seconds_bucket[5m])) by (cluster, namespace, le))',
          },
          {
            record: 'loki:tsdb_compaction_rate',
            expr: 'sum(rate(loki_tsdb_compaction_total[5m])) by (cluster, namespace)',
          },
          {
            record: 'loki:tsdb_symbol_table_size',
            expr: 'sum(loki_tsdb_symbol_table_size_bytes) by (cluster, namespace)',
          },
        ] else [
          {
            record: 'loki:boltdb_operation_rate',
            expr: 'sum(rate(loki_boltdb_operations_total[5m])) by (cluster, namespace, operation)',
          },
          {
            record: 'loki:boltdb_transaction_duration_99p',
            expr: 'histogram_quantile(0.99, sum(rate(loki_boltdb_transaction_duration_seconds_bucket[5m])) by (cluster, namespace, le))',
          },
        ],
      },
    ],
  },
}