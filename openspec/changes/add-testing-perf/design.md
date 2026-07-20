# add-testing-perf — Design

## Context

延續 phase 1–4 的 Web（Next.js 16）與 App（Flutter 3.44 + Firebase）。Web 端目前唯一的驗證手段是 phase 1 用 CDP 手動跑的場景（收藏 persist、reduced-motion、響應式），沒有可在 CI 重跑的自動化測試。Performance 56 分是 phase 1 就發現但延後處理的已知項（見 `add-mvp-web-api/tasks.md` 4.2 備註）。

## Goals / Non-Goals

**Goals:**

- Web/App 都有可重複執行的自動化測試，覆蓋目前最脆弱的邏輯（時間相關的倒數、Firebase fallback、地圖三態）。
- 真正解決 Performance 56 分的根因，而非調整測試方法蓋過問題。
- 產出一份可以安裝執行的 Android release 產物，證明「打包上架」流程走得通。

**Non-Goals:**

- 100% 測試覆蓋率；只挑「壞了使用者會有感」的邏輯。
- E2E 測試框架（Playwright/Cypress）——phase 1 的 CDP 手動腳本已覆蓋關鍵互動場景，此階段聚焦單元/元件測試補上自動化重跑能力。
- 真的上架 Google Play（需要開發者帳號付費 + 審核，超出作品集範圍）；只做到「release 產物可安裝執行」。
- iOS release build（無 Mac）。

## Decisions

- **Web 測試用 Jest + RTL（`next/jest`），不含 async Server Component**：`page.tsx` 是 async Server Component 抓 API 資料，Jest 官方文件明講不支援測試 async Server Component（建議用 E2E），這塊已有 phase 1 的 CDP 腳本覆蓋。Jest 測試改鎖定：`Countdown`（時間換算與活動結束狀態，用 `jest.useFakeTimers` 控制時鐘，不必等真實秒數）、`favorites` store（收藏/取消、persist 邏輯）、`SpotCard`（收藏按鈕與 store 互動）、`CampaignIntro`（日期格式化）。
- **Performance 根因是 Google Fonts 對 CJK 的 unicode-range 分片機制，不是「有沒有用 variable font」**：phase 1 曾嘗試把 `next/font/google` 的 `weight` 陣列拿掉、改用可變字型宣告，但 Noto Sans TC 在 Google Fonts 上並沒有真正的 variable 版本，實測請求數/位元組數幾乎沒變（仍是 22 個檔、~1.6MB）。真正原因：Google 依「常一起出現的字」把 CJK 統一表意文字區段切成幾十個 unicode-range 分片供瀏覽器按需下載，但本站文案是零散分佈在整個區段的行銷/地名/景點介紹文字，幾乎每個分片都會命中，於是分片下發反而變成「幾乎全下載、還多付 20 幾次連線開銷」。
- **改用「只含網站實際用字」的自架子集字型**：寫 `scripts/subset-noto-sans-tc.py`——掃描全部原始碼與種子 JSON 取得使用過的字元集合，用 `fonttools.subset` 對 Google 提供的完整字重檔案子集化，輸出 5 個字重（400/500/600/700/900）的 woff2，每個約 105–110KB（原始完整字重檔約 7MB，減少 98%+）。改用 `next/font/local` 載入，額外好處是不必再連 `fonts.gstatic.com`（少一次 DNS/TLS handshake）。文案新增字元時要重跑腳本，這是自架子集字型無法避免的維護成本，已在腳本註解與 README 說明。
- **不拆多個 `localFont()` 呼叫做選擇性 preload**：試過把常用字重（700/900）與其餘字重（400/500/600）拆成兩個 `localFont()` 想進一步壓 Lighthouse 分數，但 `next/font/local` 每次呼叫各自產生獨立的 `font-family`，拆開後同一段文字的粗細沒辦法在同一字型家族內用 `font-weight` 級聯選檔，會讓部分文字掉回退字型——正確性優先於分數，故維持單一 `localFont()` 宣告涵蓋全部 5 個字重。
- **Performance 分數門檻設 ≥ 75 而非 90**：優化後 Lighthouse 模擬分數是 56→80，但 `metrics` 審計顯示 observed（真實瀏覽器量測）LCP 只有 282ms，遠低於 simulated（節流模型估算）的 5.5 秒——這是 Lighthouse 對節流網路下 webfont 關鍵路徑的已知悲觀估算模式（phase 1 的 FCP 也出現過同樣現象：observed 359ms vs simulated 9.8s）。與其為了榨出模擬分數犧牲正確性或加不必要的複雜度，門檻定在「相對 56 分有顯著、誠實可驗證的改善」，並在文件中同時記錄 observed 與 simulated 兩組數字。
- **Flutter 測試新增三塊**：(1) `RemoteConfigService`/`AnalyticsService` 的 Noop 實作與 fallback 路徑（`NoopRemoteConfigService` 回傳預設值——這條其實 phase 4 就該補但漏了）；(2) `MapPage` 三態（`LocationDeniedException` 兩種、載入中、成功含 marker 渲染），用假的 `positionStreamProvider`/`spotsProvider`/`stampsProvider` override；(3) 打卡流程搭配一個記錄呼叫的 spy `AnalyticsService`，驗證 `checkin_success`/`stamp_goal_reached` 的觸發時機與參數正確（`geolocator` 的 `Position` 類別本身是純 Dart data class，官方文件明講「Constructs an instance with the given values for testing」，widget test 可直接建構假值不需平台通道）。
- **Android release 簽名**：本機用 `keytool` 產生 upload keystore（`keytool` 隨 JDK 附帶，不需額外安裝），`key.properties`/`*.jks` 都不進 repo（含真實簽名金鑰，等同密碼），`.gitignore` 排除；`build.gradle.kts` 讀取 `key.properties` 設定 release signingConfig，讀不到時 fallback 用 debug 簽名並印警告（避免其他人 clone 專案後 build release 直接失敗）。產出 `app-release.aab`（Play Console 上架格式）與 `app-release.apk`（直接安裝驗證用），emulator 安裝實測正常啟動、能吃真 API。

