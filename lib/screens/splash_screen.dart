import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _master;
  late final AnimationController _particle;
  late final AnimationController _shine;
  late final AnimationController _zoom;

  late final Animation<double> _glowOpacity;
  late final Animation<double> _particleOpacity;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _slogan1Opacity;
  late final Animation<double> _slogan2Opacity;

  late final Animation<double> _credit1Opacity;
  late final Animation<double> _credit2Opacity;
  late final Animation<double> _credit3Opacity;
  late final Animation<double> _credit4Opacity;

  late final Animation<double> _credit1Slide;
  late final Animation<double> _credit2Slide;
  late final Animation<double> _credit3Slide;
  late final Animation<double> _credit4Slide;

  final List<Animation<double>> _letterOpacities = [];
  final List<Animation<double>> _letterSlides = [];
  final List<Animation<double>> _letterScales = [];

  static const String _title = 'BHUCHAR PAN';
  static const double _totalDurationMs = 10010.0;

  bool _hasShined = false;
  bool _isHolding = false;

  @override
  void initState() {
    super.initState();
    _setupSystemUI();
    _initializeAnimations();
  }

  void _setupSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _initializeAnimations() {
    _master = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _totalDurationMs.toInt()),
    );

    _particle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    _shine = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _zoom = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _glowOpacity = Tween<double>(
      begin: 0.0,
      end: 0.42,
    ).animate(
      CurvedAnimation(
        parent: _master,
        curve: Interval(
          800.0 / _totalDurationMs,
          1800.0 / _totalDurationMs,
          curve: Curves.easeInOutSine,
        ),
      ),
    );

    _particleOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _master,
        curve: Interval(
          1800.0 / _totalDurationMs,
          3000.0 / _totalDurationMs,
          curve: Curves.easeInOutSine,
        ),
      ),
    );

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _master,
        curve: Interval(
          3000.0 / _totalDurationMs,
          4200.0 / _totalDurationMs,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _logoScale = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _master,
        curve: Interval(
          3000.0 / _totalDurationMs,
          4200.0 / _totalDurationMs,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    final math.Random rng = math.Random(888);

    for (int i = 0; i < _title.length; i++) {
      if (_title[i] == ' ') {
        _letterOpacities.add(
          const AlwaysStoppedAnimation<double>(0.0),
        );
        _letterSlides.add(
          const AlwaysStoppedAnimation<double>(0.0),
        );
        _letterScales.add(
          const AlwaysStoppedAnimation<double>(1.0),
        );
        continue;
      }

      final double delayMs =
          4200.0 + (i * 45.0) + (rng.nextDouble() * 10.0);
      final double endMs = delayMs + 800.0;

      final double startInterval = delayMs / _totalDurationMs;
      final double endInterval = endMs / _totalDurationMs;

      _letterOpacities.add(
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _master,
            curve: Interval(
              startInterval,
              endInterval,
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
      );

      _letterSlides.add(
        Tween<double>(
          begin: 8.0,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: _master,
            curve: Interval(
              startInterval,
              endInterval,
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
      );

      _letterScales.add(
        Tween<double>(
          begin: 0.98,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _master,
            curve: Interval(
              startInterval,
              endInterval,
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
      );
    }

    _slogan1Opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _master,
        curve: Interval(
          5710.0 / _totalDurationMs,
          6310.0 / _totalDurationMs,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _slogan2Opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _master,
        curve: Interval(
          6610.0 / _totalDurationMs,
          7210.0 / _totalDurationMs,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _credit1Opacity = _createFade(7210.0, 7710.0);
    _credit1Slide = _createSlide(7210.0, 7710.0);

    _credit2Opacity = _createFade(7710.0, 8210.0);
    _credit2Slide = _createSlide(7710.0, 8210.0);

    _credit3Opacity = _createFade(8210.0, 8710.0);
    _credit3Slide = _createSlide(8210.0, 8710.0);

    _credit4Opacity = _createFade(8710.0, 9210.0);
    _credit4Slide = _createSlide(8710.0, 9210.0);

    _master.addListener(() {
      if (_master.value >= (4200.0 / _totalDurationMs) &&
          !_hasShined) {
        _hasShined = true;
        _shine.forward();
      }

      if (_master.value >= (9210.0 / _totalDurationMs) &&
          !_isHolding) {
        _isHolding = true;
        _particle.stop();
      }
    });

    _master.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _zoom.forward();
        _navigateToLogin();
      }
    });

    _master.forward();
  }

  Animation<double> _createFade(double startMs, double endMs) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _master,
        curve: Interval(
          startMs / _totalDurationMs,
          endMs / _totalDurationMs,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  Animation<double> _createSlide(double startMs, double endMs) {
    return Tween<double>(
      begin: 6.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _master,
        curve: Interval(
          startMs / _totalDurationMs,
          endMs / _totalDurationMs,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  void _navigateToLogin() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _master.dispose();
    _particle.dispose();
    _shine.dispose();
    _zoom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ScaleTransition(
        scale: Tween<double>(
          begin: 1.0,
          end: 1.02,
        ).animate(
          CurvedAnimation(
            parent: _zoom,
            curve: Curves.easeInOutCubic,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _glowOpacity,
              builder: (context, child) {
                return Opacity(
                  opacity: _glowOpacity.value,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.8,
                        colors: [
                          Color(0xFF3B2A0F),
                          Colors.transparent,
                        ],
                        stops: [0.0, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.4,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _particleOpacity,
              builder: (context, child) {
                return Opacity(
                  opacity: _particleOpacity.value,
                  child: RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: _particle,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _LuxuryDustPainter(
                            _particle.value,
                            _isHolding,
                          ),
                          size: Size.infinite,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            Center(
              child: AnimatedBuilder(
                animation: _logoOpacity,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacity.value * 0.45,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFD4AF37),
                            blurRadius: 75,
                            spreadRadius: -15,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _master,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: AnimatedBuilder(
                            animation: _shine,
                            builder: (context, child) {
                              final double shineVal =
                                  Tween<double>(
                                begin: -1.0,
                                end: 2.5,
                              ).animate(
                                CurvedAnimation(
                                  parent: _shine,
                                  curve: Curves.easeInOutSine,
                                ),
                              ).value;

                              return ShaderMask(
                                blendMode: BlendMode.srcATop,
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    begin: Alignment(
                                      shineVal - 1.2,
                                      shineVal - 1.2,
                                    ),
                                    end: Alignment(
                                      shineVal + 1.2,
                                      shineVal + 1.2,
                                    ),
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withValues(alpha: 0.5),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ).createShader(bounds);
                                },
                                child: Image.asset(
                                  'assets/logo.png',
                                  width: 145,
                                  height: 160,
                                  fit: BoxFit.contain,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 38),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      _title.length,
                      (index) {
                        if (_title[index] == ' ') {
                          return const SizedBox(width: 14);
                        }

                        return AnimatedBuilder(
                          animation: _master,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                0,
                                _letterSlides[index].value,
                              ),
                              child: Transform.scale(
                                scale: _letterScales[index].value,
                                child: Opacity(
                                  opacity:
                                      _letterOpacities[index].value,
                                  child: Text(
                                    _title[index],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: 10.0,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedBuilder(
                    animation: _master,
                    builder: (context, child) {
                      return Column(
                        children: [
                          Opacity(
                            opacity: _slogan1Opacity.value,
                            child: const Text(
                              'Crafted with Heritage.',
                              style: TextStyle(
                                color: Color(0xFFD4AF37),
                                fontSize: 11,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 3.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Opacity(
                            opacity: _slogan2Opacity.value,
                            child: const Text(
                              'Delivered with Pride.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 3.5,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _master,
                builder: (context, child) {
                  return Column(
                    children: [
                      Transform.translate(
                        offset: Offset(
                          0,
                          _credit1Slide.value,
                        ),
                        child: Opacity(
                          opacity: _credit1Opacity.value,
                          child: const Text(
                            'Designed & Engineered by',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Transform.translate(
                        offset: Offset(
                          0,
                          _credit2Slide.value,
                        ),
                        child: Opacity(
                          opacity: _credit2Opacity.value,
                          child: const Text(
                            'Bhuchar Studios',
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 3.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Transform.translate(
                        offset: Offset(
                          0,
                          _credit3Slide.value,
                        ),
                        child: Opacity(
                          opacity: _credit3Opacity.value,
                          child: const Text(
                            'Devam Namera',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontFamily: 'GreatVibes',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Transform.translate(
                        offset: Offset(
                          0,
                          _credit4Slide.value,
                        ),
                        child: Opacity(
                          opacity: _credit4Opacity.value,
                          child: const Text(
                            'FOUNDER & LEAD DEVELOPER',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 3.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LuxuryDustPainter extends CustomPainter {
  final double progress;
  final bool isHolding;

  static const int particleCount = 8;

  final math.Random random = math.Random(100);

  _LuxuryDustPainter(this.progress, this.isHolding);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill;

    for (int i = 0; i < particleCount; i++) {
      final double startX =
          random.nextDouble() * size.width;

      final double startY =
          random.nextDouble() * size.height;

      final double speed =
          0.01 + random.nextDouble() * 0.02;

      final double baseSize =
          0.3 + random.nextDouble() * 0.6;

      double currentY =
          startY - (progress * size.height * speed);

      if (currentY < 0) {
        currentY = size.height + currentY;
      }

      final double twinkle = math.sin(
        (progress * math.pi * 4) + (i * 2.0),
      );

      final double opacity =
          (0.01 + (twinkle * 0.05)).clamp(0.0, 1.0);

      paint.color = const Color(0xFFD4AF37).withValues(
        alpha: opacity,
      );

      canvas.drawCircle(
        Offset(startX, currentY),
        baseSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _LuxuryDustPainter oldDelegate,
  ) {
    if (isHolding) return false;
    return oldDelegate.progress != progress;
  }
}