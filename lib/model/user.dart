enum UserRole { student, lecturer, admin, }

class User {
  final String userId;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String phonenumber;
  final String password;
  final UserRole userRole;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.userId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phonenumber,
    required this.password,
    required this.userRole,
    this.isApproved = false,
    required this.createdAt,
    required this.updatedAt,
  });

  //select a category of user: lecturer, admin or student
  bool get isLecturer => userRole == UserRole.lecturer;
  bool get isAdmin => userRole == UserRole.admin;
  bool get isStudent => userRole == UserRole.student;


  String get fullName => '$firstName $lastName';
}