# zetlabs.net OpenTofu + GitHub Actions CI/CD 설계

- **날짜**: 2026-11-16
- **상태**: 승인됨 (설계 대화 기반)
- **유형**: Explanation (설계 결정 기록)

## 목표

zetlabs.net 도메인을 OpenTofu로 구성하고, GitHub Actions가 OpenTofu를 실행해 Cloudflare에 DNS 변경을 반영한다. 변경 적용의 주체는 로컬이 아닌 CI다.

## 현재 상태 (2026-11-16 검증 완료)

| 항목 | 상태 |
| :--- | :--- |
| `zetlabs.net` zone | active — zone_id `691ceca457f17b055c015aae77c1a6bc` |
| 기존 DNS 레코드 4개 | MX / SPF / DKIM / Google 인증 TXT — record ID 전수 확보 |
| `domain/zetlabs/` 코드 | main.tf + record-mail.tf 작성, fmt/validate/init 통과 |
| `.github/workflows/tofu.yml` | `tofu-zetlabs` job 포함, `CLOUDFLARE_ZONE_ID_ZETLABS` 참조 |
| API 토큰 | Zone 권한 확장 완료 (GitHub Secrets에 유효 값 보관) |
| 로컬 `.env` 토큰 | 14자 placeholder로 무효 — 이 설계에서는 불필요 |

## 설계

### 실행 전략 — CI 주도

import 블록을 PR로 올려 CI가 검증하고, merge로 CI가 적용한다.

```text
브랜치 feat/zetlabs-dns
  → import 블록 4개 커밋 → push → PR
  → CI tofu plan (PR 코멘트 자동 출력)
     기대: Import planned 4 + Plan: 1 to add (_dmarc)
  → plan 검증 → merge → main push
  → CI tofu apply: import 4건 + _dmarc 레코드 생성
```

선택 이유:

1. 목표 아키텍처(CI 주도)를 최종 단계부터 그대로 검증한다
2. 로컬에 유효한 API 토큰이 없어도 진행 가능하다 (`.env` 무수정)
3. workflow의 PR plan 코멘트 기능이 로컬 plan 검증을 대신한다

### 코드 변경

- `domain/zetlabs/record-mail.tf`에 `import` 블록 4개 추가
- import ID 형식: `<zone_id>/<record_id>` — provider v5 공식 문서 확인 (2026-11-16, v5.19.1 docs)
- zone_id는 import 블록에서 `var.cloudflare_zone_id` 보간으로 참조. 단 OpenTofu 제약상 import ID에 sensitive variable을 쓸 수 없어 zone_id variable의 `sensitive`는 제거했다 — zone_id 자체는 비민감 식별자로 plan/로그 노출을 수용하고, 실제 비밀은 API 토큰만 관리한다 (2026-11-16 Ruling)
- import 블록은 apply 후에도 유지 (재적용 안전, 선언적)
- workflow, README는 이미 수정 완료 상태로 무변경

| 리소스 | Record ID |
| :--- | :--- |
| `cloudflare_dns_record.mx` | `677322034afc6a2eb093deda323ee2da` |
| `cloudflare_dns_record.dkim` | `3a4e61ccd73a6c8cac9b2880a1691e79` |
| `cloudflare_dns_record.google_site_verification` | `b462219707d8933c193a4ad16b527982` |
| `cloudflare_dns_record.spf` | `926d1ed3e0110e5e90859fb902ea9813` |

import 시 코드-실제 값 불일치(TTL 등)가 plan에 표시되면 코드를 실제 값으로 보정한다. 기존 레코드의 실제 값을 Cloudflare API가 Ground Truth다.

### Secret 및 커밋 구성

- `gh secret set CLOUDFLARE_ZONE_ID_ZETLABS` — PR push 전 등록 필수 (없으면 CI plan 실패)
- 커밋 분리:
  - 본건: `domain/zetlabs/`, workflow, README.md, mise.toml
  - 별도: `domain/root/record-ddns.tf` (공인 IP 마스킹 — 관심사 분리)
- `.serena/`은 `.gitignore` 등록 후 커밋 제외

## 검증 계획

1. Secret 등록 → verify: `gh secret list`에 `CLOUDFLARE_ZONE_ID_ZETLABS` 존재
2. PR plan → verify: PR 코멘트에 Import 4건 + create 1건(_dmarc), destroy 0건
3. merge 후 CI apply → verify: Actions 성공 + state에 리소스 5개
4. Cloudflare 반영 → verify: DNS 조회로 `_dmarc.zetlabs.net` TXT 응답
5. 멱등성 → verify: CI 재실행 시 "No changes"

## 리스크 및 롤백

- CI plan 실패: PR 코멘트로 원인 노출 → 브랜치에서 수정 (plan은 continue-on-error)
- import apply 실패: CI 중단. record ID는 검증 완료라 실패 확률 낮음
- **롤백 주의 — revert는 destroy를 트리거한다**: merge 후 5개 리소스가 state에 편입된 시점부터, import 블록/리소스 블록을 제거하는 revert의 plan은 "5 to destroy"가 되고 main push 자동 apply가 MX/SPF/DKIM/인증 TXT/_dmarc를 실제 삭제한다 (메일 전면 장애). 안전한 되돌리기 경로는:
  1. 문제 리소스만 forward-fix로 수정 (권장)
  2. state에서만 제거: `removed { to = ..., destroy = false }` 블록
  3. 비상시 `tofu state rm <주소>` — CI가 다음 apply에서 리소스를 재생성하므로 코드도 함께 제거해야 한다

## 범위 밖

- 홈택스 상호 정정(젯랩 → 젯랩스), Google Admin DKIM 인증, Gmail 발신 테스트
- DMARC 정책 강화(rua 리포트 수신 등) — `p=none` 유지
- `domain/root/` state 및 리소스 구조 변경
