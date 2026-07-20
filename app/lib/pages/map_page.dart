import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../analytics/analytics_service.dart';
import '../checkin/checkin_logic.dart';
import '../checkin/location.dart';
import '../checkin/stamps.dart';
import '../models.dart';
import '../providers.dart';

const _stampGoal = 6;

class MapPage extends ConsumerWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spots = ref.watch(spotsProvider);
    final position = ref.watch(positionStreamProvider);

    Widget body;
    final locationError = position.error;
    if (locationError is LocationDeniedException) {
      body = _PermissionView(
        forever: locationError.forever,
        onRetry: () {
          ref.invalidate(locationPermissionProvider);
          ref.invalidate(positionStreamProvider);
        },
      );
    } else if (spots.hasError) {
      body = _MessageView(
        icon: Icons.wifi_off,
        message: '無法載入景點資料',
        actionLabel: '重試',
        onAction: () => ref.invalidate(spotsProvider),
      );
    } else if (spots.isLoading || position.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (position.hasError) {
      body = _MessageView(
        icon: Icons.location_off,
        message: '無法取得定位',
        actionLabel: '重試',
        onAction: () => ref.invalidate(positionStreamProvider),
      );
    } else {
      body = _CheckinMap(
        spots: spots.requireValue,
        position: position.requireValue,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('地圖打卡',
            style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: body,
    );
  }
}

class _CheckinMap extends ConsumerWidget {
  const _CheckinMap({required this.spots, required this.position});

  final List<Spot> spots;
  final Position position;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stamps = ref.watch(stampsProvider).value ?? const <String>{};

    return Stack(
      children: [
        FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(23.7, 121.0),
            initialZoom: 7.2,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.checkingo.checkin_go',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(position.latitude, position.longitude),
                  width: 20,
                  height: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.shade600,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ),
                for (final (i, spot) in spots.indexed)
                  Marker(
                    point: LatLng(spot.lat, spot.lng),
                    width: 40,
                    height: 40,
                    child: _SpotMarker(
                      index: i,
                      collected: stamps.contains(spot.id),
                      onTap: () => _showSpotSheet(context, spot),
                    ),
                  ),
              ],
            ),
          ],
        ),
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.approval, color: Color(0xFFF97316)),
                  const SizedBox(width: 8),
                  Text(
                    '已集 ${stamps.length} / ${spots.length} 枚・目標 $_stampGoal 枚',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showSpotSheet(BuildContext context, Spot spot) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => _SpotSheet(spot: spot),
    );
  }
}

class _SpotMarker extends StatelessWidget {
  const _SpotMarker({
    required this.index,
    required this.collected,
    required this.onTap,
  });

  final int index;
  final bool collected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: collected ? const Color(0xFFF97316) : Colors.white,
          border: Border.all(
            color: collected ? Colors.white : const Color(0xFF0E7490),
            width: 2.5,
          ),
          boxShadow: const [
            BoxShadow(blurRadius: 4, color: Colors.black26),
          ],
        ),
        alignment: Alignment.center,
        child: collected
            ? const Icon(Icons.check, color: Colors.white, size: 22)
            : Text(
                '${index + 1}'.padLeft(2, '0'),
                style: const TextStyle(
                  color: Color(0xFF0E7490),
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }
}

/// Consumer：sheet 開啟中位置/集章變動時，距離與按鈕即時更新
class _SpotSheet extends ConsumerWidget {
  const _SpotSheet({required this.spot});

  final Spot spot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(positionStreamProvider).value;
    final stamps = ref.watch(stampsProvider).value ?? const <String>{};
    final collected = stamps.contains(spot.id);

    final distance = position == null
        ? null
        : distanceToSpotM(
            lat: position.latitude, lng: position.longitude, spot: spot);
    final inRange = position != null &&
        canCheckIn(lat: position.latitude, lng: position.longitude, spot: spot);

    final String statusText;
    if (collected) {
      statusText = '已蒐集這枚印章！';
    } else if (distance == null) {
      statusText = '定位中…';
    } else if (inRange) {
      statusText = '距離 ${formatDistance(distance)}——在打卡範圍內！';
    } else {
      statusText =
          '距離 ${formatDistance(distance)}，需進入 ${spot.checkinRadiusM} 公尺範圍';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  spot.name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w900),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFEFF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  spot.city,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF155E75),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            spot.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.blueGrey.shade700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                collected ? Icons.verified : Icons.place,
                size: 18,
                color: collected
                    ? const Color(0xFFF97316)
                    : const Color(0xFF0E7490),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  statusText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (collected || !inRange)
                  ? null
                  : () async {
                      await ref
                          .read(stampsProvider.notifier)
                          .collect(spot.id);
                      final analytics = ref.read(analyticsServiceProvider);
                      await analytics.logCheckinSuccess(
                        spotId: spot.id,
                        city: spot.city,
                      );
                      // 集章數剛好等於目標值代表「這次打卡」使其達標——
                      // Set 每次最多 +1，這個相等判定只會在跨過門檻那一刻成立一次
                      final updatedStamps =
                          await ref.read(stampsProvider.future);
                      if (updatedStamps.length == _stampGoal) {
                        await analytics.logStampGoalReached();
                      }
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('「${spot.name}」打卡成功，集章 +1！'),
                          ),
                        );
                      }
                    },
              icon: Icon(collected ? Icons.check : Icons.approval),
              label: Text(collected ? '已集章' : 'GPS 打卡蓋章'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionView extends StatelessWidget {
  const _PermissionView({required this.forever, required this.onRetry});

  final bool forever;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _MessageView(
      icon: Icons.location_off,
      message: forever
          ? '定位權限已被永久拒絕，請到系統設定開啟後回來打卡'
          : '打卡集章需要定位權限，才能判斷你是否抵達景點',
      actionLabel: forever ? '開啟設定' : '重試',
      onAction: forever ? Geolocator.openAppSettings : onRetry,
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