## Risks / Trade-offs

- [Lighthouse 模擬分數與實際使用者體感有落差] → 文件同時記錄 observed 與 simulated 數字，避免只憑單一分數誤導判斷；相關方法論已在 phase 1 建立。
- [`keytool` 產生的 keystore 遺失即無法用同一簽名更新 App（Play Console 規則）] → 這是作品集 demo，不會真的上架，遺失也無實際影響；文件註明這是正式產品必須妥善備份 keystore 的常見痛點。
- [字型子集化腳本依賴網路連線 Google Fonts] → 只在文案變更需要重新產生子集時才需要跑，不影響一般 `npm run build`（子集檔案本身已 commit 進 repo）。
- [中文專案路徑（`C:\程式\...`）在 **release** build 讓 Dart AOT snapshotter 讀 `.dill` 檔失敗（`Unable to read file`, exit 255）] →
  phase 2 design.md 曾預想過這類風險並備好「ASCII junction」方案，但這次 junction 沒用——這個失敗點會被工具鏈解回真實路徑，繞不過去。實際解法是把 `app/` **完整複製**（非連結）到 `C:\dev\checkin-go-app-build\`，release build 從那邊執行；`key.properties`、原始碼都是複製過去的快照，正式來源仍是 repo 內的 `C:\程式\...\app`。這只影響 release/profile 的 AOT 編譯路徑，debug build（JIT，不做 AOT snapshot）從 phase 2 到現在都不受影響。
- [Release APK 的 WebView 載入本機 HTTP dev server 失敗，首頁 API 卻正常] → 查證非 bug：`android:usesCleartextTraffic="true"` 只設在 `src/debug/AndroidManifest.xml`（phase 2 刻意的設計，release manifest 沒有這條例外，已用 `grep` 直接檢查合併後的 release manifest 確認不存在），Android 預設擋非 HTTPS 流量，WebView（Chromium 網路棧）確實遵守；`http` 套件（`dart:io`）在這台裝置上沒被同樣攔下，兩者的 enforcement 不對稱。WebView 顯示的正是 phase 2 設計好的「載入失敗 + 重新載入」錯誤畫面，行為正確。這只在「release build 打本機 HTTP dev server」這個組合出現；正式部署後 `WEB_URL`/`API_BASE_URL` 會指向 phase 1 規劃的 HTTPS 網址（Vercel/Render），不會有這個限制。
