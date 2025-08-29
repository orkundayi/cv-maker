/// Localizations for CV templates
class TemplateLocalizations {
  static final Map<String, Map<String, String>> _localizations = {
    'en': {
      'personal': 'Personal',
      'phoneNumber': 'Phone number',
      'email': 'Email',
      'address': 'Address',
      'linkedIn': 'LinkedIn',
      'github': 'GitHub',
      'languages': 'Languages',
      'skills': 'Skills',
      'workExperience': 'Work experience',
      'education': 'Education',
      'projects': 'Projects',
      'certificates': 'Certificates',
      'summary': 'Professional Summary',
      'present': 'Present',
      'beginner': 'Beginner',
      'intermediate': 'Intermediate',
      'advanced': 'Advanced',
      'expert': 'Expert',
      'native': 'Native',
      'fluent': 'Fluent',
    },
    'tr': {
      'personal': 'Kişisel Bilgiler',
      'phoneNumber': 'Telefon',
      'email': 'E-posta',
      'address': 'Adres',
      'linkedIn': 'LinkedIn',
      'github': 'GitHub',
      'languages': 'Diller',
      'skills': 'Yetenekler',
      'workExperience': 'İş Deneyimi',
      'education': 'Eğitim',
      'projects': 'Projeler',
      'certificates': 'Sertifikalar',
      'summary': 'Özet',
      'present': 'Devam Ediyor',
      'beginner': 'Başlangıç',
      'intermediate': 'Orta',
      'advanced': 'İleri',
      'expert': 'Uzman',
      'native': 'Ana Dil',
      'fluent': 'Akıcı',
    },
  };

  static String translate(String key, String locale) {
    final localizedStrings = _localizations[locale] ?? _localizations['en']!;
    return localizedStrings[key] ?? key;
  }
}
