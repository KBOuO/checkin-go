import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'pages/home_page.dart';
import 'pages/webview_page.dart';

void main() {
  runApp(const ProviderScope(child: CheckinGoApp()));
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
    if (_index == 1 && _webController != null) {
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
              icon: Icon(Icons.public),
              label: '活動網頁',
            ),
          ],
        ),
      ),
    );
  }
}
