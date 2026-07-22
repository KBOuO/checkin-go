import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/misc.dart' show ProviderListenable;

import '../analytics/analytics_service.dart';
import '../models.dart';
import 'stamps.dart';

/// [Ref.read] 與 [WidgetRef.read] 是同型的泛型方法（`T Function<T>(...)`）
/// 但 `Ref`／`WidgetRef` 彼此不相容（Riverpod 3 把兩者拆成互不繼承的介面，
/// `ProviderContainer` 也不是 `Ref`）。撕下 `.read` 方法本身當函式值傳遞，
/// 三邊（widget 的 WidgetRef、provider 的 Ref、測試用的 ProviderContainer）
/// 都能餵進來，不必為了測試另外包一層 provider 或改動呼叫端型別。
typedef ProviderReader = T Function<T>(ProviderListenable<T> provider);

/// 打卡＋事件追蹤的完整流程，從 widget 抽出成純邏輯函式方便測試
/// （不必透過 UI/FlutterMap 也能驗證 analytics 觸發時機）。
///
/// 回傳「這次打卡是否剛好使集章數達標」，供 UI 選擇一般或達標版的蓋章動畫——
/// 集章數剛好等於目標值代表「這次打卡」使其達標：Set 每次最多 +1，
/// 這個相等判定只會在跨過門檻那一刻成立一次，真相只算一次、UI 不重新判斷。
Future<bool> performCheckin({
  required ProviderReader read,
  required Spot spot,
  required int stampGoal,
}) async {
  await read(stampsProvider.notifier).collect(spot.id);
  final analytics = read(analyticsServiceProvider);
  await analytics.logCheckinSuccess(spotId: spot.id, city: spot.city);
  final updatedStamps = await read(stampsProvider.future);
  final goalReached = updatedStamps.length == stampGoal;
  if (goalReached) {
    await analytics.logStampGoalReached();
  }
  return goalReached;
}
