import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:vn_template/routes/app_route_string.dart';
import 'package:vn_template/screens/dino_game/view/dino_view.dart';
import 'package:vn_template/screens/onboarding/bloc/onboarding_bloc.dart';
import 'package:vn_template/screens/onboarding/view/onboarding_view.dart';
import 'package:vn_template/screens/select_app_language/bloc/select_app_language_bloc.dart';
import 'package:vn_template/screens/select_app_language/view/select_app_language_view.dart';
import 'package:vn_template/screens/splash/bloc/splash_bloc.dart';
import 'package:vn_template/screens/splash/view/splash_view.dart';
import 'package:vn_template/screens/your_interest/bloc/your_interest_bloc.dart';
import 'package:vn_template/screens/your_interest/view/your_interest_view.dart';
import 'package:vn_template/screens/dashboard/view/dashboard_view.dart';
import 'package:vn_template/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:vn_template/screens/home/bloc/home_bloc.dart';

import 'package:vn_template/screens/qr/bloc/qr_bloc.dart';
import 'package:vn_template/screens/qr/view/qr_view.dart';
import 'package:vn_template/data/models/template_model.dart';
import 'package:vn_template/screens/template_detail/bloc/template_detail_bloc.dart';
import 'package:vn_template/screens/template_detail/view/template_detail_view.dart';
import 'package:vn_template/screens/feedback_center/bloc/feedback_center_bloc.dart';
import 'package:vn_template/screens/feedback_center/view/feedback_center_view.dart';
import 'package:vn_template/screens/other_app_screen/bloc/other_apps_bloc.dart';
import 'package:vn_template/screens/other_app_screen/view/other_app_view.dart';
import 'package:vn_template/screens/maintenance/view/maintenance_view.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRoutes {
  static GoRouter routes = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutesString.splashView,
    observers: [
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ],
    routes: [

      /// splash view
      GoRoute(
        name: 'splash',
        path: AppRoutesString.splashView,
        builder: (context, state) =>
            BlocProvider(create: (context) => SplashBloc(), child: const SplashView()),
      ),
      
      /// onboarding view
      GoRoute(
        name: 'onboarding',
        path: AppRoutesString.onboardingView,
        builder: (context, state) =>
            BlocProvider(create: (context) => OnboardingBloc(), child: const OnboardingView()),
      ),
      
      /// select app language view
      GoRoute(
        name: 'selectAppLanguage',
        path: AppRoutesString.selectAppLanguageView,
        builder: (context, state) =>
            BlocProvider(create: (context) => SelectAppLanguageBloc(), child: const SelectAppLanguageView()),
      ),
      
      /// your interest view
      GoRoute(
        name: 'yourInterest',
        path: AppRoutesString.yourInterestView,
        builder: (context, state) =>
            BlocProvider(create: (context) => YourInterestBloc(), child: const YourInterestView()),
      ),
      
      /// dashboard view
      GoRoute(
        name: 'dashboard',
        path: AppRoutesString.dashboardView,
        builder: (context, state) =>
            MultiBlocProvider(
              providers: [
                BlocProvider(create: (context) => DashboardBloc()),
                BlocProvider(create: (context) => HomeBloc()),
              ],
              child: const DashboardView(),
            ),
      ),

      /// dino view
      GoRoute(
        name: 'dino',
        path: AppRoutesString.dinoView, 
        builder: (context, state) => const DinoView()
      ),

      /// qr view
      GoRoute(
        name: 'qrCode',
        path: AppRoutesString.qrCodeView,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final qrLink = extra['qrLink'] as String? ?? '';
          final title = extra['title'] as String? ?? '';
          return BlocProvider(
            create: (context) => QrCodeBloc(),
            child: QrCodeView(qrLink: qrLink, title: title),
          );
        },
      ),
      /// template detail view
      GoRoute(
        name: 'templateDetail',
        path: AppRoutesString.templateDetailView,
        builder: (context, state) {
          final template = state.extra as TemplateModel;
          return BlocProvider(
            create: (context) => TemplateDetailBloc(),
            child: TemplateDetailView(template: template),
          );
        },
      ),
      
      /// feedback center view
      GoRoute(
        name: 'feedbackCenter',
        path: AppRoutesString.feedbackCenterView,
        builder: (context, state) =>
            BlocProvider(create: (context) => FeedbackCenterBloc(), child: const FeedbackCenterView()),
      ),
      
      /// other apps view
      GoRoute(
        name: 'otherApps',
        path: AppRoutesString.otherAppsView,
        builder: (context, state) =>
            BlocProvider(create: (context) => OtherAppsBloc(), child: const OtherAppsView()),
      ),
      
      /// maintenance view
      GoRoute(
        name: 'maintenance',
        path: AppRoutesString.maintenanceView,
        builder: (context, state) => const MaintenanceView(),
      ),
    ],
  );
}
