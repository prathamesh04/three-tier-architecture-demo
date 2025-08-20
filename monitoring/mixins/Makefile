JSONNET_FMT := jsonnetfmt -n 2 --max-blank-lines 2 --string-style s --comment-style s

.PHONY: dashboards
dashboards:
	@mkdir -p compiled/dashboards
	jsonnet -J vendor mixin.libsonnet | jq -r '.grafanaDashboards | to_entries[] | "\(.key) \(.value)"' | \
	while read name dashboard; do \
		echo "$$dashboard" > compiled/dashboards/$$name; \
	done

.PHONY: dashboards-tsdb
dashboards-tsdb:
	@mkdir -p compiled/dashboards-tsdb
	jsonnet -J vendor mixin-tsdb.libsonnet | jq -r '.grafanaDashboards | to_entries[] | "\(.key) \(.value)"' | \
	while read name dashboard; do \
		echo "$$dashboard" > compiled/dashboards-tsdb/$$name; \
	done

.PHONY: alerts
alerts:
	@mkdir -p compiled
	jsonnet -J vendor mixin.libsonnet | jq -r '.prometheusAlerts' > compiled/alerts.yml

.PHONY: rules
rules:
	@mkdir -p compiled
	jsonnet -J vendor mixin.libsonnet | jq -r '.prometheusRules' > compiled/rules.yml

.PHONY: install
install:
	jb install

.PHONY: fmt
fmt:
	find . -name '*.libsonnet' -print0 | xargs -0 $(JSONNET_FMT) -i

.PHONY: build
build: install dashboards alerts rules

.PHONY: build-tsdb
build-tsdb: install dashboards-tsdb alerts rules

.PHONY: clean
clean:
	rm -rf compiled vendor

.PHONY: test
test: build
	@echo "Testing default configuration (TSDB enabled)..."
	@if jsonnet -J vendor mixin.libsonnet | jq -e '._config.tsdb == true' > /dev/null; then \
		echo "✓ TSDB is enabled by default"; \
	else \
		echo "✗ TSDB should be enabled by default"; \
		exit 1; \
	fi
	@if jsonnet -J vendor mixin.libsonnet | jq -e '.grafanaDashboards | has("loki-tsdb.json")' > /dev/null; then \
		echo "✓ TSDB dashboard is included by default"; \
	else \
		echo "✗ TSDB dashboard should be included by default"; \
		exit 1; \
	fi
	@echo "All tests passed!"