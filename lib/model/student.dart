import 'user.dart';

class Student extends User {
  final String matricule;
  final DateTime birthday;
  final String level;
  final String semester;
  final String section;
  final String filiere;
  final String academicYear;
  final String? githubLink;
  final String? linkedinLink;
  final List<String> otherLinks;

  Student({
    required super.userId,
    required super.username,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phonenumber,
    required super.password,
    super.isApproved,
    required super.createdAt,
    required super.updatedAt,
    required this.matricule,
    required this.birthday,
    required this.level,
    required this.semester,
    required this.section,
    required this.filiere,
    required this.academicYear,
    this.githubLink,
    this.linkedinLink,
    this.otherLinks = const [],
  }) : super(userRole: UserRole.student);


}
