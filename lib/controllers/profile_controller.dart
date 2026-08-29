import 'package:get/get.dart';
import 'package:hrms_app/services/api_service.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

class ProfileController extends GetxController {
  final isLoading = true.obs;
  final profileData = Rxn<Map<String, dynamic>>();
  final errorMessage = ''.obs;

  final isUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final response = await ApiService.post(
        '/employeeUser/getprofile',
        body: {'date': dateStr, 'month': now.month, 'year': now.year},
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        profileData.value = response['Data'] as Map<String, dynamic>;
      } else {
        errorMessage.value = response['Message'] ?? 'Failed to load profile';
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Network error. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updateData) async {
    isUpdating.value = true;
    try {
      final response = await ApiService.post(
        '/employeeUser/updateprofile',
        body: updateData,
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true) {
        await fetchProfile();
        return true;
      } else {
        return false;
      }
    } catch (_) {
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // ─── Helper getters ─────────────────────────────────────────
  Map<String, dynamic> get _personal =>
      profileData.value?['personal_details'] as Map<String, dynamic>? ?? {};

  Map<String, dynamic> get _professional =>
      profileData.value?['professional_details'] as Map<String, dynamic>? ?? {};

  String get fullName => _personal['full_name'] ?? 'N/A';
  String get email => _personal['email'] ?? 'N/A';
  String get phone => _personal['mobile_number'] ?? 'N/A';
  String get gender => _personal['gender'] ?? 'N/A';
  String get address => _personal['address'] ?? 'N/A';
  String get emergencyContactName =>
      _personal['emergency_contact_name'] ?? 'N/A';
  String get emergencyContactNumber =>
      _personal['emergency_contact_number'] ?? 'N/A';

  String get dob {
    final raw = _personal['dob'];
    if (raw == null) return 'N/A';
    try {
      final date = DateTime.parse(raw).toLocal();
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return raw.toString();
    }
  }

  String get designation => _professional['designation'] ?? 'N/A';
  String get role => _professional['role'] ?? 'N/A';
  String get employmentType => _professional['employment_type'] ?? 'N/A';

  String get department {
    final dept = _professional['department'];
    if (dept is Map) return dept['department_name'] ?? 'N/A';
    return 'N/A';
  }

  String get reportingManager {
    final mgr = _professional['reporting_manager'];
    if (mgr is Map) {
      final name = mgr['name'] ?? '';
      final desig = mgr['designation'] ?? '';
      return desig.isNotEmpty ? '$name ($desig)' : name;
    }
    return 'N/A';
  }

  double get grossSalary =>
      (_professional['gross_salary'] as num?)?.toDouble() ?? 0;

  String get joiningDate {
    final raw = _professional['joining_date'];
    if (raw == null) return 'N/A';
    try {
      final date = DateTime.parse(raw).toLocal();
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return raw.toString();
    }
  }

  String get employeeCode => _professional['code'] ?? 'N/A';
  bool get isActive => profileData.value?['status'] == true;

  Map<String, dynamic> get documents =>
      profileData.value?['documents'] as Map<String, dynamic>? ?? {};

  String get profilePhotoUrl {
    final photo = documents['profile_photo'];
    if (photo == null || photo.toString().isEmpty) return '';
    return '${ApiService.imageBaseUrl}$photo';
  }

  Future<String?> uploadImage(String filePath) async {
    try {
      final response = await ApiService.uploadFile(
        '/admin/common/image-upload',
        filePath,
        fieldName: 'image',
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        return response['Data']['upload_url'];
      }
    } catch (e) {
      developer.log('Error uploading image: $e');
    }
    return null;
  }
}
