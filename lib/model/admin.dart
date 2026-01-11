import 'user.dart';

class Admin extends User {
  final String? department;
  final List<String> permissions;

  Admin({
    required super.userId,
    required super.username,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phonenumber,
    required super.password,
    super.isApproved = true, // Admins are auto-approved
    required super.createdAt,
    required super.updatedAt,
    this.department,
    this.permissions = const [],
  }) : super(userRole: UserRole.admin);

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      userId: json['userId'] as String,
      username: json['username'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phonenumber: json['phonenumber'] as String,
      password: json['password'] as String,
      isApproved: json['isApproved'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      department: json['department'] as String?,
      permissions: List<String>.from(json['permissions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phonenumber': phonenumber,
      'password': password,
      'userRole': userRole.toString().split('.').last,
      'isApproved': isApproved,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'department': department,
      'permissions': permissions,
    };
  }

  Admin copyWith({
    String? userId,
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    String? phonenumber,
    String? password,
    bool? isApproved,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? department,
    List<String>? permissions,
  }) {
    return Admin(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phonenumber: phonenumber ?? this.phonenumber,
      password: password ?? this.password,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      department: department ?? this.department,
      permissions: permissions ?? this.permissions,
    );
  }
}