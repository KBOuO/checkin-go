import 'package:flutter_test/flutter_test.dart';

import 'package:checkin_go/analytics/remote_config_service.dart';

void main() {
  test('NoopRemoteConfigService 回傳預設 control', () async {
    const service = NoopRemoteConfigService();
    expect(await service.fetchHeroSloganVariant(), heroSloganVariantDefault);
    expect(heroSloganVariantDefault, 'control');
  });

  test('heroSloganVariants 涵蓋 control 與 variant_b 兩版文案', () {
    expect(heroSloganVariants.containsKey('control'), isTrue);
    expect(heroSloganVariants.containsKey('variant_b'), isTrue);
    expect(heroSloganVariants['control'], isNot(heroSloganVariants['variant_b']));
  });
}
