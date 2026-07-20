import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'analytics/analytics_service.dart';
import 'analytics/remote_config_service.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/map_page.dart';
import 'pages/webview_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      // debug 秒抓最新值方便展示 A/B 切換；production 應設合理快取間隔
      minimumFetchInterval:
          kDebugMode ? Duration.zero : const Duration(hours: 1),
    ),
  );
  await remoteConfig.setDefaults({heroSloganVariantParam: heroSloganVariantDefault});

  runApp(
    ProviderScope(
      overrides: [
        analyticsServiceProvider.overrideWithValue(
          FirebaseAnalyticsService(FirebaseAnalytics.instance),
        ),
        remoteConfigServiceProvider.overrideWithValue(
          FirebaseRemoteConfigServiceImpl(remoteConfig),
        ),
      ],
      child: const CheckinGoApp(),
    ),
  );
}

class CheckinGoApp extends StatelessWidget {
  const CheckinGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '打卡趣',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0E7490),
          secondary: const Color(0xFFF97316),
        ),
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  WebViewController? _webController;

  Future<void> _handleBack() async {
    // WebView 頁籤：系統返回鍵先走 WebView 歷史
    if (_index == 2 && _webController != null) {
      if (await _webController!.canGoBack()) {
        await _webController!.goBack();
        return;
      }
    }
    await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        // IndexedStack：切換頁籤保留各頁狀態（捲動位置、WebView 歷史）
        body: IndexedStack(
          index: _index,
          children: [
            const HomePage(),
            const MapPage(),
            WebviewPage(
              onControllerReady: (c) => _webController = c,
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: '首頁',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: '地圖打卡',
            ),
            NavigationDestination(
              icon: Icon(Icons.public),
              label: '活動網頁',
            ),
          ],
        ),
      ),
    );
  }
}
