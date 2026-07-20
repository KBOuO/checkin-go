# app-shell

## MODIFIED Requirements

### Requirement: 底部導覽
App SHALL 提供底部導覽列，含「首頁」、「地圖打卡」與「活動網頁」三個頁籤；切換頁籤 SHALL 保留各頁狀態（首頁捲動位置、地圖視角、WebView 瀏覽狀態）。

#### Scenario: 頁籤切換保留狀態
- **WHEN** 使用者在 WebView 內導航後切到首頁再切回
- **THEN** WebView 停留在原頁面，未重新載入

#### Scenario: 地圖視角保留
- **WHEN** 使用者在地圖頁縮放/平移後切到其他頁籤再切回
- **THEN** 地圖維持離開時的視角
