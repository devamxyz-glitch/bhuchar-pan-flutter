import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'login_screen.dart';

/// Represents a single luxury onboarding item.
class _OnboardingItem {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;

  const _OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _particleController;
  late final AnimationController _cardAnimationController;

  late final Animation<double> _cardScale;
  late final Animation<double> _cardOpacity;

  int _currentPage = 0;

  static const List<_OnboardingItem> _items = [
    _OnboardingItem(
      title: 'EXQUISITE SELECTION',
      subtitle: 'Artisanal Pan Blends',
      description:
          'Experience handcrafted perfection prepared using royal recipes and the finest hand-picked ingredients.',
      icon: Icons.spa_outlined,
    ),
    _OnboardingItem(
      title: 'HERITAGE & PURITY',
      subtitle: 'Uncompromised Quality',
      description:
          'Every blend honors decades of tradition, processed under rigorous hygienic standards for unmatched freshness.',
      icon: Icons.workspace_premium_outlined,
    ),
    _OnboardingItem(
      title: 'WHITE-GLOVE DELIVERY',
      subtitle: 'Preserved Freshness',
      description:
          'Delivered to your doorstep in specialized insulated luxury packaging to maintain authentic aroma and flavor.',
      icon: Icons.auto_awesome_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _setupSystemUI();

    _pageController = PageController();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _cardScale = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _cardOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _cardAnimationController.forward();
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

  @override
  void dispose() {
    _pageController.dispose();
    _particleController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (!mounted) return;

    setState(() {
      _currentPage = index;
    });

    _cardAnimationController.reset();
    _cardAnimationController.forward();
  }

  void _nextPage() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return const LoginScreen();
        },
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ------------------------------------------------------------
          // LAYER 1: Ambient Gold Glow
          // ------------------------------------------------------------
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.3),
                  radius: 0.9,
                  colors: [
                    Color(0xFF2A200A),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),

          // ------------------------------------------------------------
          // LAYER 2: Ambient Gold Dust
          // ------------------------------------------------------------
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _OnboardingParticlePainter(
                      _particleController.value,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ),

          // ------------------------------------------------------------
          // LAYER 3: Main Onboarding UI
          // ------------------------------------------------------------
          SafeArea(
            child: Column(
              children: [
                // --------------------------------------------------------
                // TOP BAR
                // --------------------------------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/logo.png',
                            width: 36,
                            height: 36,
                            fit: BoxFit.contain,
                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return const Icon(
                                Icons.spa,
                                color: Color(0xFFD4AF37),
                                size: 28,
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'BHUCHAR PAN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 4.0,
                            ),
                          ),
                        ],
                      ),

                      // Skip button
                      if (_currentPage < _items.length - 1)
                        TextButton(
                          onPressed: _navigateToLogin,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white.withValues(
                              alpha: 0.5,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: const Text(
                            'SKIP',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // --------------------------------------------------------
                // SWIPEABLE CONTENT
                // --------------------------------------------------------
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _items.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = _items[index];

                      return AnimatedBuilder(
                        animation: _cardAnimationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _cardScale.value,
                            child: Opacity(
                              opacity: _cardOpacity.value,
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Center(
                            child: _buildGlassCard(item),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // --------------------------------------------------------
                // BOTTOM CONTROLS
                // --------------------------------------------------------
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _items.length,
                          (index) => _buildIndicator(index),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Next / Get Started
                      _OnboardingButton(
                        text: _currentPage == _items.length - 1
                            ? 'GET STARTED'
                            : 'NEXT',
                        onPressed: _nextPage,
                      ),

                      const SizedBox(height: 24),

                      // Footer
                      Text(
                        'DESIGNED & ENGINEERED BY BHUCHAR STUDIOS',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // GLASS CARD
  // ================================================================

  Widget _buildGlassCard(_OnboardingItem item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 25,
          sigmaY: 25,
        ),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ----------------------------------------------------------
              // ICON RING
              // ----------------------------------------------------------
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.05),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    item.icon,
                    size: 40,
                    color: const Color(0xFFD4AF37),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ----------------------------------------------------------
              // TITLE
              // ----------------------------------------------------------
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4.0,
                ),
              ),

              const SizedBox(height: 12),

              // ----------------------------------------------------------
              // SUBTITLE
              // ----------------------------------------------------------
              Text(
                item.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.0,
                ),
              ),

              const SizedBox(height: 16),

              // ----------------------------------------------------------
              // DESCRIPTION
              // ----------------------------------------------------------
              Text(
                item.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  height: 1.6,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // PAGE INDICATOR
  // ================================================================

  Widget _buildIndicator(int index) {
    final bool isSelected = _currentPage == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 4,
      width: isSelected ? 32 : 8,
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFFD4AF37)
            : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(2),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
    );
  }
}

// ====================================================================
// ONBOARDING BUTTON
// ====================================================================

class _OnboardingButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const _OnboardingButton({
    required this.text,
    required this.onPressed,
  });

  @override
  State<_OnboardingButton> createState() => _OnboardingButtonState();
}

class _OnboardingButtonState extends State<_OnboardingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _pressController.forward();
      },
      onTapUp: (_) {
        _pressController.reverse();
      },
      onTapCancel: () {
        _pressController.reverse();
      },
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFE5C058),
                Color(0xFFB89221),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 3.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// PARTICLE PAINTER
// ====================================================================

class _OnboardingParticlePainter extends CustomPainter {
  final double progress;

  static const int particleCount = 10;

  final math.Random random = math.Random(123);

  _OnboardingParticlePainter(this.progress);

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
          0.02 + random.nextDouble() * 0.03;

      final double baseSize =
          0.4 + random.nextDouble() * 0.8;

      double currentY =
          startY - (progress * size.height * speed);

      if (currentY < 0) {
        currentY = size.height + currentY;
      }

      final double twinkle = math.sin(
        (progress * math.pi * 3) + (i * 2.0),
      );

      final double opacity =
          (0.015 + (twinkle * 0.04)).clamp(0.0, 1.0);

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
    covariant _OnboardingParticlePainter oldDelegate,
  ) {
    return oldDelegate.progress != progress;
  }
}