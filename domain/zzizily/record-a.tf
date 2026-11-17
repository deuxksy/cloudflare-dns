resource "cloudflare_dns_record" "local" {
  zone_id = var.cloudflare_zone_id
  name    = "local.${var.cloudflare_domain}"
  content = "127.0.0.1"
  type    = "A"
  ttl     = 3600
}

resource "cloudflare_dns_record" "apex" {
  zone_id = var.cloudflare_zone_id
  name    = var.cloudflare_domain
  content = "192.0.2.1"
  type    = "A"
  ttl     = 1
  proxied = true
}
