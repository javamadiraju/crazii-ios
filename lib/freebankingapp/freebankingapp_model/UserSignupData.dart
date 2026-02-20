class UserSignupData {
  final String email;
  final String password;
  final String birthDate;
  final String fullName;
  final String phoneNumber;
  final String location;
  final String job;
  final String address;
  final String accountType;
  UserSignupData({
    required this.email,
    required this.password,
    required this.birthDate,
    required this.fullName,
    required this.phoneNumber,
    required this.location,
    required this.job,
    required this.address,
   required this.accountType,
  });

  // Convert UserSignupData to a Map for API calls
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'birthDate': birthDate,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'location': location,
      'job': job,
      'address': address,
      'accountType': accountType,
    };
  }

  // Create UserSignupData from a Map (useful for parsing API responses)
  factory UserSignupData.fromJson(Map<String, dynamic> json) {
    return UserSignupData(
      email: json['email'],
      password: json['password'],
      birthDate: json['birthDate'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      location: json['location'],
      job: json['job'],
      address: json['address'],
      accountType: json['accountType'],
    );
  }
}
