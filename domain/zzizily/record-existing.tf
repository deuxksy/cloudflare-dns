resource "cloudflare_dns_record" "existing_2605f068eafb" {
  zone_id = var.cloudflare_zone_id
  type    = "A"
  name    = "ddns-linksys.zzizily.com"
  content = "192.0.2.1"
  ttl     = 1
  proxied = false

  lifecycle {
    ignore_changes = [content]
  }
}

import {
  to = cloudflare_dns_record.existing_2605f068eafb
  id = "${nonsensitive(var.cloudflare_zone_id)}/2605f068eafbb5a30e5dbd2934e50153"
}

resource "cloudflare_dns_record" "existing_d5880b55c778" {
  zone_id = var.cloudflare_zone_id
  type    = "A"
  name    = "nlog.zzizily.com"
  content = "192.0.2.1"
  ttl     = 1
  proxied = true

  lifecycle {
    ignore_changes = [content]
  }
}

import {
  to = cloudflare_dns_record.existing_d5880b55c778
  id = "${nonsensitive(var.cloudflare_zone_id)}/d5880b55c778b896ead1e9642f976b3a"
}

resource "cloudflare_dns_record" "existing_82e0db48bced" {
  zone_id = var.cloudflare_zone_id
  type    = "CNAME"
  name    = "_9c63f5b8b51a5a7adb585a5d55ae6ad7.zzizily.com"
  content = "4146200839c42d0ff2044c7074489632.7e878ca464ca03d1ee0ca12cbfc419d3.dcv202402263a3f2.sectigo.com"
  ttl     = 1
  proxied = false
}

import {
  to = cloudflare_dns_record.existing_82e0db48bced
  id = "${nonsensitive(var.cloudflare_zone_id)}/82e0db48bced0590b1b1aed8ac9e946c"
}

resource "cloudflare_dns_record" "existing_6854ed601be7" {
  zone_id = var.cloudflare_zone_id
  type    = "CNAME"
  name    = "fvmeg6k6hzoiejivopjgemlycs34b5z7._domainkey.zzizily.com"
  content = "fvmeg6k6hzoiejivopjgemlycs34b5z7.dkim.amazonses.com"
  ttl     = 1
}

import {
  to = cloudflare_dns_record.existing_6854ed601be7
  id = "${nonsensitive(var.cloudflare_zone_id)}/6854ed601be78c3ecc77c557d2aa245c"
}

resource "cloudflare_dns_record" "existing_471f535c717e" {
  zone_id = var.cloudflare_zone_id
  type    = "CNAME"
  name    = "gmg76ot722qhk7nnuy6m66d4oqjnxq32._domainkey.zzizily.com"
  content = "gmg76ot722qhk7nnuy6m66d4oqjnxq32.dkim.amazonses.com"
  ttl     = 1
}

import {
  to = cloudflare_dns_record.existing_471f535c717e
  id = "${nonsensitive(var.cloudflare_zone_id)}/471f535c717e716b9ea0ffd02db9b8f0"
}

resource "cloudflare_dns_record" "existing_d5728c049673" {
  zone_id = var.cloudflare_zone_id
  type    = "CNAME"
  name    = "qg4ae56fvyq3ytn7zivavkyzgju7jdyq._domainkey.zzizily.com"
  content = "qg4ae56fvyq3ytn7zivavkyzgju7jdyq.dkim.amazonses.com"
  ttl     = 1
}

import {
  to = cloudflare_dns_record.existing_d5728c049673
  id = "${nonsensitive(var.cloudflare_zone_id)}/d5728c049673ee21ad7eceda89dab34e"
}

resource "cloudflare_dns_record" "existing_b46bc47e284b" {
  zone_id = var.cloudflare_zone_id
  type    = "CNAME"
  name    = "sig1._domainkey.zzizily.com"
  content = "sig1.dkim.zzizily.com.at.icloudmailadmin.com"
  ttl     = 3600
  proxied = false
}

import {
  to = cloudflare_dns_record.existing_b46bc47e284b
  id = "${nonsensitive(var.cloudflare_zone_id)}/b46bc47e284b5743e095b197cca93214"
}

resource "cloudflare_dns_record" "existing_f9976933493e" {
  zone_id = var.cloudflare_zone_id
  type    = "CNAME"
  name    = "tlog.zzizily.com"
  content = "placeholder.invalid"
  ttl     = 1
  proxied = true

  lifecycle {
    ignore_changes = [content]
  }
}

import {
  to = cloudflare_dns_record.existing_f9976933493e
  id = "${nonsensitive(var.cloudflare_zone_id)}/f9976933493e2a5e583dbaf48e979daa"
}

resource "cloudflare_dns_record" "existing_f0f15d57a215" {
  zone_id = var.cloudflare_zone_id
  type    = "CNAME"
  name    = "uptime.zzizily.com"
  content = "placeholder.invalid"
  ttl     = 1
  proxied = true

  lifecycle {
    ignore_changes = [content]
  }
}

import {
  to = cloudflare_dns_record.existing_f0f15d57a215
  id = "${nonsensitive(var.cloudflare_zone_id)}/f0f15d57a215a16d5411783b4fce227b"
}

resource "cloudflare_dns_record" "existing_9ec8a2ecb3a1" {
  zone_id = var.cloudflare_zone_id
  type    = "TXT"
  name    = "_dmarc.zzizily.com"
  content = "\"v=DMARC1; p=none; rua=mailto:663691a99d3940bba11b3c675b667f53@dmarc-reports.cloudflare.net,mailto:deuxksy@gmail.com\""
  ttl     = 1
}

import {
  to = cloudflare_dns_record.existing_9ec8a2ecb3a1
  id = "${nonsensitive(var.cloudflare_zone_id)}/9ec8a2ecb3a1b900f5bf1a06c6da6bc7"
}

resource "cloudflare_dns_record" "existing_fe949bc14921" {
  zone_id = var.cloudflare_zone_id
  type    = "TXT"
  name    = "openai-domain-verification.zzizily.com"
  content = "\"dv-CmZ2fXPbTw1gSWhI60zcRnLE\""
  ttl     = 1
}

import {
  to = cloudflare_dns_record.existing_fe949bc14921
  id = "${nonsensitive(var.cloudflare_zone_id)}/fe949bc1492114726e94c17819b172a1"
}

resource "cloudflare_dns_record" "existing_359174db5d0e" {
  zone_id = var.cloudflare_zone_id
  type    = "TXT"
  name    = "zzizily.com"
  content = "\"apple-domain=PV990HX3vQKbGdHJ\""
  ttl     = 3600
}

import {
  to = cloudflare_dns_record.existing_359174db5d0e
  id = "${nonsensitive(var.cloudflare_zone_id)}/359174db5d0e6d6a7f4ab5d6755e241e"
}

resource "cloudflare_dns_record" "existing_2fa7b4c7bd88" {
  zone_id = var.cloudflare_zone_id
  type    = "TXT"
  name    = "zzizily.com"
  content = "\"v=spf1 include:amazonses.com include:_spf.google.com include:icloud.com ~all\""
  ttl     = 3600
}

import {
  to = cloudflare_dns_record.existing_2fa7b4c7bd88
  id = "${nonsensitive(var.cloudflare_zone_id)}/2fa7b4c7bd88d207d38fb5392e78954b"
}
