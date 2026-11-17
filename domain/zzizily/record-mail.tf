resource "cloudflare_dns_record" "mx" {
  zone_id  = var.cloudflare_zone_id
  name     = var.cloudflare_domain
  content  = "aspmx.l.google.com"
  type     = "MX"
  ttl      = 3600
  priority = 1
}

resource "cloudflare_dns_record" "mx5-1" {
  zone_id  = var.cloudflare_zone_id
  name     = var.cloudflare_domain
  content  = "alt1.aspmx.l.google.com"
  type     = "MX"
  ttl      = 3600
  priority = 5
}

resource "cloudflare_dns_record" "mx5-2" {
  zone_id  = var.cloudflare_zone_id
  name     = var.cloudflare_domain
  content  = "alt2.aspmx.l.google.com"
  type     = "MX"
  ttl      = 3600
  priority = 5
}

resource "cloudflare_dns_record" "mx10-1" {
  zone_id  = var.cloudflare_zone_id
  name     = var.cloudflare_domain
  content  = "alt3.aspmx.l.google.com"
  type     = "MX"
  ttl      = 3600
  priority = 10
}

resource "cloudflare_dns_record" "mx10-2" {
  zone_id  = var.cloudflare_zone_id
  name     = var.cloudflare_domain
  content  = "alt4.aspmx.l.google.com"
  type     = "MX"
  ttl      = 3600
  priority = 10
}

resource "cloudflare_dns_record" "icloud_mx01" {
  zone_id  = var.cloudflare_zone_id
  name     = var.cloudflare_domain
  content  = "mx01.mail.icloud.com"
  type     = "MX"
  ttl      = 3600
  priority = 10
}

resource "cloudflare_dns_record" "icloud_mx02" {
  zone_id  = var.cloudflare_zone_id
  name     = var.cloudflare_domain
  content  = "mx02.mail.icloud.com"
  type     = "MX"
  ttl      = 3600
  priority = 10
}

import {
  to = cloudflare_dns_record.icloud_mx01
  id = "${nonsensitive(var.cloudflare_zone_id)}/84b97908ab190b9d8199ef7f54005ed8"
}

import {
  to = cloudflare_dns_record.icloud_mx02
  id = "${nonsensitive(var.cloudflare_zone_id)}/5c08377d054087684835d005dd7b92eb"
}
