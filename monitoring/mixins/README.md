# Loki Mixin

This mixin provides Grafana dashboards, Prometheus alerts, and recording rules for monitoring Loki with **TSDB as the default index format**.

## Features

- **TSDB by default**: The mixin now defaults to using TSDB as the index format, as it's the preferred option for Loki
- **Conditional dashboards**: Automatically includes TSDB-specific dashboards when TSDB is enabled
- **Structured metadata support**: Shows structured metadata panels when TSDB is enabled
- **Backward compatibility**: Still supports BoltDB configurations when needed

## Configuration

The mixin can be configured by overriding values in `config.libsonnet`:

```jsonnet
{
  _config+:: {
    tsdb: true,                    // Default: true (TSDB enabled)
    enableStructuredMetadata: true, // Default: true when TSDB is enabled
    boltdb: false,                 // Default: false (auto-calculated as !tsdb)
    cluster: 'my-cluster',
    namespace: 'loki',
    dashboard+: {
      prefix: 'MyLoki / ',
      tags: ['loki', 'my-cluster'],
    },
  }
}
```

## Usage

### Default (TSDB enabled)

```bash
make build
```

This will create dashboards with TSDB enabled by default.

### TSDB-specific build

For explicit TSDB configuration:

```bash
make build-tsdb
```

### BoltDB configuration

To use BoltDB instead of TSDB:

```jsonnet
// custom-config.libsonnet
(import 'mixin.libsonnet') + {
  _config+:: {
    tsdb: false,
    boltdb: true,
    enableStructuredMetadata: false,
  }
}
```

Then build with:
```bash
jsonnet -J vendor custom-config.libsonnet
```

## Dashboards

The mixin includes:

1. **Loki Overview**: Main dashboard with conditional TSDB/BoltDB panels
2. **Loki TSDB**: TSDB-specific dashboard (included when `tsdb: true`)
3. **Loki BoltDB**: BoltDB-specific dashboard (included when `tsdb: false`)

### Dashboard Features

When TSDB is enabled (default):
- TSDB index performance metrics
- Symbol table size monitoring
- TSDB compaction metrics
- Structured metadata panels
- Query cache hit rates

When BoltDB is enabled:
- BoltDB transaction metrics
- File size monitoring
- Bucket count tracking

## Alerts

The mixin provides alerts that are conditional based on the index format:

**Common alerts:**
- High request error rate
- High request latency

**TSDB-specific alerts:**
- TSDB index error rate
- TSDB compaction failures
- Large symbol table size

**BoltDB-specific alerts:**
- High transaction duration

## Installation

1. Install jsonnet and jsonnet-bundler:
   ```bash
   go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@latest
   go install github.com/google/go-jsonnet/cmd/jsonnet@latest
   ```

2. Install dependencies:
   ```bash
   make install
   ```

3. Build dashboards and alerts:
   ```bash
   make build
   ```

## Testing

Run the included tests to verify the mixin configuration:

```bash
make test
```

This will verify that:
- TSDB is enabled by default
- TSDB dashboards are included by default
- Configuration is properly applied

## Migration from BoltDB

If you're migrating from a BoltDB-based setup:

1. Update your configuration to enable TSDB:
   ```jsonnet
   {
     _config+:: {
       tsdb: true,  // This is now the default
     }
   }
   ```

2. Rebuild the mixin:
   ```bash
   make clean && make build
   ```

3. Deploy the new dashboards to your Grafana instance

The mixin will automatically show the appropriate panels based on your configuration.