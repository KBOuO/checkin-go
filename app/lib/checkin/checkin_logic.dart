import 'package:geolocator/geolocator.dart';

import '../models.dart';

/// 距離與打卡判定：純函式（haversine），不經平台通道，可直接單元測試。
double distanceToSpotM({
  required double lat,
  required double lng,
  required Spot spot,
}) {
  return Geolocator.distanceBetween(lat, lng, spot.lat, spot.lng);
}

bool canCheckIn({
  required double lat,
  required double lng,
  required Spot spot,
}) {
  return distanceToSpotM(lat: lat, lng: lng, spot: spot) <=
      spot.checkinRadiusM;
}

String formatDistance(double meters) {
  if (meters < 1000) return '${meters.round()} 公尺';
  return '${(meters / 1000).toStringAsFixed(1)} 公里';
}
