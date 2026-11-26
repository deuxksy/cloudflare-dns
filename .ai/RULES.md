# RULES

모든 AI agent가 공통으로 따르는 rule. 구조·시작하기는 README.md 참조 (중복 금지).

## 검증

- `cd domain/<도메인> && tofu fmt -check && tofu validate -no-color`

## Apply 주체는 CI

- 변경(DNS/WAF/Redirect)은 PR → plan 코멘트 검증 → merge (자동 apply). 로컬 apply 금지
- 로컬 `.env`는 `tofu init`/`plan` 검증용 — 실제 apply는 CI가 GitHub Secrets으로 수행
- `workflow_dispatch`로 main 수동 재실행 가능 (멱등성 확인용)

## 되돌림 — revert 금지

- merge 후 리소스 블록 제거 revert는 "N to destroy"를 트리거해 DNS를 실제 삭제함 (메일 장애)
- 되돌림 경로: forward-fix (권장) / `removed { destroy = false }` / 비상시 `tofu state rm`

## Cloudflare 함정

- TXT content는 Cloudflare API 정규화 값(따옴표 포함, 255자 초과 시 `"chunk1" "chunk2"` 분리)과 byte 일치해야 멱등
- import ID에 sensitive variable 사용 불가 — `cloudflare_zone_id`는 `sensitive = true` 없이 선언
- import 블록은 영구 유지 (재적용 안전)
- Account API Token은 구형 `cloudflare_page_rule` 미지원(`code 1011`) — 리다이렉트는 신형 `cloudflare_ruleset` (`http_request_dynamic_redirect`) 사용
- Free/Pro `http_ratelimit`은 `managed_challenge` 불가 — `action = "block"`, `period = 10`, `mitigation_timeout = 10`, `characteristics = ["cf.colo.id", "ip.src"]` 사용

## 시크릿

- 비밀은 `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `CLOUDFLARE_API_TOKEN` 3개뿐 — 평문(`.env`) 커밋 금지
- `.env.sops` 갱신 시 반드시 `sops --input-type binary --output-type json -e .env > .env.sops` 사용 (기본 `dotenv` 포맷 금지)
- zone_id·record ID는 비민감 식별자 — 코드·문서 평문 허용
