import 'package:flutter/material.dart';

import '../features/dashboard/category_detail_screen.dart';
import '../features/dashboard/dashboard_screen.dart';

class AppRouter {
  static const String dashboardRoute = '/';
  static const String categoryDetailRoute = '/category';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboardRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const DashboardScreen(),
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
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );
    }
  }
}
