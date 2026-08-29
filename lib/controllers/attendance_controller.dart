import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrms_app/controllers/dashboard_controller.dart';
import 'package:hrms_app/services/api_service.dart';
import 'package:hrms_app/services/location_service.dart';
import 'package:hrms_app/utils/custom_snackbar.dart';
import 'package:intl/intl.dart';

class AttendanceController extends GetxController {
  final isLoading = true.obs;
  final isPunchLoading = false.obs;
  final errorMessage = ''.obs;
  final attendanceList = <Map<String, dynamic>>[].obs;
  final last7DaysAttendance = <Map<String, dynamic>>[].obs;
  final summary = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await Future.wait([_fetchSummary(), _fetchList(), _fetchLast7Days()]);
    } catch (_) {}
    isLoading.value = false;
  }

  // ─── Summary ────────────────────────────────────────────────
  Future<void> _fetchSummary() async {
    try {
      final now = DateTime.now();
      final response = await ApiService.post(
        '/employeeUser/attendance/summary',
        body: {'date': _todayStr(), 'month': now.month, 'year': now.year},
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        summary.value = response['Data'] as Map<String, dynamic>;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load summary';
    }
  }

  // ─── Attendance List ────────────────────────────────────────
  Future<void> _fetchList() async {
    try {
      final now = DateTime.now();
      final response = await ApiService.post(
        '/employeeUser/attendance/list',
        body: {'date': _todayStr(), 'month': now.month, 'year': now.year},
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        final list = response['Data'] as List<dynamic>;
        attendanceList.value = list
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load attendance history';
    }
  }

  // ─── Last 7 Days Attendance ──────────────────────────────────
  Future<void> _fetchLast7Days() async {
    try {
      final response = await ApiService.post(
        '/employeeUser/attendance/last-7-days',
        body: {},
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        final list = response['Data'] as List<dynamic>;
        last7DaysAttendance.value = list
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      print('Error fetching last 7 days attendance: $e');
    }
  }

  // ─── Punch In ───────────────────────────────────────────────
  Future<bool> punchIn() async {
    final now = DateTime.now();
    final isAfter1015 = now.hour > 10 || (now.hour == 10 && now.minute > 15);
    
    String getTodayPunchIn() {
      try {
        final dc = Get.find<DashboardController>();
        return dc.punchIn;
      } catch (_) {
        return '-';
      }
    }
    
    final isFirstPunch = getTodayPunchIn() == '-';
    
    String reason = '';
    if (isAfter1015 && isFirstPunch) {
      final result = await _showReasonDialog();
      if (result == null) {
        return false;
      }
      reason = result;
    }

    isPunchLoading.value = true;
    try {
      LocationResult? location;
      try {
        location = await LocationService.getCurrentLocation();
      } catch (locationErr) {
        CustomSnackbar.showError(
          title: 'Location Error',
          message: locationErr.toString(),
        );
        isPunchLoading.value = false;
        return false;
      }

      if (location == null) {
        CustomSnackbar.showError(
          title: 'Location Error',
          message: 'Could not fetch current location.',
        );
        isPunchLoading.value = false;
        return false;
      }

      final nowTime = DateTime.now();
      final time = DateFormat('hh:mm a').format(nowTime);
      final response = await ApiService.post(
        '/employeeUser/attendance/punchin',
        body: {
          'date': _todayStr(),
          'time': time,
          'punchIn_ip': '192.168.0.0',
          'punchIn_latitude': location.latitude.toString(),
          'punchIn_longitude': location.longitude.toString(),
          'punchIn_address': location.address,
          'reason': reason,
        },
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true) {
        CustomSnackbar.showSuccess(
          title: 'Success',
          message: response['Message'] ?? 'Punched in',
        );
        await fetchAll();
        // Refresh dashboard to update home screen status
        try {
          Get.find<DashboardController>().fetchDashboard();
        } catch (_) {}
        return true;
      } else {
        CustomSnackbar.showError(
          title: 'Error',
          message: response['Message'] ?? 'Failed to punch in',
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
      isPunchLoading.value = false;
    }
  }

  Future<String?> _showReasonDialog() async {
    final textController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return await Get.dialog<String>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[800], size: 28),
            SizedBox(width: 8),
            Text(
              'Late Punch In Reason',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2430),
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You are punching in after 10:15 AM. Please enter the reason for late arrival to submit for admin approval.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF74808F),
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: textController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter reason here...',
                  hintStyle: TextStyle(color: Color(0xFF74808F), fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFFDCE6D8)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFFDCE6D8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF52B447)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a reason';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: null),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Get.back(result: textController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF52B447),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // ─── Punch Out ──────────────────────────────────────────────
  Future<bool> punchOut() async {
    isPunchLoading.value = true;
    try {
      LocationResult? location;
      try {
        location = await LocationService.getCurrentLocation();
      } catch (locationErr) {
        CustomSnackbar.showError(
          title: 'Location Error',
          message: locationErr.toString(),
        );
        isPunchLoading.value = false;
        return false;
      }

      if (location == null) {
        CustomSnackbar.showError(
          title: 'Location Error',
          message: 'Could not fetch current location.',
        );
        isPunchLoading.value = false;
        return false;
      }

      final now = DateTime.now();
      final time = DateFormat('hh:mm a').format(now);
      final response = await ApiService.post(
        '/employeeUser/attendance/punchout',
        body: {
          'date': _todayStr(),
          'time': time,
          'punchOut_ip': '192.168.0.0',
          'punchOut_latitude': location.latitude.toString(),
          'punchOut_longitude': location.longitude.toString(),
          'punchOut_address': location.address,
        },
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true) {
        CustomSnackbar.showSuccess(
          title: 'Success',
          message: response['Message'] ?? 'Punched out',
        );
        await fetchAll();
        // Refresh dashboard to update home screen status
        try {
          Get.find<DashboardController>().fetchDashboard();
        } catch (_) {}
        return true;
      } else {
        CustomSnackbar.showError(
          title: 'Error',
          message: response['Message'] ?? 'Failed to punch out',
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
      isPunchLoading.value = false;
    }
  }

  // ─── Getters ────────────────────────────────────────────────
  String get summaryMonth => summary.value?['month'] ?? '';
  String get presentDays => '${summary.value?['present'] ?? 0}';
  String get absentDays => '${summary.value?['absent'] ?? 0}';
  String get leavesDays => '${summary.value?['leaves'] ?? 0}';
  String get holidays => '${summary.value?['holidays'] ?? 0}';
  String get totalWorkingDays => '${summary.value?['totalWorkingDays'] ?? 0}';
  String get attendancePercentage {
    final val = summary.value?['attendancePercentage'];
    if (val is num) return '${val.toStringAsFixed(1)}%';
    return '0%';
  }

  // ─── Helpers ────────────────────────────────────────────────
  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
