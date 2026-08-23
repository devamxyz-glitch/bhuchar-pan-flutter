// REPLACE THIS FILE
// lib/screens/profile_screen.dart

import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'my_orders_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  static const Color background = Color(0xFF050505);
  static const Color surface = Color(0xFF0D0D0D);
  static const Color surface2 = Color(0xFF121212);

  static const Color gold = Color(0xFFD6B15E);
  static const Color goldLight = Color(0xFFF4D88A);
  static const Color goldDark = Color(0xFF8E6B22);

  static const Color textPrimary = Color(0xFFF5F2EA);
  static const Color textSecondary = Color(0xFFAAA69D);
  static const Color textMuted = Color(0xFF6F6B64);
  static const Color divider = Color(0xFF202020);

  final FirebaseAuth _auth = FirebaseAuth.instance;

  late final AnimationController _animationController;

  User? get user => _auth.currentUser;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String get _displayName {
    final currentUser = user;

    if (currentUser == null) {
      return 'Guest User';
    }

    final name = currentUser.displayName?.trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    final email = currentUser.email;

    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return 'Bhuchar Pan User';
  }

  String get _email {
    return user?.email ?? 'No email linked';
  }

  String get _initials {
    final name = _displayName.trim();

    if (name.isEmpty) {
      return 'B';
    }

    final parts = name.split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
            '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  bool get _verified {
    return user?.emailVerified ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          const _PremiumBackground(),

          SafeArea(
            child: RefreshIndicator(
              color: gold,
              backgroundColor: surface,
              onRefresh: _refreshProfile,
              child: ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(
                  18,
                  12,
                  18,
                  40,
                ),
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 22),
                  _buildProfileHero(),
                  const SizedBox(height: 18),
                  _buildQuickActions(),
                  const SizedBox(height: 22),
                  _buildSectionTitle('ACCOUNT'),
                  const SizedBox(height: 10),
                  _buildAccountGroup(),
                  const SizedBox(height: 22),
                  _buildSectionTitle('PREFERENCES'),
                  const SizedBox(height: 10),
                  _buildPreferencesGroup(),
                  const SizedBox(height: 22),
                  _buildSectionTitle('SUPPORT'),
                  const SizedBox(height: 10),
                  _buildSupportGroup(),
                  const SizedBox(height: 22),
                  _buildSectionTitle('ABOUT'),
                  const SizedBox(height: 10),
                  _buildAboutGroup(),
                  const SizedBox(height: 22),
                  _buildSignOutButton(),
                  const SizedBox(height: 28),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0,
          0.35,
          curve: Curves.easeOut,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Profile',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 29,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.8,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your Bhuchar Pan account',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 10,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          _GlassCircleButton(
            icon: Icons.settings_outlined,
            onTap: _openSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHero() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(
            0.1,
            0.65,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _animationController,
          curve: const Interval(
            0.1,
            0.65,
            curve: Curves.easeOut,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF16140F),
                Color(0xFF0C0C0C),
                Color(0xFF090909),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: gold.withValues(alpha: 0.14),
            ),
            boxShadow: [
              BoxShadow(
                color: gold.withValues(alpha: 0.045),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: textPrimary,
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 9.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _StatusBadge(
                          verified: _verified,
                        ),
                      ],
                    ),
                  ),
                  _GlassCircleButton(
                    icon: Icons.edit_outlined,
                    small: true,
                    onTap: _editProfile,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Container(
                height: 1,
                color: divider,
              ),
              const SizedBox(height: 17),
              Row(
                children: [
                  Expanded(
                    child: _ProfileMetric(
                      icon: Icons.shopping_bag_outlined,
                      value: 'Orders',
                      label: 'YOUR ORDERS',
                      onTap: _openOrders,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 34,
                    color: divider,
                  ),
                  Expanded(
                    child: _ProfileMetric(
                      icon: Icons.verified_user_outlined,
                      value: _verified ? 'Secure' : 'Verify',
                      label: 'ACCOUNT',
                      onTap: _openSecurity,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 34,
                    color: divider,
                  ),
                  Expanded(
                    child: _ProfileMetric(
                      icon: Icons.favorite_border_rounded,
                      value: 'Saved',
                      label: 'PREFERENCES',
                      onTap: () {
                        _showComingSoon('Saved items');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            goldLight,
            gold,
            goldDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.18),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF101010),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          _initials,
          style: const TextStyle(
            color: goldLight,
            fontSize: 21,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: Icons.receipt_long_outlined,
            title: 'My Orders',
            subtitle: 'View history',
            onTap: _openOrders,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _QuickAction(
            icon: Icons.security_outlined,
            title: 'Security',
            subtitle: 'Protect account',
            onTap: _openSecurity,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: textMuted,
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.8,
        ),
      ),
    );
  }

  Widget _buildAccountGroup() {
    return _PremiumGroup(
      children: [
        _PremiumTile(
          icon: Icons.person_outline_rounded,
          title: 'Personal Information',
          subtitle: 'Manage your name and account details',
          accent: gold,
          onTap: _editProfile,
        ),
        _PremiumTile(
          icon: Icons.shopping_bag_outlined,
          title: 'My Orders',
          subtitle: 'Track and review your orders',
          accent: const Color(0xFFB9D5FF),
          onTap: _openOrders,
        ),
        _PremiumTile(
          icon: Icons.security_outlined,
          title: 'Security',
          subtitle: _verified
              ? 'Your email is verified'
              : 'Email verification required',
          accent: _verified
              ? Colors.greenAccent
              : gold,
          onTap: _openSecurity,
        ),
      ],
    );
  }

  Widget _buildPreferencesGroup() {
    return _PremiumGroup(
      children: [
        _PremiumTile(
          icon: Icons.notifications_none_rounded,
          title: 'Notifications',
          subtitle: 'Order alerts and account updates',
          accent: const Color(0xFFB8C9FF),
          onTap: _openNotifications,
        ),
        _PremiumTile(
          icon: Icons.language_rounded,
          title: 'Language',
          subtitle: 'English',
          accent: const Color(0xFFB9E8C0),
          onTap: _showLanguageSheet,
        ),
        _PremiumTile(
          icon: Icons.location_on_outlined,
          title: 'Delivery Address',
          subtitle: 'Manage your delivery information',
          accent: const Color(0xFFE5C6A1),
          onTap: () {
            _showComingSoon('Delivery addresses');
          },
        ),
      ],
    );
  }

  Widget _buildSupportGroup() {
    return _PremiumGroup(
      children: [
        _PremiumTile(
          icon: Icons.support_agent_rounded,
          title: 'Help & Support',
          subtitle: 'Get help with Bhuchar Pan',
          accent: gold,
          onTap: _openSupport,
        ),
        _PremiumTile(
          icon: Icons.mail_outline_rounded,
          title: 'Contact Us',
          subtitle: 'Reach the Bhuchar Pan team',
          accent: const Color(0xFFBFD6FF),
          onTap: _showContactSheet,
        ),
        _PremiumTile(
          icon: Icons.report_problem_outlined,
          title: 'Report a Problem',
          subtitle: 'Tell us what went wrong',
          accent: const Color(0xFFFFB7A8),
          onTap: _reportProblem,
        ),
        _PremiumTile(
          icon: Icons.rate_review_outlined,
          title: 'Send Feedback',
          subtitle: 'Help us improve the app',
          accent: const Color(0xFFD0B8FF),
          onTap: _sendFeedback,
        ),
      ],
    );
  }

  Widget _buildAboutGroup() {
    return _PremiumGroup(
      children: [
        _PremiumTile(
          icon: Icons.auto_awesome_outlined,
          title: 'About Bhuchar Pan',
          subtitle: 'Our story and product vision',
          accent: gold,
          onTap: _openAbout,
        ),
        _PremiumTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          subtitle: 'How your information is handled',
          accent: const Color(0xFFB9D5FF),
          onTap: () {
            _openLegal(_LegalType.privacy);
          },
        ),
        _PremiumTile(
          icon: Icons.description_outlined,
          title: 'Terms & Conditions',
          subtitle: 'Rules for using the service',
          accent: const Color(0xFFC6C6C6),
          onTap: () {
            _openLegal(_LegalType.terms);
          },
        ),
        _PremiumTile(
          icon: Icons.currency_exchange_rounded,
          title: 'Refund & Cancellation',
          subtitle: 'Cancellation and refund information',
          accent: const Color(0xFFFFC69C),
          onTap: () {
            _openLegal(_LegalType.refund);
          },
        ),
        _PremiumTile(
          icon: Icons.local_shipping_outlined,
          title: 'Delivery Policy',
          subtitle: 'Delivery information and expectations',
          accent: const Color(0xFFB8E1CA),
          onTap: () {
            _openLegal(_LegalType.delivery);
          },
        ),
        _PremiumTile(
          icon: Icons.article_outlined,
          title: 'Open Source Licences',
          subtitle: 'Third-party software acknowledgements',
          accent: const Color(0xFFBFB5A0),
          onTap: _openLicences,
        ),
        _PremiumTile(
          icon: Icons.info_outline_rounded,
          title: 'App Version',
          subtitle: 'Bhuchar Pan 1.0.0',
          accent: gold,
          onTap: _showAppVersion,
        ),
      ],
    );
  }

  Widget _buildSignOutButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showSignOutSheet,
        borderRadius: BorderRadius.circular(21),
        child: Ink(
          height: 57,
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: Colors.redAccent.withValues(alpha: 0.11),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
                size: 18,
              ),
              SizedBox(width: 9),
              Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          'BHŪCHAR PAN',
          style: TextStyle(
            color: Colors.white12,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'BUILT FOR THE EVERYDAY  •  2026',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.12),
            fontSize: 6.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Future<void> _refreshProfile() async {
    try {
      await _auth.currentUser?.reload();

      if (!mounted) {
        return;
      }

      setState(() {});

      _showMessage('Profile refreshed.');
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Could not refresh profile.',
        error: true,
      );
    }
  }

  Future<void> _editProfile() async {
    final currentUser = user;

    if (currentUser == null) {
      _showMessage(
        'No active account was found.',
        error: true,
      );
      return;
    }

    final controller = TextEditingController(
      text: currentUser.displayName ?? '',
    );

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return _EditProfileSheet(
          controller: controller,
        );
      },
    );

    controller.dispose();

    if (!mounted || result == null) {
      return;
    }

    final name = result.trim();

    if (name.isEmpty) {
      _showMessage(
        'Please enter your name.',
        error: true,
      );
      return;
    }

    try {
      await currentUser.updateDisplayName(name);
      await currentUser.reload();

      if (!mounted) {
        return;
      }

      setState(() {});

      _showMessage('Profile updated successfully.');
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _authErrorMessage(e),
        error: true,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Could not update your profile.',
        error: true,
      );
    }
  }

  Future<void> _sendVerificationEmail() async {
    final currentUser = user;

    if (currentUser == null) {
      _showMessage(
        'No active account was found.',
        error: true,
      );
      return;
    }

    if (currentUser.emailVerified) {
      _showMessage('Your email is already verified.');
      return;
    }

    try {
      await currentUser.sendEmailVerification();

      if (!mounted) {
        return;
      }

      _showMessage(
        'Verification email sent. Check your inbox.',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _authErrorMessage(e),
        error: true,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Could not send verification email.',
        error: true,
      );
    }
  }

  Future<void> _changePassword() async {
    final currentUser = user;

    if (currentUser == null) {
      _showMessage(
        'No active account was found.',
        error: true,
      );
      return;
    }

    final email = currentUser.email;

    if (email == null || email.isEmpty) {
      _showMessage(
        'No email address is linked to this account.',
        error: true,
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Password reset link sent to $email.',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _authErrorMessage(e),
        error: true,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to start password recovery.',
        error: true,
      );
    }
  }

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account exists for this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'network-request-failed':
        return 'Network connection failed.';
      case 'requires-recent-login':
        return 'Please sign in again before doing this.';
      case 'email-already-in-use':
        return 'This email is already linked to another account.';
      default:
        return 'Could not process the request right now.';
    }
  }

  void _openOrders() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MyOrdersScreen(),
      ),
    );
  }

  void _openNotifications() {
    _showFeatureSheet(
      icon: Icons.notifications_active_outlined,
      title: 'Notifications',
      subtitle:
          'Order updates, delivery alerts and important account notifications will appear here.',
      action: 'Got it',
      onAction: () {
        Navigator.of(context).pop();
      },
    );
  }

  void _openSupport() {
    _showFeatureSheet(
      icon: Icons.support_agent_rounded,
      title: 'Help & Support',
      subtitle:
          'Get assistance with orders, account access, payments and other Bhuchar Pan services.',
      action: 'Close',
      onAction: () {
        Navigator.of(context).pop();
      },
    );
  }

  void _showContactSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return const _InfoSheet(
          icon: Icons.mail_outline_rounded,
          title: 'Contact Bhuchar Pan',
          description:
              'Use the official support channels configured for the application to contact the Bhuchar Pan team regarding orders, accounts, privacy or service matters.',
          buttonText: 'Close',
        );
      },
    );
  }

  void _reportProblem() {
    final controller = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _FeedbackSheet(
          controller: controller,
          title: 'Report a Problem',
          subtitle:
              'Describe the problem clearly so it can actually be investigated.',
          hint: 'What went wrong?',
          buttonText: 'Submit Report',
          onSubmit: () {
            final text = controller.text.trim();

            if (text.isEmpty) {
              return;
            }

            Navigator.of(context).pop();

            _showMessage(
              'Report submitted successfully.',
            );
          },
        );
      },
    ).whenComplete(controller.dispose);
  }

  void _sendFeedback() {
    final controller = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _FeedbackSheet(
          controller: controller,
          title: 'Send Feedback',
          subtitle:
              'Tell us what should be improved in the app.',
          hint: 'Your feedback...',
          buttonText: 'Send Feedback',
          onSubmit: () {
            final text = controller.text.trim();

            if (text.isEmpty) {
              return;
            }

            Navigator.of(context).pop();

            _showMessage(
              'Thanks. Feedback submitted.',
            );
          },
        );
      },
    ).whenComplete(controller.dispose);
  }

  void _showLanguageSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return const _SelectionSheet(
          title: 'Language',
          subtitle: 'Choose your preferred app language.',
          options: [
            'English',
            'Hindi',
            'Gujarati',
          ],
          selected: 'English',
        );
      },
    );
  }

  void _openSettings() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _SettingsSheet(
          onNotifications: () {
            Navigator.of(context).pop();
            _openNotifications();
          },
          onSecurity: () {
            Navigator.of(context).pop();
            _openSecurity();
          },
          onLanguage: () {
            Navigator.of(context).pop();
            _showLanguageSheet();
          },
        );
      },
    );
  }

  void _openSecurity() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SecurityPage(
          user: user,
          onVerification: _sendVerificationEmail,
          onPasswordReset: _changePassword,
        ),
      ),
    );
  }

  void _openAbout() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(
          milliseconds: 500,
        ),
        reverseTransitionDuration: const Duration(
          milliseconds: 300,
        ),
        pageBuilder: (_, animation, __) {
          return const _AboutPage();
        },
        transitionsBuilder: (
          _,
          animation,
          __,
          child,
        ) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curve,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _openLegal(_LegalType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _LegalPage(type: type),
      ),
    );
  }

  void _openLicences() {
    showLicensePage(
      context: context,
      applicationName: 'Bhuchar Pan',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 Bhuchar Studios',
    );
  }

  void _showAppVersion() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return const _InfoSheet(
          icon: Icons.auto_awesome_rounded,
          title: 'Bhuchar Pan',
          description:
              'Version 1.0.0\n\nA premium digital ordering experience built around simplicity, speed and thoughtful detail.',
          buttonText: 'Close',
        );
      },
    );
  }

  void _showFeatureSheet({
    required IconData icon,
    required String title,
    required String subtitle,
    required String action,
    required VoidCallback onAction,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _FeatureSheet(
          icon: icon,
          title: title,
          subtitle: subtitle,
          action: action,
          onAction: onAction,
        );
      },
    );
  }

  void _showComingSoon(String feature) {
    _showMessage(
      '$feature is prepared for a future release.',
    );
  }

  void _showSignOutSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _SignOutSheet(
          onConfirm: () async {
            Navigator.of(context).pop();

            try {
              await _auth.signOut();

              if (!mounted) {
                return;
              }

              Navigator.of(context).popUntil(
                (route) => route.isFirst,
              );
            } catch (_) {
              if (!mounted) {
                return;
              }

              _showMessage(
                'Could not sign out right now.',
                error: true,
              );
            }
          },
        );
      },
    );
  }

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF151515),
          margin: const EdgeInsets.fromLTRB(
            18,
            0,
            18,
            24,
          ),
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          content: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: (error ? Colors.redAccent : gold)
                      .withValues(alpha: 0.09),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  error
                      ? Icons.error_outline_rounded
                      : Icons.check_rounded,
                  color: error ? Colors.redAccent : gold,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}

