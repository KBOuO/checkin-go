# add-firebase-analytics

## Why

作品集 phase 4：職缺加分條件「熟悉 Firebase，特別是 Firebase Analytics 或 Firebase Remote Config，用於追蹤行銷活動成效」。目前 App 有完整的行銷漏斗（看首頁活動 → 收藏景點 → GPS 打卡集章）卻沒有任何成效追蹤，也沒有內容實驗能力——這正是「行銷頁面開發」職缺日常會被要求的東西：量化使用者在漏斗每一步的掉落率、用 Remote Config 做文案 A/B test。

## What Changes

- 串接 Firebase Analytics：記錄行銷漏斗關鍵事件（瀏覽活動、收藏景點、打卡集章成功、集滿目標）。
- 串接 Firebase Remote Config：Hero 標語做 A/B test（兩版文案，含預設值與 fetch 失敗 fallback）。
- Android 端整合 `firebase_core` + `firebase_analytics` + `firebase_remote_config`；iOS 設定檔留待有 Mac 時補（不影響本 change 驗證）。
- 新增 `AnalyticsService` 抽象層：測試環境用假實作（不打真 SDK），避免 widget test 因平台通道失敗。

## Capabilities

### New Capabilities

- `app-analytics`: 行銷漏斗事件追蹤與 Remote Config A/B test — 事件清單與觸發時機、Remote Config 參數與 fallback、測試環境隔離。

### Modified Capabilities

（無 — 首頁 Hero 文案改為讀 Remote Config 值，但呈現位置與版面不變，屬實作細節而非需求變更）

## Impact

- 修改 `app/`：`main.dart` 初始化 Firebase、首頁/地圖頁加事件呼叫、Hero 文案來源改接 Remote Config。
- 新依賴：`firebase_core`、`firebase_analytics`、`firebase_remote_config`（Android 端，經 `flutterfire configure` 產生 `google-services.json` + `firebase_options.dart`）。
- 需要真實 Firebase 專案（使用者已於本次 session 用個人 Google 帳號完成 `firebase login` 授權）。
- 驗證：emulator 端到端操作漏斗全流程，於 Firebase Console 的 DebugView 確認事件即時到達；Remote Config 兩版文案於 Console 切換驗證。
