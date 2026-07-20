import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// 權限被拒（可重試）與永久拒絕（需開設定）由 UI 分流處理。
class LocationDeniedException implements Exception {
  const LocationDeniedException({required this.forever});
  final bool forever;
}

final locationPermissionProvider =
    FutureProvider<LocationPermission>((ref) async {
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  return permission;
});

final positionStreamProvider = StreamProvider<Position>((ref) async* {
  final permission = await ref.watch(locationPermissionProvider.future);
  if (permission == LocationPermission.denied) {
    throw const LocationDeniedException(forever: false);
  }
  if (permission == LocationPermission.deniedForever) {
    throw const LocationDeniedException(forever: true);
  }
  // stream 需要位移才會發事件，先給一筆目前位置避免地圖空等
  yield await Geolocator.getCurrentPosition();
  yield* Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    ),
  );
});
