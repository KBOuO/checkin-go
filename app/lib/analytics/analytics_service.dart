import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 行銷漏斗事件的抽象層。`flutter test` 在純 Dart VM 跑，
/// firebase_analytics 走平台通道會丟 MissingPluginException，
/// 測試以 [NoopAnalyticsService] override 掉，不碰真實 SDK。
abstract class AnalyticsService {
  Future<void> logCampaignView();
  Future<void> logFavoriteSpot(String spotId);
  Future<void> logCheckinSuccess({required String spotId, required String city});
  Future<void> logStampGoalReached();
}

class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService(this._analytics);
  final FirebaseAnalytics _analytics;

  @override
  Future<void> logCampaignView() => _analytics.logEvent(name: 'campaign_view');

  @override
  Future<void> logFavoriteSpot(String spotId) =>
      _analytics.logEvent(name: 'favorite_spot', parameters: {'spot_id': spotId});

  @override
  Future<void> logCheckinSuccess({required String spotId, required String city}) =>
      _analytics.logEvent(
        name: 'checkin_success',
        parameters: {'spot_id': spotId, 'city': city},
      );

  @override
  Future<void> logStampGoalReached() =>
      _analytics.logEvent(name: 'stamp_goal_reached');
}

class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  Future<void> logCampaignView() async {}

  @override
  Future<void> logFavoriteSpot(String spotId) async {}

  @override
  Future<void> logCheckinSuccess({required String spotId, required String city}) async {}

  @override
  Future<void> logStampGoalReached() async {}
}

/// main() 在 Firebase.initializeApp() 完成後 override 成 FirebaseAnalyticsService；
/// 測試環境維持 Noop 預設值，避免任何 test 誤觸平台通道。
final analyticsServiceProvider =
    Provider<AnalyticsService>((ref) => const NoopAnalyticsService());
