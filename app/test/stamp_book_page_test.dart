import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:checkin_go/checkin/stamps.dart';
import 'package:checkin_go/models.dart';
import 'package:checkin_go/pages/stamp_book_page.dart';
import 'package:checkin_go/providers.dart';

const _spots = [
  Spot(
    id: 'xiangshan-trail',
    name: '象山親山步道',
    city: '台北市',
    description: '',
    tags: [],
    lat: 25.0273,
    lng: 121.5708,
    checkinRadiusM: 300,
  ),
  Spot(
    id: 'jiufen-old-street',
    name: '九份老街',
    city: '新北市',
    description: '',
    tags: [],
    lat: 25.1097,
    lng: 121.845,
    checkinRadiusM: 300,
  ),
];

Widget _bookWith({required List<String> collectedIds}) {
  SharedPreferences.setMockInitialValues({
    StampsNotifier.storageKey: collectedIds,
  });
  return ProviderScope(
    retry: (_, _) => null,
    overrides: [
      spotsProvider.overrideWith((ref) async => _spots),
    ],
    child: const MaterialApp(home: StampBookPage()),
  );
}

void main() {
  testWidgets('尚未集章：全部顯示為未集狀態，進度為 0', (tester) async {
    await tester.pumpWidget(_bookWith(collectedIds: const []));
    await tester.pumpAndSettle();

    expect(find.text('已集 0 / 2 枚'), findsOneWidget);
    expect(find.text('象山親山步道'), findsOneWidget);
    expect(find.text('九份老街'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsNothing);
  });

  testWidgets('部分集章：進度反映已集數量，已集景點顯示勾勾', (tester) async {
    await tester.pumpWidget(
      _bookWith(collectedIds: const ['xiangshan-trail']),
    );
    await tester.pumpAndSettle();

    expect(find.text('已集 1 / 2 枚'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('集滿目標枚數：顯示環島達人解鎖文案', (tester) async {
    // stampGoal 固定為 6，需準備滿 6 個景點並全數集滿才會顯示解鎖文案
    final sixSpots = List.generate(
      6,
      (i) => Spot(
        id: 'spot-$i',
        name: '景點$i',
        city: '測試市',
        description: '',
        tags: const [],
        lat: 0,
        lng: 0,
        checkinRadiusM: 100,
      ),
    );
    SharedPreferences.setMockInitialValues({
      StampsNotifier.storageKey: sixSpots.map((s) => s.id).toList(),
    });
    await tester.pumpWidget(ProviderScope(
      retry: (_, _) => null,
      overrides: [spotsProvider.overrideWith((ref) async => sixSpots)],
      child: const MaterialApp(home: StampBookPage()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('已集 6 / 6 枚'), findsOneWidget);
    expect(find.textContaining('環島達人已解鎖'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsNWidgets(6));
  });
}
