# zetlabs.net CI 주도 DNS import/apply 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** zetlabs.net 기존 DNS 4개 레코드를 import 블록으로 tofu 관리에 편입하고, GitHub Actions가 `_dmarc` 레코드를 생성해 Cloudflare에 반영한다.

**Architecture:** CI 주도 — import 블록을 PR로 올려 workflow의 PR plan 코멘트로 검증하고, merge 시 main push 트리거로 `tofu apply`가 import 4건 + `_dmarc` 생성을 수행한다. 로컬 tofu 실행 없음(로컬 `.env` 토큰은 placeholder).

**Tech Stack:** OpenTofu 1.9 (Cloudflare provider ~> 5.0), R2 S3 backend, GitHub Actions, gh CLI

**Spec:** `docs/superpowers/specs/2026-11-16-zetlabs-dns-cicd-design.md`

## Global Constraints

- zone_id는 Secret 관리 — import 블록에서 `var.cloudflare_zone_id` 보간 사용, 평문 금지
- import ID 형식: `<zone_id>/<record_id>` (provider v5 공식 문서, 2026-11-16 확인)
- record ID 4개 (spec 표 참조): mx `677322034afc6a2eb093deda323ee2da`, dkim `3a4e61ccd73a6c8cac9b2880a1691e79`, google_site_verification `b462219707d8933c193a4ad16b527982`, spf `926d1ed3e0110e5e90859fb902ea9813`
- zone_id는 비민감 식별자 — GitHub Secret 등록·문서 기재를 허용한다 (2026-11-16 개정: import ID에 sensitive variable을 쓸 수 없는 OpenTofu 제약으로 `sensitive` 제거, 노출 수용). 실제 비밀은 API 토큰뿐이며 토큰은 어떤 형태로도 커밋 금지
- `domain/root/` 코드 구조 무변경 (record-ddns.tf 마스킹 커밋은 예외로 spec에 명시됨)
- 커밋 메시지: Conventional Commits, 말머리 영어 + 본문 한국어

## Review Focus

- **import ID 오타**: record ID를 원본(spec)과 diff 검증 — Task 1 Step 3
- **Secret 미등록 push**: CI plan이 auth 실패 — Task 3가 Task 5보다 선행 (task 순서로 보장)
- **코드-실제 레코드 불일치**: plan에 예상 밖 in-place update 표시 — Task 5 Step 2에서 create 1건 외 변경 0건 기준으로 판정
- **`_dmarc` 중복 생성**: Cloudflare에 이미 존재하면 apply 400 — API로 부재 확인됨(2026-11-16), Task 7 Step 1에서 재확인
- **평문 시크릿 커밋**: zone_id/토큰이 코드에 노출되지 않는지 — Task 1 Step 5에서 grep 검증

---

### Task 1: import 블록 추가 및 로컬 검증

**Files:**
- Modify: `domain/zetlabs/record-mail.tf` (파일 끝에 4개 블록 추가)
- Modify: `.gitignore` (`.serena/` 1줄 추가)

**Interfaces:**
- Consumes: `var.cloudflare_zone_id` (main.tf에 정의됨, Secret 주입)
- Produces: import 블록 4개 — Task 5의 plan 검증 대상, Task 6의 apply 대상

- [ ] **Step 1: `record-mail.tf` 끝에 import 블록 4개 추가**

```hcl
import {
  to = cloudflare_dns_record.mx
  id = "${var.cloudflare_zone_id}/677322034afc6a2eb093deda323ee2da"
}
```

나머지 3개(dkim, google_site_verification, spf)도 동일 패턴 — `to`는 각 리소스 주소, `id`는 `var.cloudflare_zone_id` 보간 + `/` + spec의 record ID.

- [ ] **Step 2: fmt/validate 검증 (로컬, 토큰 불필요)**

Run: `cd domain/zetlabs && tofu fmt -check && tofu validate -no-color`
Expected: fmt 무출력(exit 0), validate "Success! The configuration is valid"

- [ ] **Step 3: record ID 정합성 검증**

Run: `grep -oE '[0-9a-f]{32}' domain/zetlabs/record-mail.tf | sort`
Expected: spec의 record ID 4개와 정확히 일치 (32-hex만 추출되므로 zone_id 평문이 섞이지 않음 확인 겸용)

- [ ] **Step 4: 평문 시크릿 검증**

Run: `git diff domain/zetlabs/ | grep -cE '691ceca4|api_token' || echo 0`
Expected: `0`

- [ ] **Step 5: `.gitignore`에 `.serena/` 추가 후 커밋**

```bash
git add domain/zetlabs/record-mail.tf .gitignore
git commit -m "feat: zetlabs.net 기존 DNS 4건 import 블록 추가"
```

### Task 2: 미커밋 변경 정리 (workflow, README, mise, record-ddns)

**Files:**
- Modify: `.github/workflows/tofu.yml` (이미 수정됨, 커밋만)
- Modify: `README.md` (이미 수정됨, 커밋만)
- Create: `mise.toml` (이미 존재, untracked)
- Modify: `domain/root/record-ddns.tf` (이미 수정됨 — 별도 커밋)

**Interfaces:**
- Produces: main↔브랜치에 반영될 PR 스택 — Task 4의 PR 대상

- [ ] **Step 1: zetlabs 본건 커밋**

```bash
git add .github/workflows/tofu.yml README.md mise.toml
git commit -m "feat: tofu-zetlabs CI job 및 문서 — zetlabs.net 멀티 도메인 체계"
```

