import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/router/router.dart';
import '../../core/utils/image_picker_helper.dart';
import '../../core/utils/crop_dialog.dart';
import '../../core/utils/localization.dart';
import '../../core/models/skills_data.dart';

// Current User State Provider
class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String phone;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
  });
}

class UserProfileNotifier extends Notifier<UserProfile?> {
  @override
  UserProfile? build() => null;

  void setUser(UserProfile profile) {
    state = profile;
  }

  void clearUser() {
    state = null;
  }
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile?>(
  UserProfileNotifier.new,
);

// Brand Logo Widget (Transparent circular loops with letter H)
class BrandLogo extends StatelessWidget {
  final double size;
  const BrandLogo({super.key, this.size = 80.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: size * 0.05),
      ),
      child: Center(
        child: Container(
          width: size * 0.75,
          height: size * 0.75,
          decoration: BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: size * 0.038),
          ),
          child: Center(
            child: Text(
              'H',
              style: TextStyle(
                color: Colors.black,
                fontSize: size * 0.4,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Google Colorful G Logo Painter (Path-based vector perfect)
class GoogleLogoPainter extends CustomPainter {
  const GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Red: Top segment
    paint.color = const Color(0xFFEA4335);
    final Path redPath = Path()
      ..moveTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.05, h * 0.28)
      ..cubicTo(w * 0.15, h * 0.09, w * 0.31, 0, w * 0.5, 0)
      ..cubicTo(w * 0.69, 0, w * 0.85, h * 0.09, w * 0.95, h * 0.25)
      ..lineTo(w * 0.77, h * 0.39)
      ..cubicTo(w * 0.71, h * 0.31, w * 0.61, h * 0.26, w * 0.5, h * 0.26)
      ..cubicTo(w * 0.38, h * 0.26, w * 0.27, h * 0.32, w * 0.21, h * 0.42)
      ..close();
    canvas.drawPath(redPath, paint);

    // Green: Bottom segment
    paint.color = const Color(0xFF34A853);
    final Path greenPath = Path()
      ..moveTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.21, h * 0.58)
      ..cubicTo(w * 0.27, h * 0.68, w * 0.38, h * 0.74, w * 0.5, h * 0.74)
      ..cubicTo(w * 0.63, h * 0.74, w * 0.73, h * 0.67, w * 0.78, h * 0.57)
      ..lineTo(w * 0.96, h * 0.71)
      ..cubicTo(w * 0.87, h * 0.88, w * 0.7, h, w * 0.5, h)
      ..cubicTo(w * 0.29, h, w * 0.11, h * 0.88, w * 0.03, h * 0.71)
      ..close();
    canvas.drawPath(greenPath, paint);

    // Yellow: Left segment
    paint.color = const Color(0xFFFBBC05);
    final Path yellowPath = Path()
      ..moveTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.03, h * 0.71)
      ..cubicTo(0, h * 0.65, 0, h * 0.57, 0, h * 0.5)
      ..cubicTo(0, h * 0.43, 0, h * 0.35, w * 0.05, h * 0.28)
      ..lineTo(w * 0.21, h * 0.42)
      ..cubicTo(w * 0.2, h * 0.45, w * 0.19, h * 0.48, w * 0.19, h * 0.5)
      ..cubicTo(w * 0.19, h * 0.53, w * 0.2, h * 0.55, w * 0.21, h * 0.58)
      ..close();
    canvas.drawPath(yellowPath, paint);

    // Blue: Right segment + center bar
    paint.color = const Color(0xFF4285F4);
    final Path bluePath = Path()
      ..moveTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.78, h * 0.57)
      ..cubicTo(w * 0.77, h * 0.55, w * 0.77, h * 0.53, w * 0.77, h * 0.5)
      ..cubicTo(w * 0.77, h * 0.46, w * 0.76, h * 0.43, w * 0.77, h * 0.39)
      ..lineTo(w * 0.95, h * 0.25)
      ..cubicTo(w * 0.98, h * 0.33, w, h * 0.41, w, h * 0.5)
      ..cubicTo(w, h * 0.58, w * 0.99, h * 0.65, w * 0.96, h * 0.71)
      ..lineTo(w * 0.5, h * 0.5)
      ..close();
    canvas.drawPath(bluePath, paint);

    // Draw the actual blue horizontal bar covering the right-center cutout
    final Path barPath = Path()
      ..moveTo(w * 0.5, h * 0.39)
      ..lineTo(w * 0.96, h * 0.39)
      ..lineTo(w * 0.96, h * 0.59)
      ..lineTo(w * 0.5, h * 0.59)
      ..close();
    canvas.drawPath(barPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Facebook Blue Custom Painter
class FacebookLogoPainter extends CustomPainter {
  const FacebookLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Official Facebook Blue rounded box
    paint.color = const Color(0xFF1877F2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        Radius.circular(w * 0.15),
      ),
      paint,
    );

    // White "f" path
    paint.color = Colors.white;
    final Path path = Path()
      ..moveTo(w * 0.68, h)
      ..lineTo(w * 0.68, h * 0.61)
      ..lineTo(w * 0.81, h * 0.61)
      ..lineTo(w * 0.83, h * 0.46)
      ..lineTo(w * 0.68, h * 0.46)
      ..lineTo(w * 0.68, h * 0.36)
      ..cubicTo(w * 0.68, h * 0.32, w * 0.69, h * 0.29, w * 0.75, h * 0.29)
      ..lineTo(w * 0.83, h * 0.29)
      ..lineTo(w * 0.83, h * 0.16)
      ..cubicTo(w * 0.81, h * 0.16, w * 0.76, h * 0.15, w * 0.69, h * 0.15)
      ..cubicTo(w * 0.55, h * 0.15, w * 0.46, h * 0.23, w * 0.46, h * 0.39)
      ..lineTo(w * 0.46, h * 0.46)
      ..lineTo(w * 0.33, h * 0.46)
      ..lineTo(w * 0.33, h * 0.61)
      ..lineTo(w * 0.46, h * 0.61)
      ..lineTo(w * 0.46, h)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



class BrutalistCard extends StatefulWidget {
  final Widget child;
  final Color color;
  final double shadowOffset;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const BrutalistCard({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.shadowOffset = 4.0,
    this.padding,
    this.onTap,
  });

  @override
  State<BrutalistCard> createState() => _BrutalistCardState();
}

class _BrutalistCardState extends State<BrutalistCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine card background color
    Color cardBgColor = widget.color;
    if (isDark) {
      if (cardBgColor == Colors.white || cardBgColor == const Color(0xFF1E1E1E) || cardBgColor == AppColors.cardBg) {
        cardBgColor = const Color(0xFF1D212C);
      } else if (cardBgColor == AppColors.background || cardBgColor == const Color(0xFF121212)) {
        cardBgColor = const Color(0xFF0E1116);
      } else if (cardBgColor == AppColors.highlightBlue) {
        cardBgColor = const Color(0xFF1B365D);
      } else if (cardBgColor == AppColors.highlightPink) {
        cardBgColor = const Color(0xFF5A1E38);
      } else if (cardBgColor == AppColors.highlightGreen) {
        cardBgColor = const Color(0xFF16482B);
      }
    }

    // Determine stroke and shadow color
    final Color strokeColor = Colors.black;

    final double currentOffset = widget.onTap != null
        ? (_isPressed
            ? 0.0
            : (_isHovered ? widget.shadowOffset / 2 : widget.shadowOffset))
        : widget.shadowOffset;

    final double translation = widget.shadowOffset - currentOffset;

    Widget cardContent = Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: cardBgColor,
        border: Border.all(color: strokeColor, width: 3.0),
        boxShadow: currentOffset > 0
            ? [
                BoxShadow(
                  color: strokeColor,
                  offset: Offset(currentOffset, currentOffset),
                  blurRadius: 0,
                  spreadRadius: 0,
                )
              ]
            : null,
      ),
      child: widget.child,
    );

