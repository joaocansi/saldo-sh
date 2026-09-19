import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Core colors of the saldo.sh identity.
abstract final class SaldoBrandColors {
  static const graphite = Color(0xff171B20);
  static const amber = Color(0xffE9B45C);
  static const ivory = Color(0xffF3F1E9);
  static const sage = Color(0xffADBBAE);
}

/// Paints the same completed symbol used by [SaldoMark].
///
/// Launcher assets use this entry point so the installed icon and the in-app
/// mark always share the same geometry.
void paintSaldoMarkAsset(
  Canvas canvas,
  double size, {
  bool showBackground = true,
  bool monochrome = false,
}) {
  if (showBackground) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size, size),
        Radius.circular(size * .22),
      ),
      Paint()..color = SaldoBrandColors.graphite,
    );
  }

  if (monochrome) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size, size), Paint());
    _paintCrescent(canvas, size, Colors.white);
    _paintCoin(canvas, size, Colors.white);
    _paintPrompt(canvas, size, Colors.transparent, clear: true);
    canvas.restore();
    return;
  }

  _paintCrescent(canvas, size, SaldoBrandColors.amber);
  _paintCoin(canvas, size, SaldoBrandColors.amber);
  _paintPrompt(canvas, size, SaldoBrandColors.graphite);
}

class SaldoMark extends StatelessWidget {
  const SaldoMark({
    super.key,
    this.size = 40,
    this.progress = 1,
    this.showEntrancePath = false,
    this.showBackground = true,
  });

  final double size;
  final double progress;
  final bool showEntrancePath;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    final value = progress.clamp(0.0, 1.0);
    return Semantics(
      image: true,
      label: 'Logo saldo.sh',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: showBackground ? SaldoBrandColors.graphite : null,
          borderRadius: BorderRadius.circular(size * .22),
        ),
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            clipBehavior: showEntrancePath ? Clip.none : Clip.hardEdge,
            children: [
              _AnimatedMarkPart(
                key: const ValueKey('saldo-crescent'),
                size: size,
                entrance: _interval(value, 0, .30),
                startOffset: Offset(-size * 1.2, size * .35),
                startRotation: -math.pi * .65,
                painter: const _CrescentPainter(),
              ),
              _AnimatedMarkPart(
                key: const ValueKey('saldo-coin'),
                size: size,
                entrance: _interval(value, .25, .58),
                startOffset: Offset(size * 1.25, -size * .12),
                startRotation: math.pi * .55,
                painter: const _CoinPainter(),
              ),
              _AnimatedMarkPart(
                key: const ValueKey('saldo-prompt'),
                size: size,
                entrance: _interval(value, .56, .78),
                startOffset: Offset(0, size * .55),
                startRotation: 0,
                painter: const _PromptPainter(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static double _interval(double value, double start, double end) => Curves
      .easeInOutCubic
      .transform(((value - start) / (end - start)).clamp(0, 1));
}

/// Text signature used beside or below [SaldoMark].
class SaldoWordmark extends StatelessWidget {
  const SaldoWordmark({
    super.key,
    this.fontSize = 20,
    this.color,
  });

  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: const [
        TextSpan(text: 'saldo'),
        TextSpan(
          text: '.sh',
          style: TextStyle(color: SaldoBrandColors.amber),
        ),
      ],
    ),
    maxLines: 1,
    style: TextStyle(
      color: color ?? Theme.of(context).colorScheme.onSurface,
      fontFamily: 'monospace',
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: -fontSize * .055,
    ),
  );
}

class _AnimatedMarkPart extends StatelessWidget {
  const _AnimatedMarkPart({
    super.key,
    required this.size,
    required this.entrance,
    required this.startOffset,
    required this.startRotation,
    required this.painter,
  });

  final double size;
  final double entrance;
  final Offset startOffset;
  final double startRotation;
  final CustomPainter painter;

  @override
  Widget build(BuildContext context) => Transform.translate(
    offset: Offset.lerp(startOffset, Offset.zero, entrance)!,
    child: Transform.rotate(
      angle: startRotation * (1 - entrance),
      child: Transform.scale(
        scale: .35 + entrance * .65,
        child: Opacity(
          opacity: entrance,
          child: CustomPaint(size: Size.square(size), painter: painter),
        ),
      ),
    ),
  );
}

class _CrescentPainter extends CustomPainter {
  const _CrescentPainter();

  @override
  void paint(Canvas canvas, Size size) =>
      _paintCrescent(canvas, size.width, SaldoBrandColors.amber);

  @override
  bool shouldRepaint(covariant _CrescentPainter oldDelegate) => false;
}

class _CoinPainter extends CustomPainter {
  const _CoinPainter();

  @override
  void paint(Canvas canvas, Size size) =>
      _paintCoin(canvas, size.width, SaldoBrandColors.amber);

  @override
  bool shouldRepaint(covariant _CoinPainter oldDelegate) => false;
}

class _PromptPainter extends CustomPainter {
  const _PromptPainter();

  @override
  void paint(Canvas canvas, Size size) =>
      _paintPrompt(canvas, size.width, SaldoBrandColors.graphite);

  @override
  bool shouldRepaint(covariant _PromptPainter oldDelegate) => false;
}

void _paintCrescent(Canvas canvas, double size, Color color) {
  final outer = Path()
    ..addOval(
      Rect.fromCircle(
        center: Offset(size * .45, size * .54),
        radius: size * .30,
      ),
    );
  final inner = Path()
    ..addOval(
      Rect.fromCircle(
        center: Offset(size * .52, size * .46),
        radius: size * .28,
      ),
    );
  final crescent = Path.combine(PathOperation.difference, outer, inner);
  canvas.drawPath(crescent, Paint()..color = color);
}

void _paintCoin(Canvas canvas, double size, Color color) {
  canvas.drawCircle(
    Offset(size * .55, size * .45),
    size * .27,
    Paint()..color = color,
  );
}

void _paintPrompt(
  Canvas canvas,
  double size,
  Color color, {
  bool clear = false,
}) {
  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = size * .052
    ..strokeCap = StrokeCap.square
    ..strokeJoin = StrokeJoin.miter;
  if (clear) paint.blendMode = BlendMode.clear;

  final chevron = Path()
    ..moveTo(size * .43, size * .36)
    ..lineTo(size * .52, size * .44)
    ..lineTo(size * .43, size * .52);
  canvas.drawPath(chevron, paint);
  canvas.drawLine(
    Offset(size * .56, size * .52),
    Offset(size * .68, size * .52),
    paint,
  );
}
