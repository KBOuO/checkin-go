# app-analytics

## ADDED Requirements

### Requirement: 行銷漏斗事件追蹤
App SHALL 使用 Firebase Analytics 記錄以下事件：`campaign_view`（進入首頁且活動資料載入成功時）、`favorite_spot`（於 WebView 之外，App 內若有收藏動作時，帶 `spot_id` 參數）、`checkin_success`（GPS 打卡成功時，帶 `spot_id`、`city` 參數）、`stamp_goal_reached`（集章數首次達到活動 `stamp_goal` 時，僅觸發一次）。

#### Scenario: 首頁載入觸發瀏覽事件
- **WHEN** 首頁成功載入活動與景點資料
- **THEN** 記錄一筆 `campaign_view` 事件

#### Scenario: 打卡成功觸發事件
- **WHEN** 使用者於地圖頁完成一次 GPS 打卡
- **THEN** 記錄一筆 `checkin_success` 事件，帶正確的 `spot_id` 與 `city`

#### Scenario: 集滿目標僅觸發一次
- **WHEN** 使用者集章數達到 `stamp_goal` 之後又打卡了第 7 枚（總數 12）
- **THEN** `stamp_goal_reached` 事件僅於達標當下觸發一次，第 7 枚打卡不再重複觸發

### Requirement: Remote Config Hero 文案 A/B
App SHALL 透過 Firebase Remote Config 的 `hero_slogan_variant` 參數（值為 `control` 或 `variant_b`）決定首頁 Hero 顯示的標語版本；參數缺省或 fetch 失敗時 MUST fallback 為 `control`，MUST NOT 造成首頁載入失敗或空白。

#### Scenario: 遠端指定 variant_b
- **WHEN** Remote Config 回傳 `hero_slogan_variant = variant_b`
- **THEN** 首頁 Hero 顯示 variant_b 版本的標語文案

#### Scenario: fetch 失敗 fallback
- **WHEN** Remote Config fetch 失敗（無網路或逾時）
- **THEN** 首頁正常顯示，Hero 標語落回 `control` 版本文案

### Requirement: 測試環境隔離
單元/widget 測試 SHALL 不呼叫真實 Firebase SDK（平台通道在純 Dart 測試環境不可用）；`AnalyticsService` 抽象介面 MUST 可於測試以無操作實作替換。

#### Scenario: 測試套件通過
- **WHEN** 執行 `flutter test`
- **THEN** 既有與新增測試全數通過，無 `MissingPluginException`
