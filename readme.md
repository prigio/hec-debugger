# HEC debugger

This is a simple http server to locally inspect/debug the data which would be sent to a Splunk Http Event Collector (HEC) endpoint.

## Disclaimer

- This is NOT for production usage but rather for local inspection and debugging.
- The exposed endpoint uses HTTP and has thereforre no encryption.

## Reason
Different applications can deliver HEC-formatted data to a Splunk HEC endpoint: OpenTelemetry, Cribl, Fluentd, Fluentbit,... However, sometimes it is beneficial to see samples of the data instead of just ingesting it.

## Capabilities

This server presents an HTTP endpoint

- accepting any http method on any path
- which parses the JSON formatted payload
- and -if requested- prints the first received records of each call to the console
- then returning an HTTP 200 to the caller

## Input data
Incoming data is expected to have a different format depending on the URL it is being sent to:

- `json`: an array of json objects, received on any url ending with `.json`. Splunk HEC does not use this format, but Splunk Ingest Actions do. E.g. 

```json
       [{"key":"value1"},{"key": "value2"},{"key":"value3"}]
```
- `ndjson`: one or more json objects concatenated by a new-line character, received on any url ending with `.ndjson`. E.g. 

```json
       {"key":"value1"}
       {"key":"value2"}
       {"key":"value3"}
```

- `hec-formatted`: one or more json objects written one after the other, received on any url ending with `.hec`. E.g. 

```json
       {"key":"value1"}{"key": "value2"}{"key":"value3"}
```


For each incoming HTTP call, the tool prints the first received records to the console. How many records, and whether pretty-printing should be performed is configurable by command-line parameters. 

```
2024/02/20 14:26:01 - POST /j.hec
  Authorization:
  Tot records: 4
  First records received:
{
  "event": "metric",
  "fields": {
    "http.scheme": "http",
    "metric_name:up": 1,
    "metric_type": "Gauge",
    "net.host.port": "8888",
    "os.type": "linux",
    "service.instance.id": "localhost:8888",
    "service.name": "otel-collector",
    "service.distribution": "otel-ta"
  },
  "host": "somehost",
  "index": "infra-metrics",
  "time": 1708423020.013
  ....
```


## Usage examples


```bash
./hec-debugger -listen 127.0.0.1:8765 -pprint -print-records 3 &


curl http://localhost:8765/.json -d '[{"time": 1708423020.013,"host": "somehost","index": "infra-metrics","event": "metric","fields": {"os.type": "linux","service.distribution": "otel-ta","metric_name:up": 1,"metric_type": "Gauge","service.name": "otel-collector","service.instance.id": "localhost:8888","net.host.port": "8888","http.scheme": "http"}},{"time": 1708423020.013,"host": "somehost","index": "infra-metrics","event": "metric","fields": {"service_instance_id": "05fb769f-c557-477c-8b2d-09f9a39414d5","service_name": "otelcol","http.scheme": "http","os.type": "linux","service.distribution": "otel-ta","service.name": "otel-collector","service.instance.id": "localhost:8888","exporter": "splunk_hec/otel-metrics-to-local-splunk","service_version": "v0.89.0","metric_type": "Sum","net.host.port": "8888","metric_name:otelcol_exporter_send_failed_metric_points": 5437}}]'

curl http://localhost:8765/something.hec -d '{"time": 1708423020.013,"host": "somehost","index": "infra-metrics","event": "metric","fields": {"os.type": "linux","service.distribution": "otel-ta","metric_name:up": 1,"metric_type": "Gauge","service.name": "otel-collector","service.instance.id": "localhost:8888","net.host.port": "8888","http.scheme": "http"}}{"time": 1708423020.013,"host": "somehost","index": "infra-metrics","event": "metric","fields": {"service_instance_id": "05fb769f-c557-477c-8b2d-09f9a39414d5","service_name": "otelcol","http.scheme": "http","os.type": "linux","service.distribution": "otel-ta","service.name": "otel-collector","service.instance.id": "localhost:8888","exporter": "splunk_hec/otel-metrics-to-local-splunk","service_version": "v0.89.0","metric_type": "Sum","net.host.port": "8888","metric_name:otelcol_exporter_send_failed_metric_points": 5437}}{"time": 1708423020.013,"host": "somehost","index": "infra-metrics","event": "metric","fields": {"receiver": "prometheus/internal","service_name": "otelcol","service_version": "v0.89.0","net.host.port": "8888","http.scheme": "http","os.type": "linux","service.distribution": "otel-ta","metric_name:otelcol_receiver_refused_metric_points": 0,"metric_type": "Sum","service.name": "otel-collector","service.instance.id": "localhost:8888","service_instance_id": "05fb769f-c557-477c-8b2d-09f9a39414d5","transport": "http"}}{"time": 1708423020.013,"host": "somehost","index": "infra-metrics","event": "metric","fields": {"os.type": "linux","service.distribution": "otel-ta","service.name": "otel-collector","service.instance.id": "localhost:8888","net.host.port": "8888","http.scheme": "http","metric_name:scrape_samples_post_metric_relabeling": 52,"metric_type": "Gauge"}}'

curl http://localhost:8765/j.ndjson -d '{"time": 1708423020.013,"host": "somehostname","index": "infra-metrics","event": "metric","fields": {"os.type": "linux","sw.distribution": "otel-ta","metric_name:up": 1,"metric_type": "Gauge","service.name": "otel-collector","service.instance.id": "localhost:8888","net.host.port": "8888","http.scheme": "http"}}
{"time": 1708423020.013,"host": "somehostname","index": "infra-metrics","event": "metric","fields": {"service_instance_id": "05fb769f-c557-477c-8b2d-09f9a39414d5","service_name": "otelcol","http.scheme": "http","os.type": "linux","sw.distribution": "otel-ta","service.name": "otel-collector","service.instance.id": "localhost:8888","exporter": "splunk_hec/otel-metrics-to-local-splunk","service_version": "v0.89.0","metric_type": "Sum","net.host.port": "8888","metric_name:otelcol_exporter_send_failed_metric_points": 5437}}
{"time": 1708423020.013,"host": "somehostname","index": "infra-metrics","event": "metric","fields": {"receiver": "prometheus/internal","service_name": "otelcol","service_version": "v0.89.0","net.host.port": "8888","http.scheme": "http","os.type": "linux","sw.distribution": "otel-ta","metric_name:otelcol_receiver_refused_metric_points": 0,"metric_type": "Sum","service.name": "otel-collector","service.instance.id": "localhost:8888","service_instance_id": "05fb769f-c557-477c-8b2d-09f9a39414d5","transport": "http"}}'

```

### Configuring an OpenTelemetry collector to send data to the hec-debugger.
You can add the following to your list of opentelemetry exporters and pipelines in order to use this tool.

```yaml
exporters:
  splunk_hec/hec_debugger:
    # this is used to deliver logs and metrics to the hec debugger, so that we can inspect them
    token: "none"
    endpoint: http://localhost:8766/data.hec
    # Whether to disable gzip compression over HTTP. Defaults to false.
    disable_compression: true
    profiling_data_enabled: false
    # HTTP timeout when sending data. Defaults to 10s.
    timeout: 30s
    export_raw: false
    tls:
      insecure_skip_verify: true
```

## Building
A `Makefile` is provided. However `go build` will do the trick.
