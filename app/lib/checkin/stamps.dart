import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 已集印章（spot id 集合），persist 到 shared_preferences。
class StampsNotifier extends AsyncNotifier<Set<String>> {
  static const storageKey = 'collected_stamps';

  @override
  Future<Set<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(storageKey) ?? const []).toSet();
  }

  /// 重複打卡同一景點不會增加集章（Set 天然去重）。
  Future<void> collect(String spotId) async {
    final updated = {...await future, spotId};
    state = AsyncData(updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(storageKey, updated.toList()..sort());
  }
}

final stampsProvider =
    AsyncNotifierProvider<StampsNotifier, Set<String>>(StampsNotifier.new);
