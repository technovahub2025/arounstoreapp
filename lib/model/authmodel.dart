class User {
  final String name;
  final String email;
  final String phone;
  final String password;

  User({required this.name, this.email = '', required this.phone, required this.password});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      password: json['password'] ?? '',
     
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
     
    };
  }
}
