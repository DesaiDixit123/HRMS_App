import 'package:get/get.dart';
import 'package:hrms_app/services/api_service.dart';

class AllowanceController extends GetxController {
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final currentMonthAllowances = <Map<String, dynamic>>[].obs;
  final allAllowances = <Map<String, dynamic>>[].obs;
  final allowanceDetails = Rxn<Map<String, dynamic>>();

  // Filter states
  final currentFilter = 'this_month'.obs;
  final customStartDate = ''.obs;
  final customEndDate = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchCurrentMonthAllowances() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await ApiService.post(
        '/employeeUser/allowance/current-month',
        body: {'filter': 'this_month'},
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        final list = response['Data'] as List<dynamic>;
        currentMonthAllowances.value = list
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load current month allowances';
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
        '/employeeUser/allowance/list',
        body: body,
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        final data = response['Data'];
        final List<dynamic> list = (data is Map && data['docs'] is List)
            ? data['docs']
            : (data is List ? data : []);
        allAllowances.value = list
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load allowances';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllowanceDetails(String allowanceId) async {
    isLoading.value = true;
    errorMessage.value = '';
    allowanceDetails.value = null;
    try {
      final response = await ApiService.post(
        '/employeeUser/allowance/details',
        body: {'allowanceId': allowanceId},
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        allowanceDetails.value = response['Data'] as Map<String, dynamic>;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load allowance details';
    } finally {
      isLoading.value = false;
    }
  }
}
