import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrms_app/controllers/allowance_controller.dart';

class AllowanceDetailsScreen extends StatefulWidget {
  final String allowanceId;

  const AllowanceDetailsScreen({super.key, required this.allowanceId});

  @override
  State<AllowanceDetailsScreen> createState() => _AllowanceDetailsScreenState();
}

class _AllowanceDetailsScreenState extends State<AllowanceDetailsScreen> {
  final controller = Get.find<AllowanceController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAllowanceDetails(widget.allowanceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7FAF5),
      appBar: AppBar(
        title: Text(
          'Allowance Details',
          style: TextStyle(
            color: Color(0xFF1F2430),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF1F2430)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.allowanceDetails.value == null) {
          return Center(child: Text(controller.errorMessage.value));
        }

        final details = controller.allowanceDetails.value;
        if (details == null) {
          return Center(child: Text('No details found.'));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: details.entries.map((e) {
                if (e.key == '_id' ||
                    e.key == '__v' ||
                    e.value is Map ||
                    e.value is List) {
                  return SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.key.replaceAll('_', ' ').capitalizeFirst ?? e.key,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      SizedBox(height: 4),
                      Text(
                        e.value.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2430),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }),
    );
  }
}
