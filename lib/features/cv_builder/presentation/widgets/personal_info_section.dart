import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../../shared/widgets/custom_form_fields.dart';
import '../providers/cv_provider.dart';
import '../../domain/cv_data.dart';
import '../../data/services/image_upload_service.dart';
import '../../data/services/cv_storage_service.dart';

/// Personal information section widget
class PersonalInfoSection extends ConsumerStatefulWidget {
  const PersonalInfoSection({super.key});

  @override
  ConsumerState<PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends ConsumerState<PersonalInfoSection> {
  final _formKey = GlobalKey<FormState>();

  // Profile image widget key for direct communication
  final _profileImageKey = GlobalKey<_ProfileImageWidgetState>();

  // Text controllers
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  late final TextEditingController _cityController;
  late final TextEditingController _countryController;
  late final TextEditingController _linkedInController;
  late final TextEditingController _githubController;
  late final TextEditingController _websiteController;

  // Focus nodes for proper tab navigation
  late final FocusNode _firstNameFocusNode;
  late final FocusNode _lastNameFocusNode;
  late final FocusNode _emailFocusNode;
  late final FocusNode _phoneFocusNode;

  late final FocusNode _cityFocusNode;
  late final FocusNode _countryFocusNode;
  late final FocusNode _linkedInFocusNode;
  late final FocusNode _githubFocusNode;
  late final FocusNode _websiteFocusNode;

  // Debouncing timer
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    final personalInfo = ref.read(cvDataProvider).personalInfo;
    _firstNameController = TextEditingController(text: personalInfo.firstName);
    _lastNameController = TextEditingController(text: personalInfo.lastName);
    _emailController = TextEditingController(text: personalInfo.email);
    _phoneController = TextEditingController(text: personalInfo.phone);

    _cityController = TextEditingController(text: personalInfo.city ?? '');
    _countryController = TextEditingController(text: personalInfo.country ?? '');
    _linkedInController = TextEditingController(text: personalInfo.linkedIn ?? '');
    _githubController = TextEditingController(text: personalInfo.github ?? '');
    _websiteController = TextEditingController(text: personalInfo.website ?? '');

    // Initialize focus nodes
    _firstNameFocusNode = FocusNode();
    _lastNameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _phoneFocusNode = FocusNode();

    _cityFocusNode = FocusNode();
    _countryFocusNode = FocusNode();
    _linkedInFocusNode = FocusNode();
    _githubFocusNode = FocusNode();
    _websiteFocusNode = FocusNode();

    // Add listeners for auto-save
    _addAutoSaveListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();

    _cityController.dispose();
    _countryController.dispose();
    _linkedInController.dispose();
    _githubController.dispose();
    _websiteController.dispose();

    // Dispose focus nodes
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();

    _cityFocusNode.dispose();
    _countryFocusNode.dispose();
    _linkedInFocusNode.dispose();
    _githubFocusNode.dispose();
    _websiteFocusNode.dispose();

    super.dispose();
  }

  void _addAutoSaveListeners() {
    _firstNameController.addListener(_saveTextFields);
    _lastNameController.addListener(_saveTextFields);
    _emailController.addListener(_saveTextFields);
    _phoneController.addListener(_saveTextFields);

    _cityController.addListener(_saveTextFields);
    _countryController.addListener(_saveTextFields);
    _linkedInController.addListener(_saveTextFields);
    _githubController.addListener(_saveTextFields);
    _websiteController.addListener(_saveTextFields);
  }

  // Callback for when image is selected in the separate widget
  void _onImageSelected(String base64Image) {
    if (kDebugMode) {
      print('📱 _onImageSelected çağrıldı: ${base64Image.length} chars');
    }

    // Ayrı widget'ın UI'ını direkt güncelle
    _profileImageKey.currentState?.updateImage(base64Image);

    // Provider'ı güncelle (sadece fotoğraf için)
    final currentInfo = ref.read(cvDataProvider).personalInfo;
    final updatedInfo = PersonalInfo(
      firstName: currentInfo.firstName,
      lastName: currentInfo.lastName,
      email: currentInfo.email,
      phone: currentInfo.phone,

      city: currentInfo.city,
      country: currentInfo.country,
      linkedIn: currentInfo.linkedIn,
      github: currentInfo.github,
      website: currentInfo.website,
      profileImagePath: base64Image,
    );

    ref.read(cvDataProvider.notifier).updatePersonalInfo(updatedInfo);

    // Local storage'a kaydet
    _saveToLocalStorage();
  }

  // Helper method to save to local storage
  Future<void> _saveToLocalStorage() async {
    try {
      final currentCVData = ref.read(cvDataProvider);
      await CVStorageService.saveCVData(currentCVData);
      if (kDebugMode) {
        print('💾 Profile image saved to local storage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Local storage save error: $e');
      }
    }
  }

