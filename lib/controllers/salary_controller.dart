import 'package:get/get.dart';
import 'package:hrms_app/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SalaryController extends GetxController {
  final isLoading = true.obs;
  final isHistoryLoading = false.obs;
  final isDownloadLoading = false.obs;
  final errorMessage = ''.obs;

  final currentSalary = Rxn<Map<String, dynamic>>();
  final salaryHistoryList = <Map<String, dynamic>>[].obs;
  final selectedSalaryDetails = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    fetchCurrentSalary();
    fetchSalaryHistory();
  }

  Future<void> fetchCurrentSalary() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await ApiService.post(
        '/employeeUser/salary/current',
        body: {},
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        currentSalary.value = response['Data'] as Map<String, dynamic>;
      } else {
        errorMessage.value =
            response['Message'] ?? 'Failed to load current salary';
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Network error. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSalaryHistory() async {
    isHistoryLoading.value = true;
    try {
      final response = await ApiService.post(
        '/employeeUser/salary/history',
        body: {'page': 1, 'limit': 12},
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true &&
          response['Data'] != null &&
          response['Data']['docs'] != null) {
        final List<Map<String, dynamic>> rawList = List<Map<String, dynamic>>.from(
          response['Data']['docs'],
        );
        final Set<String> seenKeys = <String>{};
        final List<Map<String, dynamic>> uniqueList = [];
        for (var slip in rawList) {
          final month = slip['month']?.toString() ?? '';
          final year = slip['year']?.toString() ?? '';
          final key = '${month}_$year';
          if (!seenKeys.contains(key)) {
            seenKeys.add(key);
            uniqueList.add(slip);
          }
        }
        salaryHistoryList.value = uniqueList;
      }
    } catch (e) {
      print('Error fetching salary history: $e');
    } finally {
      isHistoryLoading.value = false;
    }
  }

  Future<void> fetchSalaryDetails(String salaryId) async {
    isLoading.value = true;
    try {
      final response = await ApiService.post(
        '/employeeUser/salary/details',
        body: {'salaryId': salaryId},
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        selectedSalaryDetails.value = response['Data'] as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching salary details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadSalarySlip(String slipId) async {
    isDownloadLoading.value = true;
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        throw Exception('No auth token found');
      }

      // Format based on the provided hint in the prompt:
      // /employeeUser/salary/download/:id?token=...
      final downloadUrl =
          '${ApiService.baseUrl}/employeeUser/salary/download/$slipId?token=$token';

      final uri = Uri.parse(downloadUrl);
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        throw Exception('Could not launch document');
      }
    } catch (e) {
      print('Download error: $e');
      rethrow;
    } finally {
      isDownloadLoading.value = false;
    }
  }

  // --- Helpers for Current Salary UI ---
  Map<String, dynamic> get _current => currentSalary.value ?? {};

  double get netSalary => (_current['net_salary'] as num?)?.toDouble() ?? 0.0;

  Map<String, dynamic> get _earnings =>
      _current['earnings'] as Map<String, dynamic>? ?? {};

  double get basicSalary => (_earnings['basic'] as num?)?.toDouble() ?? 0.0;
  double get incentive => (_earnings['incentive'] as num?)?.toDouble() ?? 0.0;

  List<dynamic> get allowances =>
      _earnings['allowances'] as List<dynamic>? ?? [];
  double get totalAllowances {
    double total = 0;
    for (var a in allowances) {
      total += (a['amount'] as num?)?.toDouble() ?? 0.0;
    }
    return total;
  }

  double get grossSalary => basicSalary + incentive + totalAllowances;

  Map<String, dynamic> get _deductions =>
      _current['deductions'] as Map<String, dynamic>? ?? {};

  List<dynamic> get deductionItems =>
      _deductions['items'] as List<dynamic>? ?? [];
  double get totalDeductions {
    double total = 0;
    for (var d in deductionItems) {
      total += (d['amount'] as num?)?.toDouble() ?? 0.0;
    }
    total += (_deductions['absent_deduction'] as num?)?.toDouble() ?? 0.0;
    total += (_deductions['lost_hours_deduction'] as num?)?.toDouble() ?? 0.0;
    return total;
  }

  double get absentDeduction =>
      (_deductions['absent_deduction'] as num?)?.toDouble() ?? 0.0;
  double get lostHoursDeduction =>
      (_deductions['lost_hours_deduction'] as num?)?.toDouble() ?? 0.0;

  String get currentMonthName {
    final month = _current['month'];
    final year = _current['year'];
    if (month == null || year == null) return 'N/A';

    // convert month number if possible
    try {
      final m = int.parse(month.toString());
      final months = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December",
      ];
      if (m >= 1 && m <= 12) {
        return '${months[m - 1]} $year';
      }
    } catch (_) {}
    return '$month $year';
  }

  String get currentStatus => _current['status'] ?? 'Pending';
}
