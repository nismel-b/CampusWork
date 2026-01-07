enum ProjectStatus { private, public }
enum ProjectState { enCours, termine, note }

class Project {
  final String projectId;
  final String projectName;
  final String courseName;
  final String description;
  final String? category;
  final String? imageurl;
  final String studentId;
  final List<String> collaborators;
  final String? architecturePatterns;
  final String? uml;
  final String? prototypeLink;
  final String? downloadLink;
  final ProjectStatus status;
  final List<String> resources;
  final List<String> prerequisites;
  final String? powerpointLink;
  final String? reportLink;
  final ProjectState state;
  final double? grade;
  final String? lecturerComment;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.projectId,
    required this.projectName,
    required this.courseName,
    required this.description,
    required this.studentId,
    this.imageurl,
    this.category,
    this.collaborators = const [],
    this.architecturePatterns,
    this.uml,
    this.prototypeLink,
    this.downloadLink,
    this.status = ProjectStatus.public,
    this.resources = const [],
    this.prerequisites = const [],
    this.powerpointLink,
    this.reportLink,
    this.state = ProjectState.enCours,
    this.grade,
    this.lecturerComment,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

}
