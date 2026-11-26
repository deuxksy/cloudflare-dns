# Cloudflare Free 호환 WAF 설계 (OpenTofu IaC)

## 1. 목적 및 배경
- `zzizily.com`(현재 Pro, 향후 Free 전환 가능성 고려)과 `zetlabs.net`(Free) 두 도메인 모두 정적 사이트(GitHub Pages / Cloudflare Pages)를 호스팅하고 있다.
- 수동 대시보드/MCP 설정 대신 OpenTofu IaC로 관리해, 언제든지 CI를 통해 동일하게 재현·재설정할 수 있는 필수 기본 WAF를 구축한다.

## 2. 목표 / 비목표 / 금지사항
- **목표 (Goals)**
  - 두 도메인에 Free 플랜 호환 Custom Rules(2개)와 Rate Limiting(1개)을 OpenTofu(`waf.tf`)로 선언한다.
  - 기존 `.github/workflows/tofu.yml` PR plan → merge apply 흐름에 통합한다.
- **비목표 (Non-Goals)**
  - `zzizily.com`에 이미 활성화된 Pro 전용 Managed WAF(`http_request_firewall_managed`)의 OpenTofu 이관.
  - 국가·ASN 기반 접근 제한이나 AI 크롤러 전면 차단.
- **금지사항 (Anti-Goals)**
  - 정상 검색엔진 봇(`cf.client.bot`) 및 SSL/ACME 검증(`/.well-known/`) 오탐 차단.
  - 로컬 `tofu apply` 실행 (`.ai/RULES.md` 준수).

## 3. 제약사항
- **Free 플랜 한도**: Custom Rules 최대 5개, Rate Limiting 최대 1개 (`period = 10`, `characteristics = ["cf.colo.id", "ip.src"]`, `managed_challenge` 사용 시 Free/Pro에서는 `mitigation_timeout = 0` 필수).
- **기존 리소스 호환**: `zzizily.com`의 기존 Managed WAF(`http_request_firewall_managed`)와 phase가 분리되어 충돌하지 않는다.
- **CI 토큰 권한**: GitHub Secrets의 `CLOUDFLARE_API_TOKEN`에 Zone WAF(Rulesets) 편집 권한(`Zone > Zone WAF > Edit`)이 필요하다. 신규 ruleset 추가 시 PR `tofu plan`은 로컬에서 `2 to add`만 계산하므로, 권한이 부족하면 `main` merge 후 `tofu apply` 단계에서 403이 발생할 수 있어 사전 확인이 필요하다.

## 4. 검토한 접근법
- **방식 A — 경량 필수 방어 (선택)**
  - Custom Rules 2개 + Rate Limiting 1개만 사용해 자동화 스캔과 과도한 요청만 걸러낸다.
  - 장점: 오탐 위험이 매우 낮고 Free 한도(Custom Rules 3개)의 여유를 남긴다.
- **방식 B — 적극적 봇·트래픽 통제 (기각)**
  - AI 크롤러·국가·데이터센터 ASN 챌린지까지 5개 슬롯을 모두 사용하는 방식.
  - 기각 이유: 블로그/랜딩 페이지 방문자나 SNS 미리보기 봇에 오탐을 유발할 수 있고 규칙 여유가 없다.

## 5. 상세 설계
[domain/zzizily/waf.tf](file:///Users/crong/git/cloudflare-dns/domain/zzizily/waf.tf)와 [domain/zetlabs/waf.tf](file:///Users/crong/git/cloudflare-dns/domain/zetlabs/waf.tf)에 각각 아래 2개의 `cloudflare_ruleset` 리소스를 선언한다. (두 도메인은 별도 state와 폴더로 운영되므로 각 폴더에 독립 선언한다.)

1. **Custom Rules (`phase = "http_request_firewall_custom"`, `kind = "zone"`)**
   - **규칙 1 (`block`) — 스캐너·민감 경로 차단**:
     - `not cf.client.bot` 이면서 `http.request.uri.path`가 `/.env`, `/.git`, `/wp-login.php`, `/xmlrpc.php`, `/phpmyadmin` 등 정적 사이트에 존재하지 않는 민감/스캐너 경로에 해당하는 요청 차단 (`/.well-known/` 제외).
   - **규칙 2 (`managed_challenge`) — 비정상 클라이언트 챌린지**:
     - `not cf.client.bot` 이면서 `User-Agent`가 비어 있거나 `http.request.version eq "HTTP/1.0"`인 요청에 챌린지 적용.

2. **Rate Limiting (`phase = "http_ratelimit"`, `kind = "zone"`)**
   - `not cf.bot_management.verified_bot` 및 `not starts_with(http.request.uri.path, "/.well-known/")` 조건과 함께 정적 에셋 확장자(`.css`, `.js`, `.png`, `.jpg`, `.jpeg`, `.gif`, `.svg`, `.ico`, `.webp`, `.woff`, `.woff2`)를 `ends_with`로 제외한 요청에 대해, `cf.colo.id` + `ip.src` 기준으로 **10초당 100회 초과 시 `managed_challenge` (`mitigation_timeout = 0`)** 적용.
   - 모든 규칙에 안정적인 `ref` 식별자를 부여한다.

## 6. 검증 기준
- 두 도메인 각각 `tofu fmt -check && tofu validate -no-color` 통과.
- PR 생성 시 GitHub Actions `tofu plan` 코멘트에서 각 도메인별 `2 to add, 0 to change, 0 to destroy` 확인.
