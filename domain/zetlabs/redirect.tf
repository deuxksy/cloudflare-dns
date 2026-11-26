resource "cloudflare_ruleset" "redirect_www_to_apex" {
  zone_id     = var.cloudflare_zone_id
  name        = "default"
  description = "Redirect www to apex domain"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  rules = [
    {
      ref         = "redirect_www_to_apex"
      action      = "redirect"
      description = "Redirect www.zetlabs.net to zetlabs.net (301)"
      enabled     = true
      expression  = "http.host eq \"www.${var.cloudflare_domain}\""
      action_parameters = {
        from_value = {
          status_code           = 301
          preserve_query_string = true
          target_url = {
            expression = "concat(\"https://${var.cloudflare_domain}\", http.request.uri.path)"
          }
        }
      }
    }
  ]
}
