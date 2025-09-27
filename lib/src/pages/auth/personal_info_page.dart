import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mkopo_wetu/src/providers/auth_provider.dart';
import 'package:mkopo_wetu/src/widgets/banner_ad_widget.dart';
import 'package:mkopo_wetu/src/widgets/interstitial_ad_widget.dart';
import 'package:provider/provider.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _idController = TextEditingController();
  final _dobController = TextEditingController();

  String? _gender;
  String? _maritalStatus;

  bool _isLoading = false;
  DateTime? _selectedDate;
  final InterstitialAdWidget _interstitialAdWidget = InterstitialAdWidget();

  @override
  void initState() {
    super.initState();
    _interstitialAdWidget.loadAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.user;
        if (user != null) {
          _nameController.text = user.name ?? '';
          _emailController.text = user.email ?? '';
          _idController.text = user.idNumber ?? '';
          if (user.dob != null) {
            _selectedDate = DateTime.tryParse(user.dob!);
            if (_selectedDate != null) {
              _dobController.text =
                  DateFormat('yyyy-MM-dd').format(_selectedDate!);
            }
          }
          if (user.gender != null &&
              ['Male', 'Female', 'Other'].contains(user.gender)) {
            _gender = user.gender;
          }
          if (user.maritalStatus != null &&
              ['Single', 'Married', 'Divorced', 'Widowed']
                  .contains(user.maritalStatus)) {
            _maritalStatus = user.maritalStatus;
          }
          setState(() {});
        }
      }
    });
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _idController.dispose();
    _dobController.dispose();
    _interstitialAdWidget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Tell Us About Yourself',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'This information is for identity verification and loan eligibility.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 48),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'Full name is required.' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'Email address is required.' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                    labelText: 'National ID Number',
                    prefixIcon: Icon(Icons.credit_card_outlined),
                    border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'National ID is required.' : null,
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
                validator: (value) =>
                    value!.isEmpty ? 'Date of birth is required.' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: Icon(Icons.wc_outlined),
                    border: OutlineInputBorder()),
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
                validator: (value) =>
                    value == null ? 'Gender is required.' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _maritalStatus,
                decoration: const InputDecoration(
                    labelText: 'Marital Status',
                    prefixIcon: Icon(Icons.family_restroom_outlined),
                    border: OutlineInputBorder()),
                items: ['Single', 'Married', 'Divorced', 'Widowed']
                    .map((String value) {
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
                validator: (value) =>
                    value == null ? 'Marital status is required.' : null,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _interstitialAdWidget.showAdWithCallback(() async {
                            setState(() => _isLoading = true);
                            try {
                              await authProvider.updatePersonalInfo(
                                _nameController.text,
                                _emailController.text,
                                _idController.text,
                                _dobController.text,
                                _gender!,
                                _maritalStatus!,
                              );
                              context.go('/financial-info');
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Failed to save information. Please try again.')),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _isLoading = false);
                              }
                            }
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save & Continue',
                          style: TextStyle(fontSize: 18)),
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }
}