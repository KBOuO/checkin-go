# add-app-visual-polish

## Why

phase 2–5 把 App 的功能骨架（原生首頁、GPS 打卡、Firebase、測試、release build）都做完了，但視覺與互動層面偏樸素——打卡成功只是一句 SnackBar、集章成果沒有專屬畫面可以回顧、首頁橫幅是靜態色塊。這與職缺加分條件明講的「熟悉 Flutter 進階功能（如自定義動畫、複雜 Widget 組合），能提升行銷頁面的互動體驗」有落差：目前的實作展示了「功能正確」，但沒有展示「自訂繪製、動畫編排」這類更進階的 Flutter UI 能力。

## What Changes

- 打卡成功回饋從純文字 SnackBar 改為自訂「蓋章」動畫：`CustomPainter` 手繪的印章圖形，以 `AnimationController` 編排縮放／旋轉／墨跡暈開的進場效果；集滿目標時額外呈現「達標」變化版本。
- 新增「集章護照」畫面：以 `GridView` 呈現 12 個景點的集章圖鑑，每格為自訂繪製的印章卡片（已集/未集有明顯視覺差異），從地圖頁的集章進度卡片點擊進入。
- 首頁活動橫幅加入視差捲動效果：捲動景點列表時，橫幅背景與文字以不同速率位移。
- 三者皆為前端視覺/互動層變更，不影響既有 API 契約、資料模型或 Firebase 事件邏輯。

## Capabilities

### New Capabilities

- `app-checkin-celebration`: 打卡成功的自訂動畫回饋，含集滿目標的加強版本。
- `app-stamp-book`: 集章護照畫面——景點集章圖鑑、進入方式、視覺狀態。

### Modified Capabilities

- `app-shell`: 首頁橫幅新增視差捲動效果（呈現細節變更，既有導覽/頁籤需求不變，故以 modified 記錄新增的視覺行為）。

## Impact

- 修改 `app/lib/pages/map_page.dart`（打卡成功流程）、`app/lib/pages/home_page.dart`（首頁橫幅視差）。
- 新增 `app/lib/pages/stamp_book_page.dart`、`app/lib/widgets/stamp_stamp_painter.dart`（或類似命名的 CustomPainter）、對應的動畫 overlay widget。
- `checkin_flow.dart` 的 `performCheckin` 回傳值需要能表達「這次打卡是否使集章數達標」，供 UI 選擇動畫版本（目前回傳 `void`，內部邏輯已算出但沒有曝光）。
- 不新增套件依賴——全部用 Flutter 內建的 `CustomPainter`／`AnimationController`／`Hero`，延續本專案「零外部素材、自己畫」的一貫風格（呼應 web 端 SVG／漸層視覺、space-shooter 的程式化素材）。
- 驗證：widget test 涵蓋新畫面的三種狀態（空/部分/全部集滿）與動畫觸發時機；emulator 實測打卡動畫與護照畫面截圖。
