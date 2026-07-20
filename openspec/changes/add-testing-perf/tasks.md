# add-testing-perf — Tasks

## 1. Web 效能：CJK 字型自架子集化

- [x] 1.1 掃描原始碼與種子 JSON 取得網站實際用字集合（623 個不重複字元）
- [x] 1.2 寫 `scripts/subset-noto-sans-tc.py`：下載完整字重（無現代 UA 取得未分片 TTF）→ `fonttools.subset` 依用字子集化 → 輸出 woff2
- [x] 1.3 產出 5 個字重（400/500/600/700/900）子集檔，各 ~105–110KB（原始 ~7MB/字重）
- [x] 1.4 `layout.tsx` 改用 `next/font/local`（`display: swap`），移除 `next/font/google`
- [x] 1.5 Lighthouse 重測：Performance 56 → 80；確認 Accessibility(96)/Best Practices(100)/SEO(100) 不劣化；observed LCP 282ms vs simulated 5.5s（Lighthouse 節流模型對自架 webfont 偏悲觀，與 phase 1 的 FCP 現象一致）

> 曾試拆兩個 `localFont()`（首屏字重 preload、其餘不 preload）想再壓分數，但 `next/font/local`
> 每次呼叫各自產生獨立 font-family，拆開會讓部分文字掉回退字型——已還原為單一宣告，正確性優先。

## 2. Web 測試（Jest + React Testing Library）

- [x] 2.1 `npm install -D jest jest-environment-jsdom @testing-library/react @testing-library/dom @testing-library/jest-dom @types/jest`，`next/jest` 產生 `jest.config.ts`
- [x] 2.2 `jest.setup.ts` 引入 `@testing-library/jest-dom`；`package.json` 加 `test`/`test:watch` script
- [x] 2.3 `__tests__/Countdown.test.tsx`：進行中/已結束/每秒更新（`jest.useFakeTimers` + `act()`）
- [x] 2.4 `__tests__/favorites.test.ts` + `SpotCard.test.tsx`：收藏切換、UI 與 store 一致、persist 到 localStorage
- [x] 2.5 `__tests__/CampaignIntro.test.tsx`：日期格式化渲染（含時區換算：15:59:59Z 在 Asia/Taipei 未跨日的邊界案例）
- [x] 2.6 `npm test` 全過（14/14）；測試對象不含發 fetch 的 async Server Component（`page.tsx`，已由 phase 1 的 CDP 腳本覆蓋），本就不依賴外部服務

## 3. Flutter 測試補強

- [x] 3.1 `test/remote_config_test.dart`：`NoopRemoteConfigService` fallback、兩版文案存在性
- [x] 3.2 `test/map_page_test.dart`：五態（權限拒絕/永久拒絕、景點載入失敗、定位失敗、載入中）+ 成功渲染（含真的 `FlutterMap`+`TileLayer`，用有限次數 `pump()` 而非 `pumpAndSettle()` 避開圖磚網路請求造成的 pending timer）
- [x] 3.3 打卡事件測試：把打卡＋追蹤邏輯從 widget 抽成 `performCheckin()`（`lib/checkin/checkin_flow.dart`），用假 `AnalyticsService`（spy）驗證 `checkin_success`/`stamp_goal_reached` 觸發時機與參數
- [x] 3.4 `flutter test` 全過（19/19）、`dart analyze` 乾淨

> 實作備註：`performCheckin` 原本簽名用 `WidgetRef`，測試想直接傳 `ProviderContainer` 編譯不過——
> Riverpod 3 把 `Ref`（provider 端）與 `WidgetRef`（widget 端）拆成互不繼承的介面，`ProviderContainer`
> 兩者都不是。改成撕下 `.read` 方法本身當 `T Function<T>(ProviderListenable<T>)` 型別的函式值傳遞，
> widget/provider/測試三邊都能餵。`ProviderListenable` 型別本身也不在 `flutter_riverpod` 主要 barrel
> export，需另外 `import 'package:riverpod/misc.dart'`（並把 `riverpod` 從 transitive 依賴升級成
> pubspec.yaml 的直接依賴）。

## 4. Android release build

- [x] 4.1 `keytool` 產生 upload keystore（`checkin-go-upload-keystore.jks`，存於使用者 home 目錄，不進 repo）；`android/key.properties` 設定（`.gitignore` 排除）
- [x] 4.2 `build.gradle.kts` 讀取 `key.properties` 設定 release signingConfig；無設定檔時 fallback debug 簽名 + `logger.warn`（兩條路徑都實測過：拿掉 key.properties 重建，`apksigner` 確認簽名證書變回 `CN=Android Debug`；補回後重建一次確認變回 `CN=CheckinGo Portfolio`）
- [x] 4.3 `flutter build appbundle --release` + `flutter build apk --release`——**中文路徑導致 Dart AOT snapshotter 失敗**（`Unable to read file ... app.dill`, exit 255），改從 `C:\dev\checkin-go-app-build\`（app/ 的完整複製，非 junction）建置成功；AAB 49.1MB、APK 49.0MB
- [x] 4.4 emulator 安裝 release APK，實測：首頁正確吃到真 API 資料、地圖頁 marker/進度列正常、WebView 頁因 release manifest 沒有 `usesCleartextTraffic` 例外（phase 2 刻意只給 debug）而擋下本機 HTTP dev server，正確顯示「載入失敗+重新載入」畫面而非崩潰——已用 `grep` 確認合併後 release manifest 無此屬性，證實是設計行為非缺陷

## 5. 收尾

- [x] 5.1 更新 README（Web 測試/字型子集化/Flutter 測試/release build 說明與指令）
- [x] 5.2 更新 PROJECTS.md（五階段全部完成）
