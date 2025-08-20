{
  alerts(config):: {
    groups: [
      {
        name: 'loki.alerts',
        rules: [
          {
            alert: 'LokiRequestErrors',
            expr: 'sum(rate(loki_request_duration_seconds_count{status_code!~"2.."}[5m])) by (cluster, namespace) / sum(rate(loki_request_duration_seconds_count[5m])) by (cluster, namespace) > 0.10',
            'for': '15m',
            labels: {
              severity: 'critical',
            },
            annotations: {
              summary: 'Loki request error rate is high',
              description: 'The request error rate for {{ $labels.cluster }}/{{ $labels.namespace }} is {{ $value | humanizePercentage }}',
            },
          },
          {
            alert: 'LokiRequestLatency',
            expr: 'histogram_quantile(0.99, sum(rate(loki_request_duration_seconds_bucket[5m])) by (cluster, namespace, le)) > 1',
            'for': '15m',
            labels: {
              severity: 'critical',
            },
            annotations: {
              summary: 'Loki request latency is high',
              description: 'The 99th percentile latency for {{ $labels.cluster }}/{{ $labels.namespace }} is {{ $value }}s',
            },
          },
        ] + if config.tsdb then [
          {
            alert: 'LokiTSDBIndexHighErrorRate',
            expr: 'sum(rate(loki_tsdb_index_error_total[5m])) by (cluster, namespace) / sum(rate(loki_tsdb_index_query_total[5m])) by (cluster, namespace) > 0.01',
            'for': '10m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              summary: 'Loki TSDB index error rate is high',
              description: 'The TSDB index error rate for {{ $labels.cluster }}/{{ $labels.namespace }} is {{ $value | humanizePercentage }}',
            },
          },
          {
            alert: 'LokiTSDBCompactionFailures',
            expr: 'sum(rate(loki_tsdb_compaction_failed_total[5m])) by (cluster, namespace) > 0',
            'for': '5m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              summary: 'Loki TSDB compaction failures detected',
              description: 'TSDB compaction failures detected in {{ $labels.cluster }}/{{ $labels.namespace }}',
            },
          },
          {
            alert: 'LokiTSDBSymbolTableTooBig',
            expr: 'sum(loki_tsdb_symbol_table_size_bytes) by (cluster, namespace, instance) > 100 * 1024 * 1024',
            'for': '15m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              summary: 'Loki TSDB symbol table is growing too large',
              description: 'TSDB symbol table size for {{ $labels.cluster }}/{{ $labels.namespace }}/{{ $labels.instance }} is {{ $value | humanizeBytes }}',
            },
          },
        ] else [
          {
            alert: 'LokiBoltDBTransactionDuration',
            expr: 'histogram_quantile(0.99, sum(rate(loki_boltdb_transaction_duration_seconds_bucket[5m])) by (cluster, namespace, le)) > 1',
            'for': '10m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              summary: 'Loki BoltDB transaction duration is high',
              description: 'The 99th percentile BoltDB transaction duration for {{ $labels.cluster }}/{{ $labels.namespace }} is {{ $value }}s',
            },
          },
        ],
      },
    ],
  },
}