import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/cv_data.dart';

/// CV data state provider
class CVDataNotifier extends StateNotifier<CVData> {
  CVDataNotifier() : super(CVData.empty());

  /// Update personal information
  void updatePersonalInfo(PersonalInfo personalInfo) {
    state = state.copyWith(personalInfo: personalInfo);
  }

  /// Update only text fields of personal information (preserves profile image)
  void updatePersonalInfoTextFields({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    String? address,
    String? city,
    String? country,
    String? linkedIn,
    String? github,
    String? website,
  }) {
    final currentInfo = state.personalInfo;
    final updatedInfo = PersonalInfo(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      address: address,
      city: city,
      country: country,
      linkedIn: linkedIn,
      github: github,
      website: website,
      profileImagePath: currentInfo.profileImagePath, // Preserve existing profile image
    );
    state = state.copyWith(personalInfo: updatedInfo);
  }

  /// Update CV summary
  void updateSummary(String summary) {
    state = state.copyWith(summary: summary);
  }

  /// Add work experience
  void addWorkExperience(WorkExperience experience) {
    final experiences = List<WorkExperience>.from(state.workExperiences);
    experiences.add(experience);
    state = state.copyWith(workExperiences: experiences);
  }

  /// Update work experience
  void updateWorkExperience(WorkExperience experience) {
    final experiences = state.workExperiences.map((e) {
      return e.id == experience.id ? experience : e;
    }).toList();
    state = state.copyWith(workExperiences: experiences);
  }

  /// Remove work experience
  void removeWorkExperience(String id) {
    final experiences = state.workExperiences.where((e) => e.id != id).toList();
    state = state.copyWith(workExperiences: experiences);
  }

  /// Add education
  void addEducation(Education education) {
    final educations = List<Education>.from(state.educations);
    educations.add(education);
    state = state.copyWith(educations: educations);
  }

  /// Update education
  void updateEducation(Education education) {
    final educations = state.educations.map((e) {
      return e.id == education.id ? education : e;
    }).toList();
    state = state.copyWith(educations: educations);
  }

  /// Remove education
  void removeEducation(String id) {
    final educations = state.educations.where((e) => e.id != id).toList();
    state = state.copyWith(educations: educations);
  }

  /// Add skill
  void addSkill(Skill skill) {
    final skills = List<Skill>.from(state.skills);
    skills.add(skill);
    state = state.copyWith(skills: skills);
  }

  /// Update skill
  void updateSkill(Skill skill) {
    final skills = state.skills.map((s) {
      return s.id == skill.id ? skill : s;
    }).toList();
    state = state.copyWith(skills: skills);
  }

  /// Remove skill
  void removeSkill(String id) {
    final skills = state.skills.where((s) => s.id != id).toList();
    state = state.copyWith(skills: skills);
  }

  /// Add language
  void addLanguage(Language language) {
    final languages = List<Language>.from(state.languages);
    languages.add(language);
    state = state.copyWith(languages: languages);
  }

  /// Update language
  void updateLanguage(Language language) {
    final languages = state.languages.map((l) {
      return l.id == language.id ? language : l;
    }).toList();
    state = state.copyWith(languages: languages);
  }

  /// Remove language
  void removeLanguage(String id) {
    final languages = state.languages.where((l) => l.id != id).toList();
    state = state.copyWith(languages: languages);
  }

  /// Add certificate
  void addCertificate(Certificate certificate) {
    final certificates = List<Certificate>.from(state.certificates);
    certificates.add(certificate);
    state = state.copyWith(certificates: certificates);
  }

  /// Update certificate
  void updateCertificate(Certificate certificate) {
    final certificates = state.certificates.map((c) {
      return c.id == certificate.id ? certificate : c;
    }).toList();
    state = state.copyWith(certificates: certificates);
  }

  /// Remove certificate
  void removeCertificate(String id) {
    final certificates = state.certificates.where((c) => c.id != id).toList();
    state = state.copyWith(certificates: certificates);
  }

  /// Add project
  void addProject(Project project) {
    final projects = List<Project>.from(state.projects);
    projects.add(project);
    state = state.copyWith(projects: projects);
  }

  /// Update project
  void updateProject(Project project) {
    final projects = state.projects.map((p) {
      return p.id == project.id ? project : p;
    }).toList();
    state = state.copyWith(projects: projects);
  }

  /// Remove project
  void removeProject(String id) {
    final projects = state.projects.where((p) => p.id != id).toList();
    state = state.copyWith(projects: projects);
  }

  /// Load CV data
  set cvData(CVData cvData) {
    state = cvData;
  }

  /// Reset CV data
  void resetCVData() {
    state = CVData.empty();
  }

  /// Create a copy of current CV
  CVData getCVDataCopy() {
    return state.copyWith();
  }
}

/// CV data provider
final cvDataProvider = StateNotifierProvider<CVDataNotifier, CVData>((ref) {
  return CVDataNotifier();
});

/// Current section provider for navigation
final currentSectionProvider = StateProvider<CVSection>((ref) {
  return CVSection.personalInfo;
});

/// CV sections enumeration
enum CVSection {
  personalInfo,
  summary,
  workExperience,
  education,
  skills,
  languages,
  certificates,
  projects,
  preview;

  String get title {
    switch (this) {
      case CVSection.personalInfo:
        return 'Personal Information';
      case CVSection.summary:
        return 'Professional Summary';
      case CVSection.workExperience:
        return 'Work Experience';
      case CVSection.education:
        return 'Education';
      case CVSection.skills:
        return 'Skills';
      case CVSection.languages:
        return 'Languages';
      case CVSection.certificates:
        return 'Certificates';
      case CVSection.projects:
        return 'Projects';
      case CVSection.preview:
        return 'Preview & Export';
    }
  }

  String get description {
    switch (this) {
      case CVSection.personalInfo:
        return 'Enter your basic contact information';
      case CVSection.summary:
        return 'Write a brief professional summary';
      case CVSection.workExperience:
        return 'Add your work experience and achievements';
      case CVSection.education:
        return 'List your educational background';
      case CVSection.skills:
        return 'Highlight your technical and soft skills';
      case CVSection.languages:
        return 'Specify languages you speak';
      case CVSection.certificates:
        return 'Add your certifications and licenses';
      case CVSection.projects:
        return 'Showcase your projects and accomplishments';
      case CVSection.preview:
        return 'Review your CV and export to PDF';
    }
  }
}

/// Form validation state provider
final formValidationProvider = StateProvider<Map<String, String?>>((ref) {
  return {};
});

/// Image upload state provider
final imageUploadProvider = StateProvider<String?>((ref) {
  return null;
});
