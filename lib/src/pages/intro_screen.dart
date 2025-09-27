import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:mkopo_wetu/src/widgets/banner_ad_widget.dart';
import 'package:mkopo_wetu/src/widgets/interstitial_ad_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final InterstitialAdWidget _interstitialAdWidget = InterstitialAdWidget();

  @override
  void initState() {
    super.initState();
    _interstitialAdWidget.loadAd();
    _requestPermissions();
  }

  @override
  void dispose() {
    _interstitialAdWidget.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    final permissions = [
      Permission.location,
      Permission.phone,
      Permission.sms,
      Permission.storage,
    ];

    final statuses = await permissions.request();

    if (statuses.values.every((status) => status.isGranted)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('permissions_granted', true);
    } else {
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
            'Mkopo Wetu needs these permissions to function correctly. Please enable them in your app settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _onDone() async {
    _interstitialAdWidget.showAdWithCallback(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('intro_seen', true);
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IntroductionScreen(
              pages: [
                PageViewModel(
                  title: "Welcome to Mkopo Wetu",
                  body:
                      "Your trusted partner for quick and reliable mobile loans.",
                  image: const Icon(Icons.monetization_on, size: 100),
                ),
                PageViewModel(
                  title: "Secure and Confidential",
                  body:
                      "Your data is safe with us. We value your privacy and security.",
                  image: const Icon(Icons.security, size: 100),
                ),
                PageViewModel(
                  title: "Easy Application Process",
                  body: "Apply for a loan in just a few simple steps.",
                  image: const Icon(Icons.app_registration, size: 100),
                ),
                PageViewModel(
                  title: "Instant Loan Decisions",
                  body:
                      "Get a decision on your loan application within minutes.",
                  image: const Icon(Icons.flash_on, size: 100),
                ),
              ],
              onDone: _onDone,
              onSkip: _onDone, // You can add a skip button if you want
              showSkipButton: true,
              skip: const Text("Skip"),
              next: const Icon(Icons.arrow_forward),
              done: const Text("Get Started",
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }
}
