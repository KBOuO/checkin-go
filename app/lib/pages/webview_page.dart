import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../config.dart';

/// 嵌入 React 行銷活動頁（職缺重點：WebView 將行銷網頁嵌入 App）
class WebviewPage extends StatefulWidget {
  const WebviewPage({super.key, this.onControllerReady});

  /// AppShell 需要 controller 處理系統返回鍵（WebView 歷史優先）
  final ValueChanged<WebViewController>? onControllerReady;

  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => setState(() => _progress = p),
          onPageStarted: (_) => setState(() => _failed = false),
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? true) {
              setState(() => _failed = true);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(AppConfig.webUrl));
    widget.onControllerReady?.call(_controller);
  }

  void _reload() {
    setState(() {
      _failed = false;
      _progress = 0;
    });
    _controller.loadRequest(Uri.parse(AppConfig.webUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('島嶼打卡季',
            style: TextStyle(fontWeight: FontWeight.w900)),
        bottom: (_progress < 100 && !_failed)
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(value: _progress / 100),
              )
            : null,
      ),
      body: _failed
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('活動頁載入失敗，請檢查網路'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _reload,
                    child: const Text('重新載入'),
                  ),
                ],
              ),
            )
          : WebViewWidget(controller: _controller),
    );
  }
}
