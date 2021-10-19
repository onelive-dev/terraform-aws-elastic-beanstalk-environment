data "template_file" "health_config_document" {
  template = "${file("./ConfigDocument.json")}"

  vars = {
    Enabled = "${var.ignore_http_4xx}"
  }
}

