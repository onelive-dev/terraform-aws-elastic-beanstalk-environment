data "template_file" "health_config_document" {
  template = <<EOF
  {
        "Version": 1,
        "CloudWatchMetrics": {
            "Instance": {
                "RootFilesystemUtil": null,
                "CPUIrq": null,
                "LoadAverage5min": null,
                "ApplicationRequests5xx": null,
                "ApplicationRequests4xx": null,
                "CPUUser": null,
                "LoadAverage1min": null,
                "ApplicationLatencyP50": null,
                "CPUIdle": null,
                "InstanceHealth": null,
                "ApplicationLatencyP95": null,
                "ApplicationLatencyP85": null,
                "ApplicationLatencyP90": null,
                "CPUSystem": null,
                "ApplicationLatencyP75": null,
                "CPUSoftirq": null,
                "ApplicationLatencyP10": null,
                "ApplicationLatencyP99": null,
                "ApplicationRequestsTotal": null,
                "ApplicationLatencyP99.9": null,
                "ApplicationRequests3xx": null,
                "ApplicationRequests2xx": null,
                "CPUIowait": null,
                "CPUNice": null
            },
            "Environment": {
                "InstancesSevere": null,
                "InstancesDegraded": null,
                "ApplicationRequests5xx": null,
                "ApplicationRequests4xx": null,
                "ApplicationLatencyP50": null,
                "ApplicationLatencyP95": null,
                "ApplicationLatencyP85": null,
                "InstancesUnknown": null,
                "ApplicationLatencyP90": null,
                "InstancesInfo": null,
                "InstancesPending": null,
                "ApplicationLatencyP75": null,
                "ApplicationLatencyP10": null,
                "ApplicationLatencyP99": null,
                "ApplicationRequestsTotal": null,
                "InstancesNoData": null,
                "ApplicationLatencyP99.9": null,
                "ApplicationRequests3xx": null,
                "ApplicationRequests2xx": null,
                "InstancesOk": null,
                "InstancesWarning": null
            }
        },
        "Rules": {
            "Environment": {
                "Application": {
                    "ApplicationRequests4xx": {
                        "Enabled": ${var.disable_ignore_http_4xx}
                    }
                }
            }
        }
    }
    EOF
  vars = {
    Enabled = "${var.disable_ignore_http_4xx}"
  }
}


