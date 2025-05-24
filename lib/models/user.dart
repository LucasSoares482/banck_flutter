// lib/models/user.dart
class User {
  final String id;
  final String name;
  final String email;
  final String accountNumber;
  final double balance;
  final String avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.accountNumber,
    required this.balance,
    this.avatarUrl = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      accountNumber: json['accountNumber'] as String,
      balance: json['balance'] as double,
      avatarUrl: json['avatarUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'accountNumber': accountNumber,
      'balance': balance,
      'avatarUrl': avatarUrl,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? accountNumber,
    double? balance,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      accountNumber: accountNumber ?? this.accountNumber,
      balance: balance ?? this.balance,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}