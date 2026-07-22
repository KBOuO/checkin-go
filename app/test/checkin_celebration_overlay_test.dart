import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checkin_go/widgets/checkin_celebration_overlay.dart';

Future<BuildContext> _pumpHost(WidgetTester tester) async {
  late BuildContext ctx;
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (context) {
        ctx = context;
        return const Scaffold(body: SizedBox.shrink());
      },
    ),
  ));
  return ctx;
}

void main() {
  testWidgets('一般打卡：顯示打卡成功文案與自訂印章繪製，動畫結束後自動消失',
      (tester) async {
    final context = await _pumpHost(tester);

    showCheckinCelebration(
      context,
      spotIndex: 0,
      spotName: '象山親山步道',
      goalReached: false,
    );
    await tester.pump();

    expect(find.textContaining('象山親山步道」打卡成功'), findsOneWidget);
    expect(find.textContaining('集滿了'), findsNothing);
    expect(find.byType(CustomPaint), findsWidgets);

    // 進場(550ms) + 停留(1100ms) + 退場(300ms) ≈ 1950ms，走完應自動移除
    await tester.pump(const Duration(milliseconds: 2000));

    expect(find.textContaining('打卡成功'), findsNothing);
  });

  testWidgets('達標打卡：顯示達標專屬文案而非一般文案，動畫結束後自動消失',
      (tester) async {
    final context = await _pumpHost(tester);

    showCheckinCelebration(
      context,
      spotIndex: 5,
      spotName: '阿里山國家森林遊樂區',
      goalReached: true,
    );
    await tester.pump();

    expect(find.textContaining('集滿了！環島達人解鎖'), findsOneWidget);
    expect(find.textContaining('阿里山國家森林遊樂區」打卡成功'), findsNothing);

    await tester.pump(const Duration(milliseconds: 2000));

    expect(find.textContaining('集滿了'), findsNothing);
  });
}
