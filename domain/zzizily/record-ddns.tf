# 자택 공인 IP — public repo에 평문 커밋 금지.
# 실제 값은 Cloudflare 대시보드/API(DDNS 갱신 스크립트)에서만 관리하고
# content는 생성 시 더미(192.0.2.1, RFC 5737 문서용 대역)를 넣는다.
resource "cloudflare_dns_record" "ddns-netgear" {
  zone_id = var.cloudflare_zone_id
  name    = "ddns-netgear.${var.cloudflare_domain}"
  content = "192.0.2.1"
  type    = "A"
  ttl     = 3600

  lifecycle {
    ignore_changes = [content]
  }
}
