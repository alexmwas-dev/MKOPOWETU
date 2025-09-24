import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:okoa_loan/src/services/ad_manager.dart';
import 'package:provider/provider.dart';
import 'package:okoa_loan/src/providers/auth_provider.dart';

class BasicInfoPage extends StatefulWidget {
  const BasicInfoPage({super.key});

  @override
  State<BasicInfoPage> createState() => _BasicInfoPageState();
}

class _BasicInfoPageState extends State<BasicInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _countyController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = AdManager.getBannerAd();
    _bannerAd?.load();

    // Use post-frame callback to access provider safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      if (user != null) {
        _countyController.text = user.county ?? '';
        _cityController.text = user.city ?? '';
        _addressController.text = user.address ?? '';
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _countyController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Basic Information')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                 const Text(
                  'Tell Us Where You Live',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'This information helps us to verify your identity and provide better services.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _countyController,
                  decoration: const InputDecoration(labelText: 'County', prefixIcon: Icon(Icons.location_city_outlined), border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Please enter your county' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'City/Town', prefixIcon: Icon(Icons.business_outlined), border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Please enter your city' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Residential Address', prefixIcon: Icon(Icons.home_work_outlined), border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Please enter your address' : null,
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);
                            try {
                              await authProvider.updateBasicInfo(
                                _countyController.text,
                                _cityController.text,
                                _addressController.text,
                              );
                              context.go('/personal-info');
                            } catch (e) {
                               if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to save info: ${e.toString()}')),
                                );
                               }
                            } finally {
                               if (mounted) {
                                setState(() => _isLoading = false);
                               }
                            }
                          }
                        },
                        child: const Text('Next', style: TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                           backgroundColor: Theme.of(context).primaryColor,
                           foregroundColor: Colors.white,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _bannerAd != null
          ? SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : const SizedBox.shrink(),
    );
  }
}
