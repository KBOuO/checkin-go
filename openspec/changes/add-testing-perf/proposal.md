# add-testing-perf

## Why

作品集 phase 5（收尾）：職缺條件「熟悉前端測試框架（如 Jest, React Testing Library）或 Flutter 測試」與「分析並優化網頁和應用行銷頁面的效能」。目前 Web 端零自動化測試（只有 phase 1 手動 CDP 驗證）、Flutter 端測試只覆蓋首頁與打卡邏輯（沒碰 Firebase 服務層與地圖頁）、且 Web 的 Lighthouse Performance 分數卡在 56 分（phase 1 遺留的已知問題，CJK 字型流量過大）沒有真的修。同時 App 目前只出過 debug APK，從沒走過正式 release 簽名流程——這是「協助應用打包及上架流程」職缺條件裡最後一塊拼圖。

## What Changes

- Web 導入 Jest + React Testing Library，測試不依賴後端/瀏覽器的純元件邏輯（倒數計時、收藏、卡片渲染、fallback 呈現）。
- Web 效能：找出 Performance 56 分的真因（CJK 字型用 Google Fonts 的 unicode-range 分片下發，文案字元分散導致仍要下載 22 個檔），改為依網站實際用字動態子集化、自架字型，Performance 分數 56 → 80（Lighthouse 模擬節流下的分數；實測 observed LCP 從約 359ms 到 282ms 本來就不差，模擬分數才是這次要修的目標）。
- Flutter 補測試：Firebase Analytics/Remote Config 的 fallback 邏輯、地圖頁三態（權限拒絕/永久拒絕、載入、成功含打卡流程）、事件觸發時機（用假 AnalyticsService 驗證呼叫次數與參數）。
- Android release build：產生簽名用 keystore、設定 Gradle 簽名設定、跑出簽過名的 release AAB（Play Console 上架用格式）與 APK（供直接安裝測試），驗證可安裝執行。iOS 對應流程僅文件化（無 Mac）。

## Capabilities

### New Capabilities

- `web-testing`: Jest + React Testing Library 對 Web 關鍵元件的單元測試需求。
- `app-testing`: Flutter 測試涵蓋範圍需求（含 Firebase 服務層 fallback、地圖頁三態、事件觸發驗證）。
- `app-release`: Android release build 需求（簽名、產物格式、安裝驗證）。

### Modified Capabilities

- `campaign-landing`: 新增效能需求（Lighthouse Performance 分數門檻與字型自架策略），現有版面/SEO/動畫需求不變。

## Impact

- `web/`：新增 `jest.config.ts`、`jest.setup.ts`、`__tests__/`、`package.json` test script；新增 `src/app/fonts/*.woff2`（自架子集字型）與 `scripts/subset-noto-sans-tc.py`（可重現的子集化腳本）；`layout.tsx` 從 `next/font/google` 改 `next/font/local`。
- `app/`：新增 `test/analytics_test.dart`、`test/map_page_test.dart`（或併入既有檔案）；`android/app/` 新增簽名設定（`key.properties` 不進 repo，keystore 不進 repo）。
- 不影響 `api/`。
- 驗證：`npm test`（web）、`flutter test`（app）全過；Lighthouse Performance ≥ 75（相對 56 的顯著改善，不強求 90——已知 Lighthouse 模擬模型對自架 webfont 仍偏悲觀，實測數字才是可信依據）；release AAB/APK 在 emulator 實測可安裝並正常啟動。
