api_p12_file     = "/path/to/p12file"        // Path for p12 file downloaded from VoltConsole
api_url          = "https://**api url**"     // API URL for your tenant

myns             = "namespace"               // Name of your namespace
op_name          = "originpool"              // Name of Origin Pool
pool_port        = "80"                      // Port Number
server_name1     = "target server fqdn1"     // Target Server FQDN1
server_name2     = "target server fqdn2"     // Target Server FQDN2
httplb_name      = "httplb"                  // Name of HTTP LoadBalancer
mydomain         = ["host.namespace.domain"] // Domain name to be exposed

cert             = "string///**base 64 encode SSL Certificate**"  // SSL Certificate for HTTPS access
private_key      = "string///**base 64 encode SSL Private Key**"  // SSL Private Key for HTTPS access

// WAF Parameter
waf_name         = "app_firewall"            // Name of App Firewall
