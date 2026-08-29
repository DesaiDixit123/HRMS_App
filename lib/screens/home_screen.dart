import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hrms_app/components/notification_item.dart';
import 'package:hrms_app/controllers/dashboard_controller.dart';
import 'package:hrms_app/controllers/attendance_controller.dart';
import 'package:hrms_app/screens/incentive_screen.dart';
import 'package:hrms_app/screens/allowance_screen.dart';
import 'package:hrms_app/screens/salary_deduction_screen.dart';
import 'package:hrms_app/controllers/notification_controller.dart';
import 'package:hrms_app/screens/notification_screen.dart';
import 'package:hrms_app/screens/holiday_screen.dart';
import 'package:hrms_app/screens/salary_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    Get.put(AttendanceController());
    final notificationController = Get.put(NotificationController());

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.value.isNotEmpty) {
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
                      onPressed: controller.fetchDashboard,
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final statusColor = controller.status == 'Present'
              ? Color(0xFF52B447)
              : Color(0xFFFF3B30);

          return RefreshIndicator(
            onRefresh: () async {
              await controller.fetchDashboard();
              await Get.find<AttendanceController>().fetchAll();
              await notificationController.fetchNotifications();
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Header with Greeting
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: Container(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.greeting,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => const NotificationScreen());
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Icon(
                                        Icons.notifications,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                    Obx(
                                      () =>
                                          notificationController
                                                  .unreadCount
                                                  .value >
                                              0
                                          ? Positioned(
                                              top: 0,
                                              right: 0,
                                              child: Container(
                                                padding: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFFF3B30),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Color(0xFF52B447),
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Text(
                                                  '${notificationController.unreadCount.value}',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : SizedBox.shrink(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          // Status Card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Status',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          _statusMetaRow(
                                            icon: Icons.access_time,
                                            label: 'Punch In',
                                          ),
                                          SizedBox(height: 5),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              controller.punchIn,
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Activity',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          _statusMetaRow(
                                            icon: Icons.history,
                                            label: 'Duration',
                                          ),
                                          SizedBox(height: 5),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              controller.workingTime,
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        controller.status,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  // Action Cards
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 600),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          if (controller.nextAction == 'Punch In')
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  final ac = Get.find<AttendanceController>();
                                  ac.punchIn();
                                },
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.login,
                                        size: 40,
                                        color: Color(0xFF52B447),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Punch In',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1F2430),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else if (controller.nextAction == 'Punch Out')
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  final ac = Get.find<AttendanceController>();
                                  ac.punchOut();
                                },
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.logout,
                                        size: 40,
                                        color: Color(0xFFFF3B30),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Punch Out',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1F2430),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.pending_actions,
                                      size: 40,
                                      color: Colors.orange,
                                    ),
                                    SizedBox(height: 10),
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
                          SizedBox(width: 15),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Get.to(() => const SalaryScreen());
                              },
                              child: Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.description,
                                      size: 40,
                                      color: Color(0xFF52B447),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Salary Slip',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1F2430),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 25),
                  // This Month Section
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    duration: const Duration(milliseconds: 600),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Obx(
                                () => GestureDetector(
                                  onTap: () =>
                                      _showFilterOptions(context, controller),
                                  child: Row(
                                    children: [
                                      Text(
                                        controller.currentFilter.value ==
                                                'custom'
                                            ? '${DateFormat('MMM d').format(DateTime.parse(controller.customStartDate.value))} - ${DateFormat('MMM d').format(DateTime.parse(controller.customEndDate.value))}'
                                            : controller.currentFilter.value
                                                  .replaceAll('_', ' ')
                                                  .capitalizeFirst!,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1F2430),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        color: Color(0xFF1F2430),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Text(
                                controller.dashboardData.value?['from_date'] !=
                                        null
                                    ? DateFormat('MMMM yyyy').format(
                                        DateTime.parse(
                                          controller
                                              .dashboardData
                                              .value!['from_date'],
                                        ),
                                      )
                                    : '',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF74808F),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Obx(() {
                            final allItems = [
                              _attendanceDetailCard(
                                'Total Days',
                                controller.totalWorkingDays,
                                Icons.calendar_month,
                                Color(0xFF6E3EB5),
                              ),
                              _attendanceDetailCard(
                                'Present',
                                controller.daysPresent,
                                Icons.check_circle_outline,
                                Color(0xFF52B447),
                              ),
                              _attendanceDetailCard(
                                'Absent',
                                controller.daysAbsent,
                                Icons.cancel_outlined,
                                Color(0xFFFF3B30),
                              ),
                              _attendanceDetailCard(
                                'On Leave',
                                controller.daysLeave,
                                Icons.event_busy,
                                Color(0xFFFFA500),
                              ),
                              _attendanceDetailCard(
                                'Half Day',
                                controller.halfDay,
                                Icons.exposure_zero,
                                Color(0xFF6E3EB5),
                              ),
                              _attendanceDetailCard(
                                'Holidays',
                                controller.holidayCount,
                                Icons.celebration,
                                Color(0xFF52B447),
                              ),
                              _attendanceDetailCard(
                                'Attendance',
                                controller.attendancePercentage,
                                Icons.analytics,
                                Color(0xFF4D2A86),
                              ),
                            ];

                            final displayItems =
                                controller.isAttendanceExpanded.value
                                ? allItems
                                : allItems.take(4).toList();

                            return Column(
                              children: [
                                GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 1.6,
                                  children: displayItems,
                                ),
                                SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    controller.isAttendanceExpanded.value =
                                        !controller.isAttendanceExpanded.value;
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        controller.isAttendanceExpanded.value
                                            ? 'Show Less'
                                            : 'Show More',
                                        style: TextStyle(
                                          color: Color(0xFF6E3EB5),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        controller.isAttendanceExpanded.value
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        color: Color(0xFF6E3EB5),
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  // Financial Summary Section
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    duration: const Duration(milliseconds: 600),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Summary',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2430),
                              ),
                            ),
                            SizedBox(height: 16),
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 2.3,
                              children: [
                                _summaryCard(
                                  'Incentive',
                                  '₹${controller.incentive}',
                                  Color(0xFF52B447),
                                  Icons.trending_up,
                                  onTap: () =>
                                      Get.to(() => const IncentiveScreen()),
                                ),
                                _summaryCard(
                                  'Allowance',
                                  '₹${controller.allowance}',
                                  Color(0xFF6E3EB5),
                                  Icons.wallet,
                                  onTap: () =>
                                      Get.to(() => const AllowanceScreen()),
                                ),
                                _summaryCard(
                                  'Deduction',
                                  '₹${controller.deduction}',
                                  Color(0xFFFF3B30),
                                  Icons.money_off,
                                  onTap: () => Get.to(
                                    () => const SalaryDeductionScreen(),
                                  ),
                                ),
                                _summaryCard(
                                  'Holiday',
                                  '${controller.upcomingHoliday}',
                                  Color(0xFF6E3EB5),
                                  Icons.celebration,
                                  onTap: () =>
                                      Get.to(() => const HolidayScreen()),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  // Notifications Section
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    duration: const Duration(milliseconds: 600),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Notifications',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2430),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => const NotificationScreen());
                                },
                                child: Text(
                                  'View All',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6E3EB5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Obx(() {
                            if (notificationController.isLoading.value &&
                                notificationController.notifications.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (notificationController.notifications.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                child: Center(
                                  child: Text(
                                    'No new notifications',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final topNotifications = notificationController
                                .notifications
                                .take(5)
                                .toList();

                            return Column(
                              children: topNotifications.map((notification) {
                                final title =
                                    notification['title'] ?? 'Notification';
                                final message = notification['message'] ?? '';
                                final isRead = notification['is_read'] ?? true;
                                final dateStr = notification['createdAt'] ?? '';

                                String timeAgo = '';
                                try {
                                  if (dateStr.isNotEmpty) {
                                    final date = DateTime.parse(dateStr);
                                    final difference = DateTime.now()
                                        .difference(date);
                                    if (difference.inDays > 1) {
                                      timeAgo = DateFormat(
                                        'MMM d, yyyy',
                                      ).format(date);
                                    } else if (difference.inDays == 1) {
                                      timeAgo = '1 day ago';
                                    } else if (difference.inHours > 0) {
                                      timeAgo =
                                          '${difference.inHours} hours ago';
                                    } else if (difference.inMinutes > 0) {
                                      timeAgo =
                                          '${difference.inMinutes} mins ago';
                                    } else {
                                      timeAgo = 'Just now';
                                    }
                                  }
                                } catch (_) {}

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Hero(
                                    tag: 'notif_${notification['_id']}',
                                    child: Material(
                                      color: Colors.transparent,
                                      child: NotificationItem(
                                        icon: Icons.notifications_active,
                                        iconColor: isRead
                                            ? Colors.grey
                                            : Color(0xFF6E3EB5),
                                        iconBgColor: isRead
                                            ? Colors.grey.shade100
                                            : Color(0xFFF1EBFB),
                                        title: title,
                                        description: message,
                                        timeAgo: timeAgo,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          }),
                          SizedBox(height: 30),
                        ],
                      ),
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

  Widget _attendanceDetailCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2430),
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF74808F),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(
    BuildContext context,
    DashboardController controller,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2430),
              ),
            ),
            const SizedBox(height: 20),
            _filterTile(context, 'This Month', 'this_month', controller),
            _filterTile(context, 'Last Month', 'last_month', controller),
            _filterTile(context, 'Last Week', 'last_week', controller),
            _filterTile(context, 'Custom Range', 'custom', controller),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _filterTile(
    BuildContext context,
    String title,
    String value,
    DashboardController controller,
  ) {
    return Obx(() {
      final isSelected = controller.currentFilter.value == value;
      return ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFF6E3EB5)
                : const Color(0xFF1F2430),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check, color: Color(0xFF6E3EB5))
            : null,
        onTap: () async {
          if (value == 'custom') {
            final DateTimeRange? picked = await showDateRangePicker(
              context: context,
              initialDateRange: DateTimeRange(
                start: DateTime.now().subtract(const Duration(days: 7)),
                end: DateTime.now(),
              ),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              Get.back();
              controller.fetchDashboard(
                filter: 'custom',
                fromDate: DateFormat('yyyy-MM-dd').format(picked.start),
                toDate: DateFormat('yyyy-MM-dd').format(picked.end),
              );
            }
          } else {
            Get.back();
            controller.fetchDashboard(filter: value);
          }
        },
      );
    });
  }

  Widget _statusMetaRow({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(
    String title,
    String amount,
    Color color,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2430),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF74808F),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
