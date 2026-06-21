import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/router.dart';
import 'features/auth/onboarding_screen.dart';
import 'features/customer/customer_home.dart';
import 'features/customer/category_details_screen.dart';
import 'features/worker/worker_home.dart';
import 'features/customer/worker_profile.dart';
import 'features/worker/worker_portfolio_editor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kIsWeb) {
    FirebaseFirestore.instance.settings = const Settings(
      webExperimentalForceLongPolling: true,
    );
  }

  // Clean up old seeded mock workers w1-w16
  try {
    for (int i = 1; i <= 16; i++) {
      FirebaseFirestore.instance.collection('users').doc('w$i').delete().catchError((e) {});
    }
  } catch (e) {
    debugPrint('Error cleaning up mock workers: $e');
  }

  runApp(
    const ProviderScope(
      child: HunarLoopApp(),
    ),
  );
}

class HunarLoopApp extends ConsumerWidget {
  const HunarLoopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(navigationProvider);

    Widget activeScreen;
    switch (navState.currentRoute) {
      case AppRoute.splash:
        activeScreen = const SplashScreen();
        break;
      case AppRoute.onboarding:
        activeScreen = const OnboardingScreen();
        break;
      case AppRoute.roleSelection:
        activeScreen = const RoleSelectionScreen();
        break;
      case AppRoute.login:
        activeScreen = const LoginScreen();
        break;
      case AppRoute.accountSetup:
        activeScreen = const AccountSetupScreen();
        break;
      case AppRoute.customerHome:
        activeScreen = const CustomerHomeScreen();
        break;
      case AppRoute.customerCategoryDetails:
        activeScreen = const CategoryDetailsScreen();
        break;
      case AppRoute.customerSearchResults:
        activeScreen = const CustomerSearchResultsScreen();
        break;
      case AppRoute.customerWorkerProfile:
        activeScreen = const CustomerWorkerProfileScreen();
        break;
      case AppRoute.customerBooking:
        activeScreen = const CustomerBookingScreen();
        break;
      case AppRoute.customerPayment:
        activeScreen = const CustomerPaymentScreen();
        break;
      case AppRoute.customerActiveBooking:
        activeScreen = const CustomerActiveBookingScreen();
        break;
      case AppRoute.workerHome:
        activeScreen = const WorkerHomeScreen();
        break;
      case AppRoute.workerJobDetails:
        activeScreen = const WorkerJobDetailsScreen();
        break;
      case AppRoute.workerPortfolioEditor:
        activeScreen = const WorkerPortfolioEditorScreen();
        break;
      default:
        activeScreen = const SplashScreen();
    }

    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    Widget wrappedScreen = Builder(
      builder: (context) {
        final screenW = MediaQuery.of(context).size.width;
        if (screenW > 600) {
          final borderCol = isDark ? Colors.white : Colors.black;
          final shadowCol = isDark ? const Color(0x3DFFFFFF) : const Color(0xD9000000);
          final outsideBg = isDark ? const Color(0xFF07090C) : const Color(0xFFF0F0F0);
          final appBg = isDark ? const Color(0xFF0E1116) : const Color(0xFFFFE600);
          
          return Scaffold(
            backgroundColor: outsideBg,
            body: Center(
              child: Container(
                width: 480,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: appBg,
                  border: Border(
                    left: BorderSide(color: borderCol, width: 4.0),
                    right: BorderSide(color: borderCol, width: 4.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: shadowCol,
                      offset: const Offset(8, 0),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: activeScreen,
              ),
            ),
          );
        }
        return activeScreen;
      },
    );

    return MaterialApp(
      title: 'HunarLoop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: wrappedScreen,
    );
  }
}
