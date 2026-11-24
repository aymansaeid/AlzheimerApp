class RegisterDto {
  final String email;
  final String password;
  final String fullName;
  final String? phone;
  final int role;
  final String? avatarUrl;

  RegisterDto({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
    required this.role,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'fullName': fullName,
      'phone': phone,
      'role': role,
      if (avatarUrl != null && avatarUrl!.isNotEmpty) 'avatarUrl': avatarUrl,
    };
  }
}
