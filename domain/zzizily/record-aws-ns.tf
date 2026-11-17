resource "cloudflare_dns_record" "ns_forti1" {
  zone_id = var.cloudflare_zone_id
  type    = "NS"
  name    = "forti.zzizily.com"
  content = "ns-1869.awsdns-41.co.uk"
  ttl     = 1
}

import {
  to = cloudflare_dns_record.ns_forti1
  id = "${nonsensitive(var.cloudflare_zone_id)}/11323eb9764f73d6b8968b1c54b38a3c"
}

resource "cloudflare_dns_record" "ns_forti2" {
  zone_id = var.cloudflare_zone_id
  type    = "NS"
  name    = "forti.zzizily.com"
  content = "ns-1460.awsdns-54.org"
  ttl     = 1
}

import {
  to = cloudflare_dns_record.ns_forti2
  id = "${nonsensitive(var.cloudflare_zone_id)}/b0b480ec2ee29e8048ddb0c67bdac90a"
}

resource "cloudflare_dns_record" "ns_forti3" {
  zone_id = var.cloudflare_zone_id
  type    = "NS"
  name    = "forti.zzizily.com"
  content = "ns-852.awsdns-42.net"
  ttl     = 1
}

import {
  to = cloudflare_dns_record.ns_forti3
  id = "${nonsensitive(var.cloudflare_zone_id)}/e067e707d124b6eeab3876ad96cfcc7f"
}

resource "cloudflare_dns_record" "ns_forti4" {
  zone_id = var.cloudflare_zone_id
  type    = "NS"
  name    = "forti.zzizily.com"
  content = "ns-110.awsdns-13.com"
  ttl     = 1
}

import {
  to = cloudflare_dns_record.ns_forti4
  id = "${nonsensitive(var.cloudflare_zone_id)}/08ec3ec0fee8805952233fc5b8550def"
}

resource "cloudflare_dns_record" "ns_linksys1" {
  zone_id = var.cloudflare_zone_id
  type    = "NS"
  name    = "linksys.zzizily.com"
  content = "ns-1831.awsdns-36.co.uk"
  ttl     = 1
}

import {
  to = cloudflare_dns_record.ns_linksys1
  id = "${nonsensitive(var.cloudflare_zone_id)}/edfc9bdde896d4018c085b149bc2d6b0"
}

resource "cloudflare_dns_record" "ns_linksys2" {
  zone_id = var.cloudflare_zone_id
  type    = "NS"
  name    = "linksys.zzizily.com"
  content = "ns-1147.awsdns-15.org"
  ttl     = 1
}

import {
  to = cloudflare_dns_record.ns_linksys2
  id = "${nonsensitive(var.cloudflare_zone_id)}/bf006351427d2c536c2840655169ebb9"
}

resource "cloudflare_dns_record" "ns_linksys3" {
  zone_id = var.cloudflare_zone_id
  type    = "NS"
  name    = "linksys.zzizily.com"
  content = "ns-35.awsdns-04.com"
  ttl     = 1
}

import {
  to = cloudflare_dns_record.ns_linksys3
  id = "${nonsensitive(var.cloudflare_zone_id)}/cbc2a2f445d20079dec294b5c1451619"
}

resource "cloudflare_dns_record" "ns_linksys4" {
  zone_id = var.cloudflare_zone_id
  type    = "NS"
  name    = "linksys.zzizily.com"
  content = "ns-694.awsdns-22.net"
  ttl     = 1
}

import {
  to = cloudflare_dns_record.ns_linksys4
  id = "${nonsensitive(var.cloudflare_zone_id)}/2b8e2072db4f6c1bd62c0f32df38aa4b"
}
