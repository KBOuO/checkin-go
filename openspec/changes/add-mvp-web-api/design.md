# add-mvp-web-api — Design

## Context

全新 monorepo（`api/` + `web/`，`app/` 留待 phase 2）。開發機為 Windows 11（Python 3.11、Node 24），目標是能在本機跑起來並部署到免費雲端層供面試展示。行銷資料為唯讀（景點、活動），無使用者帳號系統。

## Goals / Non-Goals

**Goals:**

- Web + API 縱切可獨立上線：`web` 部署 Vercel、`api` 部署 Render 免費層。
- Landing page 對齊職缺要求的展示點：React Hooks、狀態管理、API 串接、響應式、動畫、SEO。
- 資料模型為後續 GPS 打卡（phase 3）預留經緯度與打卡半徑。

**Non-Goals:**

- Flutter App、WebView（`add-flutter-shell`）。
- GPS 打卡、集章進度、優惠券發放（`add-gps-checkin`）。
- Firebase、自動化測試、效能調校（後續 change）。
- 資料庫與寫入型 API — 本階段全部唯讀。

## Decisions

- **Monorepo 單一 git repo**（`api/`、`web/`、預留 `app/`）：作品集展示一個連結就好，README 統一放架構圖與截圖。替代方案是三個 repo，但對單人作品只增加管理成本。
- **API 不用資料庫**：種子資料放 `api/data/spots.json`、`campaigns.json`，啟動時載入記憶體。唯讀行銷資料不需要持久化，也避開 sqlite 連線/執行緒議題；後續打卡紀錄需要寫入時再於 `add-gps-checkin` 引入 SQLite。
- **景點採用真實台灣景點**（名稱、城市、座標為公開事實資訊），共 12 個、北中南東與離島分佈，之後 GPS 打卡 demo 才有真實座標可用。圖片不用真實照片（版權），以自製漸層 + SVG 視覺呈現。
- **Next.js App Router + TypeScript + Tailwind CSS**：Landing 頁用 SSG + ISR（`revalidate` 3600s）取得景點/活動資料，SEO 與首載速度最佳，且 Render 免費層冷啟動不會拖慢頁面；倒數計時等互動部分為 client component。
- **狀態管理用 Zustand**（收藏景點清單，`persist` 到 localStorage）：職缺點名 Redux/Zustand 擇一即可，Zustand 樣板碼少、適合此規模；全域狀態刻意保留一個真實使用場景（收藏）而非為用而用。
- **進場/滾動動畫用純 CSS，framer-motion 只做微互動**：JS 驅動的進場動畫會讓 SSR HTML 帶著 `opacity:0`，內容要等 bundle 載入才可見（實測慢速網路 FCP 9.8s），且 framer-motion 的 `reducedMotion` 只停用位移、opacity 仍會動畫，無法滿足「reduce motion 直接呈現最終狀態」。改為：Hero 進場用 CSS keyframes（`animation-delay` 做 stagger）、卡片滾動進場用 CSS scroll-driven animations（`animation-timeline: view()`，以 `@supports` 漸進增強，不支援的瀏覽器直接顯示內容）、`prefers-reduced-motion` 以 media query 完全停用；framer-motion 保留給收藏按鈕等微互動（`whileTap`/`whileHover`）。
- **CORS 用環境變數控制允許來源**（本機 `http://localhost:3000` + Vercel 網域），不開 `*`。

## Risks / Trade-offs

- [Render 免費層冷啟動 30s+] → Landing 用 SSG/ISR，頁面本身不等 API；client 端補抓時有 loading/fallback 靜態內容，行銷頁不開天窗。
- [真實景點資訊過時或不精確] → 只放名稱/城市/座標/概述等低變動資訊，README 註明資料為 demo 用途。
- [Windows 檔案輸出混入 UTF-8 BOM 弄壞 JSON] → 種子 JSON 一律以無 BOM UTF-8 建立，API 啟動時以 `utf-8-sig` 讀取防禦。
- [單人專案 scope 膨脹] → 本 change 完成即可上線展示；地圖、Firebase、測試全部推到後續 change，不在此階段混入。
