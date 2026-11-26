resource "cloudflare_ruleset" "waf_custom" {
  zone_id     = var.cloudflare_zone_id
  name        = "default"
  description = "Free-compatible WAF custom rules"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  rules = [
    {
      action      = "block"
      description = "Block common scanner and sensitive paths"
      enabled     = true
      expression  = "not cf.client.bot and not starts_with(http.request.uri.path, \"/.well-known/\") and (starts_with(http.request.uri.path, \"/.env\") or starts_with(http.request.uri.path, \"/.git\") or starts_with(http.request.uri.path, \"/.aws\") or starts_with(http.request.uri.path, \"/.ssh\") or starts_with(http.request.uri.path, \"/wp-admin\") or http.request.uri.path eq \"/wp-login.php\" or http.request.uri.path eq \"/xmlrpc.php\" or starts_with(http.request.uri.path, \"/phpmyadmin\"))"
    },
    {
      action      = "managed_challenge"
      description = "Challenge requests with empty User-Agent or HTTP/1.0"
      enabled     = true
      expression  = "not cf.client.bot and (http.user_agent eq \"\" or http.request.version eq \"HTTP/1.0\")"
    }
  ]
}

resource "cloudflare_ruleset" "waf_ratelimit" {
  zone_id     = var.cloudflare_zone_id
  name        = "default"
  description = "Free-compatible rate limiting rule"
  kind        = "zone"
  phase       = "http_ratelimit"

  rules = [
    {
      action      = "managed_challenge"
      description = "Challenge excessive non-static requests per IP"
      enabled     = true
      expression  = "not (http.request.uri.path.extension in {\"css\" \"js\" \"png\" \"jpg\" \"jpeg\" \"gif\" \"svg\" \"ico\" \"webp\" \"woff\" \"woff2\"})"
      ratelimit = {
        characteristics     = ["cf.colo.id", "ip.src"]
        period              = 10
        requests_per_period = 100
        mitigation_timeout  = 10
      }
    }
  ]
}