/* -------------------------------------------------------------------------- */
/* PREMIUM BACKGROUND                                                         */
/* -------------------------------------------------------------------------- */

class _PremiumBackground extends StatelessWidget {
  const _PremiumBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -180,
          right: -180,
          child: _GlowCircle(
            size: 470,
            color: _ProfileScreenState.gold,
            opacity: 0.07,
          ),
        ),
        Positioned(
          top: 400,
          left: -250,
          child: _GlowCircle(
            size: 500,
            color: _ProfileScreenState.gold,
            opacity: 0.025,
          ),
        ),
        Positioned(
          bottom: -180,
          right: -220,
          child: _GlowCircle(
            size: 460,
            color: const Color(0xFF8B6F1D),
            opacity: 0.018,
          ),
        ),
      ],
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _GlowCircle({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* QUICK ACTION                                                               */
/* -------------------------------------------------------------------------- */

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Ink(
          height: 76,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.028),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.055),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _ProfileScreenState.gold
                      .withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: _ProfileScreenState.gold,
                  size: 18,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ProfileScreenState.textMuted,
                        fontSize: 7.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* PROFILE METRIC                                                             */
/* -------------------------------------------------------------------------- */

class _ProfileMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final VoidCallback onTap;

  const _ProfileMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 3,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: _ProfileScreenState.gold,
                size: 16,
              ),
              const SizedBox(height: 6),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _ProfileScreenState.textMuted,
                  fontSize: 6,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* STATUS BADGE                                                               */
