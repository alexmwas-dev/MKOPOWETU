import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mkopo_wetu/src/widgets/banner_ad_widget.dart';
import 'package:mkopo_wetu/src/widgets/interstitial_ad_widget.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  final InterstitialAdWidget _interstitialAdWidget = InterstitialAdWidget();

  @override
  void initState() {
    super.initState();
    _interstitialAdWidget.loadAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _interstitialAdWidget.showAdWithCallback(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPolicySection(
              title: '1. Information We Collect',
              content:
                  'We may collect the following types of personal information from you:\n\n- Personal identification information (such as your name, date of birth, and national ID number)\n- Contact information (such as your phone number and email address)\n- Financial information (such as your income and employment details)\n- Device information (such as your device type and operating system)',
            ),
            _buildPolicySection(
              title: '2. How We Use Your Information',
              content:
                  'We may use your personal information for the following purposes:\n\n- To verify your identity and assess your creditworthiness\n- To process your loan application and disburse funds\n- To communicate with you about your account and our services\n- To improve our application and develop new products\n- To comply with legal and regulatory requirements',
            ),
            _buildPolicySection(
              title: '3. Information Sharing',
              content:
                  'We may share your personal information with third parties in the following circumstances:\n\n- With credit reference bureaus to assess your credit history\n- With our service providers who assist us in our operations\n- With law enforcement agencies or other government bodies as required by law',
            ),
            _buildPolicySection(
              title: '4. Data Security',
              content:
                  'We take reasonable measures to protect your personal information from unauthorized access, use, or disclosure. However, no method of transmission over the internet or electronic storage is 100% secure.',
            ),
            _buildPolicySection(
              title: '5. Your Rights',
              content:
                  'You have the right to access, correct, or delete your personal information. You may also have the right to object to or restrict certain types of processing. To exercise these rights, please contact us at support@mkopowetu.com.',
            ),
            _buildPolicySection(
              title: '6. Changes to This Policy',
              content:
                  'We may update this Privacy Policy from time to time. Any changes will be effective immediately upon posting the updated policy in the application.',
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }

  Widget _buildPolicySection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
