import 'package:get/get.dart';
import 'package:hrms_app/services/api_service.dart';
import 'package:intl/intl.dart';

class HolidayController extends GetxController {
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final upcomingHolidays = <Map<String, dynamic>>[].obs;
  final currentMonthHolidays = <Map<String, dynamic>>[].obs;
  final allHolidays = <Map<String, dynamic>>[].obs;
  final holidayDetails = Rxn<Map<String, dynamic>>();

  // Filter states
  final currentFilter = 'this_month'.obs;
  final customStartDate = ''.obs;
  final customEndDate = ''.obs;

  @override
  void onInit() {
    super.onInit();
    refreshHolidays();
  }

  Future<void> refreshHolidays() async {
    await Future.wait([fetchUpcoming(), fetchCurrentMonth(), fetchAll()]);
  }

  Map<String, dynamic> _getFilterBody({String? filterOverride}) {
    final filter = filterOverride ?? currentFilter.value;
    final body = <String, dynamic>{'filter': filter};
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');

    if (filter == 'this_month') {
      final fromDate = DateTime(now.year, now.month, 1);
      final toDate = DateTime(now.year, now.month + 1, 0);
      body['from_date'] = dateFormat.format(fromDate);
      body['to_date'] = dateFormat.format(toDate);
    } else if (filter == 'last_month') {
      final fromDate = DateTime(now.year, now.month - 1, 1);
      final toDate = DateTime(now.year, now.month, 0);
      body['from_date'] = dateFormat.format(fromDate);
      body['to_date'] = dateFormat.format(toDate);
    } else if (filter == 'last_week') {
      final fromDate = now.subtract(const Duration(days: 7));
      body['from_date'] = dateFormat.format(fromDate);
      body['to_date'] = dateFormat.format(now);
    } else if (filter == 'custom' &&
        customStartDate.value.isNotEmpty &&
        customEndDate.value.isNotEmpty) {
      body['from_date'] = customStartDate.value;
      body['to_date'] = customEndDate.value;
    }
    return body;
  }

  Future<void> fetchUpcoming() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await ApiService.post(
        '/employeeUser/holiday/upcoming',
        body: {}, // Backend calculates upcoming automatically
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        final list = response['Data'] as List<dynamic>;
        upcomingHolidays.value = list
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load upcoming holidays';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCurrentMonth() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await ApiService.post(
        '/employeeUser/holiday/current-month',
        body: _getFilterBody(filterOverride: 'this_month'), // Always this month
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        final list = response['Data'] as List<dynamic>;
        currentMonthHolidays.value = list
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load this month\'s holidays';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await ApiService.post(
        '/employeeUser/holiday/all',
        body: _getFilterBody(), // Follows global selection
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        final data = response['Data'];
        final List<dynamic> list = (data is Map && data['docs'] is List)
            ? data['docs']
            : (data is List ? data : []);
        allHolidays.value = list.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load holidays';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchHolidayDetails(String holidayId) async {
    isLoading.value = true;
    errorMessage.value = '';
    holidayDetails.value = null;
    try {
      final response = await ApiService.post(
        '/employeeUser/holiday/details',
        body: {'holidayId': holidayId},
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        holidayDetails.value = response['Data'] as Map<String, dynamic>;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load holiday details';
    } finally {
      isLoading.value = false;
    }
  }
}
