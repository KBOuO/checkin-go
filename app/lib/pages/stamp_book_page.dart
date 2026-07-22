import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../checkin/stamps.dart';
import '../models.dart';
import '../providers.dart';
import '../widgets/stamp_badge.dart';

const _stampGoal = 6;

/// 集章護照：以圖鑑格狀呈現全部景點的集章成果，從地圖頁的進度卡片點擊進入。
class StampBookPage extends ConsumerWidget {
  const StampBookPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spots = ref.watch(spotsProvider);
    final stamps = ref.watch(stampsProvider);

    Widget body;
    if (spots.hasError || stamps.hasError) {
      body = const Center(child: Text('無法載入集章資料，請稍後再試'));
    } else if (spots.isLoading || stamps.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = _StampGrid(
        spots: spots.requireValue,
        collectedIds: stamps.requireValue,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('集章護照',
            style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: body,
    );
  }
}

class _StampGrid extends StatelessWidget {
  const _StampGrid({required this.spots, required this.collectedIds});

  final List<Spot> spots;
  final Set<String> collectedIds;

  @override
  Widget build(BuildContext context) {
    final collectedCount =
        spots.where((s) => collectedIds.contains(s.id)).length;

    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF062A38), Color(0xFF0E7490)],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '已集 $collectedCount / ${spots.length} 枚',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              Text(
                collectedCount >= _stampGoal ? '環島達人已解鎖 🎉' : '目標 $_stampGoal 枚',
                style: const TextStyle(color: Color(0xFFA5F3FC)),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 8,
              childAspectRatio: 0.78,
            ),
            itemCount: spots.length,
            itemBuilder: (context, i) {
              final spot = spots[i];
              final collected = collectedIds.contains(spot.id);
              return Column(
                children: [
                  StampBadge(index: i, collected: collected, label: spot.name),
                  const SizedBox(height: 8),
                  Text(
                    spot.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: collected ? Colors.black87 : Colors.grey,
                    ),
                  ),
                  Text(
                    spot.city,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
