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

variable "sp_name" {}

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

// Manage Service Policy
resource "volterra_service_policy" "example" {
  name      = var.sp_name
  namespace = var.myns

  algo      = "FIRST_MATCH"

  rule_list {
    rules {
      metadata {
        name = "demo-app-sp-rule1"
      }
      spec {
        action = "ALLOW"
        api_group_matcher {
          match = [ "ves-io-api-def-demo-app-api-definition-all-operations" ]
          invert_matcher = false
        }
        challenge_action  = "DEFAULT_CHALLENGE"
        waf_action {
          none = true
        }
      }
    }
    rules {
      metadata {
        name = "demo-app-sp-rule2"
      }
      spec {
        action = "DENY"
        api_group_matcher {
          match = [ "ves-io-api-def-demo-app-api-definition-base-urls" ]
          invert_matcher = false
        }
        challenge_action  = "DEFAULT_CHALLENGE"
        waf_action {
          none = true
        }
      }
    }
    rules {
      metadata {
        name = "demo-app-sp-rule3"
      }
      spec {
        action = "ALLOW"
        challenge_action  = "DEFAULT_CHALLENGE"
        waf_action {
          none = true
        }
      }
    }
  }
}

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
  // service_policies_from_namespace = true
  active_service_policies {
    policies {
      name = var.sp_name
    }
  }
  disable_waf                     = true
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
  depends_on = [volterra_origin_pool.example, volterra_service_policy.example]
}
