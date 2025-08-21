import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
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
  late final TextEditingController _addressController;
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
  late final FocusNode _addressFocusNode;
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
    _addressController = TextEditingController(text: personalInfo.address ?? '');
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
    _addressFocusNode = FocusNode();
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
    _addressController.dispose();
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
    _addressFocusNode.dispose();
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
    _addressController.addListener(_saveTextFields);
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
      address: currentInfo.address,
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
              address: _addressController.text.isEmpty ? null : _addressController.text,
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
    return ResponsiveCard(
      title: 'Personal Information',
      subtitle: 'Enter your basic contact information',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Profile Picture', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
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
                    label: const Text('Upload Photo'),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    'Optional: Add a professional photo (JPG, PNG)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppConstants.spacingM),
        ResponsiveGrid(
          children: [
            ResponsiveFormField(
              label: 'First Name',
              isRequired: true,
              child: CustomTextFormField(
                controller: _firstNameController,
                focusNode: _firstNameFocusNode,
                hint: 'Enter your first name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'First name is required';
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
              label: 'Last Name',
              isRequired: true,
              child: CustomTextFormField(
                controller: _lastNameController,
                focusNode: _lastNameFocusNode,
                hint: 'Enter your last name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Last name is required';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppConstants.spacingM),
        ResponsiveGrid(
          children: [
            ResponsiveFormField(
              label: 'Email Address',
              isRequired: true,
              child: CustomTextFormField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                hint: 'your.email@example.com',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Enter a valid email address';
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
              label: 'Phone Number',
              isRequired: true,
              child: CustomTextFormField(
                controller: _phoneController,
                focusNode: _phoneFocusNode,
                hint: '+1 (555) 123-4567',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number is required';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _addressFocusNode.requestFocus();
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingL),
        ResponsiveFormField(
          label: 'Address',
          child: CustomTextFormField(
            controller: _addressController,
            focusNode: _addressFocusNode,
            hint: '123 Main Street, Apt 4B',
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _cityFocusNode.requestFocus();
              });
            },
          ),
        ),
        const SizedBox(height: AppConstants.spacingL),
        ResponsiveGrid(
          children: [
            ResponsiveFormField(
              label: 'City',
              child: CustomTextFormField(
                controller: _cityController,
                focusNode: _cityFocusNode,
                hint: 'New York',
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _countryFocusNode.requestFocus();
                  });
                },
              ),
            ),
            ResponsiveFormField(
              label: 'Country',
              child: CustomTextFormField(
                controller: _countryController,
                focusNode: _countryFocusNode,
                hint: 'United States',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Professional Links',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppConstants.spacingS),
        Text(
          'Add links to your professional profiles (optional)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppConstants.spacingM),
        ResponsiveFormField(
          label: 'LinkedIn Profile',
          child: CustomTextFormField(
            controller: _linkedInController,
            focusNode: _linkedInFocusNode,
            hint: 'https://linkedin.com/in/yourprofile',
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
          label: 'GitHub Profile',
          child: CustomTextFormField(
            controller: _githubController,
            focusNode: _githubFocusNode,
            hint: 'https://github.com/yourusername',
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
          label: 'Personal Website',
          child: CustomTextFormField(
            controller: _websiteController,
            focusNode: _websiteFocusNode,
            hint: 'https://yourwebsite.com',
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo uploaded successfully!'), backgroundColor: AppColors.success),
          );
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e'), backgroundColor: AppColors.error));
      }
    }
    if (kDebugMode) print('🏁 _selectProfileImage tamamlandı');
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
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.border),
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
                  return Icon(PhosphorIcons.user(), size: 40, color: AppColors.grey400);
                },
              )
            : Icon(PhosphorIcons.user(), size: 40, color: AppColors.grey400),
      ),
    );
  }

  // Method to update image (called from parent)
  void updateImage(String base64Image) {
    if (kDebugMode) print('🖼️ _ProfileImageWidget.updateImage çağrıldı: ${base64Image.length} chars');
    setState(() {
      _localProfileImage = base64Image;
    });
    if (kDebugMode) print('✅ _ProfileImageWidget UI güncellendi');
  }
}
