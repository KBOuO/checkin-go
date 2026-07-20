# app-checkin

## ADDED Requirements

### Requirement: 景點地圖
「地圖打卡」頁 SHALL 以地圖顯示全部 12 個景點 marker 與使用者目前位置；已集章與未集章的 marker MUST 有可辨識的視覺差異（未集：青色圓 + 編號；已集：橘色實心 + 勾號）。

#### Scenario: 檢視地圖
- **WHEN** 使用者進入地圖頁且定位權限已授予
- **THEN** 地圖顯示 12 個景點 marker 與使用者位置點

#### Scenario: 已集章視覺
- **WHEN** 某景點已完成打卡
- **THEN** 該 marker 呈橘色實心 + 勾號

### Requirement: 定位權限流程
App SHALL 在進入地圖頁時檢查並請求定位權限：拒絕時顯示說明與「重試」；永久拒絕時顯示說明與「開啟設定」按鈕（導向系統設定），MUST NOT 无提示地呈現空白地圖。

#### Scenario: 權限拒絕
- **WHEN** 使用者拒絕定位權限
- **THEN** 顯示需要定位的說明與重試按鈕

#### Scenario: 權限永久拒絕
- **WHEN** 權限狀態為 deniedForever
- **THEN** 顯示「開啟設定」按鈕，點擊導向 App 系統設定頁

### Requirement: 距離判定打卡
點擊景點 marker SHALL 顯示景點資訊 bottom sheet（名稱、城市、描述、與使用者的即時距離）；打卡按鈕 SHALL 僅在距離 ≤ 該景點 `checkin_radius_m` 時可按，半徑外顯示所需距離提示。距離計算 MUST 為純函式（`Geolocator.distanceBetween`）以利單元測試。

#### Scenario: 半徑內打卡
- **WHEN** 使用者位於景點打卡半徑內並點擊打卡按鈕
- **THEN** 該景點集章成功，marker 轉為已集章視覺，進度 +1

#### Scenario: 半徑外不可打卡
- **WHEN** 使用者與景點距離超過打卡半徑
- **THEN** 打卡按鈕不可按，顯示目前距離與所需範圍

#### Scenario: sheet 開啟中位置更新
- **WHEN** bottom sheet 開啟時使用者移動進入半徑
- **THEN** 距離顯示即時更新且打卡按鈕解鎖，無需重開 sheet

### Requirement: 集章持久化與進度
已集印章 SHALL 持久化於本機（shared_preferences），App 重啟後保留；重複打卡同一景點 MUST NOT 增加集章數。地圖頁 SHALL 顯示集章進度（已集 X / 12・目標 6 枚）。

#### Scenario: 重啟保留
- **WHEN** 使用者打卡 1 個景點後完全關閉並重開 App
- **THEN** 該景點維持已集章狀態，進度顯示 1/12

#### Scenario: 重複打卡
- **WHEN** 使用者對已集章景點再次打卡
- **THEN** 集章數不變

### Requirement: 打卡邏輯測試
集章儲存與距離判定 SHALL 有自動化測試：半徑內/外判定、集章持久化、重複打卡去重。

#### Scenario: 測試通過
- **WHEN** 執行 `flutter test`
- **THEN** 上述測試全數通過
