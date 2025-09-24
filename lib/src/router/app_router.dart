import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:okoa_loan/src/models/loan_model.dart';
import 'package:okoa_loan/src/pages/splash_screen.dart';
import 'package:okoa_loan/src/pages/intro_screen.dart';
import 'package:okoa_loan/src/pages/auth/login_page.dart';
import 'package:okoa_loan/src/pages/auth/register_page.dart';
import 'package:okoa_loan/src/pages/auth/otp_page.dart';
import 'package:okoa_loan/src/pages/auth/personal_info_page.dart';
import 'package:okoa_loan/src/pages/auth/basic_info_page.dart';
import 'package:okoa_loan/src/pages/home/home_page.dart';
import 'package:okoa_loan/src/pages/profile/profile_page.dart';
import 'package:okoa_loan/src/pages/profile/edit_profile_page.dart';
import 'package:okoa_loan/src/pages/loan/apply_loan_page.dart';
import 'package:okoa_loan/src/pages/loan/loan_history_page.dart';
import 'package:okoa_loan/src/pages/loan/loan_details_page.dart';
import 'package:okoa_loan/src/pages/other/terms_and_conditions_page.dart';
import 'package:okoa_loan/src/pages/other/privacy_policy_page.dart';
import 'package:okoa_loan/src/pages/other/loan_terms_page.dart';
import 'package:okoa_loan/src/pages/other/contact_us_page.dart';
import 'package:okoa_loan/src/pages/other/faq_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/intro',
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/intro',
        builder: (BuildContext context, GoRouterState state) {
          return const IntroScreen();
        },
      ),
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: '/register',
        builder: (BuildContext context, GoRouterState state) {
          return const RegisterPage();
        },
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (BuildContext context, GoRouterState state) {
          return const OtpPage();
        },
      ),
      GoRoute(
        path: '/personal-info',
        builder: (BuildContext context, GoRouterState state) {
          return const PersonalInfoPage();
        },
      ),
      GoRoute(
        path: '/basic-info',
        builder: (BuildContext context, GoRouterState state) {
          return const BasicInfoPage();
        },
      ),
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) {
          return const HomePage();
        },
      ),
      GoRoute(
          path: '/profile',
          builder: (BuildContext context, GoRouterState state) {
            return const ProfilePage();
          },
          routes: [
            GoRoute(
              path: 'edit',
              builder: (BuildContext context, GoRouterState state) {
                return const EditProfilePage();
              },
            ),
          ]),
      GoRoute(
        path: '/apply-loan',
        builder: (BuildContext context, GoRouterState state) {
          return const ApplyLoanPage();
        },
      ),
      GoRoute(
        path: '/loan-history',
        builder: (BuildContext context, GoRouterState state) {
          return const LoanHistoryPage();
        },
      ),
      GoRoute(
        path: '/loan-details',
        builder: (BuildContext context, GoRouterState state) {
          final loan = state.extra as Loan;
          return LoanDetailsPage(loan: loan);
        },
      ),
      GoRoute(
        path: '/personal-details',
        redirect: (_, __) => '/profile/edit',
      ),
      GoRoute(
        path: '/financial-details',
        redirect: (_, __) => '/profile/edit',
      ),
      GoRoute(
        path: '/terms-and-conditions',
        builder: (BuildContext context, GoRouterState state) {
          return const TermsAndConditionsPage();
        },
      ),
      GoRoute(
        path: '/privacy-policy',
        builder: (BuildContext context, GoRouterState state) {
          return const PrivacyPolicyPage();
        },
      ),
      GoRoute(
        path: '/loan-terms',
        builder: (BuildContext context, GoRouterState state) {
          return const LoanTermsPage();
        },
      ),
      GoRoute(
        path: '/contact-us',
        builder: (BuildContext context, GoRouterState state) {
          return const ContactUsPage();
        },
      ),
      GoRoute(
        path: '/faq',
        builder: (BuildContext context, GoRouterState state) {
          return const FaqPage();
        },
      ),
    ],
  );
}
