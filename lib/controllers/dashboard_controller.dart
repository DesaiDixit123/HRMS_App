import 'package:get/get.dart';
import 'package:hrms_app/services/api_service.dart';
import 'package:hrms_app/utils/time_utils.dart';

class DashboardController extends GetxController {
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final dashboardData = Rxn<Map<String, dynamic>>();
  final currentFilter = 'this_month'.obs;
  final customStartDate = ''.obs;
  final customEndDate = ''.obs;
  final isAttendanceExpanded = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  Future<void> fetchDashboard({
    String? filter,
    String? fromDate,
    String? toDate,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final activeFilter = filter ?? currentFilter.value;
      final body = <String, dynamic>{'filter': activeFilter};

      if (activeFilter == 'custom') {
        body['from_date'] = fromDate ?? customStartDate.value;
        body['to_date'] = toDate ?? customEndDate.value;
      }

      final response = await ApiService.post(
        '/employeeUser/dashboard',
        body: body,
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        dashboardData.value = response['Data'] as Map<String, dynamic>;
        if (filter != null) currentFilter.value = filter;
        if (fromDate != null) customStartDate.value = fromDate;
        if (toDate != null) customEndDate.value = toDate;
      } else {
        errorMessage.value = response['Message'] ?? 'Failed to load dashboard';
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Network error. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Helper getters ─────────────────────────────────────────
  String get greeting => dashboardData.value?['greeting'] ?? 'Good Morning';

  Map<String, dynamic> get _today =>
      dashboardData.value?['today'] as Map<String, dynamic>? ?? {};

  // Today
  String get punchIn => convertTo24Hour(_today['punch_in'] ?? '-');
  String get punchOut => convertTo24Hour(_today['punch_out'] ?? '-');
  String get workingTime => _today['working_time'] ?? '0h 00m';
  String get status => _today['status'] ?? 'Absent';
  String get nextAction => _today['next_action'] ?? 'Punch In';

  // Summary
  Map<String, dynamic> get _summary =>
      dashboardData.value?['summary'] as Map<String, dynamic>? ?? {};
  int get incentive => _summary['incentive'] ?? 0;
  int get allowance => _summary['allowance'] ?? 0;
  int get deduction => _summary['deduction'] ?? 0;
  int get holiday => _summary['holiday'] ?? 0;
  int get upcomingHoliday => _summary['upcoming_holiday'] ?? 0;

  // Attendance Data
  Map<String, dynamic> get _attendanceData =>
      dashboardData.value?['attendance_data'] as Map<String, dynamic>? ?? {};
  String get totalWorkingDays =>
      '${_attendanceData['total_working_days'] ?? 0}';
  String get daysPresent => '${_attendanceData['days_present'] ?? 0}';
  String get daysAbsent => '${_attendanceData['days_absent'] ?? 0}';
  String get daysLeave => '${_attendanceData['days_leave'] ?? 0}';
  String get firstHalfDay => '${_attendanceData['first_half_day'] ?? 0}';
  String get secondHalfDay => '${_attendanceData['second_half_day'] ?? 0}';
  String get halfDay {
    final first = _attendanceData['first_half_day'] ?? 0;
    final second = _attendanceData['second_half_day'] ?? 0;
    try {
      final total = (int.tryParse(first.toString()) ?? 0) + (int.tryParse(second.toString()) ?? 0);
      return total.toString();
    } catch (_) {
      return '0';
    }
  }
  String get holidayCount => '${_attendanceData['holiday'] ?? 0}';
  String get leavesTaken => '${_attendanceData['leaves_taken'] ?? 0}';
  String get attendancePercentage =>
      _attendanceData['attendance_percentage'] ?? '0%';
}
