class User {
  final String name;
  final String phone;
  final String password;

  User({required this.name, required this.phone, required this.password});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'password': password,
    };
  }
}
