import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models.dart';
import '../providers.dart';

const _cardGradients = [
  [Color(0xFF0891B2), Color(0xFF38BDF8)],
  [Color(0xFFF97316), Color(0xFFFBBF24)],
  [Color(0xFF059669), Color(0xFF2DD4BF)],
  [Color(0xFF7C3AED), Color(0xFFE879F9)],
];

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaign = ref.watch(campaignProvider);
    final spots = ref.watch(spotsProvider);

    final hasError = campaign.hasError || spots.hasError;
    final isLoading = campaign.isLoading || spots.isLoading;

    Widget body;
    if (hasError) {
      body = _ErrorView(
        onRetry: () {
          ref.invalidate(campaignProvider);
          ref.invalidate(spotsProvider);
        },
      );
    } else if (isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(campaignProvider);
          ref.invalidate(spotsProvider);
          await Future.wait([
            ref.read(campaignProvider.future),
            ref.read(spotsProvider.future),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _CampaignBanner(campaign: campaign.requireValue),
            const SizedBox(height: 20),
            Text(
              '精選景點 × ${spots.requireValue.length}',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            for (final (i, spot) in spots.requireValue.indexed)
              _SpotCard(spot: spot, index: i),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('打卡趣 CheckinGo',
            style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: body,
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('無法連線到活動伺服器'),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('重試')),
        ],
      ),
    );
  }
}

class _CampaignBanner extends StatelessWidget {
  const _CampaignBanner({required this.campaign});

  final Campaign campaign;

  String _date(DateTime d) => '${d.year}/${d.month}/${d.day}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF062A38), Color(0xFF0E7490), Color(0xFF22B8CF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFFDBA74)),
              color: const Color(0x33F97316),
            ),
            child: const Text(
              '2026 夏季限定活動',
              style: TextStyle(color: Color(0xFFFED7AA), fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            campaign.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            campaign.slogan,
            style: const TextStyle(color: Color(0xFFCFFAFE), fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text(
            '${_date(campaign.startsAt)} — ${_date(campaign.endsAt)}'
            '・集滿 ${campaign.stampGoal} 枚換獎勵',
            style: const TextStyle(color: Color(0xFFA5F3FC), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SpotCard extends StatelessWidget {
  const _SpotCard({required this.spot, required this.index});

  final Spot spot;
  final int index;

  @override
  Widget build(BuildContext context) {
    final gradient = _cardGradients[index % _cardGradients.length];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: gradient),
              ),
              child: Text(
                '${index + 1}'.padLeft(2, '0'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          spot.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFEFF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          spot.city,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF155E75),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    spot.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blueGrey.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (final tag in spot.tags)
                        Text(
                          '#$tag',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF0E7490),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
