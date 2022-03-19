api_p12_file     = "/path/to/p12file"        // Path for p12 file downloaded from VoltConsole
api_url          = "https://**api url**"     // API URL for your tenant
healthcheck_name = "healthcheck"             // Name of Health Check  
myns             = "namespace"               // Name of your namespace
op_name          = "originpool"              // Name of Origin Pool
pool_port        = "80"                      // Port Number
k8s_svc_name     = "svc"                     // Kubernetes Seervice Name created in vK8s
vsite_name       = "vsite"                   // Name of Virtual Site
httplb_name      = "httplb"                  // Name of HTTP LoadBalancer
mydomain         = ["host.namespace.domain"] // Domain name to be exposed

cert             = "string///**base 64 encode SSL Certificate**"  // SSL Certificate for HTTPS access
private_key      = "string///**base 64 encode SSL Private Key**"  // SSL Private Key for HTTPS access

// WAF Parameter
waf_name         = "app_firewall"            // Name of App Firewall
