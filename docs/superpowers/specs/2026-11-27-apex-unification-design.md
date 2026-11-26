# 두 도메인 Apex(`@`) 기준 통일 설계

## 1. 목적 및 배경
- `zetlabs.net`은 `@`와 `www`가 모두 `200 OK`로 이중 서빙되고 있고, `zzizily.com`은 `@ → www` 301이지만 `www.zzizily.com`에 연결된 사이트가 없어 404 상태다.
- 두 도메인(`zzizily.com`, `zetlabs.net`) 모두 짧은 apex 도메인(`https://zzizily.com`, `https://zetlabs.net`)을 정본(canonical) URL로 통일하고, `www`와 기존 `blog.zzizily.com`은 301 리다이렉트로 연결한다.

## 2. 목표 / 비목표 / 금지사항
- **목표**:
  - `zzizily.com` apex를 `deuxksy/blog.zzizily.com`(GitHub Pages)에 연결하고 `www.zzizily.com`, `blog.zzizily.com`을 `https://zzizily.com`으로 301 리다이렉트한다.
  - `zetlabs.net`의 `www.zetlabs.net`을 `https://zetlabs.net`으로 301 리다이렉트한다.
  - 두 도메인 Redirect Rule 파일명을 `redirect.tf`로 통일한다.
- **비목표**: `blog.zzizily.com`의 Cloudflare Pages 이전, `tech.zzizily.com` / `ariadm.zzizily.com` 변경, 과거 블로그 포스트 본문 수정.
- **금지사항**: 로컬 `tofu apply` 실행, 기존 `blog.zzizily.com` 링크 단절(404 유발).

## 3. 제약사항
- `zzizily.com`은 Cloudflare SSL `Full` + `proxied = true` 유지 (GitHub Pages 측 `Enforce HTTPS`는 프록시 환경에서 제한될 수 있으나 Cloudflare Edge HTTPS는 정상 동작).
- DNS(`zzizily.com` → `deuxksy.github.io`)가 먼저 `main` apply로 반영된 뒤 GitHub Pages custom domain을 `zzizily.com`으로 전환해야 안전하다.

## 4. 검토한 접근법
- **호스팅**: GitHub Pages 유지 (**선택**) vs Cloudflare Pages 이전 (기각 — 기존 Hugo GitHub Actions 워크플로우 유지)
- **Apex DNS**: Cloudflare CNAME Flattening `CNAME deuxksy.github.io` 1개 (**선택**) vs GitHub Pages A 레코드 4개 (기각 — `proxied = true`에서 검증 제약은 동일하고 관리 대상만 4배 증가)
- **기존 `blog.zzizily.com`**: `https://zzizily.com`으로 301 리다이렉트 유지 (**선택**) vs DNS 삭제 (기각 — 기존 외부/검색엔진 링크 손실 방지)

## 5. 상세 변경 범위
1. **`cloudflare-dns` (`feat/apex-unify`)**:
   - `domain/zzizily/record-a.tf` → `record-cname.tf`: `cloudflare_dns_record.apex`를 `A 192.0.2.1`에서 `CNAME deuxksy.github.io` (`proxied = true`)로 교체
   - `domain/zzizily/page-rule.tf` → `domain/zzizily/redirect.tf` (`moved` 블록으로 무중단 in-place): `www.zzizily.com`, `blog.zzizily.com` → `https://zzizily.com` (301, 쿼리스트링 보존)
   - `domain/zetlabs/redirect.tf`: `www.zetlabs.net` → `https://zetlabs.net` (301, 쿼리스트링 보존)
   - `README.md`: 관리 도메인 표 현행화
2. **`/Users/crong/git/blog.zzizily.com` (`main`)**:
   - `hugo.yaml`, `static/robots.txt`, `.github/workflows/deploy.yml`의 `https://blog.zzizily.com/` → `https://zzizily.com/`
   - GitHub Pages custom domain 설정 `blog.zzizily.com` → `zzizily.com`

## 6. 검증 기준
- `cloudflare-dns`: `mise run validate && mise run plan` 통과, PR CI 통과 후 `main` merge `tofu apply` 성공.
- `blog.zzizily.com`: GitHub Actions `Deploy Hugo site to Pages` 성공.
- 라이브 확인:
  - `https://zzizily.com` → `200` (또는 브라우저 정상 접속, origin `Host: zzizily.com` `200`)
  - `https://www.zzizily.com` → `301` → `https://zzizily.com/`
  - `https://blog.zzizily.com` → `301` → `https://zzizily.com/`
  - `https://zetlabs.net` → `200`
  - `https://www.zetlabs.net` → `301` → `https://zetlabs.net/`
