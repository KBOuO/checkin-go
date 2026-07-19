# campaign-landing

## ADDED Requirements

### Requirement: Landing Page 版面
活動頁 `/` SHALL 由上而下包含：Hero 區（品牌名「打卡趣 CheckinGo」、活動 slogan、進場動畫）、活動介紹區、玩法說明區（打卡集章三步驟）、精選景點區（景點卡片格）、CTA 區（「下載 App」佔位按鈕 + 領取優惠導引）、footer（含專案為作品集用途之聲明）。

#### Scenario: 訪客瀏覽完整頁面
- **WHEN** 訪客開啟 `/`
- **THEN** 依序看到上述六個區塊，內容完整無空區

### Requirement: 活動倒數計時
Hero 或活動介紹區 SHALL 顯示至活動 `ends_at` 的即時倒數（天/時/分/秒），每秒更新。

#### Scenario: 活動進行中
- **WHEN** 現在時間早於 `ends_at`
- **THEN** 顯示遞減的倒數計時

#### Scenario: 活動已結束
- **WHEN** 現在時間晚於 `ends_at`
- **THEN** 倒數區顯示「本季活動已結束，敬請期待下一季」

### Requirement: 景點資料串接
精選景點區 SHALL 顯示來自 `marketing-api` 的景點卡片（名稱、城市、描述節錄、標籤），頁面 SHALL 以 SSG + ISR（revalidate 3600 秒）於建置期取得資料。

#### Scenario: API 正常
- **WHEN** 建置或 revalidate 時 API 回應正常
- **THEN** 景點卡片顯示 API 回傳的 12 筆景點

#### Scenario: API 無法連線
- **WHEN** 建置或 revalidate 時 API 無回應
- **THEN** 頁面 fallback 顯示內建的靜態景點內容，不出現錯誤畫面或空白區塊

### Requirement: 收藏景點
訪客 SHALL 可在景點卡片上收藏/取消收藏景點；收藏狀態以 Zustand 管理並 persist 至 localStorage，頁面頂部 SHALL 顯示目前收藏數。

#### Scenario: 收藏並重新整理
- **WHEN** 訪客收藏 2 個景點後重新整理頁面
- **THEN** 該 2 個景點維持已收藏狀態，收藏數顯示 2

### Requirement: 響應式版面
頁面 SHALL 在 375px（手機）至 1440px（桌面）寬度下正常呈現：手機單欄、桌面景點卡片至少三欄，無水平捲動。

#### Scenario: 手機瀏覽
- **WHEN** 以 375px 寬度檢視
- **THEN** 所有區塊單欄堆疊、文字可讀、無水平捲動

### Requirement: SEO
頁面 SHALL 設定 `lang="zh-Hant-TW"`、title、description、Open Graph（og:title/description/image）與 canonical，並提供 `sitemap.xml` 與 `robots.txt`。Lighthouse SEO 分數 MUST ≥ 90。

#### Scenario: 分享預覽
- **WHEN** 頁面連結貼到社群平台
- **THEN** 預覽卡片顯示活動標題、描述與 OG 圖

### Requirement: 動畫與可及性
Hero SHALL 有進場動畫，景點卡片 SHALL 有滾動進場動畫（於支援的瀏覽器漸進增強）；動畫 MUST NOT 依賴 JavaScript 載入才讓內容可見（SSR HTML 的首屏內容須立即可繪製）。當使用者系統設定 `prefers-reduced-motion: reduce` 時 SHALL 完全停用進場/滾動動畫，直接呈現最終狀態。

#### Scenario: 減少動態偏好
- **WHEN** 使用者系統啟用 reduce motion
- **THEN** 頁面直接呈現最終狀態，無進場/滾動動畫

#### Scenario: JS 尚未載入
- **WHEN** 瀏覽器已載入 HTML/CSS 但 JavaScript 尚未執行
- **THEN** Hero 與各區塊內容照常可見（動畫由 CSS 驅動）
