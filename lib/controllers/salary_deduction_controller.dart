import 'package:get/get.dart';
import 'package:hrms_app/services/api_service.dart';

class SalaryDeductionController extends GetxController {
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final currentMonthDeductions = <Map<String, dynamic>>[].obs;
  final allDeductions = <Map<String, dynamic>>[].obs;
  final deductionDetails = Rxn<Map<String, dynamic>>();

  // Filter states
  final currentFilter = 'this_month'.obs;
  final customStartDate = ''.obs;
  final customEndDate = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchCurrentMonthDeductions() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await ApiService.post(
        '/employeeUser/salary-deduction/current-month',
        body: {'filter': 'this_month'},
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        final list = response['Data'] as List<dynamic>;
        currentMonthDeductions.value = list
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load current month deductions';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final body = <String, dynamic>{'filter': currentFilter.value};
      if (currentFilter.value == 'custom' &&
          customStartDate.value.isNotEmpty &&
          customEndDate.value.isNotEmpty) {
        body['from_date'] = customStartDate.value;
        body['to_date'] = customEndDate.value;
      }
      final response = await ApiService.post(
        '/employeeUser/salary-deduction/list',
        body: body,
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        final data = response['Data'];
        final List<dynamic> list = (data is Map && data['docs'] is List)
            ? data['docs']
            : (data is List ? data : []);
        allDeductions.value = list
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load deductions';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDeductionDetails(String deductionId) async {
    isLoading.value = true;
    errorMessage.value = '';
    deductionDetails.value = null;
    try {
      final response = await ApiService.post(
        '/employeeUser/salary-deduction/details',
        body: {'deductionId': deductionId},
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        deductionDetails.value = response['Data'] as Map<String, dynamic>;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load deduction details';
    } finally {
      isLoading.value = false;
    }
  }
}
