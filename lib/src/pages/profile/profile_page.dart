import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:okoa_loan/src/providers/auth_provider.dart';
import 'package:okoa_loan/src/services/ad_manager.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = AdManager.getBannerAd();
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final userName = user?.name ?? 'User';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        centerTitle: true,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          _buildUserProfileCard(context, userInitial, user?.name, user?.phoneNumber),
          const SizedBox(height: 20),
          _buildMenuList(context, authProvider),
          const SizedBox(height: 30),
          const Center(
            child: Text(
              'Version: 1.3.4', // This can be dynamic later
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bannerAd != null
          ? Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildUserProfileCard(BuildContext context, String initial, String? name, String? phone) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(initial, style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name ?? 'Anonymous User', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(phone ?? 'No phone number', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
              ],
            ),
             const Spacer(),
             IconButton(onPressed: ()=> context.go('/profile/edit'), icon: const Icon(Icons.edit_outlined), color: Theme.of(context).primaryColor,)
          ],
        ),
      ),
    );
  }

  Widget _buildMenuList(BuildContext context, AuthProvider authProvider) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: Column(
        children: [
          _buildMenuItem(context, icon: Icons.history_outlined, title: 'Loan History', onTap: () => context.go('/loan-history')),
          _buildMenuItem(context, icon: Icons.contact_support_outlined, title: 'Contact Us', onTap: () => context.go('/contact-us')),
          _buildMenuItem(context, icon: Icons.help_center_outlined, title: 'Help', onTap: () => context.go('/faq')),
          _buildMenuItem(context, icon: Icons.description_outlined, title: 'Loan Terms', onTap: () => context.go('/loan-terms')),
           _buildMenuItem(context, icon: Icons.privacy_tip_outlined, title: 'Privacy Policy', onTap: () => context.go('/privacy-policy')),
           _buildMenuItem(context, icon: Icons.gavel_outlined, title: 'Terms & Conditions', onTap: () => context.go('/terms-and-conditions')),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildMenuItem(context, icon: Icons.logout, title: 'Logout', titleColor: Colors.red, iconColor: Colors.red, onTap: () async {
             await authProvider.logout();
             context.go('/');
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, Color? titleColor, Color? iconColor}) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary.withAlpha(204)),
      title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: titleColor)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey,),
      onTap: onTap,
    );
  }
}
