# add-app-visual-polish — Design

## Context

延續 phase 2–5 的 App（Riverpod 3、三頁籤、GPS 打卡、Firebase）。本 change 純粹是前端表現層加強，`performCheckin`（`checkin_flow.dart`）與其測試（`checkin_test.dart`）已涵蓋的邏輯（距離判定、集章持久化、事件觸發）不變，只調整其回傳值以支援 UI 分支。

## Goals / Non-Goals

**Goals:**

- 打卡成功與集章護照兩個新視覺呈現，皆為自行繪製（`CustomPainter`），不引入 Lottie／Rive 等外部動畫套件或素材檔案。
- 動畫可被 widget test 驗證觸發時機與內容（不是「跑起來看爽」而已）。
- 保留現有 GPS 判定與 Firebase 事件邏輯不變，純粹加一層呈現。

**Non-Goals:**

- 不做集章護照的分享/匯出功能（超出「視覺深化」範圍，留待未來 change）。
- 不做首頁橫幅的圖片式視差（沒有真實圖片素材），僅做漸層/文字位移的輕量視差。
- 不追求動畫效能極限優化（Impeller 分析等），Flutter 內建動畫 API 在此規模已足夠流暢。

## Decisions

- **`performCheckin` 回傳 `Future<bool>`（是否達標）**：內部已算出 `updatedStamps.length == stampGoal`，過去只用來決定要不要呼叫 analytics、沒有曝光給呼叫端。改成回傳值後，UI 依此選擇「一般蓋章」或「達標慶祝」動畫版本，邏輯真相仍只有一處（`checkin_flow.dart`），UI 不重新判斷一次達標與否。
- **蓋章動畫用 `OverlayEntry` + 單一連續 `AnimationController`（`TweenSequence`），取代 SnackBar**：SnackBar 是文字通知，蓋章需要疊在畫面中央的自訂圖形與時序（縮放彈跳 → 停留 → 淡出）；`OverlayEntry` 可疊在 bottom sheet 關閉後的地圖畫面上方，不受 sheet 生命週期限制。原規劃是「`forward()` 進場 → `Future.delayed` 停留 → `reverse()` 退場」兩段獨立動畫銜接，但實測在 `flutter_test` 的 fake-async 環境下無法可靠驅動完成——`Ticker` 的 elapsed 計算採「第一次 tick 即為零點」的 lazy-start-reference 語意，而 `elapse()`（處理 Timer/`Future.delayed`）與 `handleBeginFrame`（真正驅動 Ticker tick）在單次 `pump()` 呼叫中的執行順序是「先 elapse 後 tick」，兩段動畫銜接處會因此彼此看不到對方已完成，`Future.delayed` 排進的計時器要等到下一次 `pump()` 才會觸發。改為單一 `AnimationController(duration: 總時長)` 搭配 `TweenSequence`（依權重切三段：進場彈跳 `Curves.elasticOut`／停留常數／淡出 `Curves.easeIn`），全程只有一個連續 ticker，`AnimationStatus.completed` 即代表整段流程結束、可靠觸發 `onFinished()`；程式碼也更簡單，不必手動判斷「是否已達到某個中繼狀態才能進到下一步」。
- **印章圖形用 `CustomPainter` 手繪，不用圖片素材**：畫一個帶「墨跡不均勻邊緣」的圓形印章——以 `Path` 沿圓周加入小鋸齒／缺角製造粗糙邊緣，疊加兩層半透明圓弧（模擬蓋章力道不均的雙重疊印），中央放置勾勾圖示或景點編號；每個景點以 `(index * 37) % 30 - 15` 算出固定但看似隨機的傾斜角度，讓集章護照頁的多個印章看起來像是不同時間手動蓋上去的，而非機械複製貼上。與 space-shooter「零素材、程式生成」的一貫風格呼應。
- **集章護照頁不佔用底部導覽新頁籤，改為地圖頁進度卡片點擊進入的推疊頁面**：現有三頁籤（首頁/地圖/活動網頁）語意已完整，護照頁是「地圖打卡進度」的延伸細節，用 `Navigator.push` 更符合資訊層級（護照頁沒有自己的頂層導覽定位需求），也不必再次修改 `app-shell` 的頁籤數量規格。
- **首頁視差用 `ListView` 的 `ScrollController` 監聽捲動位移，橫幅套 `Transform.translate`**：不需要額外套件；監聽 `controller.offset`，橫幅背景以捲動位移的一小部分（如 0.3 倍）反向位移，形成背景「跟得比較慢」的經典視差感，同時鎖定位移範圍避免捲到底部時背景跑出容器。
- **動畫的 widget test 用有限次數 `pump(duration)` 而非 `pumpAndSettle()`**：`pumpAndSettle` 在有明確結束時間的動畫上會等到動畫完全停止（含 overlay 自動移除的 delay），測試改以 `pump(const Duration(milliseconds: X))` 步進到特定時間點斷言中間狀態（例如「動畫進行中 CustomPaint 存在」「1.5 秒後 overlay 已移除」），沿用 phase 5 測地圖頁 `FlutterMap` 時「有限次數 pump 而非 pumpAndSettle」的既有作法。

## Risks / Trade-offs

- [`OverlayEntry` 忘記 `remove()` 會造成疊加/記憶體殘留] → 用 `AnimationController.addStatusListener` 於 `AnimationStatus.dismissed` 時呼叫 `entry.remove()` 並 `controller.dispose()`，且以 widget test 驗證動畫結束後 overlay 確實消失。
- [視差效果在低階裝置可能造成掉幀] → 效果僅為簡單的 `Transform.translate`（GPU 合成、無重新佈局），成本極低，不預期有效能疑慮；仍以 emulator 觀察捲動是否流暢作為驗收之一。
- [集章護照頁需要景點資料與集章狀態兩個 provider，若其中之一還在載入] → 沿用既有的 `AsyncValue` 三態處理慣例（loading／error／data），不新增例外處理方式。
- [`ListView(children:)` 對離開可視範圍的子項一樣會虛擬化卸載]（實測發現，非原規劃預期）→ 首頁橫幅捲出可視範圍+快取區時，其 `Transform` 節點會整個從 element 樹移除；由於視差效果本就只在橫幅可見時才有意義，不需額外處理，但驗證/測試橫幅位移時捲動量必須控制在橫幅高度以內。
