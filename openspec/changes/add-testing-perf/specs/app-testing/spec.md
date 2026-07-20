# app-testing

## ADDED Requirements

### Requirement: Remote Config fallback 測試
`RemoteConfigService` 的 Noop 與 fetch 失敗 fallback 路徑 SHALL 有單元測試覆蓋：`NoopRemoteConfigService` 回傳預設值 `control`。

#### Scenario: 測試通過
- **WHEN** 執行 `flutter test`
- **THEN** `NoopRemoteConfigService().fetchHeroSloganVariant()` 回傳 `control`

### Requirement: 地圖頁三態測試
`MapPage` SHALL 有 widget test 覆蓋三種狀態：定位權限拒絕（含一般拒絕與永久拒絕兩種畫面）、資料載入中、成功時渲染景點 marker 與集章進度列。測試 MUST 以 Riverpod override 注入假的位置串流與景點/集章資料，不依賴真實定位平台通道。

#### Scenario: 權限拒絕測試
- **WHEN** `positionStreamProvider` override 為丟出 `LocationDeniedException(forever: false)`
- **THEN** 畫面顯示重試按鈕；`forever: true` 時顯示開啟設定按鈕

#### Scenario: 成功渲染測試
- **WHEN** 位置與景點資料皆成功注入
- **THEN** 畫面顯示集章進度文字與正確數量的景點 marker

### Requirement: 打卡事件觸發測試
打卡成功流程 SHALL 有測試驗證 analytics 事件的觸發時機與參數：打卡成功呼叫 `checkin_success`（含正確 spot_id/city）；集章數等於目標值的那次額外呼叫 `stamp_goal_reached`，之前與之後的打卡皆不重複呼叫。測試 MUST 使用記錄呼叫的假 `AnalyticsService`（spy），不依賴真實 Firebase SDK。

#### Scenario: 未達標不觸發
- **WHEN** 集章數從 0 打卡到目標值以下（例如目標 6、打卡到第 5 枚）
- **THEN** `stamp_goal_reached` 未被呼叫

#### Scenario: 達標當次觸發且僅一次
- **WHEN** 打卡使集章數剛好達到目標值，之後再打卡第 7 枚
- **THEN** `stamp_goal_reached` 恰好被呼叫一次（在達標那次），第 7 枚打卡不重複觸發
