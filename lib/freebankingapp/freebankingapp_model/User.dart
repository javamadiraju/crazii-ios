class User {
  final String accessToken;
  final UserData data;

  User({
    required this.accessToken,
    required this.data,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      accessToken: json['access_token'] ?? '',
      data: UserData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'data': data.toJson(),
    };
  }
}

class UserData {
  String idUser;
  String? loginId;
  String memberId;
  String firstName;
  String lastName;
  String dateBirth;
  String mobile;
  String email;
  String country;
  String group;
  String password;
  String lastAccess;
  String lastIp;
  String tfa;
  String? tfaSecret;
  String? tfaCode;
  String? blocked;
  String emailConfirmed;
  String smsConfirmed;
  String picture;
  String token;
  String status;
  String createdAt;
  String updatedAt;
  String memberType;
  String bonusCredit;
  String totalCredits;
  String remainingCredits;
  String bonusCreditsAwarded;
  String remainingBonusCredits;
  String credit;
  String remarks;
  String archiveDate;
  String archiveRemarks;

  UserData({
    required this.idUser,
    this.loginId,
    required this.memberId,
    required this.firstName,
    required this.lastName,
    required this.dateBirth,
    required this.mobile,
    required this.email,
    required this.country,
    required this.group,
    required this.password,
    required this.lastAccess,
    required this.lastIp,
    required this.tfa,
    this.tfaSecret,
    this.tfaCode,
    this.blocked,
    required this.emailConfirmed,
    required this.smsConfirmed,
    required this.picture,
    required this.token,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.memberType,
    required this.bonusCredit,
    required this.totalCredits,
    required this.remainingCredits,
    required this.bonusCreditsAwarded,
    required this.remainingBonusCredits,
    required this.credit,
    required this.remarks,
    required this.archiveDate,
    required this.archiveRemarks,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
  return UserData(
    idUser: json['id_user'] ?? '',
    loginId: json['login_id'] as String?,
    memberId: json['member_id'] ?? '',
    firstName: json['first_name'] ?? '',
    lastName: json['last_name'] ?? '',
    dateBirth: json['date_birth'] ?? '',
    mobile: json['mobile'] ?? '',
    email: json['email'] ?? '',
    country: json['country'] ?? '',
    group: json['group'] ?? '',
    password: json['password'] ?? '',
    lastAccess: json['last_access'] ?? '',
    lastIp: json['last_ip'] ?? '',
    tfa: json['tfa'] ?? '',
    tfaSecret: json['tfa_secret'] as String?,
    tfaCode: json['tfa_code'] as String?,
    blocked: json['blocked'] as String?,
    emailConfirmed: json['email_confirmed'] ?? '',
    smsConfirmed: json['sms_confirmed'] ?? '',
    picture: json['picture'] ?? '',
    token: json['token'] ?? '',
    status: json['status'] ?? '',
    createdAt: json['created_at'] ?? '',
    updatedAt: json['updated_at'] ?? '',
    memberType: json['member_type'] ?? '',
    bonusCredit: json['bonus_credit'] ?? '',
    totalCredits: json['total_credits'] ?? '',
    remainingCredits: json['remaining_credits'] ?? '',
    bonusCreditsAwarded: json['bonus_credits_awarded'] ?? '',
    remainingBonusCredits: json['remaining_bonus_credits'] ?? '',
    credit: json['cash_credit'] ?? '',  // <- updated here
    remarks: json['remarks'] ?? '',
    archiveDate: json['archive_date'] ?? '',
    archiveRemarks: json['archive_remarks'] ?? '',
  );
}


  Map<String, dynamic> toJson() {
  return {
    'id_user': idUser,
    'login_id': loginId,
    'member_id': memberId,
    'first_name': firstName,
    'last_name': lastName,
    'date_birth': dateBirth,
    'mobile': mobile,
    'email': email,
    'country': country,
    'group': group,
    'password': password,
    'last_access': lastAccess,
    'last_ip': lastIp,
    'tfa': tfa,
    'tfa_secret': tfaSecret,
    'tfa_code': tfaCode,
    'blocked': blocked,
    'email_confirmed': emailConfirmed,
    'sms_confirmed': smsConfirmed,
    'picture': picture,
    'token': token,
    'status': status,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'member_type': memberType,
    'bonus_credit': bonusCredit,
    'total_credits': totalCredits,
    'remaining_credits': remainingCredits,
    'bonus_credits_awarded': bonusCreditsAwarded,
    'remaining_bonus_credits': remainingBonusCredits,
    'cash_credit': credit, // <- updated here
    'remarks': remarks,
    'archive_date': archiveDate,
    'archive_remarks': archiveRemarks,
  };
}

}