  void _saveTextFields() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Set new timer - wait 500ms after user stops typing
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      // SADECE text field'ları güncelle, fotoğrafa DOKUNMA!
      try {
        // Provider'da sadece text field'ları güncelle
        ref
            .read(cvDataProvider.notifier)
            .updatePersonalInfoTextFields(
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              email: _emailController.text,
              phone: _phoneController.text,

              city: _cityController.text.isEmpty ? null : _cityController.text,
              country: _countryController.text.isEmpty ? null : _countryController.text,
              linkedIn: _linkedInController.text.isEmpty ? null : _linkedInController.text,
              github: _githubController.text.isEmpty ? null : _githubController.text,
              website: _websiteController.text.isEmpty ? null : _websiteController.text,
            );

        // Local storage'a kaydet
        final currentCVData = ref.read(cvDataProvider);
        await CVStorageService.saveCVData(currentCVData);

        if (kDebugMode) {
          print('💾 Text fields updated and saved to local storage');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Auto-save error: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final personalInfo = ref.watch(cvDataProvider).personalInfo;
    final hasPersonalInfo =
        personalInfo.firstName.isNotEmpty ||
        personalInfo.lastName.isNotEmpty ||
        personalInfo.email.isNotEmpty ||
        personalInfo.phone.isNotEmpty ||
        personalInfo.profileImagePath != null;

    return ResponsiveCard(
      title: l10n.personalInformation,
      subtitle: l10n.enterBasicContactInfo,
      actions: hasPersonalInfo
          ? [
              IconButton(
                onPressed: () => _showClearDialog(context),
                icon: Icon(PhosphorIcons.trash(), size: 18),
                tooltip: l10n.clearPersonalInformation,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ]
          : null,
      child: Form(
        key: _formKey,
        child: FocusTraversalGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Section
              _buildProfileImageSection(),
              const SizedBox(height: AppConstants.spacingXl),

              // Basic Information
              _buildBasicInfoSection(),
              const SizedBox(height: AppConstants.spacingXl),

              // Contact Information
              _buildContactInfoSection(),
              const SizedBox(height: AppConstants.spacingXl),

              // Social Links
              _buildSocialLinksSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.profilePicture,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppConstants.spacingM),
        Row(
          children: [
            // Profile Image Preview - Ayrı widget olarak
            _ProfileImageWidget(key: _profileImageKey, onImageSelected: _onImageSelected),
            const SizedBox(width: AppConstants.spacingL),
            // Upload Button
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: _selectProfileImage,
                    icon: Icon(PhosphorIcons.camera()),
                    label: Text(l10n.uploadPhoto),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    l10n.optionalPhotoHint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: ref.colors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.basicInformation,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppConstants.spacingM),
        ResponsiveGrid(
          children: [
            ResponsiveFormField(
              label: l10n.firstName,
              isRequired: true,
              child: CustomTextFormField(
                controller: _firstNameController,
                focusNode: _firstNameFocusNode,
                hint: l10n.firstNameHint,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.firstNameRequired;
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _lastNameFocusNode.requestFocus();
                  });
                },
              ),
            ),
            ResponsiveFormField(
              label: l10n.lastName,
              isRequired: true,
              child: CustomTextFormField(
                controller: _lastNameController,
                focusNode: _lastNameFocusNode,
                hint: l10n.lastNameHint,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.lastNameRequired;
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _emailFocusNode.requestFocus();
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.contactInformation,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppConstants.spacingM),
        ResponsiveGrid(
          children: [
            ResponsiveFormField(
              label: l10n.emailAddress,
              isRequired: true,
              child: CustomTextFormField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                hint: l10n.emailHint,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.emailRequired;
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return l10n.emailInvalid;
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _phoneFocusNode.requestFocus();
                  });
                },
              ),
            ),
            ResponsiveFormField(
              label: l10n.phoneNumber,
              isRequired: true,
              child: CustomTextFormField(
                controller: _phoneController,
                focusNode: _phoneFocusNode,
                hint: l10n.phoneHint,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.phoneRequired;
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _cityFocusNode.requestFocus();
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingL),
        ResponsiveGrid(
          children: [
            ResponsiveFormField(
              label: l10n.city,
              child: CustomTextFormField(
                controller: _cityController,
                focusNode: _cityFocusNode,
                hint: l10n.cityHint,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _countryFocusNode.requestFocus();
                  });
                },
              ),
            ),
            ResponsiveFormField(
              label: l10n.country,
              child: CustomTextFormField(
                controller: _countryController,
                focusNode: _countryFocusNode,
                hint: l10n.countryHint,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _linkedInFocusNode.requestFocus();
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialLinksSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.professionalLinks,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppConstants.spacingS),
        Text(
          l10n.professionalLinksHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: ref.colors.textSecondary),
        ),
        const SizedBox(height: AppConstants.spacingM),
        ResponsiveFormField(
          label: l10n.linkedinProfile,
          child: CustomTextFormField(
            controller: _linkedInController,
            focusNode: _linkedInFocusNode,
            hint: l10n.linkedinHint,
            keyboardType: TextInputType.url,
            prefixIcon: Icon(PhosphorIcons.linkedinLogo()),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _githubFocusNode.requestFocus();
              });
            },
          ),
        ),
        const SizedBox(height: AppConstants.spacingL),
        ResponsiveFormField(
          label: l10n.githubProfile,
          child: CustomTextFormField(
            controller: _githubController,
            focusNode: _githubFocusNode,
            hint: l10n.githubHint,
            keyboardType: TextInputType.url,
            prefixIcon: Icon(PhosphorIcons.githubLogo()),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _websiteFocusNode.requestFocus();
              });
            },
          ),
        ),
        const SizedBox(height: AppConstants.spacingL),
        ResponsiveFormField(
          label: l10n.personalWebsite,
          child: CustomTextFormField(
            controller: _websiteController,
            focusNode: _websiteFocusNode,
            hint: l10n.websiteHint,
            keyboardType: TextInputType.url,
            prefixIcon: Icon(PhosphorIcons.globe()),
            textInputAction: TextInputAction.done,
          ),
        ),
      ],
    );
  }

  Future<void> _selectProfileImage() async {
    if (kDebugMode) {
      print('🖼️ _selectProfileImage başladı');
    }
    try {
      if (kDebugMode) {
        print('📱 Image picker açılıyor...');
      }
      final imageFile = await ImageUploadService.pickImage(maxSizeBytes: AppConstants.maxImageSizeBytes);

      if (imageFile != null) {
        if (kDebugMode) {
          print('✅ Image seçildi: ${imageFile.name} (${imageFile.size} bytes)');
        }

        // Compress image if needed
        if (kDebugMode) {
          print('🗜️ Image sıkıştırılıyor...');
        }
        final compressedFile = await ImageUploadService.compressImage(imageFile);
        if (kDebugMode) {
          print('✅ Image sıkıştırıldı: ${compressedFile.size} bytes');
        }

        // Convert to base64 for storage
        if (kDebugMode) {
          print('🔄 Base64\'e çevriliyor...');
        }
        final base64Image = await ImageUploadService.imageToBase64(compressedFile);
        if (kDebugMode) {
          print('✅ Base64 hazır, uzunluk: ${base64Image.length}');
        }

        // Callback ile ayrı widget'a bildir
        if (kDebugMode) {
          print('📱 Ayrı widget\'a bildiriliyor...');
        }
        _onImageSelected(base64Image);

        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.profilePhotoUploaded), backgroundColor: ref.colors.success));
          if (kDebugMode) {
            print('🎉 Success message gösterildi');
          }
        }
      } else {
        if (kDebugMode) {
          print('❌ Image seçilmedi');
        }
      }
    } catch (e) {
      if (kDebugMode) print('💥 Hata oluştu: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.imageUploadFailed), backgroundColor: ref.colors.error));
      }
    }
    if (kDebugMode) print('🏁 _selectProfileImage tamamlandı');
  }

  void _showClearDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearPersonalInformation),
        content: Text(l10n.clearPersonalInfoConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearPersonalInfo();
            },
            child: Text(l10n.clear),
          ),
        ],
      ),
    );
  }

  void _clearPersonalInfo() {
    // Clear provider
    ref.read(cvDataProvider.notifier).clearPersonalInfo();

    // Clear all text controllers
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _phoneController.clear();

    _cityController.clear();
    _countryController.clear();
    _linkedInController.clear();
    _githubController.clear();
    _websiteController.clear();

    // Clear profile image in the widget
    _profileImageKey.currentState?.updateImage('');

    // Show feedback
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.personalInfoCleared), backgroundColor: ref.colors.success));
    }
  }
}

