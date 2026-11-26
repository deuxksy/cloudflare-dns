resource "cloudflare_ruleset" "waf_custom" {
  zone_id     = var.cloudflare_zone_id
  name        = "default"
  description = "Free-compatible WAF custom rules"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  rules = [
    {
      ref         = "block_scanner_paths"
      action      = "block"
      description = "Block common scanner and sensitive paths"
      enabled     = true
      expression  = "not cf.client.bot and not starts_with(http.request.uri.path, \"/.well-known/\") and (starts_with(http.request.uri.path, \"/.env\") or starts_with(http.request.uri.path, \"/.git\") or starts_with(http.request.uri.path, \"/.aws\") or starts_with(http.request.uri.path, \"/.ssh\") or starts_with(http.request.uri.path, \"/wp-admin\") or http.request.uri.path eq \"/wp-login.php\" or http.request.uri.path eq \"/xmlrpc.php\" or starts_with(http.request.uri.path, \"/phpmyadmin\"))"
    },
    {
      ref         = "challenge_empty_ua_http10"
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
      ref         = "ratelimit_non_static"
      action      = "block"
      description = "Block excessive non-static requests per IP"
      enabled     = true
      expression  = "not cf.bot_management.verified_bot and not starts_with(http.request.uri.path, \"/.well-known/\") and not (ends_with(http.request.uri.path, \".css\") or ends_with(http.request.uri.path, \".js\") or ends_with(http.request.uri.path, \".png\") or ends_with(http.request.uri.path, \".jpg\") or ends_with(http.request.uri.path, \".jpeg\") or ends_with(http.request.uri.path, \".gif\") or ends_with(http.request.uri.path, \".svg\") or ends_with(http.request.uri.path, \".ico\") or ends_with(http.request.uri.path, \".webp\") or ends_with(http.request.uri.path, \".woff\") or ends_with(http.request.uri.path, \".woff2\"))"
      ratelimit = {
        characteristics     = ["cf.colo.id", "ip.src"]
        period              = 10
        requests_per_period = 100
        mitigation_timeout  = 10
      }
    }
  ]
}
