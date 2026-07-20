import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:checkin_go/checkin/checkin_logic.dart';
import 'package:checkin_go/checkin/stamps.dart';
import 'package:checkin_go/models.dart';

const _xiangshan = Spot(
  id: 'xiangshan-trail',
  name: '象山親山步道',
  city: '台北市',
  description: '',
  tags: [],
  lat: 25.0273,
  lng: 121.5708,
  checkinRadiusM: 300,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('打卡距離判定（純函式）', () {
    test('同座標可打卡', () {
      expect(
        canCheckIn(lat: 25.0273, lng: 121.5708, spot: _xiangshan),
        isTrue,
      );
    });

    test('約 200 公尺內可打卡（半徑 300m）', () {
      // 緯度 +0.0018 度 ≈ 北移 200 公尺
      expect(
        canCheckIn(lat: 25.0291, lng: 121.5708, spot: _xiangshan),
        isTrue,
      );
    });

    test('約 1.1 公里外不可打卡', () {
      expect(
        canCheckIn(lat: 25.0373, lng: 121.5708, spot: _xiangshan),
        isFalse,
      );
    });

    test('距離格式化', () {
      expect(formatDistance(220), '220 公尺');
      expect(formatDistance(1530), '1.5 公里');
    });
  });

  group('集章儲存', () {
    test('打卡集章、持久化、重複打卡去重', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer(retry: (_, _) => null);
      addTearDown(container.dispose);

      expect(await container.read(stampsProvider.future), isEmpty);

      await container.read(stampsProvider.notifier).collect('xiangshan-trail');
      await container.read(stampsProvider.notifier).collect('xiangshan-trail');

      expect(
        await container.read(stampsProvider.future),
        {'xiangshan-trail'},
      );
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getStringList(StampsNotifier.storageKey),
        ['xiangshan-trail'],
      );
    });

    test('重啟（新 container）後從 prefs 還原', () async {
      SharedPreferences.setMockInitialValues({
        StampsNotifier.storageKey: ['jiufen-old-street'],
      });
      final container = ProviderContainer(retry: (_, _) => null);
      addTearDown(container.dispose);

      expect(
        await container.read(stampsProvider.future),
        {'jiufen-old-street'},
      );
    });
  });
}
