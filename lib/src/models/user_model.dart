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
  final String? firstName;
  final String? lastName;
  final String? nationalId;
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
    this.firstName,
    this.lastName,
    this.nationalId,
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
      firstName: json['firstName'],
      lastName: json['lastName'],
      nationalId: json['nationalId'],
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
      'firstName': firstName,
      'lastName': lastName,
      'nationalId': nationalId,
      'isVerified': isVerified,
    };
  }

  bool isPersonalInfoComplete() {
    return firstName != null &&
        lastName != null &&
        nationalId != null;
  }

  bool isResidentialInfoComplete() {
    return county != null && city != null && address != null;
  }
}
