import 'package:get/get.dart';
import 'package:hrms_app/services/api_service.dart';

class IncentiveController extends GetxController {
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final currentMonthIncentives = <Map<String, dynamic>>[].obs;
  final allIncentives = <Map<String, dynamic>>[].obs;
  final incentiveDetails = Rxn<Map<String, dynamic>>();

  // Filter states
  final currentFilter = 'this_month'.obs;
  final customStartDate = ''.obs;
  final customEndDate = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchCurrentMonthIncentives() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await ApiService.post(
        '/employeeUser/incentive/current-month',
        body: {'filter': 'this_month'},
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        final list = response['Data'] as List<dynamic>;
        currentMonthIncentives.value = list
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load current month incentives';
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
        '/employeeUser/incentive/list',
        body: body,
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        final data = response['Data'];
        final List<dynamic> list = (data is Map && data['docs'] is List)
            ? data['docs']
            : (data is List ? data : []);
        allIncentives.value = list
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load incentives';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchIncentiveDetails(String incentiveId) async {
    isLoading.value = true;
    errorMessage.value = '';
    incentiveDetails.value = null;
    try {
      final response = await ApiService.post(
        '/employeeUser/incentive/details',
        body: {'incentiveId': incentiveId},
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        incentiveDetails.value = response['Data'] as Map<String, dynamic>;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load incentive details';
    } finally {
      isLoading.value = false;
    }
  }
}
