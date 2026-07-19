/// 位址以 --dart-define 注入；預設值指向 Android emulator 的 host loopback。
/// 實體手機測試：--dart-define=API_BASE_URL=http://<電腦區網IP>:8000 …
class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
  static const webUrl = String.fromEnvironment(
    'WEB_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );
}
