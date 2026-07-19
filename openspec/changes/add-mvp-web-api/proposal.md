# add-mvp-web-api

## Why

「打卡趣 CheckinGo」是一個求職作品集專案，目標職缺是「React + Flutter 行銷頁面開發」。需要一個可部署、可展示的縱切 MVP 作為基底：虛構的台灣旅遊打卡集章行銷活動，包含 REST API 與 React 行銷活動頁。此為第一階段，刻意排除 Flutter（SDK 尚未安裝），讓 Web + API 先能獨立上線展示。

## What Changes

- 建立 monorepo 骨架：`api/`（FastAPI）、`web/`（Next.js）、之後的 `app/`（Flutter，本次不做）。
- 新增 FastAPI 後端：提供景點（spots）與活動（campaigns）的唯讀 REST API，附種子資料（台灣 12 個虛構包裝的景點、1 檔「島嶼打卡季」活動）。
- 新增 Next.js 行銷活動 Landing Page：Hero 動畫、活動倒數、精選景點卡片（吃 API）、集章玩法說明、CTA 區塊，完整 SEO（metadata / OG / sitemap）。
- 景點資料含經緯度與打卡半徑欄位，為後續 GPS 打卡（phase 3）預留，本階段僅回傳不使用。

## Capabilities

### New Capabilities

- `marketing-api`: 行銷資料 REST API — 景點列表/詳情、活動資訊，含 CORS、種子資料與錯誤格式。
- `campaign-landing`: React 行銷活動 Landing Page — 版面區塊、資料串接、響應式、動畫與 SEO 需求。

### Modified Capabilities

（無 — 全新專案）

## Impact

- 全新 repo，無既有程式碼受影響。
- 新增依賴：Python `fastapi` + `uvicorn`（api/ 獨立 venv）；Node `next`、`react`、`zustand`、`framer-motion`（web/）。
- 部署目標：web → Vercel、api → Render 免費層（本階段先確保本機可跑，部署為 tasks 的最後一步）。
- 後續 change 依賴此骨架：`add-flutter-shell`（App + WebView）、`add-gps-checkin`（地圖打卡）、`add-firebase-analytics`、`add-testing-perf`。