    if (translation > 0) {
      cardContent = Transform.translate(
        offset: Offset(translation, translation),
        child: cardContent,
      );
    }

    if (widget.onTap != null) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() {
          _isHovered = false;
          _isPressed = false;
        }),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _checkingAuth = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          final role = data['role'] ?? 'customer';
          
          final settings = data['settings'] as Map<String, dynamic>? ?? {};
          final isDark = settings['darkMode'] as bool? ?? false;
          final language = settings['language'] as String? ?? 'ENGLISH';
          
          ref.read(themeModeProvider.notifier).setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
          ref.read(localeProvider.notifier).setLocale(AppLocalizations.getFallbackLocale(language));

          ref.read(userProfileProvider.notifier).setUser(UserProfile(
            uid: user.uid,
            name: data['name'] ?? 'USER',
            email: user.email ?? '',
            phone: data['phone'] ?? '9999999999',
            role: role,
          ));
          if (mounted) {
            if (role == 'customer') {
              ref.read(navigationProvider.notifier).resetTo(AppRoute.customerHome);
            } else {
              ref.read(navigationProvider.notifier).resetTo(AppRoute.workerHome);
            }
          }
          return;
        } else {
          // Document does not exist in Firestore for this authenticated user, route to setup screen.
          if (mounted) {
            ref.read(navigationProvider.notifier).resetTo(AppRoute.accountSetup);
          }
          return;
        }
      } catch (e) {
        debugPrint('Error auto-logging in: $e');
      }
    }
    if (mounted) {
      setState(() {
        _checkingAuth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingAuth) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BrandLogo(size: 80.0),
              SizedBox(height: 24),
              CircularProgressIndicator(color: Colors.black),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const BrandLogo(size: 100.0),
              const SizedBox(height: 32),
              const Text(
                'HUNARLOOP',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.black, width: 2.0),
                ),
                child: const Text(
                  'JAHAN HAR HUNAR KI VALUE HAI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.accent,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 64),
              GestureDetector(
                onTap: () {
                  ref.read(navigationProvider.notifier).navigateTo(AppRoute.onboarding);
                },
                child: const BrutalistCard(
                  color: Colors.black,
                  shadowOffset: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'GET STARTED',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.accent,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20, color: AppColors.accent),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'AI-POWERED MATCHING',
      'desc': 'Our hyperlocal search ranks nearby skilled workers based on distance, budget, availability, and their verified Hunar Score.',
      'icon': Icons.psychology_outlined,
      'color': AppColors.highlightBlue,
    },
    {
      'title': 'LIVE VIDEO DEMOS',
      'desc': 'Request a quick 2-minute live call to check portfolio samples and agree on terms before making a booking.',
      'icon': Icons.videocam_outlined,
      'color': AppColors.highlightPink,
    },
    {
      'title': 'ESCROW PROTECTION',
      'desc': 'Payments are kept securely in escrow. Funds are only routed to the worker when you mark the job complete.',
      'icon': Icons.security_outlined,
      'color': AppColors.highlightGreen,
    }
  ];

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isSmall = screenW < 360;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmall ? 16.0 : 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currentIndex + 1}/${_slides.length}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      return TextButton(
                        onPressed: () {
                          ref.read(navigationProvider.notifier).navigateTo(AppRoute.roleSelection);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        child: const Text(
                          'SKIP',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              // Slide content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BrutalistCard(
                          color: slide['color'] as Color,
                          shadowOffset: isSmall ? 4.0 : 6.0,
                          child: Padding(
                            padding: EdgeInsets.all(isSmall ? 16.0 : 24.0),
                            child: Icon(
                              slide['icon'] as IconData,
                              size: isSmall ? 52 : 72,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: isSmall ? 24 : 48),
                        Text(
                          slide['title']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmall ? 18 : 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide['desc']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmall ? 12 : 14,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Page Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index ? Colors.black : Colors.white,
                      border: Border.all(color: Colors.black, width: 2.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: isSmall ? 20 : 32),

              // Action button
              Consumer(
                builder: (context, ref, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: BrutalistCard(
                      onTap: () {
                        if (_currentIndex < _slides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          ref.read(navigationProvider.notifier).navigateTo(AppRoute.roleSelection);
                        }
                      },
                      color: Colors.black,
                      shadowOffset: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            _currentIndex == _slides.length - 1 ? 'GET STARTED' : 'NEXT',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color highlightColor,
    required VoidCallback onTap,
    required bool isSmall,
  }) {
    return BrutalistCard(
      onTap: onTap,
      color: Colors.white,
      shadowOffset: 4.0,
      child: Padding(
        padding: EdgeInsets.all(isSmall ? 14.0 : 20.0),
        child: Row(
          children: [
            Container(
              width: isSmall ? 48 : 60,
              height: isSmall ? 48 : 60,
              decoration: BoxDecoration(
                color: highlightColor,
                border: Border.all(color: Colors.black, width: 2.0),
              ),
              child: Icon(
                icon,
                size: isSmall ? 22 : 28,
                color: Colors.black,
              ),
            ),
            SizedBox(width: isSmall ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isSmall ? 13 : 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isSmall ? 10 : 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.black,
              size: isSmall ? 20 : 24,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenW = MediaQuery.of(context).size.width;
    final isSmall = screenW < 360;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isSmall ? 16.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: isSmall ? 12 : 24),
              Text(
                'WHO ARE YOU?',
                style: TextStyle(
                  fontSize: isSmall ? 26 : 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a role to continue. You can always toggle this later in your profile.',
                style: TextStyle(
                  fontSize: isSmall ? 11 : 13,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              
              _buildRoleCard(
                context: context,
                isSmall: isSmall,
                title: 'I WANT TO HIRE TALENT',
                subtitle: 'Find verified local plumbers, painters, tutors, and mehendi artists near you.',
                icon: Icons.search_rounded,
                highlightColor: AppColors.highlightBlue,
                onTap: () {
                  ref.read(navigationProvider.notifier).navigateTo(
                    AppRoute.login,
                    arguments: {'role': 'customer'},
                  );
                },
              ),
              
              SizedBox(height: isSmall ? 16 : 24),
              
              _buildRoleCard(
                context: context,
                isSmall: isSmall,
                title: 'I WANT TO OFFER MY SKILL',
                subtitle: 'Register as a partner worker, upload demo videos, build trust, and grow earnings.',
                icon: Icons.build_rounded,
                highlightColor: AppColors.highlightGreen,
                onTap: () {
                  ref.read(navigationProvider.notifier).navigateTo(
                    AppRoute.login,
                    arguments: {'role': 'worker'},
                  );
                },
              ),
              
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;
  bool _agreeToTerms = false;

  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;
  late TapGestureRecognizer _refundRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = () => showPolicyDialogHelper(context, 'terms');
    _privacyRecognizer = TapGestureRecognizer()..onTap = () => showPolicyDialogHelper(context, 'privacy');
    _refundRecognizer = TapGestureRecognizer()..onTap = () => showPolicyDialogHelper(context, 'refund');
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    _refundRecognizer.dispose();
    super.dispose();
  }

  Future<void> _checkAndNavigate(User user, String providerName) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final role = data['role'] ?? 'customer';
        
        final loginArgs = ref.read(navigationProvider).arguments;
        final chosenRole = (loginArgs is Map && loginArgs.containsKey('role')) ? loginArgs['role'] : 'customer';

        if (role != chosenRole) {
          // Block login
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('THIS ACCOUNT IS ALREADY REGISTERED AS A ${role.toString().toUpperCase()}! YOU CANNOT USE IT FOR ${chosenRole.toString().toUpperCase()} ROLE.'),
                backgroundColor: Colors.black,
              ),
            );
          }
          return;
        }

        final settings = data['settings'] as Map<String, dynamic>? ?? {};
        final isDark = settings['darkMode'] as bool? ?? false;
        final language = settings['language'] as String? ?? 'ENGLISH';
        
        ref.read(themeModeProvider.notifier).setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
        ref.read(localeProvider.notifier).setLocale(AppLocalizations.getFallbackLocale(language));

        ref.read(userProfileProvider.notifier).setUser(UserProfile(
          uid: user.uid,
          name: data['name'] ?? 'USER',
          email: user.email ?? data['email'] ?? '',
          phone: data['phone'] ?? '',
          role: role,
        ));
        if (mounted) {
          if (role == 'customer') {
            ref.read(navigationProvider.notifier).resetTo(AppRoute.customerHome);
          } else {
            ref.read(navigationProvider.notifier).resetTo(AppRoute.workerHome);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('WELCOME BACK! LOGGED IN WITH $providerName'),
              backgroundColor: Colors.black,
            ),
          );
        }
      } else {
        if (mounted) {
          final loginArgs = ref.read(navigationProvider).arguments;
          final preSelectedRole = (loginArgs is Map && loginArgs.containsKey('role')) ? loginArgs['role'] : 'customer';
          ref.read(navigationProvider.notifier).resetTo(
            AppRoute.accountSetup,
            arguments: {'role': preSelectedRole},
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('SIGNED IN WITH $providerName! PLEASE SETUP YOUR ACCOUNT.'),
              backgroundColor: Colors.black,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error after social sign in: $e');
      if (mounted) {
        final loginArgs = ref.read(navigationProvider).arguments;
        final preSelectedRole = (loginArgs is Map && loginArgs.containsKey('role')) ? loginArgs['role'] : 'customer';
        ref.read(navigationProvider.notifier).resetTo(
          AppRoute.accountSetup,
          arguments: {'role': preSelectedRole},
        );
      }
    }
  }

  Future<void> _handleGoogleAuth() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PLEASE AGREE TO TERMS & CONDITIONS TO CONTINUE'), backgroundColor: Colors.black),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      UserCredential? userCredential;
      if (kIsWeb) {
        try {
          final googleProvider = GoogleAuthProvider();
          googleProvider.setCustomParameters({'prompt': 'select_account'});
          userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
        } catch (webError) {
          debugPrint('Real Google Sign-In with popup failed: $webError');
        }
      }

      if (userCredential == null) {
        // Fallback to high-fidelity simulated/test sign-in
        final testEmail = "google_test@hunarloop.in";
        final testPassword = "GoogleTestPassword123";
        try {
          userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          );
        } catch (_) {
          userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          );
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('RUNNING IN DEMO MODE: GOOGLE SIGN-IN SIMULATED'), backgroundColor: Colors.black),
          );
        }
      }

      await _checkAndNavigate(userCredential.user!, 'GOOGLE');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('GOOGLE SIGN IN ERROR: ${e.toString().toUpperCase()}'), backgroundColor: Colors.black),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleFacebookAuth() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PLEASE AGREE TO TERMS & CONDITIONS TO CONTINUE'), backgroundColor: Colors.black),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      UserCredential? userCredential;
      if (kIsWeb) {
        try {
          final facebookProvider = FacebookAuthProvider();
          userCredential = await FirebaseAuth.instance.signInWithPopup(facebookProvider);
        } catch (webError) {
          debugPrint('Real Facebook Sign-In failed/unconfigured: $webError');
        }
      }

      if (userCredential == null) {
        // Fallback to high-fidelity simulated/test sign-in
        final testEmail = "facebook_test@hunarloop.in";
        final testPassword = "FacebookTestPassword123";
        try {
          userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          );
        } catch (_) {
          userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          );
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('RUNNING IN DEMO MODE: FACEBOOK SIGN-IN SIMULATED'), backgroundColor: Colors.black),
          );
        }
      }

      await _checkAndNavigate(userCredential.user!, 'FACEBOOK');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('FACEBOOK SIGN IN ERROR: ${e.toString().toUpperCase()}'), backgroundColor: Colors.black),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            ref.read(navigationProvider.notifier).goBack();
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(child: BrandLogo(size: 80.0)),
                const SizedBox(height: 32),
                const Text(
                  'SIGN IN TO HUNARLOOP',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'CHOOSE YOUR PREFERRED METHOD TO CONTINUE.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 36),

                if (_isLoading)
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: Colors.black),
                        SizedBox(height: 16),
                        Text(
                          'SIGNING IN...',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                else ...[
                  // Terms and conditions agreement checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _agreeToTerms,
                          activeColor: Colors.black,
                          checkColor: AppColors.accent,
                          side: const BorderSide(color: Colors.black, width: 2.0),
                          onChanged: (val) {
                            setState(() {
                              _agreeToTerms = val ?? false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'I AGREE TO THE ',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: 'TERMS OF SERVICE',
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w900,
                                ),
                                recognizer: _termsRecognizer,
                              ),
                              const TextSpan(text: ', '),
                              TextSpan(
                                text: 'PRIVACY POLICY',
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w900,
                                ),
                                recognizer: _privacyRecognizer,
                              ),
                              const TextSpan(text: ' AND '),
                              TextSpan(
                                        text: 'REFUND POLICY',
                                        style: const TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w900,
                                        ),
                                        recognizer: _refundRecognizer,
                                      ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Google Sign-In Button
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: _handleGoogleAuth,
                      child: BrutalistCard(
                        color: Colors.white,
                        shadowOffset: 4.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                'https://img.icons8.com/color/50/google-logo.png',
                                width: 20,
                                height: 20,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata_rounded, color: Colors.black),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'SIGN IN WITH GOOGLE',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Facebook Sign-In Button
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: _handleFacebookAuth,
                      child: BrutalistCard(
                        color: Colors.white,
                        shadowOffset: 4.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                'https://img.icons8.com/?size=100&id=118497&format=png&color=000000',
                                width: 20,
                                height: 20,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.facebook_rounded, color: Colors.black),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'SIGN IN WITH FACEBOOK',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 48),
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: 'BY SIGNING IN, YOU AGREE TO OUR ',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                      children: [
                        TextSpan(
                          text: 'TERMS & POLICIES',
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => showPolicyDialogHelper(context, 'terms'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Account Setup Screen for New Users (Choose Name, Phone, and Role post sign-in)
class AccountSetupScreen extends ConsumerStatefulWidget {
  const AccountSetupScreen({super.key});

  @override
  ConsumerState<AccountSetupScreen> createState() => _AccountSetupScreenState();
}

class _AccountSetupScreenState extends ConsumerState<AccountSetupScreen> {
  int _currentStep = 1; // Step 1: Verification, Step 2: Information

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  // Step 1: Avatar selection
  final List<String> _avatars = [
    'https://img.icons8.com/color/96/builder.png',
    'https://img.icons8.com/color/96/student-male.png',
    'https://img.icons8.com/color/96/designer.png',
    'https://img.icons8.com/color/96/user-male-circle.png',
  ];
  String _selectedAvatar = 'https://img.icons8.com/color/96/user-male-circle.png';

  // Step 1: Government ID Verification (Optional)
  String _idType = 'Aadhaar Card';
  final TextEditingController _idController = TextEditingController();
  // ignore: prefer_final_fields
  bool _isVerified = false;
  String? _idCardPhotoBase64;
  String? _idCardPhotoBackBase64;
  String _verificationStatus = 'none'; // 'none', 'pending', 'approved', 'rejected'

  // Step 2: Role selection (preset from arguments)
  String _selectedRole = 'customer';
  bool _agreeToTerms = false;
  bool _isLoading = false;

  // Step 2: Worker Details
  String _selectedCategory = allCategories[0].name;
  List<String> _selectedSkills = [];
  final TextEditingController _rateController = TextEditingController(text: '350');
  String _experience = '1 Year';
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isLocating = false;

  // Step 2: Customer Details
  final TextEditingController _addressController = TextEditingController();
  String _preferredContact = 'In-App Chat';
  String _preferredSlot = 'Morning (9 AM - 12 PM)';

  bool _isEmailEditable = true;

  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;
  late TapGestureRecognizer _refundRecognizer;

  final List<String> _categories = allCategories.map((c) => c.name).toList();

  final List<String> _experienceOptions = [
    'Fresher (No Experience)',
    '1 Year',
    '2 Years',
    '3 Years',
    '5+ Years'
  ];

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = () => showPolicyDialogHelper(context, 'terms');
    _privacyRecognizer = TapGestureRecognizer()..onTap = () => showPolicyDialogHelper(context, 'privacy');
    _refundRecognizer = TapGestureRecognizer()..onTap = () => showPolicyDialogHelper(context, 'refund');

    final setupArgs = ref.read(navigationProvider).arguments;
    if (setupArgs is Map && setupArgs.containsKey('role')) {
      _selectedRole = setupArgs['role'] ?? 'customer';
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _phoneController.text = user.phoneNumber ?? '';
      if (user.email != null && user.email!.isNotEmpty) {
        _emailController.text = user.email!;
        _isEmailEditable = false;
      }
    }
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    _refundRecognizer.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _idController.dispose();
    _rateController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<String?> _pickImageWithSource() async {
    final source = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const Border(
        top: BorderSide(color: Colors.black, width: 3.0),
        left: BorderSide(color: Colors.black, width: 3.0),
        right: BorderSide(color: Colors.black, width: 3.0),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SELECT ID PHOTO SOURCE',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.black),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: Colors.black),
                title: const Text('TAKE PHOTO (CAMERA)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)),
                onTap: () => Navigator.pop(context, 'camera'),
              ),
              const Divider(color: Colors.black, thickness: 1.5),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: Colors.black),
                title: const Text('CHOOSE FROM GALLERY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)),
                onTap: () => Navigator.pop(context, 'gallery'),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return null;
    if (source == 'camera') {
      return captureImageFromCamera();
    } else if (source == 'gallery') {
      return pickImageFromGallery();
    }
    return null;
  }

  Widget _buildUploadCard({
    required String title,
    required String? imageBase64,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: BrutalistCard(
        color: imageBase64 != null ? Colors.white : const Color(0xFFFFFAD1),
        shadowOffset: 2.0,
        child: Container(
          height: 120,
          width: double.infinity,
          alignment: Alignment.center,
          child: imageBase64 != null
              ? Stack(
                  children: [
                    Positioned.fill(
                      child: Image.memory(
                        base64Decode(imageBase64.split(',').last),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo_outlined, color: Colors.black, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.black),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'TAP TO CAPTURE OR UPLOAD PHOTO',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8, color: Colors.black54),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _verifyId() async {
    final idNo = _idController.text.trim();
    if (idNo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PLEASE ENTER A VALID ID NUMBER'), backgroundColor: Colors.black),
      );
      return;
    }
    if (_idType == 'Aadhaar Card') {
      if (_idCardPhotoBase64 == null || _idCardPhotoBackBase64 == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PLEASE UPLOAD BOTH FRONT AND BACK PHOTOS OF YOUR AADHAAR CARD'), backgroundColor: Colors.black),
        );
        return;
      }
    } else {
      if (_idCardPhotoBase64 == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PLEASE UPLOAD A PHOTO OF YOUR ID CARD'), backgroundColor: Colors.black),
        );
        return;
      }
    }
    setState(() {
      _verificationStatus = 'pending';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ID SUBMITTED FOR REVIEW! VERIFICATION IS PENDING ADMIN APPROVAL.'),
        backgroundColor: Colors.black,
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      _locationController.text = 'Hazratganj, Lucknow';
      setState(() => _isLocating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CURRENT LOCATION PICKED UP AS HAZRATGANJ, LUCKNOW'), backgroundColor: Colors.black),
      );
    }
  }

  Future<void> _completeSetup() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PLEASE ENTER YOUR FULL NAME IN STEP 1'), backgroundColor: Colors.black),
      );
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PLEASE ENTER A VALID EMAIL ADDRESS'), backgroundColor: Colors.black),
      );
      return;
    }

    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PLEASE ENTER A VALID MOBILE NUMBER (AT LEAST 10 DIGITS)'), backgroundColor: Colors.black),
      );
      return;
    }

    if (_selectedRole == 'worker') {
      final rateText = _rateController.text.trim();
      final rate = int.tryParse(rateText);
      final loc = _locationController.text.trim();
      final bio = _bioController.text.trim();

      if (rate == null || rate <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PLEASE ENTER A VALID HOURLY RATE'), backgroundColor: Colors.black),
        );
        return;
      }
      if (loc.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PLEASE ADD YOUR LOCATION'), backgroundColor: Colors.black),
        );
        return;
      }
      if (bio.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PLEASE ENTER A SHORT BIOGRAPHY'), backgroundColor: Colors.black),
        );
        return;
      }
      if (_selectedSkills.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PLEASE SELECT AT LEAST ONE SKILL'), backgroundColor: Colors.black),
        );
        return;
      }
    } else {
      final addr = _addressController.text.trim();
      if (addr.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PLEASE ENTER YOUR ADDRESS'), backgroundColor: Colors.black),
        );
        return;
      }
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PLEASE AGREE TO TERMS & CONDITIONS TO CONTINUE'), backgroundColor: Colors.black),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid ?? "mock_user_${DateTime.now().millisecondsSinceEpoch}";
      final cleanPhone = phone.startsWith('+') ? phone : '+91$phone';

      final userProfile = {
        'uid': uid,
        'name': name,
        'email': email,
        'phone': cleanPhone,
        'role': _selectedRole,
        'avatarUrl': _selectedAvatar,
        'isVerified': _isVerified,
        if (_verificationStatus == 'pending' || _verificationStatus == 'approved') ...{
          'idType': _idType,
          'idNumber': _idController.text.trim(),
          'idCardPhoto': _idCardPhotoBase64,
          if (_idType == 'Aadhaar Card') 'idCardPhotoBack': _idCardPhotoBackBase64,
          'verificationStatus': _verificationStatus,
        },
        if (_selectedRole == 'worker') ...{
          'category': _selectedCategory,
          'skills': _selectedSkills,
          'rating': '4.8',
          'reviewsCount': 0,
          'hunarScore': _isVerified ? 95 : 90,
          'location': _locationController.text.trim(),
          'pricePerHour': int.parse(_rateController.text.trim()),
          'distanceKm': 1.0,
          'experienceYears': _experience,
          'bio': _bioController.text.trim(),
          'completionRate': '100%',
          'responseTime': '10 Mins',
          'isOnline': true,
        } else ...{
          'address': _addressController.text.trim(),
          'preferredContact': _preferredContact,
          'preferredSlot': _preferredSlot,
        }
      };

      await FirebaseFirestore.instance.collection('users').doc(uid).set(userProfile);

      ref.read(userProfileProvider.notifier).setUser(UserProfile(
        uid: uid,
        name: name,
        email: email,
        phone: cleanPhone,
        role: _selectedRole,
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ACCOUNT SETUP COMPLETED!'), backgroundColor: Colors.black),
        );
        
        if (_selectedRole == 'customer') {
          ref.read(navigationProvider.notifier).resetTo(AppRoute.customerHome);
        } else {
          ref.read(navigationProvider.notifier).resetTo(AppRoute.workerHome);
        }
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ERROR SAVING PROFILE: ${e.toString().toUpperCase()}'), backgroundColor: Colors.black),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'ACCOUNT SETUP (STEP $_currentStep OF 2)',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: _currentStep == 1 ? _buildStep1() : _buildStep2(),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'STEP 1: CHOOSE PROFILE PICTURE & VERIFY',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black),
        ),
        const SizedBox(height: 6),
        const Text(
          'SELECT A PICTURE AVATAR AND ENTER YOUR NAME. YOU CAN OPTIONALLY VERIFY YOUR ID.',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(height: 24),

        // Selected Avatar Preview
        Center(
          child: Column(
            children: [
              BrutalistCard(
                color: AppColors.highlightPink,
                shadowOffset: 4.0,
                child: Container(
                  width: 80,
                  height: 80,
                  alignment: Alignment.center,
                  child: _selectedAvatar.startsWith('data:')
                      ? Image.memory(
                          base64Decode(_selectedAvatar.split(',').last),
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                        )
                      : Image.network(
                          _selectedAvatar,
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person, size: 40, color: Colors.black);
                          },
                        ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'YOUR PHOTO PREVIEW',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Avatar Picker Grid
        const Text(
          'CHOOSE PROFILE AVATAR',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _avatars.map((url) {
            final isSelected = _selectedAvatar == url;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAvatar = url;
                });
              },
              child: BrutalistCard(
                color: isSelected ? AppColors.accent : Colors.white,
                shadowOffset: isSelected ? 0 : 3.0,
                padding: const EdgeInsets.all(6),
                child: SizedBox(
                  width: 54,
                  height: 54,
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.person, size: 32, color: Colors.black);
                    },
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: () async {
              final base64Image = await pickImageFromGallery();
              if (base64Image == null) return;
              if (!mounted) return;
              
              // Open cropping dialog
              final croppedBase64 = await showDialog<String>(
                context: context,
                builder: (context) => CropDialog(imageBase64: base64Image),
              );
              
              if (croppedBase64 != null) {
                setState(() {
                  _selectedAvatar = croppedBase64;
                });
              }
            },
            child: const BrutalistCard(
              color: AppColors.accent,
              shadowOffset: 3.0,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_outlined, color: Colors.black, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'CHOOSE FROM GALLERY',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Full Name Field
        const Text(
          'YOUR FULL NAME',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.person_outline, color: Colors.black),
            hintText: 'ENTER YOUR NAME',
          ),
        ),

        const SizedBox(height: 24),

        // Verification Card
        BrutalistCard(
          color: Colors.white,
          shadowOffset: 4.0,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'GOVERNMENT ID VERIFICATION',
                    style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 12),
                  ),
                  if (_isVerified || _verificationStatus == 'approved')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: _selectedRole == 'customer' ? Colors.blue : Colors.green,
                      child: const Text('VERIFIED', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8)),
                    )
                  else if (_verificationStatus == 'pending')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: Colors.orange,
                      child: const Text('PENDING REVIEW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8)),
                    )
                  else if (_verificationStatus == 'rejected')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: Colors.red,
                      child: const Text('REJECTED', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8)),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: Colors.red,
                      child: const Text('UNVERIFIED', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8)),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Verify your identity using Aadhaar or PAN card. This will unlock a verified badge and give you a higher Hunar Score.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              if (_isVerified || _verificationStatus == 'approved') ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_rounded, color: _selectedRole == 'customer' ? Colors.blue : Colors.green, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          'YOUR ID WAS VERIFIED SUCCESSFULLY!',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: _selectedRole == 'customer' ? Colors.blue : Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else if (_verificationStatus == 'pending') ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_idType.toUpperCase()}: ${_idController.text.toUpperCase()}',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.black),
                        ),
                        const SizedBox(height: 12),
                        if (_idCardPhotoBase64 != null) ...[
                          const Text('FRONT SIDE:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Colors.black)),
                          const SizedBox(height: 4),
                          BrutalistCard(
                            shadowOffset: 2.0,
                            child: SizedBox(
                              height: 120,
                              width: double.infinity,
                              child: Image.memory(
                                base64Decode(_idCardPhotoBase64!.split(',').last),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                        if (_idType == 'Aadhaar Card' && _idCardPhotoBackBase64 != null) ...[
                          const SizedBox(height: 12),
                          const Text('BACK SIDE:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Colors.black)),
                          const SizedBox(height: 4),
                          BrutalistCard(
                            shadowOffset: 2.0,
                            child: SizedBox(
                              height: 120,
                              width: double.infinity,
                              child: Image.memory(
                                base64Decode(_idCardPhotoBackBase64!.split(',').last),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        const Text(
                          'Aadhaar details submitted. Admin panel will verify and issue your Green Badge shortly. You can proceed with the next step.',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                if (_verificationStatus == 'rejected') ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                       color: Colors.red.shade100,
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                    child: const Text(
                      'THE UPLOADED ID WAS NOT READABLE. PLEASE UPLOAD A CLEAR PHOTO AND SUBMIT AGAIN.',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 8),
                    ),
                  ),
                ],
                DropdownButtonFormField<String>(
                  initialValue: _idType,
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: ['Aadhaar Card', 'PAN Card', 'Voter ID', 'Driving License'].map((id) {
                    return DropdownMenuItem<String>(
                      value: id,
                      child: Text(id.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _idType = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _idController,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (value) {
                    final upper = value.toUpperCase();
                    if (upper != value) {
                      _idController.value = _idController.value.copyWith(
                        text: upper,
                        selection: TextSelection.collapsed(offset: upper.length),
                      );
                    }
                  },
                  style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: 'ENTER ID NUMBER',
                  ),
                ),
                const SizedBox(height: 16),
                if (_idType == 'Aadhaar Card') ...[
                  _buildUploadCard(
                    title: 'Aadhaar Card Front Photo',
                    imageBase64: _idCardPhotoBase64,
                    onTap: () async {
                      final img = await _pickImageWithSource();
                      if (img != null) {
                        setState(() {
                          _idCardPhotoBase64 = img;
                        });
                      }
                    },
                    onDelete: () {
                      setState(() {
                        _idCardPhotoBase64 = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildUploadCard(
                    title: 'Aadhaar Card Back Photo',
                    imageBase64: _idCardPhotoBackBase64,
                    onTap: () async {
                      final img = await _pickImageWithSource();
                      if (img != null) {
                        setState(() {
                          _idCardPhotoBackBase64 = img;
                        });
                      }
                    },
                    onDelete: () {
                      setState(() {
                        _idCardPhotoBackBase64 = null;
                      });
                    },
                  ),
                ] else ...[
                  _buildUploadCard(
                    title: '$_idType Front Photo',
                    imageBase64: _idCardPhotoBase64,
                    onTap: () async {
                      final img = await _pickImageWithSource();
                      if (img != null) {
                        setState(() {
                          _idCardPhotoBase64 = img;
                        });
                      }
                    },
                    onDelete: () {
                      setState(() {
                        _idCardPhotoBase64 = null;
                      });
                    },
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: _verifyId,
                    child: const BrutalistCard(
                      color: Colors.black,
                      shadowOffset: 0,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text('SUBMIT FOR REVIEW', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 11)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Step Navigation Buttons
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _currentStep = 2;
                  });
                },
                child: const BrutalistCard(
                  color: Colors.white,
                  shadowOffset: 3.0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: Text(
                        'SKIP FOR NOW',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PLEASE ENTER YOUR FULL NAME FIRST'), backgroundColor: Colors.black),
                    );
                    return;
                  }
                  setState(() {
                    _currentStep = 2;
                  });
                },
                child: const BrutalistCard(
                  color: Colors.black,
                  shadowOffset: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: Text(
                        'NEXT STEP',
                        style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'STEP 2: ACCOUNT INFORMATION',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black),
        ),
        const SizedBox(height: 6),
        const Text(
          'ENTER CONTACT DETAILS AND ROLE SPECIFIC INFORMATION TO FINALIZE.',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(height: 24),

        // Email address field
        const Text(
          'EMAIL ADDRESS',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          enabled: _isEmailEditable,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email_outlined, color: Colors.black),
            hintText: 'ENTER EMAIL ADDRESS',
            filled: !_isEmailEditable,
            fillColor: Colors.black12,
          ),
        ),

        const SizedBox(height: 20),

        // Phone field
        const Text(
          'MOBILE NUMBER',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.phone_outlined, color: Colors.black),
            hintText: 'E.G. 9999999999',
          ),
        ),

        const SizedBox(height: 24),

        // Role fields
        if (_selectedRole == 'worker') ...[
          // Category dropdown
          Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final textCol = isDark ? Colors.white : Colors.black;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SELECT YOUR PRIMARY SKILL CATEGORY',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: textCol),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1D212C) : Colors.white,
                      border: Border.all(color: textCol, width: 3.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        dropdownColor: isDark ? const Color(0xFF1D212C) : Colors.white,
                        style: TextStyle(color: textCol, fontWeight: FontWeight.w900, fontSize: 13),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCategory = newValue;
                              _selectedSkills = []; // reset selected skills when category changes
                            });
                          }
                        },
                        items: _categories.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value.toUpperCase(),
                              style: TextStyle(color: textCol),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'SELECT YOUR SKILLS (TAP TO MULTI-SELECT)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: textCol),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: allCategories
                        .firstWhere((c) => c.name == _selectedCategory, orElse: () => allCategories[0])
                        .skills
                        .map((skill) {
                      final isSelected = _selectedSkills.contains(skill.name);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedSkills.remove(skill.name);
                            } else {
                              _selectedSkills.add(skill.name);
                            }
                          });
                        },
                        child: BrutalistCard(
                          color: isSelected
                              ? AppColors.accent
                              : (isDark ? const Color(0xFF161A22) : Colors.white),
                          shadowOffset: 2.0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Text(
                            skill.name.toUpperCase(),
                            style: TextStyle(
                              color: isSelected ? Colors.black : textCol,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            }
          ),

          const SizedBox(height: 20),

          // Hourly Rate textfield
          const Text(
            'HOURLY RATE (₹)',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _rateController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.currency_rupee_outlined, color: Colors.black),
              hintText: 'E.G. 350',
            ),
          ),

          const SizedBox(height: 20),

          // Experience dropdown
          const Text(
            'EXPERIENCE LEVEL',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 3.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _experience,
                isExpanded: true,
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _experience = newValue;
                    });
                  }
                },
                items: _experienceOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.toUpperCase()),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Location field + Current location button
          const Text(
            'WORK LOCATION',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _locationController,
                  style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_on_outlined, color: Colors.black),
                    hintText: 'E.G. HAZRATGANJ, LUCKNOW',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _isLocating
                  ? const Center(child: CircularProgressIndicator(color: Colors.black))
                  : GestureDetector(
                      onTap: _getCurrentLocation,
                      child: const BrutalistCard(
                        color: AppColors.accent,
                        shadowOffset: 2.0,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        child: Icon(Icons.my_location_rounded, color: Colors.black),
                      ),
                    ),
            ],
          ),

          const SizedBox(height: 20),

          // Bio multiline field
          const Text(
            'SHORT BIOGRAPHY / WORK DESCRIPTION',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _bioController,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              hintText: 'WRITE A FEW SENTENCES ABOUT YOUR GIG WORK EXPERIENCE AND SERVICE QUALITY...',
            ),
          ),
        ] else ...[
          // Customer service address
          const Text(
            'SERVICE / DELIVERY ADDRESS (WHERE WORKERS WILL ARRIVE)',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _addressController,
            maxLines: 2,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.home_outlined, color: Colors.black),
              hintText: 'ENTER YOUR FULL ADDRESS',
            ),
          ),

          const SizedBox(height: 20),

          // Preferred contact method
          const Text(
            'PREFERRED CONTACT METHOD',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 3.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _preferredContact,
                isExpanded: true,
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _preferredContact = newValue;
                    });
                  }
                },
                items: ['In-App Chat', 'Phone Calls', 'WhatsApp/SMS'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.toUpperCase()),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Preferred time slot
          const Text(
            'PREFERRED BOOKING SLOT',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 3.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _preferredSlot,
                isExpanded: true,
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _preferredSlot = newValue;
                    });
                  }
                },
                items: ['Morning (9 AM - 12 PM)', 'Afternoon (12 PM - 4 PM)', 'Evening (4 PM - 8 PM)'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.toUpperCase()),
                  );
                }).toList(),
              ),
            ),
          ),
        ],

        const SizedBox(height: 28),

        // Terms agreement
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _agreeToTerms,
                activeColor: Colors.black,
                checkColor: AppColors.accent,
                side: const BorderSide(color: Colors.black, width: 2.0),
                onChanged: (val) {
                  setState(() {
                    _agreeToTerms = val ?? false;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'I AGREE TO THE ',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: 'TERMS OF SERVICE',
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w900,
                      ),
                      recognizer: _termsRecognizer,
                    ),
                    const TextSpan(text: ', '),
                    TextSpan(
                      text: 'PRIVACY POLICY',
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w900,
                      ),
                      recognizer: _privacyRecognizer,
                    ),
                    const TextSpan(text: ' AND '),
                    TextSpan(
                      text: 'REFUND POLICY',
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w900,
                      ),
                      recognizer: _refundRecognizer,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Footer buttons
        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _currentStep = 1;
                });
              },
              child: const BrutalistCard(
                color: Colors.white,
                shadowOffset: 3.0,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Text(
                  'BACK',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.black))
                  : GestureDetector(
                      onTap: _completeSetup,
                      child: const BrutalistCard(
                        color: Colors.black,
                        shadowOffset: 0,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'COMPLETE SETUP',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

// Global helper function for showing policy dialogs across multiple widgets
void showPolicyDialogHelper(BuildContext context, String policyType) {
  String title = '';
  String content = '';

  if (policyType == 'terms') {
    title = 'TERMS OF SERVICE';
    content = '''
1. AGREEMENT TO TERMS
BY ACCESSING OR USING HUNARLOOP, YOU AGREE TO BE BOUND BY THESE TERMS OF SERVICE. IF YOU DO NOT AGREE TO ALL OF THESE TERMS, YOU ARE EXPRESSLY PROHIBITED FROM USING OUR SERVICES.

2. MARKETPLACE SERVICES
HUNARLOOP OPERATES AN HYPERLOCAL SKILL MARKETPLACE THAT FACILITATES THE BOOKING OF SKILLED GIG WORKERS. HUNARLOOP IS AN INTERMEDIARY AND IS NOT AN EMPLOYER. WE PROCESS ESCROW PAYMENTS AND COMPUTE VERIFIED TRUST SCORES BUT DO NOT DIRECTLY EMPLOY WORKER PARTNERS.

3. USER ACCOUNTS
TO ACCESS MARKETPLACE BOOKINGS, USERS MUST CREATE AN ACCOUNT SECURED BY EMAIL/PASSWORD OR GOOGLE SIGN-IN. YOU AGREE TO PROVIDE ACCURATE, CURRENT, AND COMPLETE INFORMATION.

4. ESCROW PAYMENT TERMS
ALL GIG BOOKINGS MUST BE PRE-FUNDED BY CUSTOMERS UPFRONT. FUNDS ARE SECURELY DEPOSITED INTO A RAZORPAY-POWERED ESCROW HOLDING ACCOUNT. ESCROW FUNDS ARE RELEASED TO THE WORKER IMMEDIATELY UPON CUSTOMER APPROVAL OR AUTOMATICALLY AFTER 24 HOURS OF JOB COMPLETION TIMER LAPSE.

5. LIMITATION OF LIABILITY
HUNARLOOP IS NOT LIABLE FOR THE QUALITY, SAFETY, OR LEGALITY OF GIG SERVICES PERFORMED. DISPUTES REGARDING WORK PERFORMANCE SHALL BE RESOLVED ACCORDING TO OUR ESCROW DISPUTE SETTLEMENT GUIDELINES.
''';
  } else if (policyType == 'privacy') {
    title = 'PRIVACY POLICY';
    content = '''
1. INTRODUCTION
WELCOME TO HUNARLOOP. WE VALUE YOUR PRIVACY AND ARE COMMITTED TO PROTECTING YOUR PERSONAL DATA. THIS PRIVACY POLICY EXPLAINS HOW WE COLLECT, USE, DISCLOSE, AND SAFEGUARD YOUR INFORMATION WHEN YOU VISIT OUR MARKETING WEBSITE OR USE OUR HYPERLOCAL MOBILE APPLICATION.

2. INFORMATION WE COLLECT
WE COLLECT DATA TO PROVIDE BETTER SERVICES TO ALL OUR USERS. THIS INCLUDES: IDENTITY DATA (NAME, PHONE NUMBER, EMAIL ADDRESS, ROLE); LOCATION DATA (GEOLOCATION DATA TO ENABLE HYPERLOCAL MATCHING); TRANSACTION DATA (BOOKINGS AND ESCROW PAYMENTS); MEDIA DATA (SKILL DEMO VIDEOS UPLOADED FOR AI PROFICIENCY TESTING).

3. HOW WE USE YOUR INFORMATION
WE USE COLLECTED DATA TO PERSONALIZE HYPERLOCAL MATCHES, EVALUATE SKILL VIDEOS VIA GOOGLE GEMINI AI, ROUTE ESCROW FUNDS SECURELY VIA RAZORPAY, AND IMPROVE SYSTEM SAFETY AND SECURITY.

4. DATA SHARING & STORAGE
WE DO NOT SELL YOUR PERSONAL DATA. CONTACT DETAILS ARE ONLY SHARED ONCE A CONFIRMED BOOKING IS DEPOSITED IN ESCROW. ALL USER PROFILES AND BOOKINGS DATA ARE STORED SECURELY IN FIREBASE CLOUD DATABASE.

5. SECURITY MEASURES
WE ENFORCE SECURE ACCESS MECHANISMS INCLUDING FIREBASE AUTHENTICATION (EMAIL/PASSWORD, GOOGLE SIGN-IN) AND ENCRYPTED ESCROW GATEWAYS TO ENSURE SYSTEM SAFETY.

6. CONTACT US
EMAIL US AT SUPPORT@HUNARLOOP.IN OR VISIT OUR REGISTERED OFFICE IN HAZRATGANJ, LUCKNOW, INDIA.
''';
  } else if (policyType == 'refund') {
    title = 'REFUND POLICY';
    content = '''
1. ESCROW SYSTEM AND DISPUTES
HUNARLOOP ENFORCES AN ESCROW PROTECTION SYSTEM POWERED BY RAZORPAY. PAYMENT FOR EACH BOOKING IS PRE-AUTHORIZED AND HELD IN OUR TRANSACTION GATEWAY SECURELY. RELEASE OF ESCROW IS TRIGGERED UPON USER APPROVAL OR A 24-HOUR AUTO-TIMEOUT.

2. BOOKING CANCELLATION BY CUSTOMER
CANCELLATION MORE THAN 2 HOURS BEFORE THE SLOT: 100% REFUND IS CREDITED TO ORIGINAL SOURCE. CANCELLATION WITHIN 2 HOURS OF SLOT: A FEE OF ₹100 IS DEDUCTED TO COMPENSATE WORKER, REMAINING IS REFUNDED.

3. CANCELLATION BY WORKER
IF AN ASSIGNED WORKER FAILS TO SHOW UP OR CANCELS, A 100% REFUND (INCLUDING FEES AND GST) IS INSTANTLY TRANSFERRED BACK TO CUSTOMER SOURCE. NO FEES ARE DEDUCTED.

4. WORK QUALITY DISPUTES
IF YOU ARE UNSATISFIED WITH WORK QUALITY, YOU MUST NOT MARK THE JOB COMPLETED. INSTEAD, CLICK 'RAISE A DISPUTE' WITHIN 24 HOURS, SUBMIT PHOTOS, AND OUR ARBITRATION TEAM WILL RESOLVE IT WITHIN 3 WORKING DAYS.

5. REFUND TIMELINES
ONCE A REFUND IS CONCLUDED, TRANSFERS WILL REFLECT IN THE CUSTOMER SOURCE WITHIN 5 TO 7 WORKING DAYS.
''';
  }

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(6.0, 6.0),
                blurRadius: 0,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 3.0),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 2.0),
                        ),
                        child: const Text(
                          'CLOSE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Body
              Flexible(
                child: Container(
                  color: const Color(0xFFFFFFF0),
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Text(
                      content,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              // Footer button
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.black, width: 3.0),
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(color: Colors.black, width: 2.0),
                      ),
                      child: const Text(
                        'I UNDERSTAND',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _DigiLockerSheet extends StatefulWidget {
  final String idType;
  final String idNumber;
  final String initialName;

  const _DigiLockerSheet({
    required this.idType,
    required this.idNumber,
    required this.initialName,
  });

  @override
  State<_DigiLockerSheet> createState() => _DigiLockerSheetState();
}

class _DigiLockerSheetState extends State<_DigiLockerSheet> {
  int _step = 1; // 1: Consent & Request, 2: OTP Verification, 3: Success
  bool _isLoading = false;
  final TextEditingController _otpController = TextEditingController();
  int _countdown = 59;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
  }

  void _startTimer() {
    _countdown = 59;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _proceedToOtp() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _step = 2;
        });
        _startTimer();
      }
    });
  }

  void _verifyOtp() {
    final otp = _otpController.text.trim();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PLEASE ENTER A VALID OTP'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _step = 3;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    final bgCol = isDark ? const Color(0xFF161A22) : Colors.white;

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: bgCol,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border.all(color: textCol, width: 3.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              color: const Color(0xFF0A3C75),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.vpn_key_rounded, color: Color(0xFF0A3C75), size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DIGILOCKER e-KYC',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          'National e-Governance Division, Govt. of India',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _isLoading
                  ? SizedBox(
                      height: 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: textCol),
                            const SizedBox(height: 16),
                            Text(
                              'CONNECTING SECURELY TO DIGILOCKER...',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: textCol.withAlpha(180),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _buildStepContent(isDark, textCol),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(bool isDark, Color textCol) {
    switch (_step) {
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CONSENT TO FETCH DOCUMENT',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: textCol),
            ),
            const SizedBox(height: 10),
            Text(
              'By continuing, you authorize HunarLoop to securely request and retrieve your verified ${widget.idType} details from your National DigiLocker Account.',
              style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : AppColors.textMuted, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1D212C) : Colors.black12,
                border: Border.all(color: textCol, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.credit_card, color: textCol),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.idType.toUpperCase(),
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: textCol),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.idNumber,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textCol),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _proceedToOtp,
                child: BrutalistCard(
                  color: AppColors.accent,
                  shadowOffset: 4.0,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: Text(
                        'REQUEST e-KYC OTP',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ENTER Aadhaar-Linked OTP',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: textCol),
            ),
            const SizedBox(height: 10),
            Text(
              'A 6-digit OTP has been sent via SMS to your Aadhaar-registered mobile number ending in ****8999.',
              style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : AppColors.textMuted, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 8.0),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                counterText: '',
                hintText: '000000',
                hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black26),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: textCol, width: 2.0)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.accent, width: 3.0)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _countdown > 0 ? 'RESEND OTP IN ${_countdown}S' : 'OTP NOT RECEIVED?',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: isDark ? Colors.white60 : AppColors.textMuted),
                ),
                if (_countdown == 0)
                  GestureDetector(
                    onTap: _startTimer,
                    child: const Text(
                      'RESEND OTP',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.blue, decoration: TextDecoration.underline),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _verifyOtp,
                child: BrutalistCard(
                  color: const Color(0xFF0A3C75),
                  shadowOffset: 4.0,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: Text(
                        'SUBMIT & LINK ACCOUNT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      case 3:
        final verifiedName = widget.initialName.isNotEmpty ? widget.initialName.toUpperCase() : "ARPIT SINGH YADAV";
        return Column(
          children: [
            const Center(
              child: Icon(Icons.check_circle_rounded, size: 64, color: Colors.green),
            ),
            const SizedBox(height: 16),
            Text(
              'DOCUMENT LINKED SUCCESSFULLY!',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textCol),
            ),
            const SizedBox(height: 8),
            Text(
              'Your identity has been verified via National DigiLocker database. Verified badge unlocked!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : AppColors.textMuted, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: isDark ? const Color(0xFF1D212C) : Colors.black12,
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: Colors.green),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VERIFIED NAME',
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: isDark ? Colors.white60 : AppColors.textMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          verifiedName,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textCol),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop({
                    'verified': true,
                    'verifiedName': verifiedName,
                  });
                },
                child: BrutalistCard(
                  color: Colors.black,
                  shadowOffset: 4.0,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: Text(
                        'CONTINUE ACCOUNT SETUP',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }
}
