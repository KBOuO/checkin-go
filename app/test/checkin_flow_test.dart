import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:checkin_go/analytics/analytics_service.dart';
import 'package:checkin_go/checkin/checkin_flow.dart';
import 'package:checkin_go/models.dart';

class SpyAnalyticsService implements AnalyticsService {
  final List<String> checkinSpotIds = [];
  final List<String> checkinCities = [];
  int stampGoalReachedCalls = 0;

  @override
  Future<void> logCampaignView() async {}

  @override
  Future<void> logFavoriteSpot(String spotId) async {}

  @override
  Future<void> logCheckinSuccess({
    required String spotId,
    required String city,
  }) async {
    checkinSpotIds.add(spotId);
    checkinCities.add(city);
  }

  @override
  Future<void> logStampGoalReached() async {
    stampGoalReachedCalls++;
  }
}

Spot _spot(String id, String city) => Spot(
      id: id,
      name: id,
      city: city,
      description: '',
      tags: const [],
      lat: 0,
      lng: 0,
      checkinRadiusM: 100,
    );

void main() {
  late SpyAnalyticsService spy;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    spy = SpyAnalyticsService();
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [analyticsServiceProvider.overrideWithValue(spy)],
    );
  });

  tearDown(() => container.dispose());

  Future<bool> checkin(Spot spot) =>
      performCheckin(read: container.read, spot: spot, stampGoal: 6);

  test('打卡成功記錄 checkin_success 並帶正確 spot_id/city', () async {
    await checkin(_spot('xiangshan-trail', '台北市'));

    expect(spy.checkinSpotIds, ['xiangshan-trail']);
    expect(spy.checkinCities, ['台北市']);
  });

  test('集章數未達目標時不觸發 stamp_goal_reached，回傳 false', () async {
    var lastResult = true;
    for (final id in ['s1', 's2', 's3', 's4', 's5']) {
      lastResult = await checkin(_spot(id, '台北市'));
    }
    expect(spy.stampGoalReachedCalls, 0);
    expect(lastResult, isFalse);
  });

  test('達標當次觸發一次、回傳 true，之後繼續打卡不再重複且回傳 false', () async {
    final ids = ['s1', 's2', 's3', 's4', 's5', 's6', 's7'];
    final results = <bool>[];
    for (final id in ids) {
      results.add(await checkin(_spot(id, '台北市')));
    }
    expect(spy.stampGoalReachedCalls, 1);
    expect(spy.checkinSpotIds.length, 7);
    expect(results, [false, false, false, false, false, true, false]);
  });
}
