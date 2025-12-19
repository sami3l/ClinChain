enum Role { grossiste, hopitale, pharmacien, infirmier }

class User {
  final String id;
  final String username;
  final Role role;

  User({required this.id, required this.username, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      role: _roleFromString(json['role'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'role': role.name};
  }

  static Role _roleFromString(String r) {
    switch (r.toLowerCase()) {
      case 'grossiste':
        return Role.grossiste;
      case 'hopitale':
        return Role.hopitale;
      case 'pharmacien':
        return Role.pharmacien;
      case 'infirmier':
        return Role.infirmier;
      default:
        return Role.pharmacien;
    }
  }
}
