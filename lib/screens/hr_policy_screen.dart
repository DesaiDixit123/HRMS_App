import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrms_app/controllers/hr_policy_controller.dart';
import 'package:hrms_app/utils/custom_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class HRPolicyScreen extends StatelessWidget {
  const HRPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HRPolicyController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HR Policies',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6E3EB5), Color(0xFF52B447)],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.fetchHRPolicies(),
          child: Obx(() {
            if (controller.isLoading.value && controller.policies.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage.value.isNotEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        controller.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Color(0xFF74808F)),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => controller.fetchHRPolicies(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6E3EB5),
                        ),
                        child: const Text('Retry', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (controller.policies.isEmpty) {
              return ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.gavel_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text(
                          'No policies published yet.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF74808F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Any policies from HR will appear here.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFA9B7A0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: controller.policies.length,
              itemBuilder: (context, index) {
                final policy = controller.policies[index];
                return _buildPolicyCard(context, policy);
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPolicyCard(BuildContext context, Map<String, dynamic> policy) {
    final title = policy['policy_title'] ?? 'HR Policy';
    final desc = policy['description'] ?? '';
    final hasDocument = policy['document_url'] != null && policy['document_url'].toString().isNotEmpty;

    // A clean preview text from HTML or general format
    String previewText = desc.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ');
    if (previewText.length > 80) {
      previewText = '${previewText.substring(0, 80)}...';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: InkWell(
        borderRadius: BorderRadius.circular(15.0),
        onTap: () => _showPolicyDetailsBottomSheet(context, policy),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6E3EB5).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.gavel,
                  color: Color(0xFF6E3EB5),
                  size: 28,
                ),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      previewText,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF74808F),
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasDocument) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.attachment, size: 14, color: Colors.blue[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Attachment Available',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF74808F),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPolicyDetailsBottomSheet(BuildContext context, Map<String, dynamic> policy) {
    final title = policy['policy_title'] ?? 'HR Policy';
    final desc = policy['description'] ?? '';
    final docUrl = policy['document_url']?.toString() ?? '';
    final hasDocument = docUrl.isNotEmpty;

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2430),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildFormattedDescription(desc),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (hasDocument) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _launchPolicyDocument(docUrl),
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  label: const Text(
                    'View Policy Document',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF52B447),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  List<Widget> _buildFormattedDescription(String rawDesc) {
    if (rawDesc.isEmpty) {
      return [
        const Text(
          'No description available.',
          style: TextStyle(color: Color(0xFF74808F), fontStyle: FontStyle.italic),
        )
      ];
    }

    // Split HTML lines or general breaks
    final lines = rawDesc.split(RegExp(r'<br\s*/?>'));
    List<Widget> widgets = [];

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Match numbers at start of lines for indenting bullets
      final match = RegExp(r'^(\d+)\.\s*(.*)').firstMatch(trimmed);
      if (match != null) {
        final num = match.group(1);
        final content = match.group(2);
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$num. ',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6E3EB5),
                  ),
                ),
                Expanded(
                  child: Text(
                    content ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1F2430),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              trimmed,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1F2430),
                height: 1.4,
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  Future<void> _launchPolicyDocument(String url) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        CustomSnackbar.showError(
          title: 'Error',
          message: 'Could not open the policy document link.',
        );
      }
    } catch (e) {
      debugPrint('Launch URL error: $e');
      CustomSnackbar.showError(
        title: 'Error',
        message: 'An error occurred while attempting to launch document.',
      );
    }
  }
}
