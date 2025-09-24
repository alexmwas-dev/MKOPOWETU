import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:okoa_loan/src/services/ad_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = AdManager.getBannerAd();
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: PageView(
        controller: _pageController,
        children: [
          _buildPage(
            icon: Icons.waving_hand,
            title: 'Welcome to Okoa Loan',
            content: 'Your reliable partner for quick and easy loans. We are here to help you with your financial needs.',
            onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn),
            buttonText: 'Next',
          ),
          _buildPage(
            icon: Icons.lock_person_sharp,
            title: 'We Need Some Permissions',
            content: 'To assess your loan eligibility, we need access to your SMS, call logs, and storage.',
            onPressed: () async {
              await [Permission.sms, Permission.phone, Permission.storage].request();
              _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
            },
            buttonText: 'Grant Permissions',
          ),
          _buildPage(
            icon: Icons.security,
            title: 'Data Privacy & Security',
            content: 'Your data is safe with us. We use it solely for credit scoring and will never share it with third parties.',
            onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn),
            buttonText: 'Next',
          ),
          _buildPage(
            icon: Icons.rocket_launch,
            title: 'You Are All Set!',
            content: 'You are now ready to apply for a loan. Let\'s get started!',
            onPressed: () => context.go('/login'),
            buttonText: 'Get Started',
          ),
        ],
      ),
      bottomNavigationBar: _bannerAd != null
          ? Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildPage({
    required IconData icon,
    required String title,
    required String content,
    required VoidCallback onPressed,
    required String buttonText,
  }) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: Theme.of(context).primaryColor),
          const SizedBox(height: 40),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