/// Separate widget for profile image display and selection
class _ProfileImageWidget extends ConsumerStatefulWidget {
  final Function(String) onImageSelected;

  const _ProfileImageWidget({super.key, required this.onImageSelected});

  @override
  ConsumerState<_ProfileImageWidget> createState() => _ProfileImageWidgetState();
}

class _ProfileImageWidgetState extends ConsumerState<_ProfileImageWidget> {
  String? _localProfileImage;

  @override
  void initState() {
    super.initState();
    // Initialize with current provider state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentImage = ref.read(cvDataProvider).personalInfo.profileImagePath;
      if (currentImage != null) {
        setState(() {
          _localProfileImage = currentImage;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: ref.colors.grey100,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: ref.colors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        child: _localProfileImage != null
            ? Image.memory(
                base64Decode(_localProfileImage!),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(PhosphorIcons.user(), size: 40, color: ref.colors.grey400);
                },
              )
            : Icon(PhosphorIcons.user(), size: 40, color: ref.colors.grey400),
      ),
    );
  }

  // Method to update image (called from parent)
  void updateImage(String base64Image) {
    if (kDebugMode) {
      print('🖼️ _ProfileImageWidget.updateImage çağrıldı: ${base64Image.length} chars');
    }
    setState(() {
      _localProfileImage = base64Image.isEmpty ? null : base64Image;
    });
    if (kDebugMode) print('✅ _ProfileImageWidget UI güncellendi');
  }
}
