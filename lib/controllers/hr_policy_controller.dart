import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hrms_app/services/api_service.dart';

class HRPolicyController extends GetxController {
  final isLoading = false.obs;
  final policies = <Map<String, dynamic>>[].obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHRPolicies();
  }

  Future<void> fetchHRPolicies() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await ApiService.post(
        '/employeeUser/hr-policy/list',
        body: {},
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        final list = response['Data'] as List<dynamic>;
        policies.value = list.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        errorMessage.value = response['Message'] ?? 'Failed to load HR policies';
      }
    } catch (e) {
      debugPrint('Error fetching HR policies: $e');
      errorMessage.value = 'Failed to load HR policies. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }
}
