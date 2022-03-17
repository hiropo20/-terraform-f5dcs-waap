terraform {
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.11.6"
    }
  }
}

provider "volterra" {
  api_p12_file = "**/path/to/api_credential.p12-file**"
  url          = "https://**tenant_name**.console.ves.volterra.io/api"
}

// example: create healthcheck object
resource "volterra_healthcheck" "eample-dummy-hc" {
  name                = "dummy-health-check-t"
  namespace           = "**your-namespace**"
  timeout             = 3
  interval            = 15
  unhealthy_threshold = 1
  healthy_threshold   = 3
  http_health_check {
    use_origin_server_name = true
    path                   = "/"
    use_http2              = false
  }
}
