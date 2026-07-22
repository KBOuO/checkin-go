# add-app-visual-polish — Tasks

## 1. 打卡邏輯調整

- [x] 1.1 `checkin_flow.dart`：`performCheckin` 回傳 `Future<bool>`（是否剛好達標），既有測試同步更新斷言回傳值

## 2. 自訂蓋章動畫

- [x] 2.1 `widgets/stamp_badge.dart`：`CustomPainter`（`StampPainter`）繪製印章圖形（不規則邊緣、雙層疊印）+ `StampBadge` widget（依 index 決定固定傾斜角度、置中圖示/文字）
- [x] 2.2 `widgets/checkin_celebration_overlay.dart`：`OverlayEntry` + 單一連續 `AnimationController`（`TweenSequence` 編排進場彈跳／停留／淡出三段時間軸），結束時自動移除並釋放資源；一般版與達標版兩種內容（顏色與文案皆不同）
- [x] 2.3 `map_page.dart` 的打卡按鈕改呼叫新的 overlay，取代原本的 `Navigator.pop` + `SnackBar`

## 3. 集章護照畫面

- [x] 3.1 `pages/stamp_book_page.dart`：`GridView` 呈現 12 個景點，已集/未集視覺區分，套用 `StampBadge`
- [x] 3.2 `map_page.dart` 的進度卡片包 `InkWell`，`Navigator.push` 導向護照頁

## 4. 首頁視差

- [x] 4.1 `home_page.dart`：`HomePage` 改 `ConsumerStatefulWidget`、`ScrollController` 監聽捲動位移，橫幅背景層（含裝飾圖示）套 `Transform.translate`，前景文字內容不隨位移；位移量鎖在 0–36px

## 5. 驗證

- [x] 5.1 `checkin_flow_test.dart` 更新（斷言 `performCheckin` 回傳值）；新增 `checkin_celebration_overlay_test.dart`（一般/達標兩版文案、動畫結束自動消失）、`stamp_book_page_test.dart`（未集/部分/全部集滿三態）、`home_parallax_test.dart`（捲動改變背景層位移、捲回歸零）
- [x] 5.2 `flutter test` 全過（25/25）、`dart analyze` 乾淨
- [x] 5.3 emulator 實測：首頁視差捲動、打卡蓋章動畫（一般版＋達標版）、集章護照（部分集滿狀態），截圖存 `docs/`
- [x] 5.4 更新 README（新截圖、功能說明）、PROJECTS.md、`作品集/sources/checkin-go.md`（補視覺深化的工程決策）

> 實作備註：測試蓋章動畫時發現用 `Future.delayed` 銜接兩段獨立動畫（進場 forward + 停留 + 退場 reverse）
> 在 flutter_test 的 fake-async 環境下無法可靠驅動完成（Ticker 的 lazy-start-reference 語意與
> Timer 佇列在 `elapse()`/`handleBeginFrame` 兩階段間的排序差異），改為單一連續 `AnimationController`
> + `TweenSequence` 整段時間軸，不僅測試可靠、程式碼也更簡單。另外，emulator 上驗證「捲動視差」
> 時發現 `ListView(children:)` 對離開可視範圍的子項一樣會虛擬化卸載（並非只有 `.builder` 才會），
> 捲動測試需將位移量控制在橫幅高度內，否則橫幅連同其 `Transform` 會被整個移出 element 樹。
