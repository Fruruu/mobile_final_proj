class UserProfile {
  final String id;
  final String email;
  final String? name;
  final DateTime? birthday;
  final String? phone;

  UserProfile({
    required this.id,
    required this.email,
    this.name,
    this.birthday,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (name != null) 'name': name,
      if (birthday != null) 'birthday': birthday!.toIso8601String(),
      if (phone != null) 'phone': phone,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString(),
      birthday: json['birthday'] != null
          ? DateTime.tryParse(json['birthday'].toString())
          : null,
      phone: json['phone']?.toString(),
    );
  }
}
