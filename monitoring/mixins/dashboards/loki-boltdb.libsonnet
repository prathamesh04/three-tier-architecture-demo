local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local row = grafana.row;

{
  dashboard(config)::
    dashboard.new(
      title='%sBoltDB' % config.dashboard.prefix,
      tags=config.dashboard.tags + ['boltdb'],
      schemaVersion=21,
    )
    .addTemplate(
      template.datasource(
        'datasource',
        'prometheus',
        'Prometheus',
        hide='label',
      )
    )
    .addTemplate(
      template.new(
        'cluster',
        '$datasource',
        'label_values(loki_build_info, cluster)',
        'cluster',
        refresh='time',
      )
    )
    .addTemplate(
      template.new(
        'namespace',
        '$datasource', 
        'label_values(loki_build_info{cluster=~"$cluster"}, namespace)',
        'namespace',
        refresh='time',
      )
    )
    .addRow(
      row.new(title='BoltDB Index Performance')
    )
    .addPanel(
      graphPanel.new(
        title='BoltDB Read Operations',
        datasource='$datasource',
      )
      .addTarget({
        expr: 'sum(rate(loki_boltdb_operations_total{cluster=~"$cluster",namespace=~"$namespace",operation="read"}[5m])) by (instance)',
        legendFormat: '{{instance}}',
      }),
      gridPos={x: 0, y: 1, w: 8, h: 8}
    )
    .addPanel(
      graphPanel.new(
        title='BoltDB Write Operations',
        datasource='$datasource',
      )
      .addTarget({
        expr: 'sum(rate(loki_boltdb_operations_total{cluster=~"$cluster",namespace=~"$namespace",operation="write"}[5m])) by (instance)',
        legendFormat: '{{instance}}',
      }),
      gridPos={x: 8, y: 1, w: 8, h: 8}
    )
    .addPanel(
      graphPanel.new(
        title='BoltDB Transaction Duration',
        datasource='$datasource',
      )
      .addTarget({
        expr: 'histogram_quantile(0.99, sum(rate(loki_boltdb_transaction_duration_seconds_bucket{cluster=~"$cluster",namespace=~"$namespace"}[5m])) by (le))',
        legendFormat: '99th percentile',
      }),
      gridPos={x: 16, y: 1, w: 8, h: 8}
    )
    .addRow(
      row.new(title='BoltDB Storage')
    )
    .addPanel(
      graphPanel.new(
        title='BoltDB File Size',
        datasource='$datasource',
        format='bytes',
      )
      .addTarget({
        expr: 'sum(loki_boltdb_file_size_bytes{cluster=~"$cluster",namespace=~"$namespace"}) by (instance)',
        legendFormat: '{{instance}}',
      }),
      gridPos={x: 0, y: 10, w: 12, h: 8}
    )
    .addPanel(
      graphPanel.new(
        title='BoltDB Bucket Count',
        datasource='$datasource',
      )
      .addTarget({
        expr: 'sum(loki_boltdb_bucket_count{cluster=~"$cluster",namespace=~"$namespace"}) by (instance)',
        legendFormat: '{{instance}}',
      }),
      gridPos={x: 12, y: 10, w: 12, h: 8}
    ),
}