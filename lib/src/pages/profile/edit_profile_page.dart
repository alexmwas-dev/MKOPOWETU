import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mkopo_wetu/src/providers/auth_provider.dart';
import 'package:mkopo_wetu/src/widgets/banner_ad_widget.dart';
import 'package:mkopo_wetu/src/widgets/interstitial_ad_widget.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final InterstitialAdWidget _interstitialAdWidget = InterstitialAdWidget();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _interstitialAdWidget.loadAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _interstitialAdWidget.showAdWithCallback(() {});
        final user = Provider.of<AuthProvider>(context, listen: false).user;
        if (user?.dob != null) {
          _selectedDate = DateTime.tryParse(user!.dob!);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _interstitialAdWidget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Personal', icon: Icon(Icons.person_outline)),
            Tab(text: 'Residential', icon: Icon(Icons.home_work_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PersonalDetailsForm(
              selectedDate: _selectedDate,
              onDateChanged: (date) => setState(() => _selectedDate = date)),
          const ResidentialDetailsForm(),
        ],
      ),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }
}

class PersonalDetailsForm extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateChanged;
  const PersonalDetailsForm(
      {super.key, required this.selectedDate, required this.onDateChanged});

  @override
  _PersonalDetailsFormState createState() => _PersonalDetailsFormState();
}

class _PersonalDetailsFormState extends State<PersonalDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _idController;
  late TextEditingController _dobController;
  String? _gender;
  String? _maritalStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _idController = TextEditingController(text: user?.idNumber ?? '');
    _dobController = TextEditingController();
    if (widget.selectedDate != null) {
      _dobController.text =
          DateFormat('yyyy-MM-dd').format(widget.selectedDate!);
    }
    _gender = user?.gender;
    _maritalStatus = user?.maritalStatus;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _idController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Full Name', border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'Full name is required.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: 'Email Address', border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'Email address is required.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                    labelText: 'National ID Number',
                    border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'National ID is required.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today)),
                readOnly: true,
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: widget.selectedDate ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    widget.onDateChanged(picked);
                    _dobController.text =
                        DateFormat('yyyy-MM-dd').format(picked);
                  }
                },
                validator: (value) =>
                    value!.isEmpty ? 'Date of birth is required.' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(
                    labelText: 'Gender', border: OutlineInputBorder()),
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _maritalStatus,
                decoration: const InputDecoration(
                    labelText: 'Marital Status', border: OutlineInputBorder()),
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
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
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
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Personal details updated successfully.')),
                              );
                              context.pop();
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Error: ${e.toString()}')),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        }
                      },
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Save Changes',
                        style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResidentialDetailsForm extends StatefulWidget {
  const ResidentialDetailsForm({super.key});

  @override
  _ResidentialDetailsFormState createState() => _ResidentialDetailsFormState();
}

class _ResidentialDetailsFormState extends State<ResidentialDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _countyController;
  late TextEditingController _cityController;
  late TextEditingController _addressController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _countyController = TextEditingController(text: user?.county ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
  }

  @override
  void dispose() {
    _countyController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _countyController,
                decoration: const InputDecoration(
                    labelText: 'County', border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'County is required.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                    labelText: 'City/Town', border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'City or town is required.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                    labelText: 'Residential Address',
                    border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'Residential address is required.' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isLoading = true);
                          try {
                            await authProvider.updateBasicInfo(
                              _countyController.text,
                              _cityController.text,
                              _addressController.text,
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Residential details updated successfully.')),
                              );
                              context.pop();
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Error: ${e.toString()}')),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        }
                      },
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes',
                        style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
