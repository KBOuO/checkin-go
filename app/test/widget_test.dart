import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checkin_go/models.dart';
import 'package:checkin_go/pages/home_page.dart';
import 'package:checkin_go/providers.dart';

final _fakeCampaign = Campaign(
  id: 'island-stamp-2026',
  title: '島嶼打卡季',
  slogan: '集滿島嶼的印章，換一個夏天的故事',
  description: 'demo',
  startsAt: DateTime.utc(2026, 6, 1),
  endsAt: DateTime.utc(2026, 9, 30),
  stampGoal: 6,
  reward: '限定徽章',
  spotIds: const ['xiangshan-trail'],
);

const _fakeSpots = [
  Spot(
    id: 'xiangshan-trail',
    name: '象山親山步道',
    city: '台北市',
    description: '20 分鐘登頂看 101。',
    tags: ['城市夜景', '步道'],
    lat: 25.0273,
    lng: 121.5708,
    checkinRadiusM: 300,
  ),
  Spot(
    id: 'sanxiantai',
    name: '三仙台',
    city: '台東縣',
    description: '八拱跨海步橋。',
    tags: ['跨海橋'],
    lat: 23.1237,
    lng: 121.4103,
    checkinRadiusM: 400,
  ),
];

Widget _homeWith({required List<dynamic> overrides}) {
  return ProviderScope(
    // Riverpod 3 預設對失敗 provider 自動重試，測試中關閉以取得確定性行為
    retry: (retryCount, error) => null,
    overrides: overrides.cast(),
    child: const MaterialApp(home: HomePage()),
  );
}

void main() {
  testWidgets('首頁渲染活動橫幅與景點列表', (tester) async {
    await tester.pumpWidget(_homeWith(overrides: [
      campaignProvider.overrideWith((ref) async => _fakeCampaign),
      spotsProvider.overrideWith((ref) async => _fakeSpots),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('島嶼打卡季'), findsOneWidget);
    expect(find.text('集滿島嶼的印章，換一個夏天的故事'), findsOneWidget);
    expect(find.text('精選景點 × 2'), findsOneWidget);
    expect(find.text('象山親山步道'), findsOneWidget);
    expect(find.text('三仙台'), findsOneWidget);
    expect(find.text('台北市'), findsOneWidget);
  });

  testWidgets('API 失敗顯示錯誤與重試，按重試後重新載入成功', (tester) async {
    var attempts = 0;
    await tester.pumpWidget(_homeWith(overrides: [
      campaignProvider.overrideWith((ref) async {
        attempts++;
        if (attempts == 1) throw Exception('network down');
        return _fakeCampaign;
      }),
      spotsProvider.overrideWith((ref) async => _fakeSpots),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('無法連線到活動伺服器'), findsOneWidget);
    expect(find.text('重試'), findsOneWidget);
    expect(find.text('島嶼打卡季'), findsNothing);

    await tester.tap(find.text('重試'));
    await tester.pumpAndSettle();

    expect(find.text('島嶼打卡季'), findsOneWidget);
    expect(find.text('無法連線到活動伺服器'), findsNothing);
  });
}
