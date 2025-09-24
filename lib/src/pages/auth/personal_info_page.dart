import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:okoa_loan/src/services/ad_manager.dart';
import 'package:provider/provider.dart';
import 'package:okoa_loan/src/providers/auth_provider.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _dobController = TextEditingController();

  String? _gender;
  String? _maritalStatus;

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
        _nameController.text = user.name ?? '';
        _idController.text = user.idNumber ?? '';
        _dobController.text = user.dob ?? '';
        if (user.gender != null && ['Male', 'Female', 'Other'].contains(user.gender)) {
            _gender = user.gender;
        }
        if (user.maritalStatus != null && ['Single', 'Married', 'Divorced', 'Widowed'].contains(user.maritalStatus)) {
            _maritalStatus = user.maritalStatus;
        }
        setState(() {});
      }
    });
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _nameController.dispose();
    _idController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Personal Information')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               const Text(
                  'A Bit About Yourself',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'This information is used for identity verification and to determine loan eligibility.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                 const SizedBox(height: 48),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name',  prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(labelText: 'National ID', prefixIcon: Icon(Icons.credit_card_outlined), border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter your National ID' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (value) => value!.isEmpty ? 'Please select your date of birth' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(labelText: 'Gender',  prefixIcon: Icon(Icons.wc_outlined), border: OutlineInputBorder()),
                items: ['Male', 'Female', 'Other'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _gender = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select your gender' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                 initialValue: _maritalStatus,
                decoration: const InputDecoration(labelText: 'Marital Status',  prefixIcon: Icon(Icons.family_restroom_outlined), border: OutlineInputBorder()),
                items: ['Single', 'Married', 'Divorced', 'Widowed'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _maritalStatus = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select your marital status' : null,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isLoading = true);
                          try {
                            await authProvider.updatePersonalInfo(
                              _nameController.text,
                              _idController.text,
                              _dobController.text,
                              _gender!,
                              _maritalStatus!,
                            );
                            context.go('/home');
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
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Finish Setup', style: TextStyle(fontSize: 18)),
                    ),
            ],
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
