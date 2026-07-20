import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const heroSloganVariantParam = 'hero_slogan_variant';
const heroSloganVariantDefault = 'control';

/// 兩版文案維護在程式碼內（而非直接放進 Remote Config 值），
/// Remote Config 只決定「顯示哪一版」——見 design.md 的 A/B 設計理由。
const heroSloganVariants = {
  'control': '集滿島嶼的印章，換一個夏天的故事',
  'variant_b': '走遍台灣 12 個角落，把整個夏天蓋章珍藏',
};

abstract class RemoteConfigService {
  Future<String> fetchHeroSloganVariant();
}

class FirebaseRemoteConfigServiceImpl implements RemoteConfigService {
  FirebaseRemoteConfigServiceImpl(this._remoteConfig);
  final FirebaseRemoteConfig _remoteConfig;

  @override
  Future<String> fetchHeroSloganVariant() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (_) {
      // fetch 失敗（無網路/逾時）：吃掉例外，落回已設定的 defaults 值，
      // 首頁不因 Remote Config 不可用而載入失敗
    }
    return _remoteConfig.getString(heroSloganVariantParam);
  }
}

class NoopRemoteConfigService implements RemoteConfigService {
  const NoopRemoteConfigService();

  @override
  Future<String> fetchHeroSloganVariant() async => heroSloganVariantDefault;
}

/// main() 於 Firebase 初始化後 override 成 FirebaseRemoteConfigServiceImpl；
/// 測試環境維持 Noop 預設值。
final remoteConfigServiceProvider =
    Provider<RemoteConfigService>((ref) => const NoopRemoteConfigService());

final heroSloganVariantProvider = FutureProvider<String>(
  (ref) => ref.watch(remoteConfigServiceProvider).fetchHeroSloganVariant(),
);
