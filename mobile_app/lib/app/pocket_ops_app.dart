import 'package:flutter/material.dart';

import 'app_router.dart';
import 'app_theme.dart';

class PocketOpsApp extends StatelessWidget {
  const PocketOpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Ops',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.dashboardRoute,
    );
  }
}
