# marketing-api

## ADDED Requirements

### Requirement: 景點列表 API
系統 SHALL 提供 `GET /api/spots`，回傳全部景點的 JSON 陣列；每筆景點 MUST 包含 `id`、`name`、`city`、`description`、`tags`、`lat`、`lng`、`checkin_radius_m`。端點 SHALL 支援 `?city=` 查詢參數做城市篩選。

#### Scenario: 取得全部景點
- **WHEN** 用戶端呼叫 `GET /api/spots`
- **THEN** 回傳 200 與 12 筆景點，每筆含上述全部欄位

#### Scenario: 依城市篩選
- **WHEN** 用戶端呼叫 `GET /api/spots?city=花蓮縣`
- **THEN** 回傳 200，僅含 `city` 為「花蓮縣」的景點

#### Scenario: 篩選結果為空
- **WHEN** 用戶端以不存在的城市呼叫 `GET /api/spots?city=不存在市`
- **THEN** 回傳 200 與空陣列（非 404）

### Requirement: 景點詳情 API
系統 SHALL 提供 `GET /api/spots/{id}` 回傳單一景點完整資料。

#### Scenario: 取得存在的景點
- **WHEN** 用戶端以有效 `id` 呼叫 `GET /api/spots/{id}`
- **THEN** 回傳 200 與該景點完整欄位

#### Scenario: 景點不存在
- **WHEN** 用戶端以不存在的 `id` 呼叫
- **THEN** 回傳 404，body 為 `{"detail": "spot not found"}`

### Requirement: 當前活動 API
系統 SHALL 提供 `GET /api/campaigns/current`，回傳目前進行中的行銷活動，欄位 MUST 包含 `id`、`title`、`slogan`、`description`、`starts_at`、`ends_at`（ISO 8601 UTC）、`stamp_goal`（集章目標數）、`reward`（獎勵說明）、`spot_ids`（參與景點）。

#### Scenario: 取得進行中活動
- **WHEN** 現在時間介於某活動 `starts_at` 與 `ends_at` 之間，用戶端呼叫 `GET /api/campaigns/current`
- **THEN** 回傳 200 與該活動資料

#### Scenario: 無進行中活動
- **WHEN** 沒有任何活動在進行中
- **THEN** 回傳 404，body 為 `{"detail": "no active campaign"}`

### Requirement: CORS 限制
API SHALL 僅允許環境變數 `ALLOWED_ORIGINS`（逗號分隔）列出的來源進行跨域請求，MUST NOT 使用萬用字元 `*`。

#### Scenario: 允許的來源
- **WHEN** 來自 `ALLOWED_ORIGINS` 中網域的瀏覽器請求
- **THEN** 回應帶有對應的 `Access-Control-Allow-Origin` 標頭

#### Scenario: 未列名的來源
- **WHEN** 來自未列名網域的跨域請求
- **THEN** 回應不帶 `Access-Control-Allow-Origin`，瀏覽器端封鎖

### Requirement: 種子資料
API SHALL 於啟動時從 `api/data/` 載入種子資料：12 個台灣景點（北、中、南、東與離島皆有分佈，座標為真實座標）與 1 檔進行中活動「島嶼打卡季」。種子 JSON MUST 以 UTF-8（無 BOM）儲存，載入端 SHALL 以 `utf-8-sig` 讀取。

#### Scenario: 啟動載入
- **WHEN** API 服務啟動
- **THEN** `GET /api/spots` 立即可回傳 12 筆景點，`GET /api/campaigns/current` 回傳「島嶼打卡季」
