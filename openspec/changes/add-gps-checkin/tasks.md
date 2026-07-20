# add-gps-checkin — Tasks

## 1. 依賴與權限

- [x] 1.1 `flutter pub add flutter_map latlong2 geolocator shared_preferences`
- [x] 1.2 AndroidManifest 加 `ACCESS_FINE_LOCATION`、`ACCESS_COARSE_LOCATION`

## 2. 邏輯層

- [x] 2.1 `checkin/stamps.dart`：AsyncNotifier 集章儲存（shared_preferences、去重、進度）
- [x] 2.2 `checkin/location.dart`：權限 provider（denied/deniedForever 分流）+ 位置 stream provider（先 getCurrentPosition 再 stream）
- [x] 2.3 `checkin/checkin_logic.dart`：距離計算與可打卡判定（純函式）

## 3. UI

- [x] 3.1 `pages/map_page.dart`：flutter_map + OSM tiles、12 景點 marker（未集/已集視覺）、使用者位置點、進度列
- [x] 3.2 權限拒絕/永久拒絕畫面（重試 / 開啟設定）
- [x] 3.3 景點 bottom sheet：資訊 + 即時距離（Consumer）+ 打卡按鈕（半徑判定）+ 打卡成功回饋
- [x] 3.4 `main.dart` 導覽加「地圖打卡」頁籤（IndexedStack 保留地圖視角）

## 4. 驗證

- [x] 4.1 單元測試：半徑內/外判定、集章持久化、重複打卡去重；`flutter test` 12/12 全過 + `dart analyze` 乾淨
- [x] 4.2 emulator 端到端：`adb emu geo fix 121.5708 25.0273`（象山親山步道）→ 地圖顯示 12 marker → 點 marker 顯示「距離 0 公尺——在打卡範圍內！」→ 打卡成功（SnackBar + 進度 1/12 + marker 轉橘勾）→ 點遠方景點（清水斷崖）顯示「距離 92.1 公里，需進入 400 公尺範圍」且按鈕鎖定 → `am force-stop` + 重啟 App，集章狀態與進度完整保留
- [x] 4.3 截圖存 `docs/`（app-map.png、app-checkin-sheet.png）；更新 README 與 PROJECTS.md

> 實作備註：驗證過程中彈出的是 Google Play Services 的系統「Location Accuracy」對話框
> （非本 App 的執行時權限對話框，那個已在首次啟動時授予），需點「Turn on」/「No thanks」
> 才會消失；純 emulator 環境下該對話框可能重複出現，屬 Play Services 特性而非 App 邏輯問題。
