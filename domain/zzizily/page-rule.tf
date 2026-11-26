resource "cloudflare_ruleset" "redirect_apex_to_www" {
  zone_id     = var.cloudflare_zone_id
  name        = "default"
  description = "Redirect apex domain to www"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  rules = [
    {
      ref         = "redirect_apex_to_www"
      action      = "redirect"
      description = "Redirect zzizily.com to www.zzizily.com (301)"
      enabled     = true
      expression  = "http.host eq \"${var.cloudflare_domain}\""
      action_parameters = {
        from_value = {
          status_code           = 301
          preserve_query_string = true
          target_url = {
            expression = "concat(\"https://www.${var.cloudflare_domain}\", http.request.uri.path)"
          }
        }
      }
    }
  ]
}
