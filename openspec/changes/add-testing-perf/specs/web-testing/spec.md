# web-testing

## ADDED Requirements

### Requirement: 倒數計時邏輯測試
`Countdown` 元件 SHALL 有自動化測試覆蓋：活動進行中顯示正確的天/時/分/秒、活動已結束顯示結束文案；測試 MUST 使用假時鐘（`jest.useFakeTimers`）控制時間，不依賴真實秒數流逝。

#### Scenario: 測試通過
- **WHEN** 執行 `npm test`
- **THEN** 倒數計時的進行中與已結束案例皆通過，執行時間不因等待真實秒數而變長

### Requirement: 收藏狀態測試
收藏功能（Zustand store 與 `SpotCard` 收藏按鈕）SHALL 有測試覆蓋：初始未收藏、點擊後收藏、再次點擊取消收藏，且 UI 呈現（愛心圖示狀態）與 store 狀態一致。

#### Scenario: 收藏切換
- **WHEN** 測試對 `SpotCard` 觸發收藏按鈕點擊兩次
- **THEN** 第一次後 store 含該 spot id、UI 呈現已收藏；第二次後 store 不含該 id、UI 呈現未收藏

### Requirement: Fallback 呈現測試
`CampaignIntro` 等吃資料 props 的展示型元件 SHALL 有測試驗證：給定的活動資料（含日期格式化）正確渲染成畫面文字。

#### Scenario: 日期格式化
- **WHEN** 測試以固定的 `starts_at`/`ends_at` 渲染 `CampaignIntro`
- **THEN** 畫面顯示對應格式化後的西元年月日文字

### Requirement: 測試可重複執行
`npm test` SHALL 在無網路連線、無執行中 API/Web 開發伺服器的情況下可重複執行且結果穩定（不依賴外部服務或真實時間）。

#### Scenario: 離線執行
- **WHEN** 中斷網路連線後執行 `npm test`
- **THEN** 測試套件正常執行完畢，結果與有網路時一致
