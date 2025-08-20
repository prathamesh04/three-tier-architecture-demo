(import 'mixin.libsonnet') + {
  _config+:: {
    tsdb: false,
    boltdb: true,
    enableStructuredMetadata: false,
  }
}