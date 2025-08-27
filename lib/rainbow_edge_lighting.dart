library rainbow_edge_lighting;

import 'dart:math';
import 'package:flutter/material.dart';

/// 첫/끝 색이 다르면 첫 색을 맨 뒤에 붙여 스윕 그라디언트의 이음새를 없앱니다.
List<Color> smoothLoop(List<Color> colors) {
  if (colors.isEmpty) return colors;
  final first = colors.first;
  final last  = colors.last;
  if (first.value == last.value) return colors;
  return [...colors, first];
}

/// 회전 무지개 테두리 + 같은 팔레트로 그린 주변 글로우
class RainbowEdgeLighting extends StatefulWidget {
  const RainbowEdgeLighting({
    super.key,
    required this.child,
    required this.radius,
    this.thickness = 3.0,
    this.colors,
    this.enabled = true,
    this.speed = 0.8, // rps
    this.fadeDuration = const Duration(milliseconds: 300),
    this.clip = false,
    this.showBorderWhenDisabled = true,
    this.disabledBorderColor = const Color(0x33000000),
    this.disabledBorderThickness,

    // Glow (같은 팔레트 사용)
    this.glowEnabled = false,

  });

  final Widget child;
  final double radius;
  final double thickness;
  final List<Color>? colors;
  final bool enabled;
  final double speed; // rotations per second
  final Duration fadeDuration;
  final bool clip;

  // 비활성 시 기본 테두리
  final bool showBorderWhenDisabled;
  final Color disabledBorderColor;
  final double? disabledBorderThickness;

  // Glow (동일 팔레트)
  final bool glowEnabled;


  @override
  State<RainbowEdgeLighting> createState() => _RainbowEdgeLightingState();
}

class _RainbowEdgeLightingState extends State<RainbowEdgeLighting>
    with TickerProviderStateMixin {
  late final AnimationController _spin;
  late final AnimationController _fade;
  late final Animation<double> _fadeAnim;

  final double glowOpacity = 0.75;
  final double glowBlurOuter = 25.0;
  final double glowBlurInner = 12.0;
  final double glowWidthOuter = 20.0;
  final double glowWidthInner= 12.0;
  final double glowOutset = 6.0;

  static const _defaults = <Color>[
    Colors.red, Colors.orange, Colors.yellow, Colors.green,
    Colors.blue, Colors.indigo, Colors.purple, Colors.red,
  ];

  Duration _dur(double rps) {
    if (rps <= 0) return const Duration(days: 3650);
    return Duration(milliseconds: (1000 / rps).round());
  }

  void _applySpin() {
    if (!widget.enabled || widget.speed <= 0) {
      _spin.stop();
      return;
    }
    final nd = _dur(widget.speed);
    if (_spin.duration != nd) _spin.duration = nd;
    if (!_spin.isAnimating) _spin.repeat();
  }

  void _applyFade({required bool animate}) {
    if (widget.enabled) {
      _applySpin();
      if (animate) {
        _fade.duration = widget.fadeDuration;
        _fade.forward();
      } else {
        _fade.value = 1.0;
      }
    } else {
      if (animate) {
        _fade.duration = widget.fadeDuration;
        _fade.reverse().whenComplete(() {
          if (mounted) _spin.stop();
        });
      } else {
        _fade.value = 0.0;
        _spin.stop();
      }
    }
  }

  BorderRadius get _br => BorderRadius.circular(widget.radius);

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(vsync: this, duration: _dur(widget.speed));
    _fade = AnimationController(vsync: this, value: widget.enabled ? 1.0 : 0.0);
    _fadeAnim = CurvedAnimation(parent: _fade, curve: Curves.easeInOut);
    _applySpin();
    _applyFade(animate: false);
  }

  @override
  void didUpdateWidget(covariant RainbowEdgeLighting old) {
    super.didUpdateWidget(old);
    if (old.speed != widget.speed || old.enabled != widget.enabled) {
      _applySpin();
      _applyFade(animate: true);
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.clip
        ? ClipRRect(borderRadius: _br, child: widget.child)
        : widget.child;

    final palette = smoothLoop(widget.colors ?? _defaults);

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_spin, _fadeAnim]),
        builder: (_, __) {
          final progress = _spin.value;
          final opacity = _fadeAnim.value;
          return CustomPaint(
            // 뒤: 같은 팔레트로 글로우
            painter: widget.glowEnabled
                ? _GlowPainter(
              progress: progress,
              opacity: opacity * glowOpacity,
              borderRadius: _br,
              colors: palette,
              blurOuter: glowBlurOuter,
              blurInner: glowBlurInner,
              widthOuter: glowWidthOuter,
              widthInner: glowWidthInner,
              outset: glowOutset,
            )
                : null,
            // 앞: 무지개 스트로크
            foregroundPainter: _RainbowPainter(
              progress: progress,
              opacity: opacity,
              thickness: widget.thickness,
              colors: palette,
              borderRadius: _br,
              showBaseWhenDisabled: widget.showBorderWhenDisabled,
              baseColor: widget.disabledBorderColor,
              baseThickness:
              widget.disabledBorderThickness ?? widget.thickness,
            ),
            child: child,
          );
        },
      ),
    );
  }
}
class _GlowPainter extends CustomPainter {
  _GlowPainter({
    required this.progress,
    required this.opacity,
    required this.borderRadius,
    required this.colors,     // stroke와 동일 팔레트
    required this.blurOuter,
    required this.blurInner,
    required this.widthOuter,
    required this.widthInner,
    required this.outset,
  });

