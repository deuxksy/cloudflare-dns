resource "cloudflare_dns_record" "mx" {
  zone_id  = var.cloudflare_zone_id
  name     = var.cloudflare_domain
  content  = "smtp.google.com"
  type     = "MX"
  ttl      = 300
  priority = 10
}

resource "cloudflare_dns_record" "spf" {
  zone_id = var.cloudflare_zone_id
  name    = var.cloudflare_domain
  content = "v=spf1 include:_spf.google.com ~all"
  type    = "TXT"
  ttl     = 3600
}

resource "cloudflare_dns_record" "dkim" {
  zone_id = var.cloudflare_zone_id
  name    = "google._domainkey.${var.cloudflare_domain}"
  content = "v=DKIM1;k=rsa;p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAywzXtkExWCN2lZX4qPquXu9fZ1zXTJNEhVkEB7sLmrX/VU1/ljlkkg6UcVx6VvqvoyrFkmoynhlhUtvnFbC9Dx+CkMW4MA+zYCnWmLV0EbhXeT1tuy0q1BFfNT4fnok8kSf4NnQRZ+8oYj2oOZ+EX4BSm0PV6dN74M8Kb90tLg5Alg9nz2zw3mTu1LWFambk8U3KWxJXVUKs8pXEh0xE6BtpqOvv+UKLwEe0MGb0HIzxQ8Da+7KXYdbQLhZxpWELK2VHHCgXHl4/Tnt1iF5zBiKXZgmjWoHK63F1g/rjBkr+X062fqU95GEgck2tNlwBrxFIj5I9/MlDl1fn/gs/LQIDAQAB"
  type    = "TXT"
  ttl     = 3600
}

resource "cloudflare_dns_record" "google_site_verification" {
  zone_id = var.cloudflare_zone_id
  name    = var.cloudflare_domain
  content = "google-site-verification=i64XlSX8DoFAT7iQCGowAqd45a2uqXSbPHybkWB-tZY"
  type    = "TXT"
  ttl     = 3600
}

resource "cloudflare_dns_record" "dmarc" {
  zone_id = var.cloudflare_zone_id
  name    = "_dmarc.${var.cloudflare_domain}"
  content = "v=DMARC1; p=none;"
  type    = "TXT"
  ttl     = 3600
}

import {
  to = cloudflare_dns_record.mx
  id = "${var.cloudflare_zone_id}/677322034afc6a2eb093deda323ee2da"
}

import {
  to = cloudflare_dns_record.dkim
  id = "${var.cloudflare_zone_id}/3a4e61ccd73a6c8cac9b2880a1691e79"
}

import {
  to = cloudflare_dns_record.google_site_verification
  id = "${var.cloudflare_zone_id}/b462219707d8933c193a4ad16b527982"
}

import {
  to = cloudflare_dns_record.spf
  id = "${var.cloudflare_zone_id}/926d1ed3e0110e5e90859fb902ea9813"
}
