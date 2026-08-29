import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:hrms_app/controllers/salary_controller.dart';
import 'package:hrms_app/screens/salary_details_screen.dart';

class SalaryScreen extends StatelessWidget {
  const SalaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SalaryController());
    final numberFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.currentSalary.value == null) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.value.isNotEmpty &&
              controller.currentSalary.value == null) {
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
                      onPressed: controller.fetchCurrentSalary,
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final hasCurrentSalary = controller.currentSalary.value != null;

          return RefreshIndicator(
            onRefresh: () async {
              await controller.fetchCurrentSalary();
              await controller.fetchSalaryHistory();
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Header with Salary Title
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
                          'Salary',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'View your salary slips',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 25),
                  // Main Content
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current Month Salary Card
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF52B447), Color(0xFF52B447)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Current Month Salary',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      controller.currentMonthName,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24),
                              Text(
                                'Net Salary',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                hasCurrentSalary
                                    ? numberFormat.format(controller.netSalary)
                                    : '₹0',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 24),
                              Divider(
                                color: Colors.white.withValues(alpha: 0.3),
                                height: 1,
                              ),
                              SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Gross Salary',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        hasCurrentSalary
                                            ? numberFormat.format(
                                                controller.grossSalary,
                                              )
                                            : '₹0',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Deductions',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        hasCurrentSalary
                                            ? numberFormat.format(
                                                controller.totalDeductions,
                                              )
                                            : '₹0',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
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
                                      SizedBox(height: 6),
                                      Text(
                                        controller.currentStatus,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  if (!hasCurrentSalary) return;
                                  final slipId =
                                      controller.currentSalary.value?['_id'];
                                  if (slipId != null) {
                                    await controller.fetchSalaryDetails(slipId);
                                    Get.to(() => const SalaryDetailsScreen());
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(16),
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
                                        Icons.visibility,
                                        size: 32,
                                        color: Color(0xFF6E3EB5),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'View Details',
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
                            SizedBox(width: 15),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  if (!hasCurrentSalary) return;
                                  final slipId =
                                      controller.currentSalary.value?['_id'];
                                  if (slipId != null) {
                                    await controller.downloadSalarySlip(slipId);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(16),
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
                                        Icons.download,
                                        size: 32,
                                        color: Color(0xFF52B447),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Download PDF',
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
                        SizedBox(height: 30),
                        // Salary Breakdown
                        Text(
                          'Salary Breakdown',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
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
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              if (hasCurrentSalary) ...[
                                _breakdownItem(
                                  'Basic Salary',
                                  numberFormat.format(controller.basicSalary),
                                ),
                                if (controller.incentive > 0) ...[
                                  _divider(),
                                  _breakdownItem(
                                    'Incentive',
                                    numberFormat.format(controller.incentive),
                                  ),
                                ],
                                for (var allowance
                                    in controller.allowances) ...[
                                  _divider(),
                                  _breakdownItem(
                                    (allowance['head_name'] ??
                                            allowance['allowance_name'] ??
                                            allowance['name'] ??
                                            'Allowance')
                                        .toString()
                                        .toUpperCase(),
                                    numberFormat.format(
                                      allowance['amount'] ?? 0,
                                    ),
                                  ),
                                ],
                                for (var deduction
                                    in controller.deductionItems) ...[
                                  _divider(),
                                  _breakdownItem(
                                    (deduction['head_name'] ??
                                            deduction['deduction_name'] ??
                                            deduction['name'] ??
                                            'Deduction')
                                        .toString()
                                        .toUpperCase(),
                                    '-${numberFormat.format(deduction['amount'] ?? 0)}',
                                    isDeduction: true,
                                  ),
                                ],
                                if (controller.absentDeduction > 0) ...[
                                  _divider(),
                                  _breakdownItem(
                                    'Absent Deduction',
                                    '-${numberFormat.format(controller.absentDeduction)}',
                                    isDeduction: true,
                                  ),
                                ],
                                if (controller.lostHoursDeduction > 0) ...[
                                  _divider(),
                                  _breakdownItem(
                                    'Lost Hours Deduction',
                                    '-${numberFormat.format(controller.lostHoursDeduction)}',
                                    isDeduction: true,
                                  ),
                                ],
                              ] else ...[
                                Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    'No salary breakdown available',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ],
                              _divider(),
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE8EFFF),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Net Salary',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1F2430),
                                      ),
                                    ),
                                    Text(
                                      hasCurrentSalary
                                          ? numberFormat.format(
                                              controller.netSalary,
                                            )
                                          : '₹0',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1F2430),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        // Salary History
                        Text(
                          'Salary History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2430),
                          ),
                        ),
                        SizedBox(height: 15),

                        if (controller.isHistoryLoading.value &&
                            controller.salaryHistoryList.isEmpty)
                          Center(child: CircularProgressIndicator())
                        else if (controller.salaryHistoryList.isEmpty)
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: Text(
                                'No salary history available',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ...controller.salaryHistoryList.map((slip) {
                            final slipMonth = slip['month']?.toString() ?? '';
                            final slipYear = slip['year']?.toString() ?? '';

                            String displayMonth = '$slipMonth $slipYear';
                            try {
                              final m = int.parse(slipMonth);
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
                                displayMonth = '${months[m - 1]} $slipYear';
                              }
                            } catch (_) {}

                            final net = slip['net_salary'] ?? 0;
                            final status =
                                slip['status']?.toString().toLowerCase() ??
                                'pending';

                            return Container(
                              margin: EdgeInsets.only(bottom: 12),
                              padding: EdgeInsets.all(16),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFF1EBFB),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              Icons.description,
                                              color: Color(0xFF6E3EB5),
                                              size: 28,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                displayMonth,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF1F2430),
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Payslip',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF74808F),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: status == 'paid'
                                              ? Color(0xFFE8F5E9)
                                              : Color(0xFFFFF3E0),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: status == 'paid'
                                                ? Color(0xFF52B447)
                                                : Color(0xFFFFA000),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Net Salary',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF74808F),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            numberFormat.format(net),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1F2430),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () async {
                                            final id = slip['_id'];
                                            if (id != null) {
                                              await controller
                                                  .fetchSalaryDetails(id);
                                              Get.to(
                                                () =>
                                                    const SalaryDetailsScreen(),
                                              );
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Color(0xFFDCE6D8),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.visibility,
                                                  size: 18,
                                                  color: Color(0xFF1F2430),
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  'View',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF1F2430),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () async {
                                            final id = slip['_id'];
                                            if (id != null) {
                                              await controller
                                                  .downloadSalarySlip(id);
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Color(0xFFDCE6D8),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.download,
                                                  size: 18,
                                                  color: Color(0xFF1F2430),
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  'Download',
                                                  style: TextStyle(
                                                    fontSize: 14,
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
                                ],
                              ),
                            );
                          }),
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

  Widget _breakdownItem(
    String label,
    String amount, {
    bool isDeduction = false,
  }) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Color(0xFF74808F))),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDeduction ? Color(0xFFFF3B30) : Color(0xFF1F2430),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: Color(0xFFDCE6D8),
      indent: 16,
      endIndent: 16,
    );
  }
}