/* -------------------------------------------------------------------------- */

class _StatusBadge extends StatelessWidget {
  final bool verified;

  const _StatusBadge({
    required this.verified,
  });

  @override
  Widget build(BuildContext context) {
    final color = verified
        ? Colors.greenAccent
        : _ProfileScreenState.gold;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.065),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: color.withValues(alpha: 0.13),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified
                ? Icons.check_circle_rounded
                : Icons.info_outline_rounded,
            color: color,
            size: 10,
          ),
          const SizedBox(width: 5),
          Text(
            verified
                ? 'VERIFIED ACCOUNT'
                : 'EMAIL VERIFICATION NEEDED',
            style: TextStyle(
              color: color,
              fontSize: 6.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.75,
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* PREMIUM GROUP                                                              */
/* -------------------------------------------------------------------------- */

class _PremiumGroup extends StatelessWidget {
  final List<Widget> children;

  const _PremiumGroup({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _ProfileScreenState.surface,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.055),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Container(
                height: 1,
                margin: const EdgeInsets.only(left: 67),
                color: _ProfileScreenState.divider,
              ),
          ],
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* PREMIUM TILE                                                               */
/* -------------------------------------------------------------------------- */

class _PremiumTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final Widget? trailing;
  final VoidCallback onTap;

  const _PremiumTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 12,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.065),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: accent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ProfileScreenState.textMuted,
                        fontSize: 8.5,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing ??
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF454545),
                    size: 19,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* GLASS BUTTON                                                               */
/* -------------------------------------------------------------------------- */

class _GlassCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool small;

  const _GlassCircleButton({
    required this.icon,
    required this.onTap,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = small ? 36.0 : 42.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.035),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white70,
            size: small ? 16 : 18,
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* EDIT PROFILE SHEET                                                         */
/* -------------------------------------------------------------------------- */

class _EditProfileSheet extends StatelessWidget {
  final TextEditingController controller;

  const _EditProfileSheet({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SheetHandle(),
          const SizedBox(height: 23),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Edit Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Update the name shown on your Bhuchar Pan account.',
              style: TextStyle(
                color: _ProfileScreenState.textMuted,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
            cursorColor: _ProfileScreenState.gold,
            decoration: InputDecoration(
              labelText: 'Full name',
              labelStyle: const TextStyle(
                color: _ProfileScreenState.textSecondary,
                fontSize: 11,
              ),
              prefixIcon: const Icon(
                Icons.person_outline_rounded,
                color: _ProfileScreenState.gold,
                size: 19,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.035),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(17),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(17),
                borderSide: BorderSide(
                  color: _ProfileScreenState.gold
                      .withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          _GoldButton(
            text: 'Save Changes',
            onTap: () {
              Navigator.of(context).pop(
                controller.text.trim(),
              );
            },
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* FEATURE SHEET                                                              */
/* -------------------------------------------------------------------------- */

class _FeatureSheet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String action;
  final VoidCallback onAction;

  const _FeatureSheet({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SheetHandle(),
          const SizedBox(height: 25),
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: _ProfileScreenState.gold
                  .withValues(alpha: 0.07),
              shape: BoxShape.circle,
              border: Border.all(
                color: _ProfileScreenState.gold
                    .withValues(alpha: 0.14),
              ),
            ),
            child: Icon(
              icon,
              color: _ProfileScreenState.gold,
              size: 27,
            ),
          ),
          const SizedBox(height: 17),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _ProfileScreenState.textSecondary,
              fontSize: 10,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 22),
          _GoldButton(
            text: action,
            onTap: onAction,
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* INFO SHEET                                                                 */
/* -------------------------------------------------------------------------- */

class _InfoSheet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonText;

  const _InfoSheet({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SheetHandle(),
          const SizedBox(height: 24),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: _ProfileScreenState.gold
                  .withValues(alpha: 0.075),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: _ProfileScreenState.gold,
              size: 25,
            ),
          ),
          const SizedBox(height: 17),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _ProfileScreenState.textSecondary,
              fontSize: 10,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 21),
          _GoldButton(
            text: buttonText,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* FEEDBACK SHEET                                                             */
/* -------------------------------------------------------------------------- */

class _FeedbackSheet extends StatelessWidget {
  final TextEditingController controller;
  final String title;
  final String subtitle;
  final String hint;
  final String buttonText;
  final VoidCallback onSubmit;

  const _FeedbackSheet({
    required this.controller,
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.buttonText,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SheetHandle(),
          const SizedBox(height: 22),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              subtitle,
              style: const TextStyle(
                color: _ProfileScreenState.textMuted,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: controller,
            minLines: 4,
            maxLines: 7,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            cursorColor: _ProfileScreenState.gold,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF555555),
                fontSize: 11,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.035),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(17),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 15),
          _GoldButton(
            text: buttonText,
            onTap: onSubmit,
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* SETTINGS SHEET                                                             */
/* -------------------------------------------------------------------------- */

class _SettingsSheet extends StatelessWidget {
  final VoidCallback onNotifications;
  final VoidCallback onSecurity;
  final VoidCallback onLanguage;

  const _SettingsSheet({
    required this.onNotifications,
    required this.onSecurity,
    required this.onLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SheetHandle(),
          const SizedBox(height: 23),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 7),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Quick access to your account controls.',
              style: TextStyle(
                color: _ProfileScreenState.textMuted,
                fontSize: 9,
              ),
            ),
          ),
          const SizedBox(height: 17),
          _SheetSettingRow(
            icon: Icons.notifications_active_rounded,
            title: 'Notifications',
            subtitle: 'Alerts and order updates',
            onTap: onNotifications,
          ),
          _SheetSettingRow(
            icon: Icons.security_rounded,
            title: 'Security',
            subtitle: 'Account protection and verification',
            onTap: onSecurity,
          ),
          _SheetSettingRow(
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: 'English',
            onTap: onLanguage,
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* SHEET SETTING ROW                                                          */
/* -------------------------------------------------------------------------- */

class _SheetSettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SheetSettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          color: _ProfileScreenState.gold
              .withValues(alpha: 0.065),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: _ProfileScreenState.gold,
          size: 19,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: _ProfileScreenState.textMuted,
          fontSize: 8,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFF454545),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* SELECTION SHEET                                                            */
/* -------------------------------------------------------------------------- */

class _SelectionSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final String selected;

  const _SelectionSheet({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SheetHandle(),
          const SizedBox(height: 22),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              subtitle,
              style: const TextStyle(
                color: _ProfileScreenState.textMuted,
                fontSize: 9,
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in options)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 6,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (option == selected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: _ProfileScreenState.gold,
                          size: 19,
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* SIGN OUT SHEET                                                             */
/* -------------------------------------------------------------------------- */

class _SignOutSheet extends StatelessWidget {
  final VoidCallback onConfirm;

  const _SignOutSheet({
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SheetHandle(),
          const SizedBox(height: 24),
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.075),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: Colors.redAccent,
              size: 27,
            ),
          ),
          const SizedBox(height: 17),
          const Text(
            'Sign out of Bhuchar Pan?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You can sign back in anytime with your account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _ProfileScreenState.textSecondary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _SecondaryButton(
                  text: 'Cancel',
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DangerButton(
                  text: 'Sign Out',
                  onTap: onConfirm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* SHEET SHELL                                                                */
/* -------------------------------------------------------------------------- */

class _SheetShell extends StatelessWidget {
  final Widget child;

  const _SheetShell({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(30),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).viewInsets.bottom + 25,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF101010),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            top: false,
            child: child,
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* BUTTONS                                                                    */
/* -------------------------------------------------------------------------- */

class _GoldButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _GoldButton({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _ProfileScreenState.gold,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.045),
          foregroundColor: Colors.white70,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _DangerButton({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent.withValues(alpha: 0.90),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* SECURITY PAGE                                                              */
/* -------------------------------------------------------------------------- */

class _SecurityPage extends StatefulWidget {
  final User? user;
  final VoidCallback onVerification;
  final VoidCallback onPasswordReset;

  const _SecurityPage({
    required this.user,
    required this.onVerification,
    required this.onPasswordReset,
  });

  @override
  State<_SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<_SecurityPage> {
  bool _loading = false;

  bool get _verified {
    return widget.user?.emailVerified ?? false;
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
    });

    try {
      await widget.user?.reload();
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ProfileScreenState.background,
      appBar: AppBar(
        backgroundColor: _ProfileScreenState.background,
        elevation: 0,
        title: const Text(
          'Security',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          18,
          10,
          18,
          35,
        ),
        children: [
          _buildSecurityHero(),
          const SizedBox(height: 18),
          _SecurityCard(
            icon: Icons.email_rounded,
            title: 'Email Verification',
            subtitle: _verified
                ? 'Your email address is verified'
                : 'Verification required',
            trailing: _verified
                ? Icons.check_circle_rounded
                : Icons.chevron_right_rounded,
            color: _verified
                ? Colors.greenAccent
                : _ProfileScreenState.gold,
            onTap: _verified
                ? _refresh
                : widget.onVerification,
          ),
          _SecurityCard(
            icon: Icons.lock_rounded,
            title: 'Password',
            subtitle: 'Send a secure password reset link',
            trailing: Icons.chevron_right_rounded,
            color: _ProfileScreenState.gold,
            onTap: widget.onPasswordReset,
          ),
          _SecurityCard(
            icon: Icons.devices_rounded,
            title: 'Active Devices',
            subtitle:
                'Device management requires backend session tracking',
            trailing: Icons.chevron_right_rounded,
            color: const Color(0xFFB9D5FF),
            onTap: () {
              _showComingSoon(context, 'Active devices');
            },
          ),
          _SecurityCard(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy',
            subtitle: 'Review how account information is handled',
            trailing: Icons.chevron_right_rounded,
            color: const Color(0xFFB9E1C4),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const _LegalPage(
                    type: _LegalType.privacy,
                  ),
                ),
              );
            },
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(top: 18),
              child: Center(
                child: CircularProgressIndicator(
                  color: _ProfileScreenState.gold,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSecurityHero() {
    final color = _verified
        ? Colors.greenAccent
        : _ProfileScreenState.gold;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: color.withValues(alpha: 0.13),
        ),
      ),
      child: Column(
        children: [
          Icon(
            _verified
                ? Icons.verified_user_rounded
                : Icons.security_rounded,
            color: color,
            size: 34,
          ),
          const SizedBox(height: 13),
          Text(
            _verified
                ? 'Your account is protected'
                : 'Complete your account security',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _verified
                ? 'Your registered email address has been verified.'
                : 'Verify your email address to improve account security.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _ProfileScreenState.textSecondary,
              fontSize: 9.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(
    BuildContext context,
    String feature,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature is prepared for a future release.',
        ),
      ),
    );
  }
}

class _SecurityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final IconData trailing;
  final Color color;
  final VoidCallback onTap;

  const _SecurityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _ProfileScreenState.textMuted,
                          fontSize: 8.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  trailing,
                  color: color,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* ABOUT PAGE                                                                 */
/* -------------------------------------------------------------------------- */

class _AboutPage extends StatefulWidget {
  const _AboutPage();

  @override
  State<_AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<_AboutPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ProfileScreenState.background,
      body: Stack(
        children: [
          const _PremiumBackground(),
          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                18,
                8,
                18,
                40,
              ),
              children: [
                Row(
                  children: [
                    _GlassCircleButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'About',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildBrandCard(),
                const SizedBox(height: 18),
                const _AboutFeatureCard(
                  icon: Icons.speed_rounded,
                  title: 'Simple',
                  text:
                      'A clean experience designed to keep everyday ordering quick and understandable.',
                ),
                const _AboutFeatureCard(
                  icon: Icons.bolt_rounded,
                  title: 'Fast',
                  text:
                      'Built around quick discovery, ordering and account management.',
                ),
                const _AboutFeatureCard(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Thoughtful',
                  text:
                      'Premium visual details are used to improve the experience, not simply decorate it.',
                ),
                const _AboutFeatureCard(
                  icon: Icons.security_rounded,
                  title: 'Built Securely',
                  text:
                      'Account authentication is powered through Firebase Authentication.',
                ),
                const SizedBox(height: 10),
                _buildStudioCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        22,
        32,
        22,
        30,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF090909),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: _ProfileScreenState.gold.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 6.283185,
                child: child,
              );
            },
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    _ProfileScreenState.goldLight,
                    _ProfileScreenState.gold,
                    _ProfileScreenState.goldDark,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _ProfileScreenState.gold
                        .withValues(alpha: 0.18),
                    blurRadius: 28,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.black,
                size: 29,
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'BHŪCHAR PAN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 3.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'BUILT FOR THE EVERYDAY',
            style: TextStyle(
              color: _ProfileScreenState.gold,
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Bhuchar Pan is a digital expression of a local tradition, crafted around a simple idea: ordering everyday products should feel fast, clear and effortless.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _ProfileScreenState.textSecondary,
              fontSize: 10,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudioCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.022),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.045),
        ),
      ),
      child: const Column(
        children: [
          Text(
            'BHŪCHAR STUDIOS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.8,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'DESIGNED  •  BUILT  •  CRAFTED',
            style: TextStyle(
              color: Color(0xFF555555),
              fontSize: 7,
              letterSpacing: 1.7,
            ),
          ),
          SizedBox(height: 18),
          Text(
            'DEVAM NAMERA',
            style: TextStyle(
              color: _ProfileScreenState.gold,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Founder & Creator',
            style: TextStyle(
              color: _ProfileScreenState.textMuted,
              fontSize: 8,
            ),
          ),
          SizedBox(height: 18),
          Text(
            '© 2026 Bhuchar Pan',
            style: TextStyle(
              color: Color(0xFF303030),
              fontSize: 7,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _AboutFeatureCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.022),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.045),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: _ProfileScreenState.gold
                  .withValues(alpha: 0.065),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: _ProfileScreenState.gold,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: const TextStyle(
                    color: _ProfileScreenState.textSecondary,
                    fontSize: 9,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* LEGAL PAGE                                                                 */
/* -------------------------------------------------------------------------- */

enum _LegalType {
  privacy,
  terms,
  refund,
  delivery,
}

class _LegalPage extends StatelessWidget {
  final _LegalType type;

  const _LegalPage({
    required this.type,
  });

  String get title {
    switch (type) {
      case _LegalType.privacy:
        return 'Privacy Policy';
      case _LegalType.terms:
        return 'Terms & Conditions';
      case _LegalType.refund:
        return 'Refund & Cancellation';
      case _LegalType.delivery:
        return 'Delivery Policy';
    }
  }

  String get content {
    switch (type) {
      case _LegalType.privacy:
        return '''
Privacy Policy

Bhuchar Pan respects your privacy and aims to collect only information required to provide the application and ordering experience.

Account Information

Your account may contain information such as your name and email address. Authentication is handled through Firebase Authentication.

Orders

Order information may be stored to provide order history, order processing and customer support.

Security

Reasonable technical measures are used to protect application data. No internet-connected system can promise absolute security.

Third-Party Services

The application may use trusted third-party services for authentication, analytics, payments, hosting or other operational requirements.

Data Usage

Information should be used only for legitimate application functionality, service delivery, support and legally required purposes.

Updates

This policy may be updated as the application evolves.
''';

      case _LegalType.terms:
        return '''
Terms & Conditions

By using Bhuchar Pan, you agree to use the application lawfully and responsibly.

Account

You are responsible for maintaining access to your account and for activity performed through it.

Orders

Product availability, pricing, delivery estimates and order acceptance may change based on operational conditions.

Payments

Payments may be processed through supported third-party payment providers.

Prohibited Use

You must not misuse the application, attempt unauthorized access, interfere with service operation or use the platform for unlawful activities.

Service Availability

Features may be modified, temporarily unavailable or discontinued when operationally necessary.

Changes

Bhuchar Pan may update features, policies or service availability as the platform develops.
''';

      case _LegalType.refund:
        return '''
Refund & Cancellation

Orders may be cancelled according to the operational rules applicable to the order.

Cancellation

Cancellation availability may depend on the current status of the order. Orders already prepared or dispatched may not be cancellable.

Refunds

Where a refund is approved, the refund method and processing time may depend on the original payment method and payment provider.

Damaged or Incorrect Orders

If an order is incorrect or arrives damaged, contact support with the order information as soon as reasonably possible.

Policy Changes

Refund and cancellation rules may be updated as the service develops.
''';

      case _LegalType.delivery:
        return '''
Delivery Policy

Bhuchar Pan aims to provide reliable and timely local delivery.

Delivery Area

Delivery availability depends on the service area currently supported by Bhuchar Pan.

Delivery Time

Estimated delivery times are not guaranteed and may change because of traffic, weather, product availability, operational conditions or other factors.

Order Accuracy

Please review your delivery information before placing an order.

Failed Delivery

If delivery cannot be completed because the provided information is incorrect or the recipient is unavailable, additional delivery arrangements may be required.

Support

For delivery issues, contact Bhuchar Pan support with your order details.
''';
    }
  }

  @override
  Widget build(BuildContext context) {
    final paragraphs = content
        .trim()
        .split('\n\n');

    return Scaffold(
      backgroundColor: _ProfileScreenState.background,
      appBar: AppBar(
        backgroundColor: _ProfileScreenState.background,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          20,
          8,
          20,
          40,
        ),
        itemCount: paragraphs.length,
        itemBuilder: (context, index) {
          final paragraph = paragraphs[index];

          final isHeading = index == 0 ||
              _looksLikeHeading(paragraph);

          return Padding(
            padding: EdgeInsets.only(
              bottom: isHeading ? 9 : 17,
            ),
            child: Text(
              paragraph,
              style: TextStyle(
                color: isHeading
                    ? Colors.white
                    : _ProfileScreenState.textSecondary,
                fontSize: isHeading ? 14 : 10,
                fontWeight: isHeading
                    ? FontWeight.w700
                    : FontWeight.w400,
                height: isHeading ? 1.4 : 1.7,
              ),
            ),
          );
        },
      ),
    );
  }

  bool _looksLikeHeading(String value) {
    const headings = [
      'Account Information',
      'Orders',
      'Security',
      'Third-Party Services',
      'Data Usage',
      'Updates',
      'Account',
      'Payments',
      'Prohibited Use',
      'Service Availability',
      'Changes',
      'Cancellation',
      'Refunds',
      'Damaged or Incorrect Orders',
      'Policy Changes',
      'Delivery Area',
      'Delivery Time',
      'Order Accuracy',
      'Failed Delivery',
      'Support',
    ];

    return headings.contains(value.trim());
  }
}

/* -------------------------------------------------------------------------- */
/* END                                                                        */
/* -------------------------------------------------------------------------- */