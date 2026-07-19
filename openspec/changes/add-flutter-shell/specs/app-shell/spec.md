# app-shell

## ADDED Requirements

### Requirement: 底部導覽
App SHALL 提供底部導覽列，含「首頁」與「活動網頁」兩個頁籤；切換頁籤 SHALL 保留各頁狀態（首頁捲動位置、WebView 瀏覽狀態）。

#### Scenario: 頁籤切換保留狀態
- **WHEN** 使用者在 WebView 內導航後切到首頁再切回
- **THEN** WebView 停留在原頁面，未重新載入

### Requirement: 原生活動首頁
首頁 SHALL 以原生 Widget 呈現：活動橫幅（title、slogan、活動期間）與精選景點列表（名稱、城市、描述、標籤），資料來自 marketing-api（`/api/campaigns/current`、`/api/spots`）。

#### Scenario: 資料載入成功
- **WHEN** API 回應正常
- **THEN** 橫幅顯示「島嶼打卡季」與活動期間，列表顯示 12 個景點卡片

#### Scenario: 載入中
- **WHEN** API 請求進行中
- **THEN** 顯示載入指示（不閃爍空白畫面）

#### Scenario: 載入失敗可重試
- **WHEN** API 無法連線
- **THEN** 顯示錯誤提示與「重試」按鈕，按下後重新請求

### Requirement: 品牌主題一致性
App SHALL 使用 Material 3，主色調與 Web 端一致（海洋青 seed + 夕陽橘強調），活動文案與 Web 相同來源（API）。

#### Scenario: 視覺對照
- **WHEN** 並排比較 App 首頁與 Web Landing Page
- **THEN** 主色、活動標題、slogan、景點資訊一致

### Requirement: 環境位址注入
API 與網頁位址 SHALL 以 `--dart-define`（`API_BASE_URL`、`WEB_URL`）注入，預設值指向 Android emulator host loopback（`10.0.2.2`）。

#### Scenario: 預設值
- **WHEN** 未帶 dart-define 直接 `flutter run`
- **THEN** App 打 `http://10.0.2.2:8000` 與 `http://10.0.2.2:3000`

### Requirement: 首頁 Widget 測試
首頁 SHALL 有 widget tests：以 Riverpod override 注入假資料驗證成功渲染，注入錯誤驗證錯誤/重試 UI。

#### Scenario: 測試通過
- **WHEN** 執行 `flutter test`
- **THEN** 首頁成功/錯誤兩組測試通過
