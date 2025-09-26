import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mkopo_wetu/src/widgets/banner_ad_widget.dart';
import 'package:mkopo_wetu/src/widgets/interstitial_ad_widget.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildContactCard(context),
          const SizedBox(height: 24),
          _buildContactOptions(context),
        ],
      ),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor, Colors.green.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.headset_mic_outlined,
                size: 64, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'Get in Touch',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'We are here to help you 24/7.',
              style:
                  TextStyle(fontSize: 16, color: Colors.white.withAlpha(204)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOptions(BuildContext context) {
    return Column(
      children: [
        _buildContactItem(context,
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: 'support@mkopowetu.com'),
        _buildContactItem(context,
            icon: Icons.phone_outlined,
            title: 'Phone',
            subtitle: '+254 712 345 678'),
        _buildContactItem(context,
            icon: Icons.location_on_outlined,
            title: 'Address',
            subtitle: 'Nairobi, Kenya'),
      ],
    );
  }

  Widget _buildContactItem(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).primaryColor.withAlpha(25),
          child: Icon(icon, size: 28, color: Theme.of(context).primaryColor),
        ),
        title: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
