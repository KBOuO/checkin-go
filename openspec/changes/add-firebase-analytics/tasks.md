# add-firebase-analytics — Tasks

## 1. Firebase 專案與設定

- [x] 1.1 使用者於自己終端機完成 `firebase login`（瀏覽器 OAuth，帳號 kbc254511@gmail.com）
- [x] 1.2 `firebase projects:create checkin-go-portfolio`（首次卡在「Callers must accept Terms of Service」，需先在 Console 走一次建立精靈接受 GCP 條款，之後 API 建立才會過）
- [x] 1.3 `dart pub global activate flutterfire_cli`，`flutterfire configure --platforms=android` 產生 `firebase_options.dart` + `android/app/google-services.json`，並自動 patch 好 Gradle plugin
- [x] 1.4 Remote Config 參數 `hero_slogan_variant`（預設值 `control`）——改用 CLI（`remoteconfig.template.json` + `firebase deploy --only remoteconfig`）部署，比手動點 Console UI 更快也可重現

## 2. 依賴與初始化

- [x] 2.1 `flutter pub add firebase_core firebase_analytics firebase_remote_config`
- [x] 2.2 `main.dart`：`WidgetsFlutterBinding.ensureInitialized()` + `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`，並設定 `RemoteConfigSettings`（debug 用 `Duration.zero` fetch 間隔）+ `setDefaults`

## 3. AnalyticsService 抽象層

- [x] 3.1 `lib/analytics/analytics_service.dart`：介面 + `FirebaseAnalyticsService`（真實 SDK）+ `NoopAnalyticsService`（測試/無 Firebase 環境）
- [x] 3.2 `lib/analytics/remote_config_service.dart`：包裝 `hero_slogan_variant` 讀取（含預設值、fetch 失敗 fallback）
- [x] 3.3 Riverpod provider（`Provider` 預設 Noop 實作）；`main()` 於 `ProviderScope.overrides` 換上真實 Firebase 實作，測試環境維持 Noop 不需額外 override

## 4. 事件串接

- [x] 4.1 首頁：`ref.listen(campaignProvider)` 資料到位時觸發 `campaign_view`
- [x] 4.2 地圖頁打卡成功：觸發 `checkin_success`（spot_id/city）；集章數剛好等於目標值（`_stampGoal`）時額外觸發 `stamp_goal_reached`——採「Set 每次最多 +1，等於門檻只會成立一次」的邏輯，比另存 shared_preferences 防重旗標更簡單且等價
- [x] 4.3 首頁 Hero：讀 Remote Config variant 決定標語文案（兩版寫在程式碼常數 `heroSloganVariants`）

## 5. 驗證

- [x] 5.1 `flutter test` 全過（8/8，含既有 phase 2/3 測試）、`dart analyze` 乾淨
- [x] 5.2 emulator 開 DebugView（`adb shell setprop debug.firebase.analytics.app com.checkingo.checkin_go`），操作漏斗（開首頁→GPS 打卡 5 個景點集滿 6 枚〔含 phase 3 已收藏的 1 枚〕）；Firebase Console DebugView 截圖確認：`campaign_view` ×3、`checkin_success` ×5、`stamp_goal_reached` ×1（剛好在達標那次觸發，之後不再重複），與 spec 場景完全吻合
- [x] 5.3 CLI 部署 `hero_slogan_variant=variant_b` → force-stop 重啟 App → Hero 標語變為 variant_b 版本文案（截圖）；驗證後切回 `control`
- [x] 5.4 更新 README（Firebase 設定步驟、DebugView 操作方式、截圖）與 PROJECTS.md

> 實作備註：emulator 兩度無預警當掉（`qemu-system-x86_64-headless` 程序消失，非 OOM/非資源不足），
> 重開後穩定運行；原因不明，記入風險觀察，未來若再發生可考慮換 `-gpu swiftshader`（非 indirect）或降低 RAM。
