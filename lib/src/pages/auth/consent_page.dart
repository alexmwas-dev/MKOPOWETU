import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:mkopo_wetu/src/providers/auth_provider.dart';
import 'package:mkopo_wetu/src/widgets/banner_ad_widget.dart';
import 'package:mkopo_wetu/src/widgets/interstitial_ad_widget.dart';
import 'package:provider/provider.dart';

class ConsentPage extends StatefulWidget {
  const ConsentPage({super.key});

  @override
  State<ConsentPage> createState() => _ConsentPageState();
}

class _ConsentPageState extends State<ConsentPage> {
  bool _termsAccepted = false;
  bool _privacyAccepted = false;
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
  void dispose() {
    _interstitialAdWidget.dispose();
    super.dispose();
  }

  // NOTE: The following legal texts should be reviewed by a qualified
  // legal professional. They have not been shortened to preserve their
  // legal integrity.
  final String _termsAndConditionsText = '''
## Terms and Conditions

**1. Introduction**
By using the Mkopo Wetu mobile application ("App"), you agree to be bound by these Terms and Conditions ("Terms"). If you do not agree with any part of these terms, you must not use our application.

**2. Eligibility**
To be eligible for a loan, you must be at least 18 years old, a citizen of Kenya with a valid National ID, and have a registered mobile number with a reputable mobile money provider. You must provide accurate and complete information during the registration and application process.

**3. Loan Application and Approval**
All loan applications are subject to our credit assessment and approval process. We reserve the right to approve or reject any loan application at our sole discretion. The approved loan amount and repayment terms will be communicated to you within the App.

**4. Fees and Repayment**
- **Service Fee:** A service fee will be charged on each loan, which will be disclosed to you before you accept the loan.
- **Repayment:** You are obligated to repay your loan, including the principal amount and any applicable fees, on or before the due date specified in the loan agreement.
- **Late Repayment:** Failure to repay the loan on time will result in a late repayment penalty. Continued default may lead to being reported to Credit Reference Bureaus (CRBs).

**5. User Conduct**
You agree to use the App for lawful purposes only. You must not:
- Provide false or misleading information.
- Attempt to interfere with the App's security or functionality.
- Use the App for any fraudulent or illegal activities.

**6. Limitation of Liability**
Mkopo Wetu shall not be liable for any direct, indirect, incidental, or consequential damages arising from your use of the App or your inability to use the App.

**7. Data Privacy**
We are committed to protecting your privacy. Our data collection and usage practices are outlined in our Privacy Policy. By accepting these Terms, you also consent to our Privacy Policy.

**8. Changes to Terms**
We reserve the right to modify these Terms and Conditions at any time. We will notify you of any significant changes. Your continued use of the App after any such changes constitutes your acceptance of the new Terms.

**9. Governing Law**
These Terms shall be governed by and construed in accordance with the laws of Kenya.
''';

  final String _privacyPolicyText = '''
## Privacy Policy

**1. Information We Collect**
We collect the following information to provide and improve our services:
- **Personal Information:** Your full name, National ID number, date of birth, gender, and contact information (phone number, email address).
- **Financial Information:** Mobile money transaction history (e.g., M-Pesa statements), and credit information from Credit Reference Bureaus (CRBs) to assess your creditworthiness.
- **Device Information:** Information about your device, including model, operating system, and unique device identifiers.
- **Location Information:** We may request access to your device's location to verify your address and for security purposes.
- **Contacts:** We may request access to your contacts to verify your identity and prevent fraud.

**2. How We Use Your Information**
Your information is used to:
- Verify your identity.
- Determine your eligibility for a loan.
- Process your loan application and disburse funds.
- Communicate with you regarding your account and our services.
- Manage your loan, including processing repayments and collections.
- Comply with legal and regulatory obligations.
- Prevent and detect fraud.

**3. Information Sharing**
We may share your information with:
- **Credit Reference Bureaus (CRBs):** As required by law, we share credit information with CRBs.
- **Third-Party Service Providers:** We work with trusted partners for services like SMS notifications, data analytics, and payment processing. These partners are bound by confidentiality agreements.
- **Legal and Regulatory Authorities:** We may disclose your information to law enforcement or other government bodies if required by law.
- **Collection Agencies:** If you default on your loan, we may share your information with collection agencies.

**4. Data Security**
We implement robust technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. All data is transmitted over secure SSL connections.

**5. Your Rights**
You have the right to:
- Access the personal information we hold about you.
- Request correction of inaccurate or incomplete information.
- Request deletion of your data, subject to legal and contractual restrictions.
- Object to the processing of your data for specific purposes.

**6. Contact Us**
If you have any questions or concerns about our Privacy Policy or data practices, please contact us at support@mkopowetu.com.
''';

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/privacy.json',
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              const Text(
                'Review and Accept Policies',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'To continue, please review and accept our Terms of Service and Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ),
              const SizedBox(height: 32),
              _buildConsentRow(
                value: _termsAccepted,
                onChanged: (value) => setState(() => _termsAccepted = value!),
                text: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    children: [
                      const TextSpan(text: 'I have read and agree to the '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _showInfoDialog(
                              'Terms of Service', _termsAndConditionsText),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildConsentRow(
                value: _privacyAccepted,
                onChanged: (value) => setState(() => _privacyAccepted = value!),
                text: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    children: [
                      const TextSpan(text: 'I acknowledge and consent to the '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () =>
                              _showInfoDialog('Privacy Policy', _privacyPolicyText),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: (_termsAccepted && _privacyAccepted)
                    ? () async {
                        final authProvider = context.read<AuthProvider>();
                        await authProvider.updateUser(
                          isConsentComplete: true,
                        );
                        context.go('/personal-info');
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Agree & Continue'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }

  Widget _buildConsentRow(
      {required bool value,
      required ValueChanged<bool?> onChanged,
      required Widget text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,
        ),
        Expanded(child: text),
      ],
    );
  }
}
