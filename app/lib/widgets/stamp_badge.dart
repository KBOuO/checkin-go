import 'dart:math';

import 'package:flutter/material.dart';

/// 印章圖形：自訂繪製，不依賴外部圖片素材。
///
/// 圓周疊加隨機抖動製造粗糙邊緣、雙層疊印模擬蓋章力道不均，
/// 呼應本專案「零素材、程式生成視覺」的一貫風格（web 端 SVG/漸層、
/// space-shooter 的程式化音效與繪圖）。
class StampPainter extends CustomPainter {
  const StampPainter({required this.color, required this.seed});

  final Color color;

  /// 決定粗糙邊緣抖動的種子；同一顆印章（同一 [seed]）每次繪製結果一致，
  /// 不會在重新渲染時跳動——用呼叫端穩定的景點索引即可，不用時間戳記等易變值。
  final int seed;

  static const _notches = 24;
  static const _jitterFraction = 0.06;

  Path _roughCircle(Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final rnd = Random(seed);
    final path = Path();
    for (var i = 0; i <= _notches; i++) {
      final angle = (i / _notches) * 2 * pi;
      final jitter = 1.0 + (rnd.nextDouble() - 0.5) * _jitterFraction;
      final point = center + Offset(cos(angle), sin(angle)) * radius * jitter;
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _roughCircle(size);
    final radius = size.shortestSide / 2;

    canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.12));

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.11
      ..color = color.withValues(alpha: 0.9);
    canvas.drawPath(path, ringPaint);

    // 雙層疊印：位移一點再疊一次淡色描邊，模擬手蓋印章力道不均的重疊感
    canvas.save();
    canvas.translate(radius * 0.05, -radius * 0.04);
    canvas.drawPath(
      path,
      ringPaint
        ..color = color.withValues(alpha: 0.35)
        ..strokeWidth = radius * 0.07,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant StampPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.seed != seed;
}

/// 一枚完整印章：粗糙圓形 + 置中圖示/文字，固定但看似隨機的傾斜角度。
///
/// 傾斜角度由 [index] 決定式計算——集章護照頁的多顆印章因此看起來
/// 像不同時間手動蓋上去的，卻不是每次 rebuild 就換一個角度。
class StampBadge extends StatelessWidget {
  const StampBadge({
    super.key,
    required this.index,
    required this.collected,
    required this.label,
    this.size = 72,
    this.color = const Color(0xFFF97316),
  });

  final int index;
  final bool collected;
  final String label;
  final double size;
  final Color color;

  double get _tiltDegrees => ((index * 37) % 30 - 15).toDouble();

  @override
  Widget build(BuildContext context) {
    final effectiveColor = collected ? color : Colors.blueGrey.shade300;
    return Opacity(
      opacity: collected ? 1 : 0.45,
      child: Transform.rotate(
        angle: _tiltDegrees * pi / 180,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: StampPainter(color: effectiveColor, seed: index),
            child: Center(
              child: collected
                  ? Icon(Icons.check_rounded,
                      color: effectiveColor, size: size * 0.4)
                  : Text(
                      '${index + 1}'.padLeft(2, '0'),
                      style: TextStyle(
                        color: effectiveColor,
                        fontWeight: FontWeight.w900,
                        fontSize: size * 0.24,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
