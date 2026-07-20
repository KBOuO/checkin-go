# add-firebase-analytics — Design

## Context

延續 phase 2/3 的 App（Riverpod 3、三頁籤導覽、GPS 打卡集章）。Firebase 專案由使用者以個人 Google 帳號透過 `firebase login` 授權後，用 CLI（`flutterfire configure`）建立並接上 Android app。開發驗證走 Android emulator。

## Goals / Non-Goals

**Goals:**

- 行銷漏斗四個關鍵事件在 Firebase Console DebugView 即時可見。
- Remote Config 控制 Hero 標語兩版文案，Console 端改值免重新出包即生效（下次 fetch）。
- Widget test 不因 Firebase 平台通道而失敗（沿用既有測試基線）。

**Non-Goals:**

- iOS Firebase 設定（無 Mac，`GoogleService-Info.plist` 留待有 Mac 時走 `flutterfire configure` 補）。
- 使用者身分識別 / 使用者屬性（demo 無登入系統，不做 user-level 分析）。
- Remote Config 的伺服器端條件式分流（例如依地區/版本分眾）——用預設的隨機 A/B 即可，不做進階規則。
- Crashlytics、Performance Monitoring（超出「Analytics/Remote Config」加分條件範圍）。

## Decisions

- **事件清單刻意精簡為漏斗關鍵三步**：`campaign_view`（進首頁看到活動）、`checkin_success`（打卡成功，帶 spot_id/city）、`stamp_goal_reached`（集滿 6 枚，只觸發一次）。`favorite_spot` 保留在 spec 文字中但無對應 scenario——收藏功能目前只存在於 Web（phase 1 的 Zustand store），Flutter App 本身沒有收藏動作，故不強行湊一個假事件；等 App 真的有收藏 UI 時再補。全部用 Firebase Analytics 的 `logEvent` 自訂事件；不疊加自動蒐集事件之外的雜訊，讓 Console 上的漏斗故事清楚：這是唯一能在面試時攤開 Console 截圖講的敘事。
- **`stamp_goal_reached` 用「集章數等於目標值」判定，不用額外的 shared_preferences 防重旗標**：`collect()` 每次呼叫最多讓 Set 長度 +1（重複打卡同景點會被 Set 去重，長度不變），所以「長度剛好等於 `stampGoal`」這個條件只會在跨過門檻的那一次成立，之後繼續打卡使長度超過目標就不會再滿足相等判定。比原規劃的持久化旗標更簡單、少一個狀態來源，且語義完全等價（已在 emulator 實測驗證：第 6 枚打卡時觸發、之前 5 枚都沒觸發）。
- **AnalyticsService 抽象層**：`lib/analytics/analytics_service.dart` 定義介面，`FirebaseAnalyticsService` 是正式實作，`NoopAnalyticsService` 給 widget test 用（Riverpod override）。原因：`firebase_analytics` 呼叫平台通道，在 `flutter test` 的純 Dart VM 環境會丟 `MissingPluginException`，這在 phase 2/3 建立的測試基線上必須維持可過。
- **Remote Config 用 `fetchAndActivate` + `setConfigSettings(minimumFetchInterval: Duration.zero)` 僅限 debug**：production 應設合理快取間隔（例如 1 小時），但 demo/面試展示需要改了 Console 值馬上在下次啟動看到效果，兩者用 `kDebugMode` 切換。
- **Hero 文案 A/B 用單一 Remote Config 參數 `hero_slogan_variant`**（`control` / `variant_b`），而非直接把整段文案放 Remote Config：職缺要展示的是「用 Remote Config 做 A/B test」的能力，參數化實驗分支比參數化文案內容更能說明實驗設計；兩版文案仍在程式碼內維護，避免 Console 打錯字直接影響production 文案品質。
- **只做 Android**：職缺列「Firebase Analytics 或 Remote Config」為加分項，非「iOS+Android 都要」；Android 端完整可跑即達成目的，iOS 差異在 README 說明。

## Risks / Trade-offs

- [Firebase 免費 Spark 方案的 Analytics 資料在 Console 有數小時延遲] → 開發驗證改看 DebugView（`adb shell setprop debug.firebase.analytics.app <package>`），近即時，不必等 Console 主報表。
- [`flutterfire configure` 需要使用者的 Google 帳號與 Firebase 專案存取權] → 已在本 change 開始前由使用者完成 `firebase login`；CLI 產生的 `google-services.json`／`firebase_options.dart` 屬帳號綁定產物，不含機密金鑰（Firebase Android/Web config 本就設計為可隨 App 公開），可安全進 repo。
- [中文專案路徑（`C:\程式\...`）疊加 Firebase Gradle plugin] → 沿用 phase 2 已驗證的 `android.overridePathCheck=true`，實測建置成功，無新增問題。
- [`firebase projects:create` 直接用 API 會被擋（Callers must accept Terms of Service）] → 需先在 Firebase Console 網頁走一次「建立專案」精靈觸發 GCP 條款同意，之後 CLI 建立才會過；一次性帳號設定，不影響後續自動化。
- [Android emulator headless 執行中無預警當掉兩次（`qemu-system-x86_64-headless` 程序消失，非資源不足）] → 重開後穩定；原因未查明，記錄為已知不穩定項，非本 change 程式碼問題。
