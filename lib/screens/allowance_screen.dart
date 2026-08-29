import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrms_app/controllers/allowance_controller.dart';
import 'package:intl/intl.dart';
import 'package:hrms_app/screens/allowance_details_screen.dart';

class AllowanceScreen extends StatelessWidget {
  const AllowanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AllowanceController());

    return Scaffold(
      backgroundColor: Color(0xFFF7FAF5),
      appBar: AppBar(
        title: Text(
          'Allowances',
          style: TextStyle(
            color: Color(0xFF1F2430),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF1F2430)),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.currentMonthAllowances.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.currentMonthAllowances.isEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        return RefreshIndicator(
          onRefresh: controller.fetchAll,
          child: controller.allAllowances.isEmpty
              ? ListView(
                  children: [
                    SizedBox(height: 100),
                    Center(
                      child: Text(
                        'No allowances found for this month.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemCount: controller.allAllowances.length,
                  itemBuilder: (context, index) {
                    final item = controller.allAllowances[index];
                    final amount = item['amount']?.toString() ?? '0';
                    final dateStr = item['createdAt'] ?? '';
                    final status = item['status'] == true
                        ? 'Active'
                        : 'Pending';
                    final title = item['title'] ?? 'Allowance';

                    String formattedDate = dateStr;
                    try {
                      if (dateStr.isNotEmpty) {
                        formattedDate = DateFormat(
                          'MMM d, yyyy',
                        ).format(DateTime.parse(dateStr));
                      }
                    } catch (_) {}

                    return GestureDetector(
                      onTap: () {
                        Get.to(
                          () =>
                              AllowanceDetailsScreen(allowanceId: item['_id']),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(16),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2430),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹$amount',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6E3EB5),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  status.toString().toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        status.toString().toLowerCase() ==
                                            'active'
                                        ? Color(0xFF6E3EB5)
                                        : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      }),
    );
  }

  void _showFilterSheet(BuildContext context, AllowanceController controller) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Allowances',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2430),
              ),
            ),
            SizedBox(height: 20),
            _filterTile(context, 'This Month', 'this_month', controller),
            _filterTile(context, 'Last Month', 'last_month', controller),
            _filterTile(context, 'Last Week', 'last_week', controller),
            _filterTile(context, 'Custom Range', 'custom', controller),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _filterTile(
    BuildContext context,
    String title,
    String value,
    AllowanceController controller,
  ) {
    return Obx(() {
      final isSelected = controller.currentFilter.value == value;
      return ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Color(0xFF6E3EB5) : Color(0xFF1F2430),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check, color: Color(0xFF6E3EB5))
            : null,
        onTap: () async {
          if (value == 'custom') {
            final DateTimeRange? picked = await showDateRangePicker(
              context: context,
              initialDateRange: DateTimeRange(
                start: DateTime.now().subtract(Duration(days: 7)),
                end: DateTime.now(),
              ),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              controller.currentFilter.value = 'custom';
              controller.customStartDate.value = DateFormat(
                'yyyy-MM-dd',
              ).format(picked.start);
              controller.customEndDate.value = DateFormat(
                'yyyy-MM-dd',
              ).format(picked.end);
              Get.back();
              controller.fetchAll();
            }
          } else {
            controller.currentFilter.value = value;
            Get.back();
            controller.fetchAll();
          }
        },
      );
    });
  }
}
