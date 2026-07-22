import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/analytics_service.dart';
import '../analytics/remote_config_service.dart';
import '../models.dart';
import '../providers.dart';

const _cardGradients = [
  [Color(0xFF0891B2), Color(0xFF38BDF8)],
  [Color(0xFFF97316), Color(0xFFFBBF24)],
  [Color(0xFF059669), Color(0xFF2DD4BF)],
  [Color(0xFF7C3AED), Color(0xFFE879F9)],
];

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

/// 視差位移上限（像素）：橫幅背景層預留這麼多緩衝高度供反向位移，
/// 超過此範圍鎖住不再增加，避免捲到底部時背景層跑出容器露出空白。
const _kParallaxMaxOffset = 36.0;

class _HomePageState extends ConsumerState<HomePage> {
  final _scrollController = ScrollController();
  double _parallax = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final next =
        (_scrollController.offset * 0.3).clamp(0.0, _kParallaxMaxOffset);
    if (next != _parallax) setState(() => _parallax = next);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final campaign = ref.watch(campaignProvider);
    final spots = ref.watch(spotsProvider);
    final heroVariant =
        ref.watch(heroSloganVariantProvider).value ?? heroSloganVariantDefault;

    ref.listen<AsyncValue<Campaign>>(campaignProvider, (previous, next) {
      if (next.hasValue) {
        ref.read(analyticsServiceProvider).logCampaignView();
      }
    });

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
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            _CampaignBanner(
              campaign: campaign.requireValue,
              sloganOverride: heroSloganVariants[heroVariant],
              parallax: _parallax,
            ),
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
  const _CampaignBanner({
    required this.campaign,
    this.sloganOverride,
    this.parallax = 0,
  });

  final Campaign campaign;
  /// Remote Config A/B 決定的標語文案；null（服務未就緒/無此 key）時退回 API 給的 campaign.slogan
  final String? sloganOverride;

  /// 捲動視差位移量（像素）：背景漸層層依此反向位移，文字內容層不動，
  /// 兩層速率不同即形成「背景跟得比較慢」的視差感。
  final double parallax;

  String _date(DateTime d) => '${d.year}/${d.month}/${d.day}';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          // 背景層：預留 _kParallaxMaxOffset 緩衝高度，隨捲動反向位移
          Positioned(
            top: -_kParallaxMaxOffset,
            left: 0,
            right: 0,
            height: 210 + _kParallaxMaxOffset * 2,
            child: Transform.translate(
              key: const Key('homeBannerParallaxLayer'),
              offset: Offset(0, _kParallaxMaxOffset - parallax),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF062A38),
                      Color(0xFF0E7490),
                      Color(0xFF22B8CF),
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.local_activity_outlined,
                    size: 140,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),
          ),
          // 前景內容層：不隨視差位移，固定貼齊容器
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
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
                  sloganOverride ?? campaign.slogan,
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
