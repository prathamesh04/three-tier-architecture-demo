local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local row = grafana.row;

{
  dashboard(config)::
    local baseDashboard = 
      dashboard.new(
        title='%sOverview' % config.dashboard.prefix,
        tags=config.dashboard.tags,
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
        row.new(title='Overview')
      )
      .addPanel(
        graphPanel.new(
          title='Requests per second',
          datasource='$datasource',
        )
        .addTarget({
          expr: 'sum(rate(loki_request_duration_seconds_count{cluster=~"$cluster",namespace=~"$namespace"}[5m])) by (route)',
          legendFormat: '{{route}}',
        }),
        gridPos={x: 0, y: 1, w: 12, h: 8}
      )
      .addPanel(
        graphPanel.new(
          title='Request Duration 99th percentile',
          datasource='$datasource',
        )
        .addTarget({
          expr: 'histogram_quantile(0.99, sum(rate(loki_request_duration_seconds_bucket{cluster=~"$cluster",namespace=~"$namespace"}[5m])) by (le, route))',
          legendFormat: '{{route}}',
        }),
        gridPos={x: 12, y: 1, w: 12, h: 8}
      );

    local tsdbPanels = if config.tsdb then
      baseDashboard
      .addRow(
        row.new(title='TSDB Index', collapse=false)
      )
      .addPanel(
        graphPanel.new(
          title='TSDB Index Size',
          datasource='$datasource',
        )
        .addTarget({
          expr: 'sum(loki_tsdb_symbol_table_size_bytes{cluster=~"$cluster",namespace=~"$namespace"})',
          legendFormat: 'Symbol Table Size',
        }),
        gridPos={x: 0, y: 10, w: 8, h: 6}
      )
      .addPanel(
        graphPanel.new(
          title='TSDB Index Queries',
          datasource='$datasource',
        )
        .addTarget({
          expr: 'sum(rate(loki_tsdb_index_query_total{cluster=~"$cluster",namespace=~"$namespace"}[5m]))',
          legendFormat: 'Index Queries/sec',
        }),
        gridPos={x: 8, y: 10, w: 8, h: 6}
      )
      .addPanel(
        graphPanel.new(
          title='TSDB Index Query Duration',
          datasource='$datasource',
        )
        .addTarget({
          expr: 'histogram_quantile(0.99, sum(rate(loki_tsdb_index_query_duration_seconds_bucket{cluster=~"$cluster",namespace=~"$namespace"}[5m])) by (le))',
          legendFormat: '99th percentile',
        })
        .addTarget({
          expr: 'histogram_quantile(0.50, sum(rate(loki_tsdb_index_query_duration_seconds_bucket{cluster=~"$cluster",namespace=~"$namespace"}[5m])) by (le))',
          legendFormat: '50th percentile',
        }),
        gridPos={x: 16, y: 10, w: 8, h: 6}
      )
    else baseDashboard;

    local structuredMetadataPanels = if config.enableStructuredMetadata then
      tsdbPanels
      .addRow(
        row.new(title='Structured Metadata', collapse=false)
      )
      .addPanel(
        graphPanel.new(
          title='Structured Metadata Queries',
          datasource='$datasource',
        )
        .addTarget({
          expr: 'sum(rate(loki_structured_metadata_query_total{cluster=~"$cluster",namespace=~"$namespace"}[5m]))',
          legendFormat: 'Queries/sec',
        }),
        gridPos={x: 0, y: 17, w: 12, h: 6}
      )
      .addPanel(
        graphPanel.new(
          title='Structured Metadata Index Size',
          datasource='$datasource',
        )
        .addTarget({
          expr: 'sum(loki_structured_metadata_index_size_bytes{cluster=~"$cluster",namespace=~"$namespace"})',
          legendFormat: 'Index Size',
        }),
        gridPos={x: 12, y: 17, w: 12, h: 6}
      )
    else tsdbPanels;

    structuredMetadataPanels,
}