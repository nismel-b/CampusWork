enum GroupType { project, study, collaboration }

class Group {
  final String? groupId;
  final String name;
  final String description;
  final String createdBy; // userId du créateur (admin/lecturer)
  final GroupType type;
  final String? courseName;
  final String? academicYear;
  final String? section;
  final List<String> members; // userIds des membres
  final List<String> projects; // projectIds associés
  final List<String> evaluationCriteria;
  final int maxMembers;
  final bool isOpen; // Permet aux étudiants de rejoindre librement
  final DateTime createdAt;
  final DateTime? updatedAt;

  Group({
    this.groupId,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.type,
    this.courseName,
    this.academicYear,
    this.section,
    this.members = const [],
    this.projects = const [],
    this.evaluationCriteria = const [],
    this.maxMembers = 10,
    this.isOpen = false,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'type': type.toString().split('.').last,
      'courseName': courseName,
      'academicYear': academicYear,
      'section': section,
      'members': members.join(','),
      'projects': projects.join(','),
      'evaluationCriteria': evaluationCriteria.join(','),
      'maxMembers': maxMembers,
      'isOpen': isOpen ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      groupId: map['groupId'],
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      createdBy: map['createdBy'] ?? '',
      type: GroupType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => GroupType.project,
      ),
      courseName: map['courseName'],
      academicYear: map['academicYear'],
      section: map['section'],
      members: _parseStringList(map['members']),
      projects: _parseStringList(map['projects']),
      evaluationCriteria: _parseStringList(map['evaluationCriteria']),
      maxMembers: map['maxMembers'] ?? 10,
      isOpen: (map['isOpen'] ?? 0) == 1,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is String) {
      return value.isEmpty ? [] : value.split(',').map((e) => e.trim()).toList();
    }
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  bool get isFull => members.length >= maxMembers;
  bool get hasProjects => projects.isNotEmpty;
  int get memberCount => members.length;
  int get projectCount => projects.length;

  bool isMember(String userId) => members.contains(userId);
  bool isCreator(String userId) => createdBy == userId;

  Group copyWith({
    String? groupId,
    String? name,
    String? description,
    String? createdBy,
    GroupType? type,
    String? courseName,
    String? academicYear,
    String? section,
    List<String>? members,
    List<String>? projects,
    List<String>? evaluationCriteria,
    int? maxMembers,
    bool? isOpen,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Group(
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      type: type ?? this.type,
      courseName: courseName ?? this.courseName,
      academicYear: academicYear ?? this.academicYear,
      section: section ?? this.section,
      members: members ?? this.members,
      projects: projects ?? this.projects,
      evaluationCriteria: evaluationCriteria ?? this.evaluationCriteria,
      maxMembers: maxMembers ?? this.maxMembers,
      isOpen: isOpen ?? this.isOpen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}