# 涉外服务法律法规政策文件分类归档总表 · 独立站点

纯静态站点，零外部依赖（不引用任何 CDN、字体、图片外链），可部署到任意静态托管。

## 目录结构

```
涉外服务法规站/
├── index.html              主页：67 件法规总表（筛选 / 检索 / 打印）
├── 404.html                错误页
├── robots.txt              禁止搜索引擎收录
├── .nojekyll               跳过 GitHub Pages 的 Jekyll 处理
├── assets/favicon.svg      站点图标
├── docs/                   67 件原文（001–067）
│   ├── NNN.pdf             在线查看用（Word 转 PDF，浏览器直接打开）
│   └── NNN.docx            原始 Word 文件（供下载）
└── deploy-github-pages.sh  一键发布脚本
```

## 原文链接是怎么生成的

1. `_match.py` 把总表 67 行与 01–05 目录的 67 份 docx 按「标题＋文号＋日期＋地区」打分配对，确保一一对应；
2. `_prep_docs.py` 按序号复制成 `docs/NNN.docx`，并生成转换清单；
3. Word COM（`_convert.ps1` 逻辑）批量导出 `docs/NNN.pdf`；
4. `_addlinks.py` 把每行标题包成指向 `docs/NNN.pdf` 的链接，右侧加 `DOCX` 下载按钮。

新增文件后重跑 1→4 即可，序号与表格行号严格对应。

## 已内置

- **主题 / 层级双层筛选** + 关键词全文检索（纯前端，无后端）
- **手机端适配**：≤900px 三列统计卡、≤560px 两列 + 紧凑表格
- **打印样式**：Ctrl+P 直接出 A4 版，自动隐藏筛选栏
- **不收录**：`robots.txt` 全站 Disallow + 页面 `noindex`

## 发布到 GitHub Pages

前置：GitHub 账号 + 一个 classic Personal Access Token（勾选 `repo`）。

```bash
cd 涉外服务法规站
GITHUB_TOKEN=ghp_xxxxxxxx GITHUB_USER=你的用户名 bash deploy-github-pages.sh
```

脚本依次完成：建仓库 → 推送 main → 开启 Pages → 轮询构建状态 → 输出网址。
仓库已存在时可直接重复执行，用于**更新线上内容**（同样的网址，内容覆盖）。

生成网址：`https://<用户名>.github.io/<仓库名>/`（默认仓库名 `shewai-fagui-zongbiao`）

## 后续更新内容

改完 `index.html` 后重新执行一次上面的命令即可，网址不变。

## 想绑自己的域名

1. 在仓库根目录加 `CNAME` 文件，内容写一行域名，如 `fg.example.com`
2. 域名 DNS 加一条 CNAME 记录指向 `<用户名>.github.io`
3. GitHub 仓库 Settings → Pages 勾选 Enforce HTTPS

## 想加访问密码

GitHub Pages 是纯静态托管，**无法**做密码或登录。需要真限制的话只能：
Cloudflare Access（域名托管在 Cloudflare）、或自有服务器配 Basic Auth。
