import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:hrms_app/controllers/salary_controller.dart';

class SalaryDetailsScreen extends StatelessWidget {
  const SalaryDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SalaryController>();
    final numberFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Color(0xFFF7FAF5),
      appBar: AppBar(
        title: Text(
          'Salary Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF52B447),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        final details = controller.selectedSalaryDetails.value;
        if (details == null) {
          return Center(
            child: Text(
              'No details available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final month = details['month']?.toString() ?? '';
        final year = details['year']?.toString() ?? '';
        String displayMonth = '$month $year';
        try {
          final m = int.parse(month);
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
            displayMonth = '${months[m - 1]} $year';
          }
        } catch (_) {}

        final netSalary = details['net_salary'] ?? 0;
        final earnings = details['earnings'] ?? {};
        final basic = earnings['basic'] ?? 0;
        final incentive = earnings['incentive'] ?? 0;
        final allowances = earnings['allowances'] as List<dynamic>? ?? [];

        double totalAllowances = 0;
        for (var a in allowances) {
          totalAllowances += (a['amount'] ?? 0);
        }
        final grossSalary = basic + incentive + totalAllowances;

        final deductions = details['deductions'] ?? {};
        final deductionItems = deductions['items'] as List<dynamic>? ?? [];
        final absentDeduction = deductions['absent_deduction'] ?? 0;
        final lostHoursDeduction = deductions['lost_hours_deduction'] ?? 0;

        double totalDeductions = 0;
        for (var d in deductionItems) {
          totalDeductions += (d['amount'] ?? 0);
        }
        totalDeductions += absentDeduction;
        totalDeductions += lostHoursDeduction;

        final attendance = details['attendance_details'] ?? {};
        final dailyHistory =
            attendance['daily_history'] as List<dynamic>? ?? [];

        return SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6E3EB5), Color(0xFF52B447)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF52B447).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      displayMonth.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Net Payable',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    SizedBox(height: 8),
                    Text(
                      numberFormat.format(netSalary),
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 24),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gross Earnings',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                numberFormat.format(grossSalary),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            color: Colors.white30,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Total Deductions',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                numberFormat.format(totalDeductions),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
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

              SizedBox(height: 25),

              // Attendance Overview
              Text(
                'Attendance Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2430),
                ),
              ),
              SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildOverviewRow(
                      'Total Days',
                      attendance['total_days']?.toString() ?? '-',
                    ),
                    _divider(),
                    _buildOverviewRow(
                      'Payable Days',
                      attendance['paid_days']?.toString() ?? '-',
                    ),
                    _divider(),
                    _buildOverviewRow(
                      'Present Days',
                      attendance['present_days']?.toString() ?? '-',
                    ),
                    _divider(),
                    _buildOverviewRow(
                      'Absent Days',
                      attendance['absent_days']?.toString() ?? '-',
                    ),
                  ],
                ),
              ),

              if (dailyHistory.isNotEmpty) ...[
                SizedBox(height: 25),
                Text(
                  'Daily History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2430),
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: dailyHistory.length,
                    separatorBuilder: (context, index) => _divider(),
                    itemBuilder: (context, index) {
                      final dayData = dailyHistory[index];
                      final date = dayData['date']?.toString() ?? '';
                      final day = dayData['day']?.toString() ?? '';
                      final rawStatus = dayData['status']?.toString() ?? '';
                      String status = rawStatus;
                      if (day.toLowerCase().trim() == 'sunday' && status.toLowerCase().trim() == 'absent') {
                        status = 'Holiday';
                      }
                      if (status.toLowerCase().trim() == 'first half day' || status.toLowerCase().trim() == 'second half day') {
                        status = 'Half Day';
                      }

                      Color statusColor = Colors.grey;
                      if (status.toLowerCase().contains('present')) {
                        statusColor = Color(0xFF52B447);
                      } else if (status.toLowerCase().contains('absent'))
                        statusColor = Color(0xFFFF3B30);
                      else if (status.toLowerCase().contains('leave'))
                        statusColor = Color(0xFFFFA000);
                      else if (status.toLowerCase().contains('holiday') ||
                          status.toLowerCase().contains('week off'))
                        statusColor = Color(0xFF6E3EB5);

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Color(0xFFF7FAF5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    date.split('-').last,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF1F2430),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    day,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2430),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    date,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOverviewRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF74808F),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2430),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: Color(0xFFE2E8F0));
  }
}
