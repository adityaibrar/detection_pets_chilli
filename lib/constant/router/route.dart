import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../views/base_page.dart';
import '../../views/detection_page.dart';
import '../../views/splash_page.dart';
import '../../views/starter_page.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return SplashPage();
      },
    ),
    GoRoute(
      path: '/starter',
      builder: (context, state) {
        return StarterPage();
      },
    ),
    GoRoute(
      path: '/base-page',
      builder: (context, state) {
        return BasePage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/detection-page',
          builder: (context, state) {
            return DetectionPage();
          },
        ),
      ],
    ),
  ],
);
