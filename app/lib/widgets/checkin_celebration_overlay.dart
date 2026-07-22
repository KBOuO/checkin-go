import 'dart:async';

import 'package:flutter/material.dart';

import 'stamp_badge.dart';

/// 打卡成功的蓋章動畫：疊在畫面中央的 [OverlayEntry]，取代純文字 SnackBar。
///
/// 動畫由單一 [AnimationController]（[SingleTickerProviderStateMixin]）跑完
/// 整段「進場彈跳 → 停留 → 淡出」的時間軸（見 [_CelebrationOverlayState]），
/// 而非用 `Future.delayed` 銜接兩段獨立動畫——單一連續 ticker 才能讓
/// `AnimationStatus.completed` 可靠地標誌整段流程真正結束，overlay 隨即自動
/// 移除，呼叫端不需持有任何控制器或手動清理。
Future<void> showCheckinCelebration(
  BuildContext context, {
  required int spotIndex,
  required String spotName,
  required bool goalReached,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final completer = Completer<void>();
  late final OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _CelebrationOverlay(
      spotIndex: spotIndex,
      spotName: spotName,
      goalReached: goalReached,
      onFinished: () {
        entry.remove();
        if (!completer.isCompleted) completer.complete();
      },
    ),
  );
  overlay.insert(entry);
  return completer.future;
}

class _CelebrationOverlay extends StatefulWidget {
  const _CelebrationOverlay({
    required this.spotIndex,
    required this.spotName,
    required this.goalReached,
    required this.onFinished,
  });

  final int spotIndex;
  final String spotName;
  final bool goalReached;
  final VoidCallback onFinished;

  @override
  State<_CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<_CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  static const _totalDuration = Duration(milliseconds: 1900);

  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _totalDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onFinished();
      });

    // 時間軸切三段（權重＝佔總時長比例）：進場彈跳（elastic）／停留／淡出。
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.3, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 70),
    ]).animate(_controller);

    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 12,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 68),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              color: Colors.black.withValues(alpha: 0.35 * _opacity.value),
              alignment: Alignment.center,
              child: Opacity(
                opacity: _opacity.value,
                child: Transform.scale(scale: _scale.value, child: child),
              ),
            );
          },
          child: _CelebrationCard(
            spotIndex: widget.spotIndex,
            spotName: widget.spotName,
            goalReached: widget.goalReached,
          ),
        ),
      ),
    );
  }
}

class _CelebrationCard extends StatelessWidget {
  const _CelebrationCard({
    required this.spotIndex,
    required this.spotName,
    required this.goalReached,
  });

  final int spotIndex;
  final String spotName;
  final bool goalReached;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(blurRadius: 24, color: Colors.black38)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StampBadge(
            index: spotIndex,
            collected: true,
            label: spotName,
            size: 96,
            color: goalReached
                ? const Color(0xFFDC2626)
                : const Color(0xFFF97316),
          ),
          const SizedBox(height: 16),
          Text(
            goalReached ? '集滿了！環島達人解鎖 🎉' : '「$spotName」打卡成功！',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: Color(0xFF103649),
            ),
          ),
          if (goalReached) ...[
            const SizedBox(height: 4),
            const Text(
              '集章護照可以回顧全部足跡',
              style: TextStyle(color: Colors.blueGrey, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
