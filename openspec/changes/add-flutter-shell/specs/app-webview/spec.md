# app-webview

## ADDED Requirements

### Requirement: 嵌入行銷網頁
「活動網頁」頁籤 SHALL 以 WebView（`webview_flutter`）載入 `WEB_URL` 指向的 React 行銷頁，並啟用 JavaScript（頁面互動需要）。

#### Scenario: 載入活動頁
- **WHEN** 使用者切到「活動網頁」頁籤
- **THEN** WebView 顯示「島嶼打卡季」Landing Page，收藏等互動可操作

### Requirement: 載入進度與失敗處理
WebView 載入中 SHALL 顯示進度指示；載入失敗（無網路、位址錯誤）SHALL 顯示原生錯誤畫面與「重新載入」按鈕，MUST NOT 呈現瀏覽器預設錯誤頁。

#### Scenario: 載入中
- **WHEN** 頁面尚未載入完成
- **THEN** 顯示線性進度條

#### Scenario: 載入失敗
- **WHEN** WEB_URL 無法連線
- **THEN** 顯示原生錯誤畫面與重新載入按鈕，按下後重試

### Requirement: WebView 內返回導航
在 WebView 頁籤按系統返回鍵時，若 WebView 可返回上一頁 SHALL 先在 WebView 內返回，不可返回時才交還系統預設行為。

#### Scenario: 網頁內返回
- **WHEN** 使用者在 WebView 內點了站內連結後按系統返回鍵
- **THEN** WebView 回到上一頁，App 不退出
