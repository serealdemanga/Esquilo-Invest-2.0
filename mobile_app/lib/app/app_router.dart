import 'package:flutter/material.dart';

import '../features/dashboard/category_detail_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/dashboard/holding_detail_screen.dart';

class DashboardRouteArgs {
  const DashboardRouteArgs({
    this.initialTabIndex = 0,
    this.openAiOnStart = false,
  });

  final int initialTabIndex;
  final bool openAiOnStart;
}

class AppRouter {
  static const String dashboardRoute = '/';
  static const String categoryDetailRoute = '/category';
  static const String holdingDetailRoute = '/holding';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboardRoute:
        final args = settings.arguments;
        return MaterialPageRoute<void>(
          builder:
              (_) => DashboardScreen(
                initialTabIndex:
                    args is DashboardRouteArgs ? args.initialTabIndex : 0,
                openAiOnStart:
                    args is DashboardRouteArgs ? args.openAiOnStart : false,
              ),
          settings: settings,
        );
      case categoryDetailRoute:
        final args = settings.arguments;
        if (args is! CategoryDetailArgs) {
          return MaterialPageRoute<void>(
            builder: (_) => const DashboardScreen(),
            settings: settings,
          );
        }

        return MaterialPageRoute<void>(
          builder: (_) => CategoryDetailScreen(args: args),
          settings: settings,
        );
      case holdingDetailRoute:
        final args = settings.arguments;
        if (args is! HoldingDetailArgs) {
          return MaterialPageRoute<void>(
            builder: (_) => const DashboardScreen(),
            settings: settings,
          );
        }

        return MaterialPageRoute<void>(
          builder: (_) => HoldingDetailScreen(args: args),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );
    }
  }
}
