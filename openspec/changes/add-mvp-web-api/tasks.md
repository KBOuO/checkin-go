# add-mvp-web-api — Tasks

## 1. Monorepo 骨架

- [x] 1.1 建立 `api/`、`web/` 目錄與根 `.gitignore`（node_modules、.venv、.next、__pycache__、.env*）
- [x] 1.2 建立根 `README.md` 骨架（專案簡介、架構圖佔位、各子專案啟動方式佔位）

## 2. marketing-api（FastAPI）

- [x] 2.1 `api/` 建 venv、安裝 `fastapi` + `uvicorn`，寫 `requirements.txt`
- [x] 2.2 建立種子資料 `api/data/spots.json`（12 個台灣景點：名稱/城市/描述/標籤/真實座標/checkin_radius_m，UTF-8 無 BOM）與 `campaigns.json`（「島嶼打卡季」，ends_at 設為未來日期）
- [x] 2.3 實作 Pydantic 模型與資料載入（`utf-8-sig` 讀取、啟動時載入記憶體）
- [x] 2.4 實作 `GET /api/spots`（含 `?city=` 篩選）、`GET /api/spots/{id}`（404 處理）、`GET /api/campaigns/current`（無進行中活動回 404）
- [x] 2.5 加上 CORS middleware（`ALLOWED_ORIGINS` 環境變數，預設 `http://localhost:3000`）
- [x] 2.6 本機驗證：`uvicorn` 啟動後以 curl 打三支端點 + 篩選 + 404 案例，對照 spec 場景

## 3. campaign-landing（Next.js）

- [x] 3.1 `create-next-app`（TypeScript + App Router + Tailwind），設定 `lang="zh-Hant-TW"`（Next 16.2 / React 19 / Tailwind v4）
- [x] 3.2 安裝 `zustand`、`framer-motion`；建立 API client（`API_BASE_URL` 環境變數）與型別定義
- [x] 3.3 實作頁面資料層：SSG + ISR（revalidate 3600）抓景點與活動，API 失敗時 fallback 靜態內容
- [x] 3.4 實作 Hero 區（品牌視覺、slogan、進場動畫）
- [x] 3.5 實作活動介紹區 + 倒數計時 client component（含活動結束狀態）
- [x] 3.6 實作玩法說明區（三步驟圖解，自製 SVG/漸層視覺）
- [x] 3.7 實作精選景點區：卡片格（名稱/城市/描述節錄/標籤）+ 滾動進場動畫
- [x] 3.8 實作收藏功能：Zustand store（persist localStorage）+ 卡片收藏鈕 + 頂部收藏數
- [x] 3.9 實作 CTA 區與 footer（作品集聲明）
- [x] 3.10 響應式調整：375px 單欄 / 桌面三欄，確認無水平捲動（CDP 實測 scrollWidth == clientWidth == 375）
- [x] 3.11 SEO：metadata（title/description/OG/canonical）、`sitemap.xml`、`robots.txt`、`prefers-reduced-motion` 支援

> 實作備註：進場/滾動動畫依 design.md 決策改為純 CSS（keyframes + scroll-driven animations），
> framer-motion 保留在收藏按鈕微互動（`whileTap`/`whileHover`）。原因：JS 驅動進場會讓 SSR
> 首屏 `opacity:0` 等 JS 才可見，且 framer 的 reducedMotion 仍會跑 opacity 動畫，違反 spec。

## 4. 驗證

- [x] 4.1 端到端手動驗證：api + web 同時本機跑，逐條核對兩份 spec 的場景——API 6 場景（curl）、
      fallback（停 API 冷重建，頁面照常生成 + 備援註記）、收藏 persist（CDP：收藏 2 個 → reload
      → aria-pressed ×2 + header 計數 2）、reduced-motion（CDP：opacity 1 / animation none）、
      響應式 375px 無水平捲動
- [x] 4.2 Lighthouse 跑分：**SEO 100**（規格 ≥ 90 達標）、Best Practices 100、A11y 96、
      **Performance 56（行動模擬基準值，供 add-testing-perf 對照）**。主因：Noto Sans TC
      CJK 字型切片約 1.5MB（22 個 woff2）在模擬慢速 4G 下拖慢 FCP/LCP（observed FCP 實際
      359ms）；已改用可變字型省掉多字重，進一步子集化/系統字型留給效能 change

## 5. 部署

- [ ] 5.1 api 部署到 Render 免費層，設定 `ALLOWED_ORIGINS`
- [ ] 5.2 web 部署到 Vercel，設定 `API_BASE_URL`，驗證線上頁面與 OG 預覽
- [ ] 5.3 README 補上線上網址、架構說明、截圖；更新 `C:\程式\PROJECTS.md` 狀態
