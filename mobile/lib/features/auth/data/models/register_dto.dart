class RegisterDto {
  final String email;
  final String password;
  final String fullName;
  final String? phone;
  final int role;

  RegisterDto({
    required this.email,
    required this.password,
    required this.fullName,
    this.phone,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'fullName': fullName,
      if (phone != null) 'phone': phone,
      'role': role,
    };
  }
}
