variable "api_p12_file" {}
variable "api_url" {}
variable "healthcheck_name" {}
variable "myns" {}
variable "op_name" {}
variable "pool_port" {}
variable "httplb_name" {}
variable "mydomain" {}

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
resource "volterra_origin_pool" "this" {
  name                   = var.op_name
  namespace              = var.myns
  endpoint_selection     = "LOCAL_PREFERRED"
  loadbalancer_algorithm = "LB_OVERRIDE"
  port                   = var.pool_port
  no_tls                 = true
  origin_servers [
    {
      public_name = var.ser_name1
    },
    {
      public_name = var.ser_name2
    }
  ]
}

// Manage HTTP LoadBalancer
resource "volterra_http_loadbalancer" "this" {
  name                            = var.httplb_name
  namespace                       = var.myns
  domains                         = var.mydomain
  advertise_on_public_default_vip = true
  no_challenge                    = true
  round_robin                     = true
  disable_rate_limit              = true
  service_policies_from_namespace = true
  disable_waf                     = true
  default_route_pools {
    pool {
      name      = var.op_name
      namespace = var.myns
    }
  }
  depends_on = [volterra_origin_pool.this]
}
