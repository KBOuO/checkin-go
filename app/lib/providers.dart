import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api.dart';
import 'models.dart';

final marketingApiProvider = Provider<MarketingApi>((ref) => MarketingApi());

final campaignProvider = FutureProvider<Campaign>(
  (ref) => ref.watch(marketingApiProvider).fetchCurrentCampaign(),
);

final spotsProvider = FutureProvider<List<Spot>>(
  (ref) => ref.watch(marketingApiProvider).fetchSpots(),
);
