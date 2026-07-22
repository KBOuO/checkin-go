# app-checkin-celebration

## ADDED Requirements

### Requirement: 打卡成功蓋章動畫
GPS 打卡成功時，App SHALL 顯示自訂繪製的蓋章動畫（縮放＋回彈進場），取代純文字提示；動畫 MUST 在有限時間內（約 1.5 秒內）自動消失並回到地圖畫面，不需使用者手動關閉。

#### Scenario: 一般打卡成功
- **WHEN** 使用者在打卡半徑內完成一次未達成集章目標的打卡
- **THEN** 顯示蓋章動畫（含景點名稱），動畫結束後自動消失，畫面回到地圖

#### Scenario: 動畫期間畫面不可重複觸發
- **WHEN** 蓋章動畫顯示中
- **THEN** 使用者無法對同一次打卡重複觸發動畫（動畫由單一 overlay 控制，非重疊生成）

### Requirement: 集滿目標的加強版動畫
當本次打卡使集章數剛好達到活動目標時，App SHALL 顯示與一般打卡不同、更明顯的慶祝變化版本（例如額外文案或視覺強調），而非與一般打卡相同的動畫。

#### Scenario: 達標打卡
- **WHEN** 使用者打卡後集章數剛好等於活動目標值
- **THEN** 顯示達標版本的蓋章動畫，與一般版本有可辨識的視覺差異

#### Scenario: 超過目標後的打卡維持一般版本
- **WHEN** 使用者在已達標後繼續打卡其他景點
- **THEN** 顯示一般版本動畫，不再觸發達標版本

### Requirement: 動畫資源正確釋放
蓋章動畫使用的 `AnimationController` 與 overlay MUST 在動畫結束或畫面卸載時正確釋放，不得殘留。

#### Scenario: 動畫結束後資源釋放
- **WHEN** 蓋章動畫播放完畢
- **THEN** 對應的 overlay 從畫面樹移除、`AnimationController` 已 dispose
