import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hrms_app/services/api_service.dart';

class LettersController extends GetxController {
  final isLoading = false.obs;
  final letters = <Map<String, dynamic>>[].obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyLetters();
  }

  Future<void> fetchMyLetters() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await ApiService.post(
        '/employeeUser/letters/list',
        body: {},
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        final list = response['Data'] as List<dynamic>;
        letters.value = list.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        errorMessage.value = response['Message'] ?? 'Failed to load letters';
      }
    } catch (e) {
      debugPrint('Error fetching letters: $e');
      errorMessage.value = 'Failed to load letters. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }
}