  final double progress;   // 0..1
  final double opacity;    // 0..1
  final BorderRadius borderRadius;
  final List<Color> colors;
  final double blurOuter;
  final double blurInner;
  final double widthOuter;
  final double widthInner;
  final double outset;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final rect = Offset.zero & size;

    // ✔ radius 반영 + 바깥으로 퍼지게
// 교체 (퍼짐 중심을 덜 바깥으로)
    final glowRRect = borderRadius.toRRect(
      rect.inflate(outset - widthOuter * 0.25).deflate(widthInner * 0.1),
    );
    // ✔ 회전 스윕 그라디언트 (AuroraPainter와 동일한 원리)
    Shader sweep() => SweepGradient(
      startAngle: 0,
      endAngle: 2 * pi,
      colors: colors,
      // 원한다면 일정 간격 스톱 추가 가능: stops: const [0, .25, .5, .75, 1],
      transform: GradientRotation(progress * 2 * pi),
    ).createShader(rect);

    // 1층: 넓고 부드러운 글로우
    final glowPaint1 = Paint()
      ..shader = sweep()
      ..style = PaintingStyle.stroke
      ..strokeWidth = widthOuter * 0.9   // ← 두께 절반
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurOuter * 0.9) // ← 블러 40%
      ..isAntiAlias = true
      ..colorFilter = ColorFilter.mode(
        Colors.white.withValues(alpha: opacity * 0.30),   // ← 0.75 → 0.50
        BlendMode.modulate,
      )
      ..blendMode = BlendMode.srcOver;

    // ✅ 먼저 1층 글로우
    canvas.drawRRect(glowRRect, glowPaint1);

    // 2층: 조금 좁고 덜 흐린 글로우 (깊이감)
    final glowPaint2 = Paint()
      ..shader = sweep()
      ..style = PaintingStyle.stroke
      ..strokeWidth = widthInner
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurOuter * 0.2) // ← 블러 40%
      ..isAntiAlias = true
      ..colorFilter = ColorFilter.mode(
        Colors.white.withValues(alpha: opacity * 1),
        BlendMode.modulate,
      )
      ..blendMode = BlendMode.srcOver;

    canvas.drawRRect(glowRRect, glowPaint2);

  }

  @override
  bool shouldRepaint(covariant _GlowPainter old) =>
      old.progress != progress ||
          old.opacity  != opacity  ||
          old.borderRadius != borderRadius ||
          old.colors != colors ||
          old.blurOuter != blurOuter ||
          old.blurInner != blurInner ||
          old.widthOuter != widthOuter ||
          old.widthInner != widthInner ||
          old.outset != outset;
}

class _RainbowPainter extends CustomPainter {
  _RainbowPainter({
    required this.progress,
    required this.opacity,
    required this.thickness,
    required this.colors,
    required this.borderRadius,
    required this.showBaseWhenDisabled,
    required this.baseColor,
    required this.baseThickness,
  });

  final double progress;   // 0..1
  final double opacity;    // 0..1
  final double thickness;
  final List<Color> colors;
  final BorderRadius borderRadius;

  final bool showBaseWhenDisabled;
  final Color baseColor;
  final double baseThickness;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect.deflate(thickness * 0.2));

    // 비활성 기본 테두리(무지개와 교차 페이드)
    if (showBaseWhenDisabled) {
      final baseAlpha = (1.0 - opacity).clamp(0.0, 1.0);
      if (baseAlpha > 0) {
        final basePaint = Paint()
          ..color = baseColor.withValues(alpha: baseColor.opacity * baseAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = baseThickness
          ..isAntiAlias = true;
        canvas.drawRRect(rrect, basePaint);
      }
    }

    if (opacity <= 0) return;

    final shader = SweepGradient(
      startAngle: 0,
      endAngle: 2 * pi,
      colors: colors,
      transform: GradientRotation(progress * 2 * pi),
    ).createShader(rect);

    final stroke = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..isAntiAlias = true
      ..colorFilter = ColorFilter.mode(
        Colors.white.withValues(alpha: opacity),
        BlendMode.modulate,
      );

    canvas.drawRRect(rrect, stroke);
  }

  @override
  bool shouldRepaint(covariant _RainbowPainter old) =>
      old.progress != progress ||
          old.opacity  != opacity  ||
          old.thickness != thickness ||
          old.colors != colors ||
          old.borderRadius != borderRadius ||
          old.showBaseWhenDisabled != showBaseWhenDisabled ||
          old.baseColor != baseColor ||
          old.baseThickness != baseThickness;
}
