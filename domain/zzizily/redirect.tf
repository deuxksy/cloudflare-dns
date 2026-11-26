moved {
  from = cloudflare_ruleset.redirect_apex_to_www
  to   = cloudflare_ruleset.redirect_to_apex
}

resource "cloudflare_ruleset" "redirect_to_apex" {
  zone_id     = var.cloudflare_zone_id
  name        = "default"
  description = "Redirect www and blog to apex domain"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  rules = [
    {
      ref         = "redirect_to_apex"
      action      = "redirect"
      description = "Redirect www.zzizily.com and blog.zzizily.com to zzizily.com (301)"
      enabled     = true
      expression  = "http.host eq \"www.${var.cloudflare_domain}\" or http.host eq \"blog.${var.cloudflare_domain}\""
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
