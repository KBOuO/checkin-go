# add-flutter-shell

## Why

作品集 phase 2：職缺要求「使用 Flutter 開發行銷相關應用頁面」與「熟悉 WebView 實作，將行銷網頁內容嵌入 Flutter 應用中」。目前只有 Web + API，需要 Flutter App 殼展示跨平台一致性與 WebView 嵌入——後者是此職缺特別點名、也是多數作品集缺少的差異化重點。

## What Changes

- 新增 `app/`：Flutter App「打卡趣」，Material 3、品牌視覺與 Web 端一致（海洋/夕陽色調）。
- 底部導覽兩個頁籤：**首頁**（原生 Widget：活動橫幅 + 精選景點列表，串 marketing-api）與**活動網頁**（WebView 嵌入 React Landing Page）。
- 狀態管理用 Riverpod：API 資料以 FutureProvider 載入，含 loading / error / retry 狀態。
- API/網頁位址以 `--dart-define` 注入，預設指向 Android emulator 的 host loopback（10.0.2.2）。
- GPS 打卡、地圖（phase 3）與 Firebase（phase 4）不在此範圍。

## Capabilities

### New Capabilities

- `app-shell`: Flutter App 殼 — 導覽結構、原生活動首頁（活動資訊 + 景點列表）、marketing-api 串接與錯誤處理、品牌主題。
- `app-webview`: WebView 頁 — 嵌入行銷網頁、載入進度與失敗處理、返回導航。

### Modified Capabilities

（無）

## Impact

- 新增 `app/` 子專案；`api/`、`web/` 不變（WebView 直接吃現有 Next.js 頁面）。
- 新依賴：Flutter SDK 3.44（已裝於 C:\dev\flutter）、`flutter_riverpod`、`webview_flutter`、`http`。
- 驗證管道：`flutter analyze` + widget tests + `flutter build apk --debug`；Android emulator 實機驗證 WebView。
- 後續 change 依賴此殼：`add-gps-checkin`（地圖頁籤）、`add-firebase-analytics`。
