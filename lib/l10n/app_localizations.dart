import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'CV Maker'**
  String get appName;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @enterBasicContactInfo.
  ///
  /// In en, this message translates to:
  /// **'Enter your basic contact information'**
  String get enterBasicContactInfo;

  /// No description provided for @clearPersonalInformation.
  ///
  /// In en, this message translates to:
  /// **'Clear Personal Information'**
  String get clearPersonalInformation;

  /// No description provided for @clearPersonalInfoConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all personal information? This action cannot be undone.'**
  String get clearPersonalInfoConfirm;

  /// No description provided for @profilePicture.
  ///
  /// In en, this message translates to:
  /// **'Profile Picture'**
  String get profilePicture;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get uploadPhoto;

  /// No description provided for @optionalPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Optional: Add a professional photo (JPG, PNG)'**
  String get optionalPhotoHint;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get firstNameHint;

  /// No description provided for @lastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get lastNameHint;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameRequired;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get lastNameRequired;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'your.email@example.com'**
  String get emailHint;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'+1 (555) 123-4567'**
  String get phoneHint;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get emailInvalid;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @cityHint.
  ///
  /// In en, this message translates to:
  /// **'New York'**
  String get cityHint;

  /// No description provided for @countryHint.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get countryHint;

  /// No description provided for @professionalLinks.
  ///
  /// In en, this message translates to:
  /// **'Professional Links'**
  String get professionalLinks;

  /// No description provided for @professionalLinksHint.
  ///
  /// In en, this message translates to:
  /// **'Add links to your professional profiles (optional)'**
  String get professionalLinksHint;

  /// No description provided for @linkedinProfile.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn Profile'**
  String get linkedinProfile;

  /// No description provided for @githubProfile.
  ///
  /// In en, this message translates to:
  /// **'GitHub Profile'**
  String get githubProfile;

  /// No description provided for @personalWebsite.
  ///
  /// In en, this message translates to:
  /// **'Personal Website'**
  String get personalWebsite;

  /// No description provided for @linkedinHint.
  ///
  /// In en, this message translates to:
  /// **'https://linkedin.com/in/yourprofile'**
  String get linkedinHint;

  /// No description provided for @githubHint.
  ///
  /// In en, this message translates to:
  /// **'https://github.com/yourusername'**
  String get githubHint;

  /// No description provided for @websiteHint.
  ///
  /// In en, this message translates to:
  /// **'https://yourwebsite.com'**
  String get websiteHint;

  /// No description provided for @professionalSummary.
  ///
  /// In en, this message translates to:
  /// **'Professional Summary'**
  String get professionalSummary;

  /// No description provided for @summaryDescription.
  ///
  /// In en, this message translates to:
  /// **'Write a brief overview of your professional background'**
  String get summaryDescription;

  /// No description provided for @clearSummary.
  ///
  /// In en, this message translates to:
  /// **'Clear Summary'**
  String get clearSummary;

  /// No description provided for @summaryHint.
  ///
  /// In en, this message translates to:
  /// **'Write a brief overview of your professional background, key skills, and career objectives...'**
  String get summaryHint;

  /// No description provided for @clearSummaryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear the summary? This action cannot be undone.'**
  String get clearSummaryConfirm;

  /// No description provided for @workExperience.
  ///
  /// In en, this message translates to:
  /// **'Work Experience'**
  String get workExperience;

  /// No description provided for @workExperienceDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your professional work history'**
  String get workExperienceDescription;

  /// No description provided for @clearAllExperiences.
  ///
  /// In en, this message translates to:
  /// **'Clear All Experiences'**
  String get clearAllExperiences;

  /// No description provided for @addExperience.
  ///
  /// In en, this message translates to:
  /// **'Add Experience'**
  String get addExperience;

  /// No description provided for @editExperience.
  ///
  /// In en, this message translates to:
  /// **'Edit Experience'**
  String get editExperience;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get jobTitle;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @currentlyWorking.
  ///
  /// In en, this message translates to:
  /// **'Currently working here'**
  String get currentlyWorking;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @jobTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Software Engineer'**
  String get jobTitleHint;

  /// No description provided for @companyHint.
  ///
  /// In en, this message translates to:
  /// **'Google Inc.'**
  String get companyHint;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'San Francisco, CA'**
  String get locationHint;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your key responsibilities and achievements...'**
  String get descriptionHint;

  /// No description provided for @clearExperiencesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all work experiences? This action cannot be undone.'**
  String get clearExperiencesConfirm;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @educationDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your educational background'**
  String get educationDescription;

  /// No description provided for @clearAllEducation.
  ///
  /// In en, this message translates to:
  /// **'Clear All Education'**
  String get clearAllEducation;

  /// No description provided for @addEducation.
  ///
  /// In en, this message translates to:
  /// **'Add Education'**
  String get addEducation;

  /// No description provided for @editEducation.
  ///
  /// In en, this message translates to:
  /// **'Edit Education'**
  String get editEducation;

  /// No description provided for @degree.
  ///
  /// In en, this message translates to:
  /// **'Degree'**
  String get degree;

  /// No description provided for @institution.
  ///
  /// In en, this message translates to:
  /// **'Institution'**
  String get institution;

  /// No description provided for @degreeHint.
  ///
  /// In en, this message translates to:
  /// **'Bachelor of Computer Science'**
  String get degreeHint;

  /// No description provided for @institutionHint.
  ///
  /// In en, this message translates to:
  /// **'Stanford University'**
  String get institutionHint;

  /// No description provided for @clearEducationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all education entries? This action cannot be undone.'**
  String get clearEducationConfirm;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills;

  /// No description provided for @skillsDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your technical and soft skills'**
  String get skillsDescription;

  /// No description provided for @clearAllSkills.
  ///
  /// In en, this message translates to:
  /// **'Clear All Skills'**
  String get clearAllSkills;

  /// No description provided for @addSkill.
  ///
  /// In en, this message translates to:
  /// **'Add Skill'**
  String get addSkill;

  /// No description provided for @editSkill.
  ///
  /// In en, this message translates to:
  /// **'Edit Skill'**
  String get editSkill;

  /// No description provided for @skillName.
  ///
  /// In en, this message translates to:
  /// **'Skill Name'**
  String get skillName;

  /// No description provided for @skillLevel.
  ///
  /// In en, this message translates to:
  /// **'Skill Level'**
  String get skillLevel;

  /// No description provided for @skillCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get skillCategory;

  /// No description provided for @skillNameHint.
  ///
  /// In en, this message translates to:
  /// **'React.js'**
  String get skillNameHint;

  /// No description provided for @clearSkillsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all skills? This action cannot be undone.'**
  String get clearSkillsConfirm;

  /// No description provided for @beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// No description provided for @intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @expert.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get expert;

  /// No description provided for @technical.
  ///
  /// In en, this message translates to:
  /// **'Technical'**
  String get technical;

  /// No description provided for @soft.
  ///
  /// In en, this message translates to:
  /// **'Soft Skills'**
  String get soft;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// No description provided for @languagesDescription.
  ///
  /// In en, this message translates to:
  /// **'Add languages you speak'**
  String get languagesDescription;

  /// No description provided for @clearAllLanguages.
  ///
  /// In en, this message translates to:
  /// **'Clear All Languages'**
  String get clearAllLanguages;

  /// No description provided for @addLanguage.
  ///
  /// In en, this message translates to:
  /// **'Add Language'**
  String get addLanguage;

  /// No description provided for @editLanguage.
  ///
  /// In en, this message translates to:
  /// **'Edit Language'**
  String get editLanguage;

  /// No description provided for @languageName.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageName;

  /// No description provided for @languageLevel.
  ///
  /// In en, this message translates to:
  /// **'Proficiency Level'**
  String get languageLevel;

  /// No description provided for @languageNameHint.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageNameHint;

  /// No description provided for @clearLanguagesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all languages? This action cannot be undone.'**
  String get clearLanguagesConfirm;

  /// No description provided for @native.
  ///
  /// In en, this message translates to:
  /// **'Native'**
  String get native;

  /// No description provided for @fluent.
  ///
  /// In en, this message translates to:
  /// **'Fluent'**
  String get fluent;

  /// No description provided for @conversational.
  ///
  /// In en, this message translates to:
  /// **'Conversational'**
  String get conversational;

  /// No description provided for @basic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get basic;

  /// No description provided for @certificates.
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get certificates;

  /// No description provided for @certificatesDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your certifications and achievements'**
  String get certificatesDescription;

  /// No description provided for @clearAllCertificates.
  ///
  /// In en, this message translates to:
  /// **'Clear All Certificates'**
  String get clearAllCertificates;

  /// No description provided for @addCertificate.
  ///
  /// In en, this message translates to:
  /// **'Add Certificate'**
  String get addCertificate;

  /// No description provided for @editCertificate.
  ///
  /// In en, this message translates to:
  /// **'Edit Certificate'**
  String get editCertificate;

  /// No description provided for @certificateName.
  ///
  /// In en, this message translates to:
  /// **'Certificate Name'**
  String get certificateName;

  /// No description provided for @issuingOrganization.
  ///
  /// In en, this message translates to:
  /// **'Issuing Organization'**
  String get issuingOrganization;

  /// No description provided for @issueDate.
  ///
  /// In en, this message translates to:
  /// **'Issue Date'**
  String get issueDate;

  /// No description provided for @certificateNameHint.
  ///
  /// In en, this message translates to:
  /// **'AWS Certified Solutions Architect'**
  String get certificateNameHint;

  /// No description provided for @organizationHint.
  ///
  /// In en, this message translates to:
  /// **'Amazon Web Services'**
  String get organizationHint;

  /// No description provided for @clearCertificatesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all certificates? This action cannot be undone.'**
  String get clearCertificatesConfirm;

  /// No description provided for @projects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// No description provided for @projectsDescription.
  ///
  /// In en, this message translates to:
  /// **'Showcase your personal and professional projects'**
  String get projectsDescription;

  /// No description provided for @clearAllProjects.
  ///
  /// In en, this message translates to:
  /// **'Clear All Projects'**
  String get clearAllProjects;

  /// No description provided for @addProject.
  ///
  /// In en, this message translates to:
  /// **'Add Project'**
  String get addProject;

  /// No description provided for @editProject.
  ///
  /// In en, this message translates to:
  /// **'Edit Project'**
  String get editProject;

  /// No description provided for @projectName.
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get projectName;

  /// No description provided for @projectUrl.
  ///
  /// In en, this message translates to:
  /// **'Live Demo URL'**
  String get projectUrl;

  /// No description provided for @githubUrl.
  ///
  /// In en, this message translates to:
  /// **'GitHub URL'**
  String get githubUrl;

  /// No description provided for @technologies.
  ///
  /// In en, this message translates to:
  /// **'Technologies'**
  String get technologies;

  /// No description provided for @projectNameHint.
  ///
  /// In en, this message translates to:
  /// **'E-commerce Website'**
  String get projectNameHint;

  /// No description provided for @urlHint.
  ///
  /// In en, this message translates to:
  /// **'https://myproject.com'**
  String get urlHint;

  /// No description provided for @githubUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://github.com/username/project'**
  String get githubUrlHint;

  /// No description provided for @technologiesHint.
  ///
  /// In en, this message translates to:
  /// **'React, Node.js, MongoDB'**
  String get technologiesHint;

  /// No description provided for @liveDemo.
  ///
  /// In en, this message translates to:
  /// **'Live Demo'**
  String get liveDemo;

  /// No description provided for @github.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get github;

  /// No description provided for @clearProjectsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all projects? This action cannot be undone.'**
  String get clearProjectsConfirm;

  /// No description provided for @cvPreview.
  ///
  /// In en, this message translates to:
  /// **'CV Preview'**
  String get cvPreview;

  /// No description provided for @previewDescription.
  ///
  /// In en, this message translates to:
  /// **'Preview and export your CV'**
  String get previewDescription;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clearAllData;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @loadDemoData.
  ///
  /// In en, this message translates to:
  /// **'Load Demo Data'**
  String get loadDemoData;

  /// No description provided for @chooseTemplate.
  ///
  /// In en, this message translates to:
  /// **'Choose Template'**
  String get chooseTemplate;

  /// No description provided for @modern.
  ///
  /// In en, this message translates to:
  /// **'Modern'**
  String get modern;

  /// No description provided for @minimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get minimal;

  /// No description provided for @professional.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get professional;

  /// No description provided for @noDataMessage.
  ///
  /// In en, this message translates to:
  /// **'No data available to preview. Please fill in your information in the previous sections.'**
  String get noDataMessage;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @clearAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all data? This will remove all your CV information and cannot be undone.'**
  String get clearAllConfirm;

  /// No description provided for @exportingPdf.
  ///
  /// In en, this message translates to:
  /// **'Exporting PDF...'**
  String get exportingPdf;

  /// No description provided for @pdfExported.
  ///
  /// In en, this message translates to:
  /// **'CV exported successfully!'**
  String get pdfExported;

  /// No description provided for @exportError.
  ///
  /// In en, this message translates to:
  /// **'Failed to export PDF'**
  String get exportError;

  /// No description provided for @demoDataLoaded.
  ///
  /// In en, this message translates to:
  /// **'Demo data loaded successfully!'**
  String get demoDataLoaded;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @prev.
  ///
  /// In en, this message translates to:
  /// **'Prev'**
  String get prev;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @helpDescription.
  ///
  /// In en, this message translates to:
  /// **'Welcome to CV Maker! Follow these steps to create your professional resume:'**
  String get helpDescription;

  /// No description provided for @helpStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Enter your personal information'**
  String get helpStep1;

  /// No description provided for @helpStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Write a professional summary'**
  String get helpStep2;

  /// No description provided for @helpStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Add your work experiences'**
  String get helpStep3;

  /// No description provided for @helpStep4.
  ///
  /// In en, this message translates to:
  /// **'4. List your education'**
  String get helpStep4;

  /// No description provided for @helpStep5.
  ///
  /// In en, this message translates to:
  /// **'5. Highlight your skills'**
  String get helpStep5;

  /// No description provided for @helpStep6.
  ///
  /// In en, this message translates to:
  /// **'6. Add languages you speak'**
  String get helpStep6;

  /// No description provided for @helpStep7.
  ///
  /// In en, this message translates to:
  /// **'7. Include certifications'**
  String get helpStep7;

  /// No description provided for @helpStep8.
  ///
  /// In en, this message translates to:
  /// **'8. Showcase your projects'**
  String get helpStep8;

  /// No description provided for @helpStep9.
  ///
  /// In en, this message translates to:
  /// **'9. Preview and export your CV'**
  String get helpStep9;

  /// No description provided for @helpTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: All fields are automatically saved as you type!'**
  String get helpTip;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get gotIt;

  /// No description provided for @profilePhotoUploaded.
  ///
  /// In en, this message translates to:
  /// **'Profile photo uploaded successfully!'**
  String get profilePhotoUploaded;

  /// No description provided for @personalInfoCleared.
  ///
  /// In en, this message translates to:
  /// **'Personal information cleared successfully'**
  String get personalInfoCleared;

  /// No description provided for @summaryCleared.
  ///
  /// In en, this message translates to:
  /// **'Summary cleared successfully'**
  String get summaryCleared;

  /// No description provided for @experienceCleared.
  ///
  /// In en, this message translates to:
  /// **'Work experiences cleared successfully'**
  String get experienceCleared;

  /// No description provided for @educationCleared.
  ///
  /// In en, this message translates to:
  /// **'Education entries cleared successfully'**
  String get educationCleared;

  /// No description provided for @skillsCleared.
  ///
  /// In en, this message translates to:
  /// **'Skills cleared successfully'**
  String get skillsCleared;

  /// No description provided for @languagesCleared.
  ///
  /// In en, this message translates to:
  /// **'Languages cleared successfully'**
  String get languagesCleared;

  /// No description provided for @certificatesCleared.
  ///
  /// In en, this message translates to:
  /// **'Certificates cleared successfully'**
  String get certificatesCleared;

  /// No description provided for @projectsCleared.
  ///
  /// In en, this message translates to:
  /// **'Projects cleared successfully'**
  String get projectsCleared;

  /// No description provided for @allDataCleared.
  ///
  /// In en, this message translates to:
  /// **'All data cleared successfully'**
  String get allDataCleared;

  /// No description provided for @linkOpened.
  ///
  /// In en, this message translates to:
  /// **'Opening in browser...'**
  String get linkOpened;

  /// No description provided for @linkOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link'**
  String get linkOpenError;

  /// No description provided for @urlLaunchError.
  ///
  /// In en, this message translates to:
  /// **'Unable to open URL. Please copy and open manually:'**
  String get urlLaunchError;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @degreeCertificate.
  ///
  /// In en, this message translates to:
  /// **'Degree/Certificate'**
  String get degreeCertificate;

  /// No description provided for @degreeRequired.
  ///
  /// In en, this message translates to:
  /// **'Degree is required'**
  String get degreeRequired;

  /// No description provided for @institutionRequired.
  ///
  /// In en, this message translates to:
  /// **'Institution is required'**
  String get institutionRequired;

  /// No description provided for @gpaOptional.
  ///
  /// In en, this message translates to:
  /// **'GPA (Optional)'**
  String get gpaOptional;

  /// No description provided for @gpaHint.
  ///
  /// In en, this message translates to:
  /// **'3.8'**
  String get gpaHint;

  /// No description provided for @addNewEducation.
  ///
  /// In en, this message translates to:
  /// **'Add New Education'**
  String get addNewEducation;

  /// No description provided for @skillsExpertise.
  ///
  /// In en, this message translates to:
  /// **'Skills & Expertise'**
  String get skillsExpertise;

  /// No description provided for @languagesCommunication.
  ///
  /// In en, this message translates to:
  /// **'Languages & Communication'**
  String get languagesCommunication;

  /// No description provided for @certificationsLicenses.
  ///
  /// In en, this message translates to:
  /// **'Certifications & Licenses'**
  String get certificationsLicenses;

  /// No description provided for @certificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Professional credentials and achievements'**
  String get certificationsDescription;

  /// No description provided for @portfolioProjects.
  ///
  /// In en, this message translates to:
  /// **'Portfolio & Projects'**
  String get portfolioProjects;

  /// No description provided for @cvSections.
  ///
  /// In en, this message translates to:
  /// **'CV Sections'**
  String get cvSections;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @selectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Select Start Date'**
  String get selectStartDate;

  /// No description provided for @selectEndDate.
  ///
  /// In en, this message translates to:
  /// **'Select End Date'**
  String get selectEndDate;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @pleaseSelectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a start date'**
  String get pleaseSelectStartDate;

  /// No description provided for @pleaseSelectEndDateOrMarkCurrent.
  ///
  /// In en, this message translates to:
  /// **'Please select an end date or mark as current study'**
  String get pleaseSelectEndDateOrMarkCurrent;

  /// No description provided for @educationUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Education updated successfully!'**
  String get educationUpdatedSuccessfully;

  /// No description provided for @educationAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Education added successfully!'**
  String get educationAddedSuccessfully;

  /// No description provided for @selectIssueDate.
  ///
  /// In en, this message translates to:
  /// **'Select Issue Date'**
  String get selectIssueDate;

  /// No description provided for @selectExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Select Expiry Date'**
  String get selectExpiryDate;

  /// No description provided for @imageUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image'**
  String get imageUploadFailed;

  /// No description provided for @chipInputHint.
  ///
  /// In en, this message translates to:
  /// **'Type and press Enter to add'**
  String get chipInputHint;

  /// No description provided for @certificateHasExpiry.
  ///
  /// In en, this message translates to:
  /// **'This certificate has an expiry date'**
  String get certificateHasExpiry;

  /// No description provided for @noExpiry.
  ///
  /// In en, this message translates to:
  /// **'No expiry'**
  String get noExpiry;

  /// No description provided for @expires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get expires;

  /// No description provided for @verifyCertificate.
  ///
  /// In en, this message translates to:
  /// **'Verify Certificate'**
  String get verifyCertificate;

  /// No description provided for @expiryBeforeIssueError.
  ///
  /// In en, this message translates to:
  /// **'Expiry date cannot be before issue date'**
  String get expiryBeforeIssueError;

  /// No description provided for @credentialIdOptional.
  ///
  /// In en, this message translates to:
  /// **'Credential ID (Optional)'**
  String get credentialIdOptional;

  /// No description provided for @credentialIdHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., AWS-12345, PMP-67890'**
  String get credentialIdHint;

  /// No description provided for @writingTips.
  ///
  /// In en, this message translates to:
  /// **'Writing Tips'**
  String get writingTips;

  /// No description provided for @keepItConcise.
  ///
  /// In en, this message translates to:
  /// **'Keep it concise (3-5 sentences, 100-500 characters)'**
  String get keepItConcise;

  /// No description provided for @highlightKeyStrengths.
  ///
  /// In en, this message translates to:
  /// **'• Highlight your key strengths and experience'**
  String get highlightKeyStrengths;

  /// No description provided for @mentionCareerGoals.
  ///
  /// In en, this message translates to:
  /// **'• Mention your career goals and what you bring'**
  String get mentionCareerGoals;

  /// No description provided for @useActionWords.
  ///
  /// In en, this message translates to:
  /// **'• Use action words and quantifiable achievements'**
  String get useActionWords;

  /// No description provided for @tailorToRole.
  ///
  /// In en, this message translates to:
  /// **'• Tailor it to the specific role you\'re applying for'**
  String get tailorToRole;

  /// No description provided for @tooShort.
  ///
  /// In en, this message translates to:
  /// **'Too short'**
  String get tooShort;

  /// No description provided for @tooLong.
  ///
  /// In en, this message translates to:
  /// **'Too long'**
  String get tooLong;

  /// No description provided for @perfectLength.
  ///
  /// In en, this message translates to:
  /// **'Perfect length'**
  String get perfectLength;

  /// No description provided for @characterCount.
  ///
  /// In en, this message translates to:
  /// **'Character count'**
  String get characterCount;

  /// No description provided for @proTips.
  ///
  /// In en, this message translates to:
  /// **'Pro Tips'**
  String get proTips;

  /// No description provided for @summaryGrabAttention.
  ///
  /// In en, this message translates to:
  /// **'Your summary should grab attention immediately. Start with your years of experience or key achievement, then mention 2-3 core skills, and end with what you\'re looking for or can contribute.'**
  String get summaryGrabAttention;

  /// No description provided for @modernSidebarDescription.
  ///
  /// In en, this message translates to:
  /// **'Professional modern CV with colored sidebar for personal info and skills'**
  String get modernSidebarDescription;

  /// No description provided for @minimalCleanDescription.
  ///
  /// In en, this message translates to:
  /// **'Simple and clean CV design focusing on content'**
  String get minimalCleanDescription;

  /// No description provided for @professionalCorporateDescription.
  ///
  /// In en, this message translates to:
  /// **'Professional corporate style with classic layout'**
  String get professionalCorporateDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
