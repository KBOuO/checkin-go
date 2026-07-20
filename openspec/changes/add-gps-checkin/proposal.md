# add-gps-checkin

## Why

作品集 phase 3：職缺加分條件「熟悉 GPS 和地圖功能（如 geolocator …），能實現基於位置的行銷功能」。「島嶼打卡季」的核心玩法（到景點現場 GPS 打卡集章）目前只存在文案裡，需要真的做出來，讓 App 從「殼」變成有完整行銷閉環的產品：看活動（Web/首頁）→ 到現場打卡（GPS）→ 集章進度 → 兌換動機。

## What Changes

- App 新增第三個頁籤「地圖打卡」：全台地圖顯示 12 個景點 marker（已集章/未集章兩種狀態）與使用者位置。
- GPS 定位（geolocator）：處理執行時權限（含拒絕/永久拒絕的 UI），持續更新位置。
- 打卡判定：與景點距離 ≤ `checkin_radius_m` 才可打卡；點 marker 出現景點資訊 bottom sheet（即時距離、打卡按鈕）。
- 集章持久化：已集印章存本機（shared_preferences），App 重啟保留；地圖頁顯示進度（已集 X/12、目標 6）。
- 地圖用 flutter_map（OSM tiles，免 API key）；不動 `api/` 與 `web/`。

## Capabilities

### New Capabilities

- `app-checkin`: GPS 打卡集章 — 地圖與景點 marker、定位權限流程、距離判定打卡、集章持久化與進度顯示。

### Modified Capabilities

- `app-shell`: 底部導覽從兩個頁籤擴為三個（首頁／地圖打卡／活動網頁），頁籤狀態保留需求不變。

## Impact

- 修改 `app/`：新增 map/checkin 模組、`main.dart` 導覽加頁籤、Android manifest 加定位權限。
- 新依賴：`flutter_map`、`latlong2`、`geolocator`、`shared_preferences`。
- 打卡紀錄存本機而非 API：API 維持唯讀無狀態（Render 免費層磁碟不持久，伺服器端集章反而會遺失資料）；匿名打卡事件上報留給 phase 4（Firebase Analytics）。
- 驗證：單元測試（距離判定、集章持久化）+ emulator 模擬定位（`adb emu geo fix`）端到端實測。
