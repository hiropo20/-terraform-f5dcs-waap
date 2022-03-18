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

variable "waf_name" {}

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


// Manage APP Firewall
resource "volterra_app_firewall" "example" {
  name                   = var.waf_name
  namespace              = var.myns

  // One of the arguments from example list "allow_all_response_codes allowed_response_codes" must be set
  // allow_all_response_codes = true
  allowed_response_codes {
    response_code = [ "200" ]
  }

  // One of the arguments from example list "default_anonymization custom_anonymization disable_anonymization" must be set
  // default_anonymization = true
  custom_anonymization  {
    anonymization_config {
      query_parameter {
        query_param_name = "mypass"
      }
    }
  }

  // One of the arguments from example list "use_default_blocking_page blocking_page" must be set
  // use_default_blocking_page = true
  blocking_page {
    blocking_page = "string:///PGh0bWw+PGhlYWQ+PHRpdGxlPlJlcXVlc3QgUmVqZWN0ZWQgQ3VzdG9tIFBhZ2U8L3RpdGxlPjwvaGVhZD48Ym9keT5UaGUgcmVxdWVzdGVkIFVSTCB3YXMgcmVqZWN0ZWQuIFBsZWFzZSBjb25zdWx0IHdpdGggeW91ciBhZG1pbmlzdHJhdG9yLjxici8+PGJyLz5Zb3VyIHN1cHBvcnQgSUQgaXM6IHt7cmVxdWVzdF9pZH19PGJyLz48YnIvPjxhIGhyZWY9ImphdmFzY3JpcHQ6aGlzdG9yeS5iYWNrKCkiPltHbyBCYWNrXTwvYT48L2JvZHk+PC9odG1sPg=="
  }

  // One of the arguments from example list "default_bot_setting bot_protection_setting" must be set
  // default_bot_setting = true
  bot_protection_setting {
    malicious_bot_action = "BLOCK"
    suspicious_bot_action = "REPORT"
    good_bot_action = "REPORT"
  }

  // One of the arguments from example list "default_detection_settings detection_settings" must be set
  // default_detection_settings = true
  detection_settings {
    signature_selection_setting {
      default_attack_type_settings = true
      high_medium_accuracy_signatures = true
    }
    enable_suppression         = true
    enable_threat_campaigns    = true
    default_violation_settings = true
  }

  // One of the arguments from example list "use_loadbalancer_setting blocking monitoring" must be set
  //use_loadbalancer_setting = true
  blocking = true
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
  //disable_waf                     = true
  app_firewall {
    namespace                     = var.myns
    name                          = var.waf_name
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
  depends_on = [volterra_origin_pool.example, volterra_app_firewall.example]
}
