import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  late final AnimationController _entryController;
  late final AnimationController _pulseController;

  late final Animation<double> _cardScale;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  late final Animation<double> _emailOpacity;
  late final Animation<Offset> _emailSlide;

  late final Animation<double> _passwordOpacity;
  late final Animation<Offset> _passwordSlide;

  late final Animation<double> _forgotOpacity;
  late final Animation<Offset> _forgotSlide;

  late final Animation<double> _loginOpacity;
  late final Animation<Offset> _loginSlide;

  late final Animation<double> _registerOpacity;
  late final Animation<Offset> _registerSlide;

  late final Animation<double> _guestOpacity;
  late final Animation<Offset> _guestSlide;

  late final Animation<double> _creditsOpacity;
  late final Animation<Offset> _creditsSlide;

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _setupSystemUI();
    _setupAnimations();
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

  void _setupAnimations() {
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _cardScale = Tween<double>(
      begin: 0.96,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(
          0.0,
          0.4,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _logoScale = Tween<double>(
      begin: 0.90,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(
          0.1,
          0.5,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(
          0.1,
          0.5,
          curve: Curves.easeOut,
        ),
      ),
    );

    _emailOpacity = _createFade(0.2, 0.4);
    _emailSlide = _createSlide(0.2, 0.4);

    _passwordOpacity = _createFade(0.3, 0.5);
    _passwordSlide = _createSlide(0.3, 0.5);

    _forgotOpacity = _createFade(0.4, 0.6);
    _forgotSlide = _createSlide(0.4, 0.6);

    _loginOpacity = _createFade(0.5, 0.7);
    _loginSlide = _createSlide(0.5, 0.7);

    _registerOpacity = _createFade(0.6, 0.8);
    _registerSlide = _createSlide(0.6, 0.8);

    _guestOpacity = _createFade(0.7, 0.9);
    _guestSlide = _createSlide(0.7, 0.9);

    _creditsOpacity = _createFade(0.8, 1.0);
    _creditsSlide = _createSlide(0.8, 1.0);

    _entryController.forward();
  }

  Animation<double> _createFade(double start, double end) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Interval(
          start,
          end,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  Animation<Offset> _createSlide(double start, double end) {
    return Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Interval(
          start,
          end,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _showPremiumSnackbar(
    String message, {
    bool isError = false,
  }) {
    final ScaffoldMessengerState messenger =
        ScaffoldMessenger.of(context);

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          bottom: 24,
          left: 24,
          right: 24,
        ),
        duration: const Duration(seconds: 4),
        content: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF111111).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isError
                  ? Colors.redAccent.withValues(alpha: 0.5)
                  : const Color(0xFFD4AF37).withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isError
                    ? Colors.redAccent.withValues(alpha: 0.15)
                    : const Color(0xFFD4AF37).withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: isError
                    ? Colors.redAccent
                    : const Color(0xFFD4AF37),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) =>
            const HomeScreen(),
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
        transitionDuration: const Duration(
          milliseconds: 1000,
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      _showPremiumSnackbar(
        'Welcome back to Bhuchar Pan.',
      );

      await Future<void>.delayed(
        const Duration(milliseconds: 450),
      );

      if (!mounted) return;

      _navigateToHome();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      _showPremiumSnackbar(
        _handleFirebaseAuthError(e),
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;

      _showPremiumSnackbar(
        'An unexpected error occurred.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRegister() async {
    if (_isLoading) return;

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      _showPremiumSnackbar(
        'Account created successfully.',
      );

      await Future<void>.delayed(
        const Duration(milliseconds: 450),
      );

      if (!mounted) return;

      _navigateToHome();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      _showPremiumSnackbar(
        _handleFirebaseAuthError(e),
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;

      _showPremiumSnackbar(
        'An unexpected error occurred.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleResetPassword() async {
    if (_isLoading) return;

    final String email = _emailController.text.trim();

    if (email.isEmpty ||
        !RegExp(
          r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(email)) {
      _showPremiumSnackbar(
        'Please enter a valid email to reset password.',
        isError: true,
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      _showPremiumSnackbar(
        'Password reset link sent to your email.',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      _showPremiumSnackbar(
        _handleFirebaseAuthError(e),
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;

      _showPremiumSnackbar(
        'An unexpected error occurred.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGuest() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInAnonymously();

      if (!mounted) return;

      _showPremiumSnackbar(
        'Browsing as Guest.',
      );

      await Future<void>.delayed(
        const Duration(milliseconds: 450),
      );

      if (!mounted) return;

      _navigateToHome();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      _showPremiumSnackbar(
        _handleFirebaseAuthError(e),
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;

      _showPremiumSnackbar(
        'An unexpected error occurred.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.5,
                    colors: [
                      const Color(0xFF2A200A).withValues(alpha: 0.4),
                      Colors.black,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 420,
                    ),
                    child: AnimatedBuilder(
                      animation: _entryController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _cardScale.value,
                          child: child,
                        );
                      },
                      child: _buildGlassCard(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 30,
          sigmaY: 30,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            36,
            30,
            36,
            36,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A).withValues(alpha: 0.65),
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLogo(),
                const SizedBox(height: 38),
                _buildAnimatedItem(
                  opacity: _emailOpacity,
                  slide: _emailSlide,
                  child: _LuxuryTextField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    label: 'Email Address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [
                      AutofillHints.email,
                    ],
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }

                      if (!RegExp(
                        r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value.trim())) {
                        return 'Enter a valid email';
                      }

                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _buildAnimatedItem(
                  opacity: _passwordOpacity,
                  slide: _passwordSlide,
                  child: _LuxuryTextField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    label: 'Password',
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onTogglePassword: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      _handleLogin();
                    },
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Password is required';
                      }

                      if (value.trim().length < 6) {
                        return 'Password must be at least 6 characters';
                      }

                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildAnimatedItem(
                  opacity: _forgotOpacity,
                  slide: _forgotSlide,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed:
                          _isLoading ? null : _handleResetPassword,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFD4AF37),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildAnimatedItem(
                  opacity: _loginOpacity,
                  slide: _loginSlide,
                  child: _LuxuryButton(
                    text: 'LOGIN',
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                    isPrimary: true,
                  ),
                ),
                const SizedBox(height: 16),
                _buildAnimatedItem(
                  opacity: _registerOpacity,
                  slide: _registerSlide,
                  child: _LuxuryButton(
                    text: 'CREATE ACCOUNT',
                    onPressed: _handleRegister,
                    isLoading: _isLoading,
                    isPrimary: false,
                  ),
                ),
                const SizedBox(height: 16),
                _buildAnimatedItem(
                  opacity: _guestOpacity,
                  slide: _guestSlide,
                  child: TextButton(
                    onPressed: _isLoading ? null : _handleGuest,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white.withValues(
                        alpha: 0.6,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue as Guest',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _buildAnimatedItem(
                  opacity: _creditsOpacity,
                  slide: _creditsSlide,
                  child: _buildCredits(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _entryController,
        _pulseController,
      ]),
      builder: (context, child) {
        final double pulseValue = Tween<double>(
          begin: 0.85,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _pulseController,
            curve: Curves.easeInOutSine,
          ),
        ).value;

        return Opacity(
          opacity: _logoOpacity.value,
          child: Transform.scale(
            scale: _logoScale.value,
            child: SizedBox(
              width: 170,
              height: 170,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 168,
                    height: 168,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withValues(
                            alpha: 0.22 * pulseValue,
                          ),
                          blurRadius: 42 * pulseValue,
                          spreadRadius: 6 * pulseValue,
                        ),
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withValues(
                            alpha: 0.08,
                          ),
                          blurRadius: 70,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 158,
                    height: 158,
                    padding: const EdgeInsets.all(2.5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFE08A),
                          Color(0xFFD4AF37),
                          Color(0xFF9A7415),
                          Color(0xFFE5C45A),
                          Color(0xFFB88620),
                        ],
                      ),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo.png',
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return Container(
                              color: Colors.black,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.storefront_rounded,
                                color: Color(0xFFD4AF37),
                                size: 64,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    left: 25,
                    right: 25,
                    child: Container(
                      height: 1.5,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color(0xFFFFE08A),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCredits() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'DESIGNED & ENGINEERED BY BHUCHAR STUDIOS',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Devam Namera',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'GreatVibes',
            fontWeight: FontWeight.w400,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'FOUNDER & LEAD DEVELOPER',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.8),
            fontSize: 8,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedItem({
    required Animation<double> opacity,
    required Animation<Offset> slide,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, widgetChild) {
        return Transform.translate(
          offset: slide.value,
          child: Opacity(
            opacity: opacity.value,
            child: widgetChild,
          ),
        );
      },
      child: child,
    );
  }
}

class _LuxuryTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final IconData icon;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onTogglePassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;

  const _LuxuryTextField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.obscureText = false,
    this.onTogglePassword,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.validator,
    this.autofillHints,
  });

  @override
  State<_LuxuryTextField> createState() => _LuxuryTextFieldState();
}

class _LuxuryTextFieldState extends State<_LuxuryTextField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = widget.focusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused
              ? const Color(0xFFD4AF37).withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(
                    alpha: 0.1,
                  ),
                  blurRadius: 16,
                ),
              ]
            : [],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onFieldSubmitted,
        validator: widget.validator,
        autofillHints: widget.autofillHints,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        cursorColor: const Color(0xFFD4AF37),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(
            color: _isFocused
                ? const Color(0xFFD4AF37)
                : Colors.white.withValues(alpha: 0.4),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.0,
          ),
          prefixIcon: Icon(
            widget.icon,
            color: _isFocused
                ? const Color(0xFFD4AF37)
                : Colors.white.withValues(alpha: 0.4),
            size: 20,
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    widget.obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 20,
                  ),
                  onPressed: widget.onTogglePassword,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          errorStyle: const TextStyle(
            color: Colors.redAccent,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _LuxuryButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isPrimary;

  const _LuxuryButton({
    required this.text,
    required this.onPressed,
    required this.isLoading,
    required this.isPrimary,
  });

  @override
  State<_LuxuryButton> createState() => _LuxuryButtonState();
}

class _LuxuryButtonState extends State<_LuxuryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverController;
  late final Animation<double> _scaleAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(
      CurvedAnimation(
        parent: _hoverController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _hoverController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _hoverController.reverse();
  }

  void _onTapCancel() {
    _hoverController.reverse();
  }

  void _onHover(bool isHovered) {
    if (mounted) {
      setState(() {
        _isHovered = isHovered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (PointerEnterEvent event) {
        _onHover(true);
      },
      onExit: (PointerExitEvent event) {
        _onHover(false);
      },
      child: GestureDetector(
        onTapDown: widget.isLoading ? null : _onTapDown,
        onTapUp: widget.isLoading ? null : _onTapUp,
        onTapCancel: widget.isLoading ? null : _onTapCancel,
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: widget.isPrimary
                  ? const LinearGradient(
                      colors: [
                        Color(0xFFE5C058),
                        Color(0xFFB89221),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: widget.isPrimary
                  ? null
                  : Colors.transparent,
              border: widget.isPrimary
                  ? null
                  : Border.all(
                      color: _isHovered
                          ? const Color(0xFFD4AF37)
                          : const Color(0xFFD4AF37).withValues(
                              alpha: 0.3,
                            ),
                      width: 1,
                    ),
              boxShadow: widget.isPrimary
                  ? [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(
                          alpha: _isHovered ? 0.4 : 0.25,
                        ),
                        blurRadius: _isHovered ? 24 : 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(
                          widget.isPrimary
                              ? Colors.black87
                              : const Color(0xFFD4AF37),
                        ),
                      ),
                    )
                  : Text(
                      widget.text,
                      style: TextStyle(
                        color: widget.isPrimary
                            ? Colors.black87
                            : const Color(0xFFD4AF37),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}