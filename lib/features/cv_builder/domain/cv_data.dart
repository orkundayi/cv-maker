import 'package:uuid/uuid.dart';

/// CV data model representing the complete resume information
class CVData {
  final String id;
  final PersonalInfo personalInfo;
  final List<WorkExperience> workExperiences;
  final List<Education> educations;
  final List<Skill> skills;
  final List<Language> languages;
  final List<Certificate> certificates;
  final List<Project> projects;
  final String? summary;
  final DateTime createdAt;
  final DateTime updatedAt;

  CVData({
    String? id,
    required this.personalInfo,
    this.workExperiences = const [],
    this.educations = const [],
    this.skills = const [],
    this.languages = const [],
    this.certificates = const [],
    this.projects = const [],
    this.summary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  CVData copyWith({
    String? id,
    PersonalInfo? personalInfo,
    List<WorkExperience>? workExperiences,
    List<Education>? educations,
    List<Skill>? skills,
    List<Language>? languages,
    List<Certificate>? certificates,
    List<Project>? projects,
    String? summary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CVData(
      id: id ?? this.id,
      personalInfo: personalInfo ?? this.personalInfo,
      workExperiences: workExperiences ?? this.workExperiences,
      educations: educations ?? this.educations,
      skills: skills ?? this.skills,
      languages: languages ?? this.languages,
      certificates: certificates ?? this.certificates,
      projects: projects ?? this.projects,
      summary: summary ?? this.summary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personalInfo': personalInfo.toJson(),
      'workExperiences': workExperiences.map((e) => e.toJson()).toList(),
      'educations': educations.map((e) => e.toJson()).toList(),
      'skills': skills.map((e) => e.toJson()).toList(),
      'languages': languages.map((e) => e.toJson()).toList(),
      'certificates': certificates.map((e) => e.toJson()).toList(),
      'projects': projects.map((e) => e.toJson()).toList(),
      'summary': summary,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CVData.fromJson(Map<String, dynamic> json) {
    return CVData(
      id: json['id'] as String?,
      personalInfo: PersonalInfo.fromJson(json['personalInfo'] as Map<String, dynamic>),
      workExperiences:
          (json['workExperiences'] as List<dynamic>?)
              ?.map((e) => WorkExperience.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      educations:
          (json['educations'] as List<dynamic>?)?.map((e) => Education.fromJson(e as Map<String, dynamic>)).toList() ??
          [],
      skills: (json['skills'] as List<dynamic>?)?.map((e) => Skill.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      languages:
          (json['languages'] as List<dynamic>?)?.map((e) => Language.fromJson(e as Map<String, dynamic>)).toList() ??
          [],
      certificates:
          (json['certificates'] as List<dynamic>?)
              ?.map((e) => Certificate.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      projects:
          (json['projects'] as List<dynamic>?)?.map((e) => Project.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      summary: json['summary'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Create an empty CV template
  factory CVData.empty() {
    return CVData(personalInfo: PersonalInfo.empty());
  }

  /// Create a demo CV with sample data
  factory CVData.demo() {
    return CVData(
      personalInfo: PersonalInfo.demo(),
      summary:
          'Experienced software developer with 5+ years of expertise in full-stack development. Passionate about creating scalable solutions and leading development teams. Strong background in modern web technologies and agile methodologies.',
      workExperiences: [
        WorkExperience(
          id: 'exp1',
          jobTitle: 'Senior Software Developer',
          company: 'Tech Solutions Inc.',
          startDate: DateTime(2021, 1),
          endDate: null,
          isCurrentJob: true,
          description: 'Leading a team of 5 developers in building scalable web applications.',
          responsibilities: [
            'Architect and develop modern web applications using React and Node.js',
            'Lead technical discussions and code reviews',
            'Mentor junior developers and establish best practices',
          ],
          location: 'Istanbul, Turkey',
        ),
        WorkExperience(
          id: 'exp2',
          jobTitle: 'Software Developer',
          company: 'Digital Agency Ltd.',
          startDate: DateTime(2019, 6),
          endDate: DateTime(2020, 12),
          isCurrentJob: false,
          description: 'Developed responsive web applications and mobile apps.',
          responsibilities: [
            'Built responsive web applications using modern frameworks',
            'Collaborated with design team to implement pixel-perfect UIs',
            'Optimized application performance and user experience',
          ],
          location: 'Ankara, Turkey',
        ),
      ],
      educations: [
        Education(
          id: 'edu1',
          institution: 'Istanbul Technical University',
          degree: 'Bachelor of Science in Computer Engineering',
          startDate: DateTime(2015, 9),
          endDate: DateTime(2019, 6),
          gpa: 3.45,
          description: 'Focused on software engineering and data structures.',
        ),
      ],
      skills: [
        Skill(id: 'skill1', name: 'Flutter', level: SkillLevel.expert, category: SkillCategory.technical),
        Skill(id: 'skill2', name: 'React', level: SkillLevel.advanced, category: SkillCategory.technical),
        Skill(id: 'skill3', name: 'Node.js', level: SkillLevel.advanced, category: SkillCategory.technical),
        Skill(id: 'skill4', name: 'Leadership', level: SkillLevel.intermediate, category: SkillCategory.soft),
        Skill(id: 'skill5', name: 'English', level: SkillLevel.expert, category: SkillCategory.language),
      ],
      projects: [
        Project(
          id: 'proj1',
          name: 'E-Commerce Platform',
          description:
              'A modern e-commerce platform built with React and Node.js, featuring real-time inventory management and payment processing.',
          technologies: ['React', 'Node.js', 'MongoDB', 'Stripe API'],
          startDate: DateTime(2023, 3),
          endDate: DateTime(2023, 8),
          isOngoing: false,
          url: 'https://example.com',
          githubUrl: 'https://github.com/example/ecommerce',
        ),
        Project(
          id: 'proj2',
          name: 'Task Management App',
          description:
              'A collaborative task management application with real-time updates and team collaboration features.',
          technologies: ['Flutter', 'Firebase', 'Riverpod'],
          startDate: DateTime(2023, 9),
          endDate: null,
          isOngoing: true,
          githubUrl: 'https://github.com/example/taskapp',
        ),
      ],
      languages: [
        Language(id: 'lang1', name: 'Turkish', level: LanguageLevel.native),
        Language(id: 'lang2', name: 'English', level: LanguageLevel.advanced),
        Language(id: 'lang3', name: 'German', level: LanguageLevel.intermediate),
      ],
      certificates: [
        Certificate(
          id: 'cert1',
          name: 'AWS Certified Solutions Architect',
          issuer: 'Amazon Web Services',
          issueDate: DateTime(2023, 4),
          expiryDate: DateTime(2026, 4),
          credentialId: 'AWS-12345',
          url: 'https://aws.amazon.com/certification/',
        ),
        Certificate(
          id: 'cert2',
          name: 'Google Flutter Certified Developer',
          issuer: 'Google',
          issueDate: DateTime(2022, 11),
          expiryDate: null,
          credentialId: 'FLUTTER-67890',
        ),
      ],
    );
  }

  /// Check if CV has meaningful content
  bool get hasContent {
    // Check if personal info has basic required fields
    final hasBasicInfo =
        personalInfo.firstName.isNotEmpty && personalInfo.lastName.isNotEmpty && personalInfo.email.isNotEmpty;

    // Check if any other section has content
    final hasOtherContent =
        workExperiences.isNotEmpty ||
        educations.isNotEmpty ||
        skills.isNotEmpty ||
        projects.isNotEmpty ||
        languages.isNotEmpty ||
        certificates.isNotEmpty ||
        (summary != null && summary!.isNotEmpty);

    return hasBasicInfo && hasOtherContent;
  }
}

/// Personal information model
class PersonalInfo {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  final String? city;
  final String? country;
  final String? linkedIn;
  final String? github;
  final String? website;
  final String? profileImagePath;

  const PersonalInfo({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,

    this.city,
    this.country,
    this.linkedIn,
    this.github,
    this.website,
    this.profileImagePath,
  });

  PersonalInfo copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,

    String? city,
    String? country,
    String? linkedIn,
    String? github,
    String? website,
    String? profileImagePath,
  }) {
    return PersonalInfo(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,

      city: city ?? this.city,
      country: country ?? this.country,
      linkedIn: linkedIn ?? this.linkedIn,
      github: github ?? this.github,
      website: website ?? this.website,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'city': city,
      'country': country,
      'linkedIn': linkedIn,
      'github': github,
      'website': website,
      'profileImagePath': profileImagePath,
    };
  }

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      firstName: (json['firstName'] as String?) ?? '',
      lastName: (json['lastName'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',

      city: json['city'] as String?,
      country: json['country'] as String?,
      linkedIn: json['linkedIn'] as String?,
      github: json['github'] as String?,
      website: json['website'] as String?,
      profileImagePath: json['profileImagePath'] as String?,
    );
  }

  factory PersonalInfo.empty() {
    return const PersonalInfo(firstName: '', lastName: '', email: '', phone: '');
  }

  /// Create demo personal info
  factory PersonalInfo.demo() {
    return const PersonalInfo(
      firstName: 'John',
      lastName: 'Doe',
      email: 'john.doe@example.com',
      phone: '+90 555 123 4567',
      city: 'Istanbul',
      country: 'Turkey',
      linkedIn: 'linkedin.com/in/johndoe',
      github: 'github.com/johndoe',
      website: 'johndoe.dev',
    );
  }
}

/// Work experience model
class WorkExperience {
  final String id;
  final String jobTitle;
  final String company;
  final String? location;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrentJob;
  final String? description;
  final List<String> responsibilities;

  WorkExperience({
    String? id,
    required this.jobTitle,
    required this.company,
    this.location,
    required this.startDate,
    this.endDate,
    this.isCurrentJob = false,
    this.description,
    this.responsibilities = const [],
  }) : id = id ?? const Uuid().v4();

  WorkExperience copyWith({
    String? id,
    String? jobTitle,
    String? company,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrentJob,
    String? description,
    List<String>? responsibilities,
  }) {
    return WorkExperience(
      id: id ?? this.id,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrentJob: isCurrentJob ?? this.isCurrentJob,
      description: description ?? this.description,
      responsibilities: responsibilities ?? this.responsibilities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobTitle': jobTitle,
      'company': company,
      'location': location,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isCurrentJob': isCurrentJob,
      'description': description,
      'responsibilities': responsibilities,
    };
  }

  factory WorkExperience.fromJson(Map<String, dynamic> json) {
    return WorkExperience(
      id: json['id'] as String? ?? const Uuid().v4(),
      jobTitle: (json['jobTitle'] as String?) ?? '',
      company: (json['company'] as String?) ?? '',
      location: json['location'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      isCurrentJob: (json['isCurrentJob'] as bool?) ?? false,
      description: json['description'] as String?,
      responsibilities: List<String>.from((json['responsibilities'] as List<dynamic>?) ?? []),
    );
  }
}

/// Education model
class Education {
  final String id;
  final String degree;
  final String institution;
  final String? location;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrentStudy;
  final String? description;
  final double? gpa;

  Education({
    String? id,
    required this.degree,
    required this.institution,
    this.location,
    required this.startDate,
    this.endDate,
    this.isCurrentStudy = false,
    this.description,
    this.gpa,
  }) : id = id ?? const Uuid().v4();

  Education copyWith({
    String? id,
    String? degree,
    String? institution,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrentStudy,
    String? description,
    double? gpa,
  }) {
    return Education(
      id: id ?? this.id,
      degree: degree ?? this.degree,
      institution: institution ?? this.institution,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrentStudy: isCurrentStudy ?? this.isCurrentStudy,
      description: description ?? this.description,
      gpa: gpa ?? this.gpa,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'degree': degree,
      'institution': institution,
      'location': location,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isCurrentStudy': isCurrentStudy,
      'description': description,
      'gpa': gpa,
    };
  }

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'] as String? ?? const Uuid().v4(),
      degree: (json['degree'] as String?) ?? '',
      institution: (json['institution'] as String?) ?? '',
      location: json['location'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      isCurrentStudy: (json['isCurrentStudy'] as bool?) ?? false,
      description: json['description'] as String?,
      gpa: (json['gpa'] as num?)?.toDouble(),
    );
  }
}

/// Skill model
class Skill {
  final String id;
  final String name;
  final SkillLevel level;
  final SkillCategory category;

  Skill({String? id, required this.name, required this.level, required this.category}) : id = id ?? const Uuid().v4();

  Skill copyWith({String? id, String? name, SkillLevel? level, SkillCategory? category}) {
    return Skill(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'level': level.name, 'category': category.name};
  }

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] as String? ?? const Uuid().v4(),
      name: (json['name'] as String?) ?? '',
      level: SkillLevel.values.firstWhere(
        (e) => e.name == (json['level'] as String?),
        orElse: () => SkillLevel.beginner,
      ),
      category: SkillCategory.values.firstWhere(
        (e) => e.name == (json['category'] as String?),
        orElse: () => SkillCategory.technical,
      ),
    );
  }
}

/// Skill level enumeration
enum SkillLevel {
  beginner,
  intermediate,
  advanced,
  expert;

  String get displayName {
    switch (this) {
      case SkillLevel.beginner:
        return 'Beginner';
      case SkillLevel.intermediate:
        return 'Intermediate';
      case SkillLevel.advanced:
        return 'Advanced';
      case SkillLevel.expert:
        return 'Expert';
    }
  }

  int get percentage {
    switch (this) {
      case SkillLevel.beginner:
        return 25;
      case SkillLevel.intermediate:
        return 50;
      case SkillLevel.advanced:
        return 75;
      case SkillLevel.expert:
        return 100;
    }
  }
}

/// Skill category enumeration
enum SkillCategory {
  technical,
  soft,
  language,
  other;

  String get displayName {
    switch (this) {
      case SkillCategory.technical:
        return 'Technical';
      case SkillCategory.soft:
        return 'Soft Skills';
      case SkillCategory.language:
        return 'Languages';
      case SkillCategory.other:
        return 'Other';
    }
  }
}

/// Language model
class Language {
  final String id;
  final String name;
  final LanguageLevel level;

  Language({String? id, required this.name, required this.level}) : id = id ?? const Uuid().v4();

  Language copyWith({String? id, String? name, LanguageLevel? level}) {
    return Language(id: id ?? this.id, name: name ?? this.name, level: level ?? this.level);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'level': level.name};
  }

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'] as String? ?? const Uuid().v4(),
      name: (json['name'] as String?) ?? '',
      level: LanguageLevel.values.firstWhere(
        (e) => e.name == (json['level'] as String?),
        orElse: () => LanguageLevel.beginner,
      ),
    );
  }
}

/// Language level enumeration
enum LanguageLevel {
  beginner,
  elementary,
  intermediate,
  upperIntermediate,
  advanced,
  native;

  String get displayName {
    switch (this) {
      case LanguageLevel.beginner:
        return 'A1 - Beginner';
      case LanguageLevel.elementary:
        return 'A2 - Elementary';
      case LanguageLevel.intermediate:
        return 'B1 - Intermediate';
      case LanguageLevel.upperIntermediate:
        return 'B2 - Upper Intermediate';
      case LanguageLevel.advanced:
        return 'C1 - Advanced';
      case LanguageLevel.native:
        return 'C2 - Native';
    }
  }
}

/// Certificate model
class Certificate {
  final String id;
  final String name;
  final String issuer;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final String? credentialId;
  final String? url;

  Certificate({
    String? id,
    required this.name,
    required this.issuer,
    required this.issueDate,
    this.expiryDate,
    this.credentialId,
    this.url,
  }) : id = id ?? const Uuid().v4();

  Certificate copyWith({
    String? id,
    String? name,
    String? issuer,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? credentialId,
    String? url,
  }) {
    return Certificate(
      id: id ?? this.id,
      name: name ?? this.name,
      issuer: issuer ?? this.issuer,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      credentialId: credentialId ?? this.credentialId,
      url: url ?? this.url,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'issuer': issuer,
      'issueDate': issueDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'credentialId': credentialId,
      'url': url,
    };
  }

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'] as String? ?? const Uuid().v4(),
      name: (json['name'] as String?) ?? '',
      issuer: (json['issuer'] as String?) ?? '',
      issueDate: DateTime.parse(json['issueDate'] as String),
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate'] as String) : null,
      credentialId: json['credentialId'] as String?,
      url: json['url'] as String?,
    );
  }
}

/// Project model
class Project {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isOngoing;
  final String? url;
  final String? githubUrl;
  final List<String> technologies;

  Project({
    String? id,
    required this.name,
    required this.description,
    required this.startDate,
    this.endDate,
    this.isOngoing = false,
    this.url,
    this.githubUrl,
    this.technologies = const [],
  }) : id = id ?? const Uuid().v4();

  Project copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    bool? isOngoing,
    String? url,
    String? githubUrl,
    List<String>? technologies,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isOngoing: isOngoing ?? this.isOngoing,
      url: url ?? this.url,
      githubUrl: githubUrl ?? this.githubUrl,
      technologies: technologies ?? this.technologies,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isOngoing': isOngoing,
      'url': url,
      'githubUrl': githubUrl,
      'technologies': technologies,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String? ?? const Uuid().v4(),
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      isOngoing: (json['isOngoing'] as bool?) ?? false,
      url: json['url'] as String?,
      githubUrl: json['githubUrl'] as String?,
      technologies: List<String>.from((json['technologies'] as List<dynamic>?) ?? []),
    );
  }
}
