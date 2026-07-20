import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'package:checkin_go/checkin/location.dart';
import 'package:checkin_go/models.dart';
import 'package:checkin_go/pages/map_page.dart';
import 'package:checkin_go/providers.dart';

const _spots = [
  Spot(
    id: 'xiangshan-trail',
    name: '象山親山步道',
    city: '台北市',
    description: '20 分鐘登頂看 101。',
    tags: ['城市夜景'],
    lat: 25.0273,
    lng: 121.5708,
    checkinRadiusM: 300,
  ),
];

Widget _mapWith({required List<dynamic> overrides}) {
  return ProviderScope(
    // Riverpod 3 預設對失敗 provider 自動重試，測試中關閉以取得確定性行為
    retry: (_, _) => null,
    overrides: overrides.cast(),
    child: const MaterialApp(home: MapPage()),
  );
}

void main() {
  testWidgets('定位權限被拒絕：顯示說明與重試按鈕', (tester) async {
    await tester.pumpWidget(_mapWith(overrides: [
      spotsProvider.overrideWith((ref) async => _spots),
      positionStreamProvider.overrideWith(
        (ref) => Stream.error(const LocationDeniedException(forever: false)),
      ),
    ]));
    await tester.pumpAndSettle();

    expect(screenTextExists('打卡集章需要定位權限，才能判斷你是否抵達景點'), isTrue);
    expect(screenTextExists('重試'), isTrue);
    expect(screenTextExists('開啟設定'), isFalse);
  });

  testWidgets('定位權限被永久拒絕：顯示開啟設定按鈕', (tester) async {
    await tester.pumpWidget(_mapWith(overrides: [
      spotsProvider.overrideWith((ref) async => _spots),
      positionStreamProvider.overrideWith(
        (ref) => Stream.error(const LocationDeniedException(forever: true)),
      ),
    ]));
    await tester.pumpAndSettle();

    expect(screenTextExists('定位權限已被永久拒絕，請到系統設定開啟後回來打卡'), isTrue);
    expect(screenTextExists('開啟設定'), isTrue);
  });

  testWidgets('景點資料載入失敗：顯示重試按鈕', (tester) async {
    await tester.pumpWidget(_mapWith(overrides: [
      spotsProvider.overrideWith((ref) async => throw Exception('network')),
      positionStreamProvider.overrideWith((ref) => const Stream.empty()),
    ]));
    await tester.pumpAndSettle();

    expect(screenTextExists('無法載入景點資料'), isTrue);
  });

  testWidgets('定位失敗（非權限問題）：顯示無法取得定位', (tester) async {
    await tester.pumpWidget(_mapWith(overrides: [
      spotsProvider.overrideWith((ref) async => _spots),
      positionStreamProvider.overrideWith(
        (ref) => Stream.error(Exception('gps hardware error')),
      ),
    ]));
    await tester.pumpAndSettle();

    expect(screenTextExists('無法取得定位'), isTrue);
  });

  testWidgets('資料載入中：顯示進度指示', (tester) async {
    await tester.pumpWidget(_mapWith(overrides: [
      spotsProvider.overrideWith((ref) => Completer<List<Spot>>().future),
      positionStreamProvider.overrideWith((ref) => const Stream.empty()),
    ]));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('定位與景點皆就緒：顯示集章進度列（不等地圖圖磚網路載入）', (tester) async {
    final position = Position(
      latitude: 25.0273,
      longitude: 121.5708,
      timestamp: DateTime(2026, 7, 20),
      accuracy: 5,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
    await tester.pumpWidget(_mapWith(overrides: [
      spotsProvider.overrideWith((ref) async => _spots),
      positionStreamProvider.overrideWith((ref) => Stream.value(position)),
    ]));
    // 只 pump 固定次數，不用 pumpAndSettle——TileLayer 會嘗試打真實網路
    // 抓地圖圖磚，pumpAndSettle 會為了等那個永遠不會「settle」的請求卡住。
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(screenTextExists('已集 0 / 1 枚・目標 6 枚'), isTrue);
  });
}

bool screenTextExists(String text) {
  return find.text(text).evaluate().isNotEmpty;
}
