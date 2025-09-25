class User {
  final String uid;
  final String? name;
  final String phoneNumber;
  final String? email;
  final String? idNumber;
  final String? dob;
  final String? gender;
  final String? maritalStatus;
  final String? county;
  final String? city;
  final String? address;
  final String? otp;
  final double? loanLimit;
  final String? employmentStatus;
  final double? monthlyIncome;
  final double? monthlyExpenses;
  final bool isVerified;

  User({
    required this.uid,
    this.name,
    required this.phoneNumber,
    this.email,
    this.idNumber,
    this.dob,
    this.gender,
    this.maritalStatus,
    this.county,
    this.city,
    this.address,
    this.otp,
    this.loanLimit,
    this.employmentStatus,
    this.monthlyIncome,
    this.monthlyExpenses,
    this.isVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      idNumber: json['idNumber'],
      dob: json['dob'],
      gender: json['gender'],
      maritalStatus: json['maritalStatus'],
      county: json['county'],
      city: json['city'],
      address: json['address'],
      otp: json['otp'],
      loanLimit: json['loanLimit']?.toDouble(),
      employmentStatus: json['employmentStatus'],
      monthlyIncome: json['monthlyIncome']?.toDouble(),
      monthlyExpenses: json['monthlyExpenses']?.toDouble(),
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'idNumber': idNumber,
      'dob': dob,
      'gender': gender,
      'maritalStatus': maritalStatus,
      'county': county,
      'city': city,
      'address': address,
      'otp': otp,
      'loanLimit': loanLimit,
      'employmentStatus': employmentStatus,
      'monthlyIncome': monthlyIncome,
      'monthlyExpenses': monthlyExpenses,
      'isVerified': isVerified,
    };
  }

  User copyWith({
    String? uid,
    String? name,
    String? phoneNumber,
    String? email,
    String? idNumber,
    String? dob,
    String? gender,
    String? maritalStatus,
    String? county,
    String? city,
    String? address,
    String? otp,
    double? loanLimit,
    String? employmentStatus,
    double? monthlyIncome,
    double? monthlyExpenses,
    bool? isVerified,
  }) {
    return User(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      idNumber: idNumber ?? this.idNumber,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      county: county ?? this.county,
      city: city ?? this.city,
      address: address ?? this.address,
      otp: otp ?? this.otp,
      loanLimit: loanLimit ?? this.loanLimit,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  bool isPersonalInfoComplete() {
    return name != null &&
        idNumber != null &&
        dob != null &&
        gender != null &&
        maritalStatus != null;
  }

  bool isFinancialInfoComplete() {
    return employmentStatus != null &&
        monthlyIncome != null &&
        monthlyExpenses != null;
  }

  bool isResidentialInfoComplete() {
    return county != null && city != null && address != null;
  }
}
