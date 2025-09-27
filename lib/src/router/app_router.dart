import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mkopo_wetu/src/models/loan_model.dart';
import 'package:mkopo_wetu/src/models/payment_model.dart';
import 'package:mkopo_wetu/src/pages/splash_screen.dart';
import 'package:mkopo_wetu/src/pages/intro_screen.dart';
import 'package:mkopo_wetu/src/pages/auth/login_page.dart';
import 'package:mkopo_wetu/src/pages/auth/register_page.dart';
import 'package:mkopo_wetu/src/pages/auth/otp_page.dart';
import 'package:mkopo_wetu/src/pages/auth/consent_page.dart';
import 'package:mkopo_wetu/src/pages/auth/personal_info_page.dart';
import 'package:mkopo_wetu/src/pages/auth/financial_info_page.dart';
import 'package:mkopo_wetu/src/pages/auth/basic_info_page.dart';
import 'package:mkopo_wetu/src/pages/home/home_page.dart';
import 'package:mkopo_wetu/src/pages/profile/profile_page.dart';
import 'package:mkopo_wetu/src/pages/profile/edit_profile_page.dart';
import 'package:mkopo_wetu/src/pages/loan/apply_loan_page.dart';
import 'package:mkopo_wetu/src/pages/loan/loan_history_page.dart';
import 'package:mkopo_wetu/src/pages/loan/loan_details_page.dart';
import 'package:mkopo_wetu/src/pages/loan/payment_page.dart';
import 'package:mkopo_wetu/src/pages/loan/payment_details_page.dart';
import 'package:mkopo_wetu/src/pages/other/terms_and_conditions_page.dart';
import 'package:mkopo_wetu/src/pages/other/privacy_policy_page.dart';
import 'package:mkopo_wetu/src/pages/other/loan_terms_page.dart';
import 'package:mkopo_wetu/src/pages/other/contact_us_page.dart';
import 'package:mkopo_wetu/src/pages/other/faq_page.dart';
import 'package:mkopo_wetu/src/providers/auth_provider.dart';
import 'package:mkopo_wetu/src/widgets/payment_success_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  GoRouter get router {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: authProvider,
      redirect: (BuildContext context, GoRouterState state) async {
        final prefs = await SharedPreferences.getInstance();
        final introSeen = prefs.getBool('intro_seen') ?? false;

        final isSplash = state.matchedLocation == '/splash';
        final isIntro = state.matchedLocation == '/intro';
        final isLogin = state.matchedLocation == '/login';
        final isRegister = state.matchedLocation == '/register';

        if (isSplash) {
          return null;
        }

        if (!introSeen && !isIntro) {
          return '/intro';
        }

        if (introSeen && isIntro) {
          return '/login';
        }

        final isAuthenticated = authProvider.isAuthenticated;
        final isVerified = authProvider.isVerified;
        final user = authProvider.user;

        if (isAuthenticated) {
          if (isVerified) {
            if (user != null) {
              if (!user.isConsentComplete) {
                return '/consent';
              }
              if (!user.isPersonalInfoComplete()) {
                return '/personal-info';
              }
              if (!user.isFinancialInfoComplete()) {
                return '/financial-info';
              }
              if (!user.isResidentialInfoComplete()) {
                return '/basic-info';
              }
            }

            if (isLogin ||
                isRegister ||
                state.matchedLocation == '/otp-verification' ||
                state.matchedLocation == '/consent') {
              return '/home';
            }
          } else {
            if (state.matchedLocation != '/otp-verification') {
              return '/otp-verification';
            }
          }
        } else {
          if (!isLogin && !isRegister && !isIntro && !isSplash) {
            return '/login';
          }
        }

        return null;
      },
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
          path: '/consent',
          builder: (BuildContext context, GoRouterState state) {
            return const ConsentPage();
          },
        ),
        GoRoute(
          path: '/personal-info',
          builder: (BuildContext context, GoRouterState state) {
            return const PersonalInfoPage();
          },
        ),
        GoRoute(
          path: '/financial-info',
          builder: (BuildContext context, GoRouterState state) {
            return const FinancialInfoPage();
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
          path: '/loan',
          redirect: (_, __) => '/loan/apply',
          routes: [
          GoRoute(
            path: 'apply',
            builder: (BuildContext context, GoRouterState state) {
              return const ApplyLoanPage();
            },
          ),
          GoRoute(
            path: 'history',
            builder: (BuildContext context, GoRouterState state) {
              final Map<String, dynamic>? args =
                  state.extra as Map<String, dynamic>?;

              return LoanHistoryPage(
                initialTabIndex: args?['initialTabIndex'] ?? 0,
              );
            },
          ),
          GoRoute(
            path: 'details',
            builder: (BuildContext context, GoRouterState state) {
              final loan = state.extra as Loan;
              return LoanDetailsPage(loan: loan);
            },
          ),
          GoRoute(
            path: 'payment',
            builder: (BuildContext context, GoRouterState state) {
              final args = state.extra as Map<String, dynamic>;
              final loan = args['loan'] as Loan?;
              final loanAmount = args['loanAmount'] as double?;
              final repaymentDays = args['repaymentDays'] as int?;
              return PaymentPage(
                loan: loan,
                loanAmount: loanAmount,
                repaymentDays: repaymentDays,
              );
            },
          ),
          GoRoute(
            path: 'payment-details',
            builder: (BuildContext context, GoRouterState state) {
              final payment = state.extra as Payment;
              return PaymentDetailsPage(payment: payment);
            },
          ),
          GoRoute(
            path: 'success',
            builder: (BuildContext context, GoRouterState state) {
              return const PaymentSuccessScreen();
            },
          ),
        ]),
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
}
