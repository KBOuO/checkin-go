# add-gps-checkin — Design

## Context

延續 phase 2 的 App 殼（Riverpod 3、Material 3、IndexedStack 導覽）。景點資料已含 `lat`/`lng`/`checkin_radius_m`（phase 1 預留）。驗證環境為 Pixel 7 emulator（可用 `adb emu geo fix` 模擬定位）。

## Goals / Non-Goals

**Goals:**

- 地圖 + GPS 打卡在 emulator 端到端可展示（模擬定位 → 打卡 → 重啟保留）。
- 權限流程完整：未授權、拒絕、永久拒絕都有對應 UI。
- 打卡邏輯可單元測試（不依賴平台通道）。

**Non-Goals:**

- 打卡資料上傳伺服器（phase 4 以 Firebase Analytics 記事件）。
- 防作弊（mock location 偵測）、離線地圖、iOS 定位設定（無 Mac 可測）。
- 獎勵兌換流程（顯示進度即可，兌換是行銷文案層）。

## Decisions

- **地圖用 `flutter_map`（OSM tiles）而非 Google Maps / Mapbox**：兩者都要 API key + 帳號（Google 還要綁計費），作品集 demo 讓面試官 clone 即跑比較重要；職缺寫「如 geolocator 或 mapbox_maps_flutter」，GPS 能力由 geolocator 展示，地圖框架可談遷移路徑（flutter_map 換 TileLayer 即可接 Mapbox tiles）。OSM tile 用量政策要求帶 `userAgentPackageName`。
- **定位用 `geolocator`**：職缺點名。`positionStreamProvider` 先 yield `getCurrentPosition()` 再接 `getPositionStream`（stream 要位移才觸發，先給初始定位避免地圖空等）；權限流程獨立成 `locationPermissionProvider`，denied/deniedForever 拋例外由 UI 分流（重試 vs 開啟設定）。
- **距離判定用 `Geolocator.distanceBetween`**：純靜態 haversine 計算，不走平台通道，單元測試可直接驗證「半徑內可打卡/半徑外不可」。
- **集章存 `shared_preferences`（AsyncNotifier）**：唯一寫入是「新增一枚印章」，字串清單足矣，不需要 SQLite/drift。不存伺服器：Render 免費層磁碟非持久，伺服器端集章重啟即消失，本機儲存反而是對使用者誠實的選擇；此決策記入 proposal Impact。
- **打卡 bottom sheet 用 Consumer 即時更新距離**：sheet 開著時位置變動（走近景點）按鈕狀態要跟著解鎖，不能開 sheet 時算一次就定格。
- **Marker 視覺沿用印章語彙**：未集=青色圓 + 編號、已集=橘色實心 + 勾，與 Web/首頁的印章圓一致。

## Risks / Trade-offs

- [OSM tile 伺服器對高流量不友善] → demo 用量極小；README 註明正式產品應換自架 tile 或 Mapbox/MapTiler。
- [emulator 首次定位可能拿不到 fix] → 驗證流程先 `adb emu geo fix` 再開 App；App 端 stream 先 yield getCurrentPosition 降低空等。
- [位置權限被永久拒絕] → UI 提供「開啟設定」（`Geolocator.openAppSettings()`）。
- [flutter_map 大版本 API 變動頻繁] → 鎖 pubspec caret 範圍，README 記錄實測版本。
