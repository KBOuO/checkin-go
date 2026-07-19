# add-flutter-shell — Design

## Context

Windows 11 開發機，Flutter 3.44.6 + Android SDK 36 + Temurin JDK 21（Gradle 用；系統 JDK 25 對 Gradle 太新）。專案路徑含中文（`c:\程式\...`），Android Gradle 建置對非 ASCII 路徑歷史上有雷，需驗證。iOS 無 Mac 無法建置，僅在 README 記錄上架流程。

## Goals / Non-Goals

**Goals:**

- App 殼可在 Android emulator 跑起來：原生首頁吃 API、WebView 正確載入 Web 活動頁。
- 與 Web 品牌視覺一致（Material 3 seed 色 + 同款文案）。
- 建立 Flutter 專案的驗證基線：analyze、widget test、debug APK。

**Non-Goals:**

- GPS/地圖、Firebase、推播、上架（後續 change）。
- iOS 實機建置（無 Mac；流程文件化即可）。
- 離線快取、深色主題。

## Decisions

- **狀態管理用 Riverpod**（`flutter_riverpod`）：職缺列 GetX/Provider/Riverpod/BLoC 擇一；Riverpod compile-safe、測試容易，`FutureProvider` 天生帶 loading/error 狀態，適合唯讀 API 資料。BLoC 對此規模樣板碼過多。
- **WebView 用官方 `webview_flutter`**：職缺點名 WebView；官方套件支援 Android/iOS。Windows desktop 不支援，故開發驗證走 Android emulator（`google_apis;x86_64` image）。
- **HTTP 用 `http` 套件 + 手寫 model.fromJson**：只有兩支唯讀端點，不需要 dio/retrofit/json_serializable 的重量；手寫序列化也展示基本功。
- **位址用 `--dart-define` 注入**：`API_BASE_URL` 預設 `http://10.0.2.2:8000`、`WEB_URL` 預設 `http://10.0.2.2:3000`（emulator 的 host loopback）；實體手機測試時以 dart-define 覆寫成電腦區網 IP。Android 9+ 預設擋 cleartext HTTP，debug 用 `usesCleartextTraffic` 於 debug manifest 開放（release 走 HTTPS 部署網址）。
- **首頁沿用 API 資料模型**：活動橫幅（title/slogan/期間/倒數文字）+ 景點卡片列表（城市 badge、描述、標籤 chips），視覺對齊 Web 的卡片設計，展示「跨平台視覺一致性」。
- **測試策略**：widget test 以 Riverpod override 注入假資料（不打真 API），驗證首頁渲染與錯誤狀態；WebView 不做 widget test（platform view 無法在 host VM 渲染），以 emulator 實測 + 截圖驗證。

## Risks / Trade-offs

- [中文路徑弄壞 Gradle/AAPT2] → 先直接建置驗證；若失敗，以 ASCII junction（如 `C:\dev\checkin-go-app` → `app/`）繞過並記錄。
- [emulator 在 Windows Home 無 WHPX 加速起不來] → 改裝 AEHD（`extras;google;Android_Emulator_Hypervisor_Driver`）；再不行退回 `flutter build apk --debug` + widget tests 作為本 change 驗證底線，emulator 驗證列入待辦。
- [WebView 載入本機 dev server 與正式環境行為不同] → 位址可注入，部署後改打正式網址回歸一次。
