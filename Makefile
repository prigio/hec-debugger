FILENAME="hec-debugger"
default: help

help:
	@echo "Available 'make' commands"
	@echo "  - make local - compiles the executable for the current architecture, useful for testing purposes"
	@echo "  - make all - compiles the executable for all target architectures"
	@echo "  - make run - starts the tool locally"
	@echo "  - make test - sends some test data to a locally running instance of the tool"

run:
	@echo "Executing ${FILENAME} on 127.0.0.1:8765"
	@ echo ""
	./${FILENAME} -listen 127.0.0.1:8765 -pprint -print-records 3


test: 
	curl http://localhost:8765/j.json -d '[{"time": 1708423020.013,"host": "somehostname","index": "infra-metrics","event": "metric","fields": {"os.type": "linux","sw.distribution": "otel-ta","metric_name:up": 1,"metric_type": "Gauge","service.name": "otel-collector","service.instance.id": "localhost:8888","net.host.port": "8888","http.scheme": "http"}},{"time": 1708423020.013,"host": "somehostname","index": "infra-metrics","event": "metric","fields": {"service_instance_id": "05fb769f-c557-477c-8b2d-09f9a39414d5","service_name": "otelcol","http.scheme": "http","os.type": "linux","sw.distribution": "otel-ta","service.name": "otel-collector","service.instance.id": "localhost:8888","exporter": "splunk_hec/otel-metrics-to-local-splunk","service_version": "v0.89.0","metric_type": "Sum","net.host.port": "8888","metric_name:otelcol_exporter_send_failed_metric_points": 5437}},{"time": 1708423020.013,"host": "somehostname","index": "infra-metrics","event": "metric","fields": {"receiver": "prometheus/internal","service_name": "otelcol","service_version": "v0.89.0","net.host.port": "8888","http.scheme": "http","os.type": "linux","sw.distribution": "otel-ta","metric_name:otelcol_receiver_refused_metric_points": 0,"metric_type": "Sum","service.name": "otel-collector","service.instance.id": "localhost:8888","service_instance_id": "05fb769f-c557-477c-8b2d-09f9a39414d5","transport": "http"}},{"time": 1708423020.013,"host": "somehostname","index": "infra-metrics","event": "metric","fields": {"os.type": "linux","sw.distribution": "otel-ta","service.name": "otel-collector","service.instance.id": "localhost:8888","net.host.port": "8888","http.scheme": "http","metric_name:scrape_samples_post_metric_relabeling": 52,"metric_type": "Gauge"}}]'
	@echo ""
	curl http://localhost:8765/j.hec -d '{"time": 1708423020.013,"host": "somehostname","index": "infra-metrics","event": "metric","fields": {"os.type": "linux","sw.distribution": "otel-ta","metric_name:up": 1,"metric_type": "Gauge","service.name": "otel-collector","service.instance.id": "localhost:8888","net.host.port": "8888","http.scheme": "http"}}{"time": 1708423020.013,"host": "somehostname","index": "infra-metrics","event": "metric","fields": {"service_instance_id": "05fb769f-c557-477c-8b2d-09f9a39414d5","service_name": "otelcol","http.scheme": "http","os.type": "linux","sw.distribution": "otel-ta","service.name": "otel-collector","service.instance.id": "localhost:8888","exporter": "splunk_hec/otel-metrics-to-local-splunk","service_version": "v0.89.0","metric_type": "Sum","net.host.port": "8888","metric_name:otelcol_exporter_send_failed_metric_points": 5437}}{"time": 1708423020.013,"host": "somehostname","index": "infra-metrics","event": "metric","fields": {"receiver": "prometheus/internal","service_name": "otelcol","service_version": "v0.89.0","net.host.port": "8888","http.scheme": "http","os.type": "linux","sw.distribution": "otel-ta","metric_name:otelcol_receiver_refused_metric_points": 0,"metric_type": "Sum","service.name": "otel-collector","service.instance.id": "localhost:8888","service_instance_id": "05fb769f-c557-477c-8b2d-09f9a39414d5","transport": "http"}}{"time": 1708423020.013,"host": "somehostname","index": "infra-metrics","event": "metric","fields": {"os.type": "linux","sw.distribution": "otel-ta","service.name": "otel-collector","service.instance.id": "localhost:8888","net.host.port": "8888","http.scheme": "http","metric_name:scrape_samples_post_metric_relabeling": 52,"metric_type": "Gauge"}}'
	@echo ""
	curl http://localhost:8765/j.ndjson -d '{"time": 1708423020.013,"host": "somehostname","index": "infra-metrics","event": "metric","fields": {"os.type": "linux","sw.distribution": "otel-ta","metric_name:up": 1,"metric_type": "Gauge","service.name": "otel-collector","service.instance.id": "localhost:8888","net.host.port": "8888","http.scheme": "http"}}\
		{"time": 1708423020.013,"host": "somehostname","index": "infra-metrics","event": "metric","fields": {"service_instance_id": "05fb769f-c557-477c-8b2d-09f9a39414d5","service_name": "otelcol","http.scheme": "http","os.type": "linux","sw.distribution": "otel-ta","service.name": "otel-collector","service.instance.id": "localhost:8888","exporter": "splunk_hec/otel-metrics-to-local-splunk","service_version": "v0.89.0","metric_type": "Sum","net.host.port": "8888","metric_name:otelcol_exporter_send_failed_metric_points": 5437}}\
		{"time": 1708423020.013,"host": "somehostname","index": "infra-metrics","event": "metric","fields": {"receiver": "prometheus/internal","service_name": "otelcol","service_version": "v0.89.0","net.host.port": "8888","http.scheme": "http","os.type": "linux","sw.distribution": "otel-ta","metric_name:otelcol_receiver_refused_metric_points": 0,"metric_type": "Sum","service.name": "otel-collector","service.instance.id": "localhost:8888","service_instance_id": "05fb769f-c557-477c-8b2d-09f9a39414d5","transport": "http"}}'

local:
	@echo "Building ${FILENAME}"
	go build

all: ensure_dirs .linux .osx .osxm1 .windows

ensure_dirs:
	- mkdir -p build/linux_x86_64/
	- mkdir -p build/darwin_x86_64/
	- mkdir -p build/darwin_arm_64/
	- mkdir -p build/windows_x86_64/

#Environment settings for cross compilation
#Ref: https://www.digitalocean.com/community/tutorials/how-to-build-go-executables-for-multiple-platforms-on-ubuntu-16-04

.linux:
	@echo "Compiling for Linux within build/linux_x86_64/"
	GOOS=linux GOARCH=amd64 go build -o build/linux_x86_64/

.osx:
	@echo "Compiling for OsX (darwin) build/darwin_x86_64/"
	GOOS=darwin GOARCH=amd64 go build -o build/darwin_x86_64/

.osxm1:
	@echo "Compiling for OsX M1 (darwin) build/darwin_arm_64/"
	GOOS=darwin GOARCH=arm64 go build -o build/darwin_arm_64/

.windows:
	@echo "Compiling for Windows within build/windows_x86_64/"
	GOOS=windows GOARCH=amd64 go build -o build/windows_x86_64/

