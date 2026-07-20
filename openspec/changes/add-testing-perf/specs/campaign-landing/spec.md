# campaign-landing

## ADDED Requirements

### Requirement: 效能
頁面 SHALL 對 CJK 字型使用「僅含網站實際用字」的自架子集字型，而非直接載入 Google Fonts 完整 unicode-range 分片；Lighthouse Performance 分數（行動模擬）SHALL 相對修正前的基準（56 分）有顯著且可驗證的改善。README SHALL 同時記錄 Lighthouse 模擬分數與瀏覽器實測（observed）的 FCP/LCP 數字，避免僅憑單一模擬分數誤導效能判斷。

#### Scenario: 字型自架
- **WHEN** 檢視頁面載入的字型請求
- **THEN** 字型檔案來自站台自身網域（非 fonts.gstatic.com），且檔案數量與總位元組數相較修正前明顯減少

#### Scenario: 分數改善
- **WHEN** 對 build 後的頁面執行 Lighthouse（行動模擬、無節流覆寫）
- **THEN** Performance 分數高於修正前基準（56），且 Accessibility／Best Practices／SEO 三項不因此劣化
