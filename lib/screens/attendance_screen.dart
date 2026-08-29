import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrms_app/controllers/attendance_controller.dart';
import 'package:hrms_app/controllers/dashboard_controller.dart';
import 'package:hrms_app/theme/app_theme.dart';
import 'package:hrms_app/utils/time_utils.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AttendanceController());
    final dashboardController = Get.put(DashboardController());

    final now = DateTime.now();
    final hours = now.hour.toString().padLeft(2, '0');
    final minutes = now.minute.toString().padLeft(2, '0');
    final formattedTime = '$hours:$minutes';

    final days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dayName = days[now.weekday % 7];
    final monthName = months[now.month];
    final formattedDate = '$dayName, $monthName ${now.day}, ${now.year}';

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.value.isNotEmpty &&
              controller.summary.value == null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                    SizedBox(height: 16),
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Color(0xFF74808F)),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: controller.fetchAll,
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await controller.fetchAll();
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6E3EB5), Color(0xFF52B447)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attendance',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Track your work hours',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 25),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current Time Card
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 60,
                                color: Color(0xFF1F2430),
                              ),
                              SizedBox(height: 20),
                              Text(
                                formattedTime,
                                style: TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2430),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF74808F),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        // Punch In / Punch Out Buttons
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  if (dashboardController.nextAction ==
                                      'Punch In')
                                    Expanded(
                                      child: SizedBox(
                                        height: 56,
                                        child: Obx(
                                          () => ElevatedButton(
                                            onPressed:
                                                controller.isPunchLoading.value
                                                ? null
                                                : () => controller.punchIn(),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(
                                                0xFF52B447,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child:
                                                controller.isPunchLoading.value
                                                ? SizedBox(
                                                    height: 24,
                                                    width: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2.5,
                                                        ),
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.login,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        'Punch In',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                      ),
                                    )
                                  else if (dashboardController.nextAction ==
                                      'Punch Out')
                                    Expanded(
                                      child: SizedBox(
                                        height: 56,
                                        child: Obx(
                                          () => ElevatedButton(
                                            onPressed:
                                                controller.isPunchLoading.value
                                                ? null
                                                : () => controller.punchOut(),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(
                                                0xFFFF3B30,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child:
                                                controller.isPunchLoading.value
                                                ? SizedBox(
                                                    height: 24,
                                                    width: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2.5,
                                                        ),
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.logout,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        'Punch Out',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    Expanded(
                                      child: SizedBox(
                                        height: 56,
                                        child: ElevatedButton(
                                          onPressed: null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[200],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.pending_actions,
                                                color: Colors.orange[800],
                                                size: 20,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Pending Approval',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.orange[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        // Monthly Summary
                        Text(
                          controller.summaryMonth.isNotEmpty
                              ? controller.summaryMonth
                              : 'This Month',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2430),
                          ),
                        ),
                        SizedBox(height: 15),
                        Column(
                          children: [
                            Row(
                              children: [
                                _statCard(
                                  controller.presentDays,
                                  'Present',
                                  Color(0xFF1F2430),
                                ),
                                SizedBox(width: 12),
                                _statCard(
                                  controller.absentDays,
                                  'Absent',
                                  Color(0xFFFF3B30),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                _statCard(
                                  controller.leavesDays,
                                  'Leaves',
                                  Color(0xFFFFA500),
                                ),
                                SizedBox(width: 12),
                                _statCard(
                                  controller.holidays,
                                  'Holidays',
                                  Color(0xFF6E3EB5),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        // Attendance History
                        Text(
                          'Recent History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2430),
                          ),
                        ),
                        SizedBox(height: 15),
                        if (controller.last7DaysAttendance.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'No attendance records found',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF74808F),
                                ),
                              ),
                            ),
                          )
                        else
                          ...controller.last7DaysAttendance.map(
                            (record) => _historyItem(record),
                          ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _statCard(String value, String label, Color valueColor) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 13, color: Color(0xFF74808F)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyItem(Map<String, dynamic> record) {
    final date = record['date'] ?? '';
    final rawStatus = (record['attendance_status'] ?? '').toString();
    final totalHours = record['total_working_hours'] ?? '00:00';
    final punches = record['punches'] as List<dynamic>? ?? [];
    final normalizedStatus = _normalizeAttendanceStatus(rawStatus);
    final statusKey = normalizedStatus.toLowerCase();

    // Format date
    String formattedDate = date;
    String dayName = record['day'] ?? '';
    try {
      final dt = DateTime.parse(date);
      formattedDate = DateFormat('MMM d, yyyy').format(dt);
      if (dayName.isEmpty) {
        dayName = DateFormat('EEEE').format(dt);
      }
    } catch (_) {}

    final statusMeta = _statusMeta(statusKey);

    final firstPunch = punches.isNotEmpty ? punches.first : null;
    final isPunchPending = punches.any((p) => p['status'] == 'Pending') || rawStatus == 'Pending';
    final punchInTime = isPunchPending
        ? 'Admin Punch In'
        : convertTo24Hour(firstPunch != null ? (firstPunch['punchIn_time'] ?? '-') : '-');
    final punchOutTime = convertTo24Hour(firstPunch != null
        ? (firstPunch['punchOut_time'] ?? '-')
        : '-');

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left: Status and Date
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    normalizedStatus,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: statusMeta.color,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '$formattedDate ($dayName)',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.mutedText,
                    ),
                  ),
                ],
              ),
            ),
            // Right: Timing Variables (In, Out, Hours)
            Expanded(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _simpleMetric('In', punchInTime),
                  _simpleMetric('Out', punchOutTime),
                  _simpleMetric('Hrs', totalHours, valueColor: statusMeta.color),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _simpleMetric(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppTheme.mutedText,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value.isEmpty ? '-' : value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppTheme.ink,
          ),
        ),
      ],
    );
  }

  _AttendanceStatusMeta _statusMeta(String statusKey) {
    if (statusKey == 'holiday' || statusKey == 'weekly off') {
      return _AttendanceStatusMeta(
        color: Color(0xFF2B7FFF),
        background: Color(0xFFEAF2FF),
        icon: Icons.beach_access,
      );
    }

    if (statusKey.contains('present') || statusKey.contains('full')) {
      return _AttendanceStatusMeta(
        color: Color(0xFF159947),
        background: Color(0xFFE7F7EC),
        icon: Icons.check_circle,
      );
    }

    if (statusKey.contains('absent')) {
      return _AttendanceStatusMeta(
        color: Color(0xFFD93A2F),
        background: Color(0xFFFDECEA),
        icon: Icons.cancel,
      );
    }

    if (statusKey.contains('half')) {
      return _AttendanceStatusMeta(
        color: Color(0xFF8E44AD),
        background: Color(0xFFF3E8FB),
        icon: Icons.adjust,
      );
    }

    if (statusKey.contains('pending')) {
      return _AttendanceStatusMeta(
        color: Color(0xFFEF8B17),
        background: Color(0xFFFFF3E3),
        icon: Icons.pending_actions,
      );
    }

    if (statusKey.contains('leave')) {
      return _AttendanceStatusMeta(
        color: Color(0xFFEF8B17),
        background: Color(0xFFFFF3E3),
        icon: Icons.event_busy,
      );
    }

    return _AttendanceStatusMeta(
      color: Color(0xFF2B7FFF),
      background: Color(0xFFEAF2FF),
      icon: Icons.info,
    );
  }

  String _normalizeAttendanceStatus(String status) {
    final lower = status.toLowerCase().trim();
    if (lower == 'first half day' || lower == 'second half day') {
      return 'Half Day';
    }
    return status;
  }
}

class _AttendanceStatusMeta {
  final Color color;
  final Color background;
  final IconData icon;

  const _AttendanceStatusMeta({
    required this.color,
    required this.background,
    required this.icon,
  });
}
