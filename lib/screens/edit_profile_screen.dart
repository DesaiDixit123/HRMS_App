import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hrms_app/components/app_header.dart';
import 'package:hrms_app/controllers/profile_controller.dart';
import 'package:hrms_app/utils/custom_snackbar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileController controller = Get.find<ProfileController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController emergencyContactNameController;
  late TextEditingController emergencyContactNumberController;

  String? selectedGender;
  DateTime? selectedDob;

  final ImagePicker _picker = ImagePicker();
  String? _tempPhotoPath;
  String? _uploadedPhotoUrl;
  bool _isUploadingPhoto = false;

  // Document states
  final Map<String, String?> _uploadedDocs = {};
  final Map<String, bool> _uploadingDocs = {};

  @override
  void initState() {
    super.initState();
    // Initialize with existing data. We need the raw data to patch correctly.
    final personal =
        controller.profileData.value?['personal_details']
            as Map<String, dynamic>? ??
        {};

    emailController = TextEditingController(text: personal['email'] ?? '');
    phoneController = TextEditingController(
      text: personal['mobile_number'] ?? '',
    );
    addressController = TextEditingController(text: personal['address'] ?? '');
    emergencyContactNameController = TextEditingController(
      text: personal['emergency_contact_name'] ?? '',
    );
    emergencyContactNumberController = TextEditingController(
      text: personal['emergency_contact_number'] ?? '',
    );

    selectedGender = personal['gender'];
    final rawDob = personal['dob'];
    if (rawDob != null && rawDob.toString().isNotEmpty) {
      try {
        selectedDob = DateTime.parse(rawDob.toString()).toLocal();
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    emergencyContactNameController.dispose();
    emergencyContactNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _tempPhotoPath = image.path;
      });
      await _uploadPhoto(image.path);
    }
  }

  Future<void> _uploadPhoto(String path) async {
    setState(() {
      _isUploadingPhoto = true;
    });

    final uploadUrl = await controller.uploadImage(path);
    if (uploadUrl != null) {
      setState(() {
        _uploadedPhotoUrl = uploadUrl;
      });
      CustomSnackbar.showSuccess(
        title: 'Success',
        message: 'Photo uploaded successfully!',
      );
    } else {
      setState(() {
        _tempPhotoPath = null;
      });
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to upload photo.',
      );
    }

    setState(() {
      _isUploadingPhoto = false;
    });
  }

  Future<void> _pickDocument(String docKey) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      await _uploadDocument(docKey, result.files.single.path!);
    }
  }

  Future<void> _uploadDocument(String docKey, String path) async {
    setState(() {
      _uploadingDocs[docKey] = true;
    });

    final uploadUrl = await controller.uploadImage(path);
    if (uploadUrl != null) {
      setState(() {
        _uploadedDocs[docKey] = uploadUrl;
      });
      CustomSnackbar.showSuccess(
        title: 'Success',
        message:
            '${docKey.replaceAll('_', ' ').toUpperCase()} uploaded successfully!',
      );
    } else {
      CustomSnackbar.showError(
        title: 'Error',
        message:
            'Failed to upload ${docKey.replaceAll('_', ' ').toUpperCase()}.',
      );
    }

    setState(() {
      _uploadingDocs[docKey] = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          selectedDob ??
          DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF52B447),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1F2430),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDob) {
      setState(() {
        selectedDob = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final personalUpdates = {
      'email': emailController.text.trim(),
      'mobile_number': phoneController.text.trim(),
      'address': addressController.text.trim(),
      'emergency_contact_name': emergencyContactNameController.text.trim(),
      'emergency_contact_number': emergencyContactNumberController.text.trim(),
    };

    if (selectedGender != null) {
      personalUpdates['gender'] = selectedGender!;
    }

    if (selectedDob != null) {
      // Backend usually expects YYYY-MM-DD
      personalUpdates['dob'] =
          '${selectedDob!.year}-${selectedDob!.month.toString().padLeft(2, '0')}-${selectedDob!.day.toString().padLeft(2, '0')}';
    }

    // Retain existing personal_details and update with new fields
    final currentPersonal =
        controller.profileData.value?['personal_details']
            as Map<String, dynamic>? ??
        {};
    final mergedPersonalDetails = {...currentPersonal, ...personalUpdates};

    final updateData = <String, dynamic>{
      'personal_details': mergedPersonalDetails,
    };

    // If photo was uploaded, include it in documents
    if (_uploadedPhotoUrl != null || _uploadedDocs.isNotEmpty) {
      final currentDocs = controller.documents;
      final mergedDocs = {
        ...currentDocs,
        if (_uploadedPhotoUrl != null) 'profile_photo': _uploadedPhotoUrl,
        ..._uploadedDocs,
      };
      updateData['documents'] = mergedDocs;
    }

    final success = await controller.updateProfile(updateData);
    if (success) {
      Get.back();
      CustomSnackbar.showSuccess(
        title: 'Success',
        message: 'Profile updated successfully!',
      );
    } else {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to update profile.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                const AppHeader(
                  title: 'Edit Profile',
                  subtitle: 'Update your personal details',
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: _isUploadingPhoto ? null : _pickImage,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF52B447),
                                    width: 3,
                                  ),
                                  color: const Color(0xFFF5F5F5),
                                ),
                                child: ClipOval(
                                  child: _isUploadingPhoto
                                      ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : _tempPhotoPath != null
                                      ? Image.file(
                                          File(_tempPhotoPath!),
                                          fit: BoxFit.cover,
                                        )
                                      : controller.profilePhotoUrl.isNotEmpty
                                      ? Image.network(
                                          controller.profilePhotoUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.person,
                                                    size: 70,
                                                    color: Color(0xFFA9B7A0),
                                                  ),
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 70,
                                          color: Color(0xFFA9B7A0),
                                        ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF52B447),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildTextField(
                        controller: emailController,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Email is required';
                          }
                          if (!GetUtils.isEmail(val)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Phone number is required';
                          }
                          if (val.length < 10) {
                            return 'Enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(),
                      const SizedBox(height: 16),
                      _buildDateField(context),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: addressController,
                        label: 'Address',
                        icon: Icons.location_on,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Emergency Contact',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2430),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: emergencyContactNameController,
                        label: 'Name',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: emergencyContactNumberController,
                        label: 'Phone Number',
                        icon: Icons.phone_android,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 30),
                      // Documents Section
                      const Text(
                        'My Documents',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2430),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDocumentUploadItem('aadhar_card', 'Aadhar Card'),
                      _buildDocumentUploadItem('pan_card', 'PAN Card'),
                      _buildDocumentUploadItem('bank_details', 'Bank Details'),
                      _buildDocumentUploadItem(
                        'qualification_certificates',
                        'Qualification Certificates',
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: controller.isUpdating.value
                                ? null
                                : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF52B447),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: controller.isUpdating.value
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF74808F),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFA9B7A0)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDCE6D8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDCE6D8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF52B447)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF3B30)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF74808F),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedGender,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.people, color: Color(0xFFA9B7A0)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDCE6D8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDCE6D8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF52B447)),
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'Male', child: Text('Male')),
            DropdownMenuItem(value: 'Female', child: Text('Female')),
            DropdownMenuItem(value: 'Other', child: Text('Other')),
          ],
          onChanged: (value) {
            setState(() {
              selectedGender = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date of Birth',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF74808F),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDCE6D8)),
            ),
            child: Row(
              children: [
                const Icon(Icons.cake, color: Color(0xFFA9B7A0)),
                const SizedBox(width: 12),
                Text(
                  selectedDob != null
                      ? '${selectedDob!.year}-${selectedDob!.month.toString().padLeft(2, '0')}-${selectedDob!.day.toString().padLeft(2, '0')}'
                      : 'Select Date',
                  style: TextStyle(
                    fontSize: 16,
                    color: selectedDob != null
                        ? const Color(0xFF1F2430)
                        : const Color(0xFF74808F),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentUploadItem(String docKey, String label) {
    final isUploading = _uploadingDocs[docKey] ?? false;
    final isUploaded =
        _uploadedDocs[docKey] != null || controller.documents[docKey] != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isUploading ? null : () => _pickDocument(docKey),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUploaded
                  ? const Color(0xFF52B447)
                  : const Color(0xFFDCE6D8),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isUploaded ? Icons.check_circle : Icons.upload_file,
                color: isUploaded
                    ? const Color(0xFF52B447)
                    : const Color(0xFF6E3EB5),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2430),
                  ),
                ),
              ),
              if (isUploading)
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (isUploaded)
                const Text(
                  'Uploaded',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF52B447),
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFFA9B7A0),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
