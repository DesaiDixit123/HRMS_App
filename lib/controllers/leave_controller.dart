import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hrms_app/services/api_service.dart';
import 'package:hrms_app/utils/custom_snackbar.dart';
import 'package:intl/intl.dart';

class LeaveController extends GetxController {
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final errorMessage = ''.obs;

  // Leave types (fetched or fallback)
  final leaveTypes = <Map<String, dynamic>>[].obs;

  // Applied leaves list
  final appliedLeaves = <Map<String, dynamic>>[].obs;

  // Leave statistics
  final leaveAllowed = 0.0.obs;
  final leaveUsed = 0.0.obs;
  final leaveRemaining = 0.0.obs;
  final leavePending = 0.0.obs;
  final leaveTypeBalances = <Map<String, dynamic>>[].obs;

  // Form fields
  final selectedLeaveTypeId = ''.obs;
  final selectedDayType =
      'full day'.obs; // first half, second half, late, full day
  final selectedLeaveDay = 'single'.obs; // single, multiple
  final fromDate = Rxn<DateTime>();
  final toDate = Rxn<DateTime>();
  final reason = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeaveTypes();
    fetchLeaveBalances();
    fetchMyLeaves();
  }

  // ─── Fetch Leave Types ──────────────────────────────────────
  Future<void> fetchLeaveTypes() async {
    try {
      final response = await ApiService.post(
        '/employeeUser/leave/types',
        body: {},
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        final list = response['Data'] as List<dynamic>;
        leaveTypes.assignAll(
          list.map((e) => Map<String, dynamic>.from(e)).toList(),
        );
      }
    } catch (e) {
      debugPrint('Error fetching leave types: $e');
      errorMessage.value = 'Failed to load leave types';
    }
  }

  // ─── Fetch Leave Balances ───────────────────────────────────
  Future<void> fetchLeaveBalances() async {
    try {
      final response = await ApiService.post(
        '/employeeUser/leave/balances',
        body: {},
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        final data = response['Data'] as Map<String, dynamic>;
        leaveAllowed.value = (data['total_paid_allowed'] ?? 0.0).toDouble();
        leaveUsed.value = (data['total_leave_days_taken'] ?? 0.0).toDouble();
        leaveRemaining.value = (data['remaining_paid_leaves'] ?? 0.0).toDouble();
        leavePending.value = (data['total_leave_days_pending'] ?? 0.0).toDouble();

        if (data['type_balances'] != null) {
          final list = data['type_balances'] as List<dynamic>;
          leaveTypeBalances.assignAll(
            list.map((e) => Map<String, dynamic>.from(e)).toList(),
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching leave balances: $e');
    }
  }

  // ─── Fetch My Leaves ───────────────────────────────────────
  Future<void> fetchMyLeaves() async {
    isLoading.value = true;
    try {
      final response = await ApiService.post(
        '/employeeUser/leave/history',
        body: {'page': 1, 'limit': 100},
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true &&
          response['Data'] != null &&
          response['Data']['docs'] != null) {
        final list = response['Data']['docs'] as List<dynamic>;
        appliedLeaves.value = list
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
    } catch (_) {
      // If admin endpoint fails with employee token, just show empty
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Apply Leave ────────────────────────────────────────────
  Future<bool> applyLeave() async {
    if (selectedLeaveTypeId.value.isEmpty) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Please select a leave type',
      );
      return false;
    }
    if (fromDate.value == null) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Please select a from date',
      );
      return false;
    }
    if (selectedLeaveDay.value == 'multiple' && toDate.value == null) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Please select a to date',
      );
      return false;
    }
    if (reason.value.trim().isEmpty) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Please provide a reason',
      );
      return false;
    }

    isSubmitting.value = true;
    try {
      final body = <String, dynamic>{
        'leavetypeid': selectedLeaveTypeId.value,
        'leave_per_day_type': selectedDayType.value,
        'leave_day': selectedLeaveDay.value,
        'from_date': DateFormat('yyyy-MM-dd').format(fromDate.value!),
        'reason': reason.value.trim(),
      };
      if (selectedLeaveDay.value == 'multiple' && toDate.value != null) {
        body['to_date'] = DateFormat('yyyy-MM-dd').format(toDate.value!);
      }

      final response = await ApiService.post(
        '/employeeUser/leave/apply',
        body: body,
        requiresAuth: true,
      );

      if (response['IsSuccess'] == true) {
        CustomSnackbar.showSuccess(
          title: 'Success',
          message: response['Message'] ?? 'Leave applied!',
        );
        resetForm();
        await fetchMyLeaves();
        await fetchLeaveBalances();
        return true;
      } else {
        CustomSnackbar.showError(
          title: 'Error',
          message: response['Message'] ?? 'Failed to apply leave',
        );
        return false;
      }
    } on ApiException catch (e) {
      CustomSnackbar.showError(title: 'Error', message: e.message);
      return false;
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Network error. Please try again.',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─── Cancel Leave ───────────────────────────────────────────
  Future<bool> cancelLeave(String leaveId) async {
    isLoading.value = true;
    try {
      final response = await ApiService.post(
        '/employeeUser/leave/cancel',
        body: {'leaveapplyid': leaveId},
        requiresAuth: true,
      );

      if (response['IsSuccess'] == true) {
        CustomSnackbar.showSuccess(
          title: 'Success',
          message: response['Message'] ?? 'Leave cancelled successfully',
        );
        await fetchMyLeaves();
        await fetchLeaveBalances();
        return true;
      } else {
        CustomSnackbar.showError(
          title: 'Error',
          message: response['Message'] ?? 'Failed to cancel leave',
        );
        return false;
      }
    } on ApiException catch (e) {
      CustomSnackbar.showError(title: 'Error', message: e.message);
      return false;
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Network error. Please try again.',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    selectedLeaveTypeId.value = '';
    selectedDayType.value = 'full day';
    selectedLeaveDay.value = 'single';
    fromDate.value = null;
    toDate.value = null;
    reason.value = '';
  }

  // ─── Helpers ────────────────────────────────────────────────
  String get selectedLeaveTypeName {
    final type = leaveTypes.firstWhereOrNull(
      (t) => t['_id'] == selectedLeaveTypeId.value,
    );
    return type?['name'] ?? 'Select';
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
