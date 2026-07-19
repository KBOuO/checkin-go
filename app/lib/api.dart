import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';
import 'models.dart';

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => 'ApiException: $message';
}

class MarketingApi {
  MarketingApi({http.Client? client, this.baseUrl = AppConfig.apiBaseUrl})
      : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  // FastAPI 的 Content-Type 未帶 charset，http 套件會 fallback 到 latin1，
  // 一律用 bodyBytes 以 UTF-8 解碼避免中文亂碼
  Future<dynamic> _getJson(String path) async {
    final res = await _client.get(Uri.parse('$baseUrl$path'));
    if (res.statusCode != 200) {
      throw ApiException('GET $path -> ${res.statusCode}');
    }
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  Future<List<Spot>> fetchSpots() async {
    final data = await _getJson('/api/spots') as List;
    return data
        .map((e) => Spot.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<Campaign> fetchCurrentCampaign() async {
    final data = await _getJson('/api/campaigns/current');
    return Campaign.fromJson(data as Map<String, dynamic>);
  }
}
