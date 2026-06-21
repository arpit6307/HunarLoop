import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppRoute {
  splash,
  onboarding,
  roleSelection,
  login,
  accountSetup,
  
  // Customer Routes
  customerHome,
  customerCategoryDetails,
  customerSearchResults,
  customerWorkerProfile,
  customerBooking,
  customerPayment,
  customerActiveBooking,
  customerChat,

  // Worker Routes
  workerHome,
  workerJobDetails,
  workerPortfolioEditor,
}

class NavigationState {
  final AppRoute currentRoute;
  final List<AppRoute> history;
  final dynamic arguments;

  NavigationState({
    required this.currentRoute,
    this.history = const [],
    this.arguments,
  });

  NavigationState copyWith({
    AppRoute? currentRoute,
    List<AppRoute>? history,
    dynamic arguments,
  }) {
    return NavigationState(
      currentRoute: currentRoute ?? this.currentRoute,
      history: history ?? this.history,
      arguments: arguments ?? this.arguments,
    );
  }
}

class NavigationNotifier extends Notifier<NavigationState> {
  @override
  NavigationState build() {
    return NavigationState(currentRoute: AppRoute.splash);
  }

  void navigateTo(AppRoute route, {dynamic arguments}) {
    final updatedHistory = List<AppRoute>.from(state.history)..add(state.currentRoute);
    state = NavigationState(
      currentRoute: route,
      history: updatedHistory,
      arguments: arguments,
    );
  }

  void goBack() {
    if (state.history.isNotEmpty) {
      final updatedHistory = List<AppRoute>.from(state.history);
      final prevRoute = updatedHistory.removeLast();
      state = NavigationState(
        currentRoute: prevRoute,
        history: updatedHistory,
      );
    }
  }

  void resetTo(AppRoute route, {dynamic arguments}) {
    state = NavigationState(
      currentRoute: route,
      history: const [],
      arguments: arguments,
    );
  }
}

final navigationProvider = NotifierProvider<NavigationNotifier, NavigationState>(() {
  return NavigationNotifier();
});
