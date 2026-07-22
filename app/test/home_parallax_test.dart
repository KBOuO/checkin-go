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

// 12 個景點確保列表夠長、可以真的捲動出視差位移
final _fakeSpots = List.generate(
  12,
  (i) => Spot(
    id: 'spot-$i',
    name: '景點 $i',
    city: '測試市',
    description: '描述',
    tags: const ['標籤'],
    lat: 25.0,
    lng: 121.0,
    checkinRadiusM: 300,
  ),
);

double _bannerTranslateY(WidgetTester tester) {
  final transform = tester.widget<Transform>(
    find.byKey(const Key('homeBannerParallaxLayer')),
  );
  return transform.transform.getTranslation().y;
}

void main() {
  testWidgets('捲動景點列表時，橫幅背景層位移量隨捲動改變；捲回頂部後歸零',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      retry: (_, _) => null,
      overrides: [
        campaignProvider.overrideWith((ref) async => _fakeCampaign),
        spotsProvider.overrideWith((ref) async => _fakeSpots),
      ],
      child: const MaterialApp(home: HomePage()),
    ));
    await tester.pumpAndSettle();

    final initialY = _bannerTranslateY(tester);

    // 用 jumpTo 直接設定捲動位置（非模擬拖曳手勢），避免慣性/回彈動畫
    // 尚未 settle 時讀到不確定的中間值；位移量刻意保持在橫幅高度內，
    // 捲太遠橫幅會被 ListView 判定離開可視範圍而整個從樹上卸載
    // （Flutter Sliver 對 offscreen 子項的正常虛擬化行為，非本功能的 bug）。
    final scrollable =
        tester.state<ScrollableState>(find.byType(Scrollable).first);

    scrollable.position.jumpTo(60);
    await tester.pump();

    final scrolledY = _bannerTranslateY(tester);
    expect(scrolledY, isNot(equals(initialY)));

    scrollable.position.jumpTo(0);
    await tester.pump();

    expect(_bannerTranslateY(tester), equals(initialY));
  });
}
