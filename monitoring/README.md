# Loki Monitoring Integration

This directory contains Loki monitoring configuration for the three-tier architecture demo.

## Quick Start

To deploy Loki monitoring with TSDB (default configuration):

```bash
cd monitoring/mixins
make build
```

This will generate:
- `compiled/dashboards/` - Grafana dashboards with TSDB as default
- `compiled/alerts.yml` - Prometheus alerts  
- `compiled/rules.yml` - Recording rules

## Kubernetes Integration

To deploy alongside your three-tier architecture:

1. **Add Loki to your existing namespace:**

```bash
# Add Loki helm repo
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Loki with TSDB configuration
helm install loki grafana/loki \
  --namespace <your-namespace> \
  --set index_gateway.enabled=true \
  --set storage.bucketNames.chunks=loki-chunks \
  --set storage.bucketNames.ruler=loki-ruler \
  --set storage.type=s3
```

2. **Deploy monitoring dashboards:**

```bash
kubectl create configmap loki-dashboards \
  --from-file=compiled/dashboards/ \
  -n <your-namespace>
```

3. **Add Prometheus rules:**

```bash  
kubectl apply -f compiled/alerts.yml
kubectl apply -f compiled/rules.yml
```

## Configuration

The monitoring is configured for TSDB by default. To customize:

```jsonnet
// custom-loki-config.libsonnet
(import 'mixin.libsonnet') + {
  _config+:: {
    // Customize for your environment
    cluster: 'three-tier-demo',
    namespace: 'default',
    
    // TSDB is enabled by default
    // tsdb: false,  // Uncomment to use BoltDB instead
    
    dashboard+: {
      prefix: 'ThreeTier Loki / ',
      tags: ['loki', 'three-tier', 'demo'],
    },
  }
}
```

Then build with your custom config:
```bash
jsonnet -J vendor custom-loki-config.libsonnet
```