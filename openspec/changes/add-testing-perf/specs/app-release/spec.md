# app-release

## ADDED Requirements

### Requirement: Release 簽名設定
Android release build SHALL 使用專屬簽名（非 debug 簽名）；簽名金鑰與密碼設定檔（`key.properties`、`*.jks`/`*.keystore`）MUST NOT 進版本控制。找不到簽名設定檔時，release build SHALL fallback 使用 debug 簽名並印出警告，而非直接建置失敗。

#### Scenario: 有簽名設定
- **WHEN** `key.properties` 存在且指向有效 keystore
- **THEN** `flutter build appbundle --release` 產出以該 keystore 簽名的 AAB

#### Scenario: 無簽名設定
- **WHEN** `key.properties` 不存在（例如他人 clone 專案後直接建置）
- **THEN** release build 仍成功完成（fallback debug 簽名），並在建置輸出中顯示警告訊息

### Requirement: Release 產物與安裝驗證
Release build SHALL 產出 Play Console 上架用的 AAB 與可直接安裝測試的 APK；兩者 SHALL 在 emulator 或實機安裝後正常啟動並可完整操作三個頁籤（首頁、地圖打卡、活動網頁）。

#### Scenario: 安裝驗證
- **WHEN** 將 release APK 安裝到 emulator 並啟動
- **THEN** App 正常顯示首頁資料，三個頁籤皆可正常切換與操作
