import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpringHealthLogoAnimated extends StatefulWidget {
  final double size;
  final bool showText;
  final VoidCallback? onComplete;

  const SpringHealthLogoAnimated({
    super.key,
    this.size = 140,
    this.showText = true,
    this.onComplete,
  });

  @override
  State<SpringHealthLogoAnimated> createState() =>
      _SpringHealthLogoAnimatedState();
}

class _SpringHealthLogoAnimatedState extends State<SpringHealthLogoAnimated>
    with TickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _orbitCtrl;
  late AnimationController _scanCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _textCtrl;

  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _floatAnim;
  late Animation<double> _glowAnim;
  late Animation<double> _orbitAnim;
  late Animation<double> _scanAnim;
  late Animation<double> _particleAnim;
  late Animation<double> _textFadeAnim;
  late Animation<Offset> _textSlideAnim;

  final List<_Particle> _particles = [];
  final Random _rng = Random(42);

  @override
  void initState() {
    super.initState();
    _buildParticles();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _scaleAnim = CurvedAnimation(
      parent: _entranceCtrl,
      curve: Curves.elasticOut,
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(
      begin: -6.0,
      end: 6.0,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
    _orbitAnim = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: _orbitCtrl, curve: Curves.linear));

    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: false);
    _scanAnim = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scanCtrl, curve: Curves.easeInOut));

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _particleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_particleCtrl);

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textFadeAnim = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut);
    _textSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    _entranceCtrl.forward().then((_) {
      if (!mounted) return;
      _textCtrl.forward().then((_) {
        if (!mounted) return;
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) widget.onComplete?.call();
        });
      });
    });
  }

  void _buildParticles() {
    for (int i = 0; i < 14; i++) {
      _particles.add(
        _Particle(
          angle: _rng.nextDouble() * 2 * pi,
          radius: 0.52 + _rng.nextDouble() * 0.22,
          speed: 0.3 + _rng.nextDouble() * 0.7,
          size: 1.2 + _rng.nextDouble() * 2.2,
          color: i % 3 == 0
              ? const Color(0xFF00E5FF)
              : i % 3 == 1
              ? const Color(0xFFC6F135)
              : const Color(0xFFFF6B35),
          phase: _rng.nextDouble(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _floatCtrl.dispose();
    _glowCtrl.dispose();
    _orbitCtrl.dispose();
    _scanCtrl.dispose();
    _particleCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([
            _floatAnim,
            _glowAnim,
            _orbitAnim,
            _scanAnim,
            _particleAnim,
          ]),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatAnim.value),
              child: SizedBox(
                width: widget.size * 1.3,
                height: widget.size * 1.3,
                child: CustomPaint(
                  painter: _LogoPainter(
                    glowValue: _glowAnim.value,
                    orbitAngle: _orbitAnim.value,
                    scanValue: _scanAnim.value,
                    particleValue: _particleAnim.value,
                    particles: _particles,
                    logoSize: widget.size,
                  ),
                  child: Center(child: child),
                ),
              ),
            );
          },
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/spring_health_logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),

        if (widget.showText) ...[
          SizedBox(height: widget.size * 0.04),
          FadeTransition(
            opacity: _textFadeAnim,
            child: SlideTransition(
              position: _textSlideAnim,
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFC6F135), Color(0xFF00E5FF)],
                ).createShader(bounds),
                child: Text(
                  'SPRING HEALTH',
                  style: GoogleFonts.poppins(
                    fontSize: widget.size * 0.175,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: widget.size * 0.016,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: widget.size * 0.02),
          FadeTransition(
            opacity: _textFadeAnim,
            child: SlideTransition(
              position: _textSlideAnim,
              child: Text(
                'MEMBER APP',
                style: GoogleFonts.poppins(
                  fontSize: widget.size * 0.09,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.75),
                  letterSpacing: widget.size * 0.042,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════
//  PAINTER — orbit ring + scan line + floating particles
// ════════════════════════════════════════════════════════════

class _LogoPainter extends CustomPainter {
  final double glowValue;
  final double orbitAngle;
  final double scanValue;
  final double particleValue;
  final List<_Particle> particles;
  final double logoSize;

  static const _lime = Color(0xFFC6F135);
  static const _cyan = Color(0xFF00E5FF);

  const _LogoPainter({
    required this.glowValue,
    required this.orbitAngle,
    required this.scanValue,
    required this.particleValue,
    required this.particles,
    required this.logoSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = logoSize / 2;

    _drawGlowRing(canvas, cx, cy, r);
    _drawOrbitRing(canvas, cx, cy, r);
    _drawOrbitDot(canvas, cx, cy, r);
    _drawScanLine(canvas, cx, cy, r);
    _drawParticles(canvas, cx, cy, r);
  }

  // ── Pulsing glow behind image ──────────────────────────────
  void _drawGlowRing(Canvas canvas, double cx, double cy, double r) {
    for (final entry in [
      (_lime, 0.18 + 0.22 * glowValue, r + 4 + 8 * glowValue, 12.0),
      (_cyan, 0.08 + 0.10 * glowValue, r + 8 + 14 * glowValue, 20.0),
    ]) {
      canvas.drawCircle(
        Offset(cx, cy),
        entry.$3,
        Paint()
          ..color = entry.$1.withValues(alpha: entry.$2)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, entry.$4),
      );
    }
  }

  // ── Dashed orbit ring ──────────────────────────────────────
  void _drawOrbitRing(Canvas canvas, double cx, double cy, double r) {
    final orbitR = r + 10;
    final paint = Paint()
      ..color = _lime.withValues(alpha: 0.30 + 0.25 * glowValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const dashCount = 20;
    const dashArc = 0.12;
    const gapArc = (2 * pi / dashCount) - dashArc;

    for (int i = 0; i < dashCount; i++) {
      final start = i * (dashArc + gapArc) + orbitAngle * 0.3;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: orbitR),
        start,
        dashArc,
        false,
        paint,
      );
    }
  }

  // ── Glowing dot orbiting the ring ─────────────────────────
  void _drawOrbitDot(Canvas canvas, double cx, double cy, double r) {
    final orbitR = r + 10;
    final dx = cx + orbitR * cos(orbitAngle);
    final dy = cy + orbitR * sin(orbitAngle);

    // Glow
    canvas.drawCircle(
      Offset(dx, dy),
      7,
      Paint()
        ..color = _lime.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // Core dot
    canvas.drawCircle(Offset(dx, dy), 3.5, Paint()..color = _lime);

    // Trailing tail
    for (int i = 1; i <= 5; i++) {
      final ta = orbitAngle - i * 0.18;
      final tx = cx + orbitR * cos(ta);
      final ty = cy + orbitR * sin(ta);
      final alpha = (1 - i / 6) * 0.5;
      canvas.drawCircle(
        Offset(tx, ty),
        2.5 - i * 0.3,
        Paint()..color = _cyan.withValues(alpha: alpha),
      );
    }
  }

  // ── Horizontal scan line sweeping through image ───────────
  void _drawScanLine(Canvas canvas, double cx, double cy, double r) {
    if (scanValue < -0.85 || scanValue > 0.85) return;
    final y = cy + scanValue * r;

    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          _cyan.withValues(alpha: 0.50),
          _lime.withValues(alpha: 0.70),
          _cyan.withValues(alpha: 0.50),
          Colors.transparent,
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(cx - r, y - 1, r * 2, 2));

    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
    );
    canvas.drawRect(Rect.fromLTWH(cx - r, y - 1.2, r * 2, 2.4), scanPaint);
    // Glow below the line
    canvas.drawRect(
      Rect.fromLTWH(cx - r, y - 6, r * 2, 12),
      Paint()
        ..color = _lime.withValues(alpha: 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.restore();
  }

  // ── Floating particles around figure ──────────────────────
  void _drawParticles(Canvas canvas, double cx, double cy, double r) {
    for (final p in particles) {
      final progress = ((particleValue + p.phase) % 1.0);
      final angle = p.angle + particleValue * p.speed * pi;
      final dist = r * p.radius;
      final px = cx + dist * cos(angle);
      final py = cy + dist * sin(angle);

      // Fade in then out
      final alpha = progress < 0.5 ? progress * 2 : (1 - progress) * 2;

      canvas.drawCircle(
        Offset(px, py),
        p.size * alpha,
        Paint()
          ..color = p.color.withValues(alpha: alpha * 0.8)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size),
      );
    }
  }

  @override
  bool shouldRepaint(_LogoPainter old) =>
      old.glowValue != glowValue ||
      old.orbitAngle != orbitAngle ||
      old.scanValue != scanValue ||
      old.particleValue != particleValue;
}

// ── Particle data ──────────────────────────────────────────
class _Particle {
  final double angle;
  final double radius;
  final double speed;
  final double size;
  final Color color;
  final double phase;

  const _Particle({
    required this.angle,
    required this.radius,
    required this.speed,
    required this.size,
    required this.color,
    required this.phase,
  });
}
