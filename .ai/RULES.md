# RULES

모든 AI agent가 공통으로 따르는 rule. 구조·시작하기는 README.md 참조 (중복 금지).

## 검증

- `cd domain/<도메인> && tofu fmt -check && tofu validate -no-color`

## Apply 주체는 CI

- DNS 변경은 PR → plan 코멘트 검증 → merge (자동 apply). 로컬 apply 금지
- 로컬 `.env`의 Cloudflare 토큰은 placeholder로 무효 — CI가 GitHub Secrets으로 apply
- `workflow_dispatch`로 main 수동 재실행 가능 (멱등성 확인용)

## 되돌림 — revert 금지

- merge 후 리소스 블록 제거 revert는 "N to destroy"를 트리거해 DNS를 실제 삭제함 (메일 장애)
- 되돌림 경로: forward-fix (권장) / `removed { destroy = false }` / 비상시 `tofu state rm`

## Cloudflare 함정

- TXT content는 Cloudflare API 정규화 값(따옴표 포함, 255자 초과 시 `"chunk1" "chunk2"` 분리)과 byte 일치해야 멱등
- import ID에 sensitive variable 사용 불가 — `cloudflare_zone_id`는 `sensitive = true` 없이 선언
- import 블록은 영구 유지 (재적용 안전)

## 시크릿

- 비밀은 API 토큰뿐 — sops(`.env.sops`)로 보관, 어떤 형태로도 커밋 금지
- zone_id·record ID는 비민감 식별자 — 코드·문서 평문 허용
