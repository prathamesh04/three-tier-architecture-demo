local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local row = grafana.row;

{
  dashboard(config)::
    dashboard.new(
      title='%sTSDB' % config.dashboard.prefix,
      tags=config.dashboard.tags + ['tsdb'],
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
      row.new(title='TSDB Index Performance')
    )
    .addPanel(
      graphPanel.new(
        title='Index Read Rate',
        datasource='$datasource',
      )
      .addTarget({
        expr: 'sum(rate(loki_tsdb_index_read_total{cluster=~"$cluster",namespace=~"$namespace"}[5m])) by (operation)',
        legendFormat: '{{operation}}',
      }),
      gridPos={x: 0, y: 1, w: 8, h: 8}
    )
    .addPanel(
      graphPanel.new(
        title='Index Write Rate',
        datasource='$datasource',
      )
      .addTarget({
        expr: 'sum(rate(loki_tsdb_index_write_total{cluster=~"$cluster",namespace=~"$namespace"}[5m])) by (operation)',
        legendFormat: '{{operation}}',
      }),
      gridPos={x: 8, y: 1, w: 8, h: 8}
    )
    .addPanel(
      graphPanel.new(
        title='Index Compaction Rate',
        datasource='$datasource',
      )
      .addTarget({
        expr: 'sum(rate(loki_tsdb_compaction_total{cluster=~"$cluster",namespace=~"$namespace"}[5m]))',
        legendFormat: 'Compactions/sec',
      }),
      gridPos={x: 16, y: 1, w: 8, h: 8}
    )
    .addRow(
      row.new(title='TSDB Storage')
    )
    .addPanel(
      graphPanel.new(
        title='Symbol Table Size',
        datasource='$datasource',
        format='bytes',
      )
      .addTarget({
        expr: 'sum(loki_tsdb_symbol_table_size_bytes{cluster=~"$cluster",namespace=~"$namespace"}) by (instance)',
        legendFormat: '{{instance}}',
      }),
      gridPos={x: 0, y: 10, w: 12, h: 8}
    )
    .addPanel(
      graphPanel.new(
        title='Index File Count',
        datasource='$datasource',
      )
      .addTarget({
        expr: 'sum(loki_tsdb_index_files{cluster=~"$cluster",namespace=~"$namespace"}) by (instance)',
        legendFormat: '{{instance}}',
      }),
      gridPos={x: 12, y: 10, w: 12, h: 8}
    )
    .addRow(
      row.new(title='TSDB Query Performance')
    )
    .addPanel(
      graphPanel.new(
        title='Query Duration Distribution',
        datasource='$datasource',
      )
      .addTarget({
        expr: 'histogram_quantile(0.99, sum(rate(loki_tsdb_index_query_duration_seconds_bucket{cluster=~"$cluster",namespace=~"$namespace"}[5m])) by (le))',
        legendFormat: '99th percentile',
      })
      .addTarget({
        expr: 'histogram_quantile(0.95, sum(rate(loki_tsdb_index_query_duration_seconds_bucket{cluster=~"$cluster",namespace=~"$namespace"}[5m])) by (le))',
        legendFormat: '95th percentile',
      })
      .addTarget({
        expr: 'histogram_quantile(0.50, sum(rate(loki_tsdb_index_query_duration_seconds_bucket{cluster=~"$cluster",namespace=~"$namespace"}[5m])) by (le))',
        legendFormat: '50th percentile',
      }),
      gridPos={x: 0, y: 19, w: 12, h: 8}
    )
    .addPanel(
      graphPanel.new(
        title='Query Cache Hit Rate',
        datasource='$datasource',
        max=1,
        min=0,
        format='percentunit',
      )
      .addTarget({
        expr: 'sum(rate(loki_tsdb_query_cache_hit_total{cluster=~"$cluster",namespace=~"$namespace"}[5m])) / sum(rate(loki_tsdb_query_cache_total{cluster=~"$cluster",namespace=~"$namespace"}[5m]))',
        legendFormat: 'Cache Hit Rate',
      }),
      gridPos={x: 12, y: 19, w: 12, h: 8}
    ),
}