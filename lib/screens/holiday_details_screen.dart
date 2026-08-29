import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrms_app/controllers/holiday_controller.dart';
import 'package:intl/intl.dart';

class HolidayDetailsScreen extends StatelessWidget {
  final String holidayId;

  const HolidayDetailsScreen({super.key, required this.holidayId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HolidayController>();

    // Fetch details when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchHolidayDetails(holidayId);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF5),
      appBar: AppBar(
        title: const Text(
          'Holiday Details',
          style: TextStyle(
            color: Color(0xFF1F2430),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F2430)),
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.holidayDetails.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.holidayDetails.value == null) {
          return Center(child: Text(controller.errorMessage.value));
        }

        final data = controller.holidayDetails.value;
        if (data == null) {
          return const Center(child: Text('No details found.'));
        }

        final title = data['holiday_title'] ?? data['name'] ?? 'Holiday';
        final description = data['description'] ?? 'No description available.';
        final fromDateStr = data['from_date'] ?? '';
        final toDateStr = data['to_date'] ?? '';

        String formattedFromDate = fromDateStr;
        String formattedToDate = toDateStr;
        String duration = '';

        try {
          if (fromDateStr.isNotEmpty) {
            final fromDate = DateTime.parse(fromDateStr);
            formattedFromDate = DateFormat(
              'EEEE, MMMM d, yyyy',
            ).format(fromDate);

            if (toDateStr.isNotEmpty) {
              final toDate = DateTime.parse(toDateStr);
              formattedToDate = DateFormat('EEEE, MMMM d, yyyy').format(toDate);

              final diff = toDate.difference(fromDate).inDays + 1;
              duration = diff > 1 ? '$diff Days' : '1 Day';
            }
          }
        } catch (_) {}

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1EBFB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.celebration,
                        color: Color(0xFF6E3EB5),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2430),
                      ),
                    ),
                    if (duration.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF52B447).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          duration,
                          style: const TextStyle(
                            color: Color(0xFF52B447),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'Schedule',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2430),
                ),
              ),
              const SizedBox(height: 12),
              _infoTile(Icons.calendar_today, 'From', formattedFromDate),
              _infoTile(Icons.calendar_today, 'To', formattedToDate),
              const SizedBox(height: 25),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2430),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF74808F),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6E3EB5), size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF74808F)),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2430),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
