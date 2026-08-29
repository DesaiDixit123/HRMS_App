import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrms_app/controllers/holiday_controller.dart';
import 'package:hrms_app/screens/holiday_details_screen.dart';
import 'package:intl/intl.dart';

class HolidayScreen extends StatelessWidget {
  const HolidayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HolidayController());

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF5),
      appBar: AppBar(
        title: const Text(
          'Holidays',
          style: TextStyle(
            color: Color(0xFF1F2430),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F2430)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, controller),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshHolidays,
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.upcomingHolidays.isEmpty &&
              controller.allHolidays.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              if (controller.upcomingHolidays.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Text(
                      'Upcoming Holidays',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2430),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return _HolidayListItem(
                        item: controller.upcomingHolidays[index],
                      );
                    }, childCount: controller.upcomingHolidays.length),
                  ),
                ),
              ],
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Holidays',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2430),
                        ),
                      ),
                      Text(
                        controller.currentFilter.value
                            .replaceAll('_', ' ')
                            .capitalizeFirst!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6E3EB5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (controller.allHolidays.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(
                      child: Text(
                        'No holidays found for this filter.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return _HolidayListItem(
                        item: controller.allHolidays[index],
                      );
                    }, childCount: controller.allHolidays.length),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        }),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, HolidayController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Holidays',
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
    HolidayController controller,
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
              controller.currentFilter.value = 'custom';
              controller.customStartDate.value = DateFormat(
                'yyyy-MM-dd',
              ).format(picked.start);
              controller.customEndDate.value = DateFormat(
                'yyyy-MM-dd',
              ).format(picked.end);
              Get.back();
              controller.refreshHolidays();
            }
          } else {
            controller.currentFilter.value = value;
            Get.back();
            controller.refreshHolidays();
          }
        },
      );
    });
  }
}

class _HolidayListItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const _HolidayListItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final title = item['holiday_title'] ?? item['name'] ?? 'Holiday';
    final dateStr = item['from_date'] ?? item['date'] ?? '';
    final description = item['description'] ?? '';

    String formattedDate = dateStr;
    String dayName = '';
    try {
      if (dateStr.isNotEmpty) {
        final date = DateTime.parse(dateStr);
        formattedDate = DateFormat('MMM d, yyyy').format(date);
        dayName = DateFormat('EEEE').format(date);
      }
    } catch (_) {}

    return GestureDetector(
      onTap: () {
        if (item['_id'] != null) {
          Get.to(() => HolidayDetailsScreen(holidayId: item['_id']));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF1EBFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.celebration, color: Color(0xFF6E3EB5)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2430),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$formattedDate ($dayName)',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF74808F),
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
