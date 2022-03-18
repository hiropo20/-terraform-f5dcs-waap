variable "api_p12_file" {}
variable "api_url" {}
variable "myns" {}
variable "op_name" {}
variable "pool_port" {}
variable "server_name1" {}
variable "server_name2" {}
variable "httplb_name" {}
variable "mydomain" {}
variable "cert" {}
variable "private_key" {}


terraform {
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.11.6"
    }
  }
}

provider "volterra" {
  api_p12_file = var.api_p12_file
  url          = var.api_url
}

//// Create Objects //////////////////////////////////////////
// Manage Origin Pool
resource "volterra_origin_pool" "example" {
  name                   = var.op_name
  namespace              = var.myns
  endpoint_selection     = "LOCAL_PREFERRED"
  loadbalancer_algorithm = "LB_OVERRIDE"
  port                   = var.pool_port
  no_tls                 = true
  origin_servers {
    public_name {
      dns_name = var.server_name1
    }
  }
  origin_servers {
    public_name {
      dns_name = var.server_name2
    }
  }
}



// Manage HTTP LoadBalancer
resource "volterra_http_loadbalancer" "example" {
  name                            = var.httplb_name
  namespace                       = var.myns
  domains                         = var.mydomain
  advertise_on_public_default_vip = true
  no_challenge                    = true
  round_robin                     = true
  disable_rate_limit              = true
  service_policies_from_namespace = true
  disable_waf                     = true
  // disable_bot_defense          = true
  bot_defense {
    regional_endpoint = "ASIA"
    policy {
      protected_app_endpoints {
        metadata {
          name = "demo-bot-endpoint"
        }
        http_methods  = [ "ANY" ]
        any_domain    = true
        path {
          prefix = "/"
        }
        mitigation {
          flag = true
        }
      }
      js_insert_all_pages {
        javascript_location = "AFTER_HEAD"
      }
      js_download_path      = "/common.js"
    }
    timeout = 1000
  }

  default_route_pools {
    pool {
      name      = var.op_name
      namespace = var.myns
    }
  }
  // For http load balancer. Please delete https block and eliminate comment out here.
  //http {
  //  dns_volterra_managed = false
  //}
  https {
    tls_parameters {
      tls_certificates {
        certificate_url = var.cert
        private_key {
          clear_secret_info {
            url = var.private_key
            provider = ""
          }
          secret_encoding_type = "EncodingNone"
        }
      }
    }
  }
  depends_on = [volterra_origin_pool.example]
}

