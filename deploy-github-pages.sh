#!/usr/bin/env bash
# 一键发布本目录到 GitHub Pages
# 用法：GITHUB_TOKEN=xxx GITHUB_USER=yourname bash deploy-github-pages.sh [仓库名]
set -uo pipefail

: "${GITHUB_TOKEN:?缺少 GITHUB_TOKEN 环境变量}"
: "${GITHUB_USER:?缺少 GITHUB_USER 环境变量}"
REPO="${1:-shewai-fagui-zongbiao}"
API="https://api.github.com"
H_AUTH="Authorization: Bearer ${GITHUB_TOKEN}"
H_JSON="Accept: application/vnd.github+json"

say(){ printf '%s\n' "$*"; }
json_get(){ python3 -c "import json,sys;d=json.load(sys.stdin);print(d.get('$1','') or '')" 2>/dev/null; }

cd "$(dirname "$0")" || exit 1

say "==> 1/4 创建仓库 ${GITHUB_USER}/${REPO}"
code=$(curl -s -o /tmp/ghrepo.json -w '%{http_code}' -X POST "${API}/user/repos" \
  -H "${H_AUTH}" -H "${H_JSON}" \
  --data "{\"name\":\"${REPO}\",\"description\":\"涉外服务法律法规政策文件分类归档总表（67件）\",\"private\":false,\"has_issues\":false,\"has_wiki\":false,\"auto_init\":false}")
if [ "$code" = "201" ]; then say "    已创建"; else
  say "    返回码 ${code}（422=仓库已存在，400/401=token 无效或权限不足）"
  if [ "$code" = "401" ]; then say "    token 校验失败，停止。"; exit 2; fi
fi

say "==> 2/4 提交并推送"
git init -q 2>/dev/null
git config user.name "${GITHUB_USER}"
git config user.email "${GITHUB_USER}@users.noreply.github.com"
git symbolic-ref HEAD refs/heads/main 2>/dev/null
git add -A
git commit -qm "涉外服务法律法规政策文件分类归档总表（67件）" 2>/dev/null || say "    无新增改动"
git remote remove origin 2>/dev/null
git remote add origin "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO}.git"
if ! git push -q -u origin main --force; then
  say "    推送失败（检查 token 是否有 repo 权限）"; exit 3
fi
git remote set-url origin "https://github.com/${GITHUB_USER}/${REPO}.git"
say "    推送完成"

say "==> 3/4 开启 GitHub Pages"
code=$(curl -s -o /tmp/ghpages.json -w '%{http_code}' -X POST "${API}/repos/${GITHUB_USER}/${REPO}/pages" \
  -H "${H_AUTH}" -H "${H_JSON}" \
  --data '{"source":{"branch":"main","path":"/"}}')
if [ "$code" = "409" ] || [ "$code" = "422" ]; then
  code=$(curl -s -o /tmp/ghpages.json -w '%{http_code}' -X PUT "${API}/repos/${GITHUB_USER}/${REPO}/pages" \
    -H "${H_AUTH}" -H "${H_JSON}" \
    --data '{"source":{"branch":"main","path":"/"}}')
fi
say "    Pages 返回码 ${code}"

say "==> 4/4 等待构建"
URL=""
for i in $(seq 1 12); do
  body=$(curl -s "${API}/repos/${GITHUB_USER}/${REPO}/pages" -H "${H_AUTH}" -H "${H_JSON}")
  URL=$(printf '%s' "$body" | json_get html_url)
  ST=$(printf '%s' "$body" | json_get status)
  say "    第 ${i} 次：status=${ST:-unknown}"
  if [ "$ST" = "built" ]; then break; fi
  sleep 6
done

if [ -z "$URL" ]; then URL="https://${GITHUB_USER}.github.io/${REPO}/"; fi
say ""
say "站点地址：${URL}"
say "仓库地址：https://github.com/${GITHUB_USER}/${REPO}"