- [ ] **Step 2: record-ddns 공인 IP 마스킹 별도 커밋**

```bash
git add domain/root/record-ddns.tf
git commit -m "fix: ddns-netgear 공인 IP 평문 제거 — ignore_changes 전환"
```

- [ ] **Step 3: working tree clean 확인**

Run: `git status --porcelain | grep -v '^.M\|??' || echo CLEAN`
Expected: `CLEAN` (.serena/은 Task 1에서 ignore 처리돼 untracked에도 안 남음)

### Task 3: GitHub Secret 등록

**Files:** 없음 (GitHub 원격 설정)

**Interfaces:**
- Consumes: zone_id 실제 값 (spec Global Constraints)
- Produces: `CLOUDFLARE_ZONE_ID_ZETLABS` secret — Task 5 CI plan이 소비

- [ ] **Step 1: Secret 등록**

```bash
gh secret set CLOUDFLARE_ZONE_ID_ZETLABS --body "691ceca457f17b055c015aae77c1a6bc"
```

- [ ] **Step 2: 등록 확인**

Run: `gh secret list`
Expected: `CLOUDFLARE_ZONE_ID_ZETLABS` 행 존재 (기존 AWS 2건, CLOUDFLARE_API_TOKEN, CLOUDFLARE_ZONE_ID, CLOUDFLARE_DOMAIN 포함 총 7건)

### Task 4: 브랜치 생성 및 PR 오픈

**Files:** 없음 (git 브랜치/PR)

**Interfaces:**
- Consumes: Task 1~2의 커밋
- Produces: PR 번호 — Task 5/6 검증 대상

- [ ] **Step 1: 브랜치 생성 후 push**

```bash
git checkout -b feat/zetlabs-dns && git push -u origin feat/zetlabs-dns
```

- [ ] **Step 2: PR 생성**

```bash
gh pr create --title "feat: zetlabs.net DNS import 및 CI 주도 apply" --body "<요약 + 검증 체크리스트>"
```
base: `main`. PR 본문에 spec/plan 링크 포함.

- [ ] **Step 3: PR 상태 확인**

Run: `gh pr view --json number,state`
Expected: state `OPEN`

### Task 5: PR plan 검증

**Files:** 없음 (CI 출력 검증)

**Interfaces:**
- Consumes: PR의 `tofu-zetlabs` job plan 출력, Task 3 Secret
- Produces: plan 승인 판정 — merge 가능 근거

- [ ] **Step 1: Actions 완료 대기 후 plan 코멘트 확인**

Run: `gh run watch $(gh run list --branch feat/zetlabs-dns --limit 1 --json databaseId -q '.[0].databaseId')`
이후: `gh pr view --comments`
Expected: `[zetlabs.net] OpenTofu Plan` 코멘트에 `Import planned 4` 리소스 4건 + `Plan: 1 to add, 0 to change, 0 to destroy`

- [ ] **Step 2: 예상 외 변경 판정**

plan에 import 대상 4건의 in-place update(~)가 표시되면 코드-실제 불일치. TTL/priority 등을 Cloudflare API 응답(2026-11-16 확보: MX ttl 300 priority 10, TXT 3건 ttl 3600)과 대조해 **코드를 실제 값으로 보정**하고 push. destroy(−) 표시 시 중단하고 원인 조사.

- [ ] **Step 3: root job 무이상 확인**

같은 PR 코멘트에서 root(`zzizily.com`) job도 확인 — record-ddns.tf의 lifecycle 추가로 인한 `1 to change`만 허용.

### Task 6: merge 및 CI apply 검증

**Files:** 없음

**Interfaces:**
- Consumes: Task 5 승인된 plan
- Produces: import 완료 state(R2) + `_dmarc` 레코드 — Task 7 검증 대상

- [ ] **Step 1: 사용자 merge 승인 후 merge**

**⚠ 외부 가시적 작업 — 사용자 명시 승인 후 실행.**
Run: `gh pr merge --merge`
(main push 트리거로 `tofu apply -auto-approve` 자동 실행됨)

- [ ] **Step 2: apply 완료 확인**

Run: `gh run watch $(gh run list --branch main --limit 1 --json databaseId -q '.[0].databaseId')`
Expected: `tofu-zetlabs` job success — apply 로그에 "Import complete" 4건 + "Creation complete" 1건(dmarc) + "Apply complete! Resources: 1 imported... 1 added"

### Task 7: Cloudflare 반영 및 멱등성 검증

**Files:** 없음

**Interfaces:**
- Consumes: Task 6 apply 결과
- Produces: 검증 5단계 완료 증거 (spec 검증 계획)

- [ ] **Step 1: DNS 전파 확인**

Run: `dig +short TXT _dmarc.zetlabs.net @1.1.1.1`
Expected: `"v=DMARC1; p=none;"`

- [ ] **Step 2: 멱등성 — workflow_dispatch 재실행**

Run: `gh workflow run "OpenTofu" --ref main` 후 해당 run watch
Expected: `tofu-zetlabs` apply 로그에 "No changes. Infrastructure is up-to-date" (또는 0 add/0 change/0 destroy)

- [ ] **Step 3: 기존 메일 레코드 무손상 확인**

Run: `dig +short MX zetlabs.net @1.1.1.1` → `10 smtp.google.com.` / `dig +short TXT zetlabs.net @1.1.1.1` → SPF + google-site-verification
Expected: 기존 값 그대로
