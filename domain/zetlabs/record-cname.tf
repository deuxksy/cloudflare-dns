# ZetLabs 홈페이지 — Cloudflare Pages (zetlabs/deuxksy) (2026-11-18)
resource "cloudflare_dns_record" "homepage" {
  zone_id = var.cloudflare_zone_id
  type    = "CNAME"
  name    = var.cloudflare_domain
  content = "zetlabs.pages.dev"
  ttl     = 1
  proxied = true
}

# ZetLabs 홈페이지 www — Cloudflare Pages (zetlabs/deuxksy) (2026-11-21)
resource "cloudflare_dns_record" "homepage_www" {
  zone_id = var.cloudflare_zone_id
  type    = "CNAME"
  name    = "www"
  content = "zetlabs.pages.dev"
  ttl     = 1
  proxied = true
}
