# cloudflare-dns

[![OpenTofu](https://github.com/deuxksy/cloudflare-dns/actions/workflows/tofu.yml/badge.svg?branch=main)](https://github.com/deuxksy/cloudflare-dns/actions/workflows/tofu.yml)

`zzizily.com`·`zetlabs.net` 두 개인 도메인의 Cloudflare DNS, Free 호환 WAF, Redirect Rule을 OpenTofu와 R2 Backend로 선언적 관리하는 IaC 저장소입니다. PR에서 `tofu plan`을 검증하고 `main` 병합 시 GitHub Actions가 자동 `apply`합니다.

## 시작하기

로컬 `tofu apply`는 금지하며, 변경은 항상 **PR → plan 검증 → main merge**로 적용합니다.

```bash
# 1. domain/<zzizily|zetlabs>/ 내 .tf 파일 편집
# 2. 로컬 검증 (.env 필요)
source .env && cd domain/<zzizily|zetlabs> && tofu init && tofu fmt -check && tofu validate -no-color && tofu plan -no-color
# 3. PR 생성 → CI plan 확인 → main merge (자동 apply)
```

## 관리 도메인

| 도메인 | 경로 | 관리 리소스 |
|---|---|---|
| `zzizily.com` | `domain/zzizily/` | DNS, Free 호환 WAF, Redirect Rule (`@` → `www`) |
| `zetlabs.net` | `domain/zetlabs/` | DNS, Free 호환 WAF |

## 환경 변수 · GitHub Secrets

| 로컬 `.env` | GitHub Secret | 용도 |
|---|---|---|
| `AWS_ACCESS_KEY_ID` | `AWS_ACCESS_KEY_ID` | R2 State Backend (R2 Account API Token) |
| `AWS_SECRET_ACCESS_KEY` | `AWS_SECRET_ACCESS_KEY` | R2 State Backend (R2 Account API Token) |
| `TF_VAR_cloudflare_api_token` | `CLOUDFLARE_API_TOKEN` | Cloudflare Account API Token (`DNS`, `Zone WAF Rules`, `Dynamic URL Redirects` Edit) |

## 문서

- **Tutorials**: [시작하기](#시작하기) — 로컬 검증 및 PR 배포 흐름
- **How-To**: [CI/CD 파이프라인](./docs/okf/how-to/cicd-pipeline.md) — PR plan · merge apply · 수동 재실행
- **Reference**: [문서 허브](./docs/README.md) · [OKF 인덱스](./docs/okf/README.md) · [환경 변수 템플릿](./.env.example)
- **Explanation**: [아키텍처](./docs/okf/explanation/architecture.md) — 로컬 · GitHub Actions · Cloudflare R2/API 구조
