import 'user.dart';

class Lecturer extends User {
  final String uniteDenseignement;
  final String section;
  final String? evaluationGrid;
  final String? validationRequirements;
  final String? finalSubmissionRequirements;

  Lecturer({
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
    required this.uniteDenseignement,
    required this.section,
    this.evaluationGrid,
    this.validationRequirements,
    this.finalSubmissionRequirements,
  }) : super(userRole: UserRole.lecturer);


}