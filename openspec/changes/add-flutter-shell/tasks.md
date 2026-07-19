# add-flutter-shell — Tasks

## 1. 專案建立

- [x] 1.1 `flutter create --org com.checkingo --project-name checkin_go app`（Android/iOS 平台，Flutter 3.44.6）
- [x] 1.2 加依賴：`flutter_riverpod`（3.x）、`webview_flutter`、`http`；app 名稱「打卡趣」
- [x] 1.3 debug manifest 開 `usesCleartextTraffic`；中文路徑 Gradle 建置以 `android.overridePathCheck=true` 過關（AGP 預設直接拒絕非 ASCII 路徑，override 後 AAPT2/NDK 實測正常）

## 2. 資料層

- [x] 2.1 `Spot`、`Campaign` model（fromJson）與 `MarketingApi` client（dart-define 位址；以 `bodyBytes` + UTF-8 解碼避免 FastAPI 無 charset 導致中文亂碼）
- [x] 2.2 Riverpod providers：`campaignProvider`、`spotsProvider`（FutureProvider）

## 3. UI

- [x] 3.1 App 殼：Material 3（海洋青 seed）、NavigationBar + IndexedStack 保留頁籤狀態
- [x] 3.2 首頁：活動橫幅（漸層卡片）+ 景點列表卡片（編號漸層圓、城市 badge、描述、標籤），配色對齊 Web
- [x] 3.3 首頁 loading / error + 重試 + 下拉更新
- [x] 3.4 WebView 頁：載入 WEB_URL、線性進度條、原生錯誤畫面 + 重新載入、PopScope 系統返回鍵先走 WebView 歷史

## 4. 驗證

- [x] 4.1 `dart analyze` 無問題（註：`flutter analyze` 的 analysis server 會被中文路徑弄掛——LSP Content-Length 位元組數 bug，改用 `dart analyze` 即可）
- [x] 4.2 widget tests 2/2 通過：成功渲染 + 錯誤重試（注意 Riverpod 3 預設自動重試失敗 provider，測試需 `retry: (_, __) => null` 關閉才有確定性）
- [x] 4.3 `flutter build apk --debug` 成功（133s；Temurin 21 + Gradle + NDK/CMake 自動安裝）
- [x] 4.4 Android emulator（Pixel 7 AVD、Android 36、WHPX 加速）實測：首頁吃到真 API（10.0.2.2:8000）、WebView 完整載入 Web 活動頁（10.0.2.2:3000），截圖存 `docs/app-home.png`、`docs/app-webview.png`
- [x] 4.5 更新 README（app 啟動方式、截圖、iOS 說明）與 PROJECTS.md
