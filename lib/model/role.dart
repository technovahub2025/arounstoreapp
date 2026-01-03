class Role {
  final String role;

  Role({required this.role,});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      role: json['role'] ?? ''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role':role
     
    };
  }
}
