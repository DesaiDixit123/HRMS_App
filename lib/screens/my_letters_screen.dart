import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrms_app/controllers/letters_controller.dart';
import 'package:hrms_app/services/api_service.dart';
import 'package:hrms_app/utils/custom_snackbar.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MyLettersScreen extends StatelessWidget {
  const MyLettersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LettersController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All My Letters',
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
          onRefresh: () => controller.fetchMyLetters(),
          child: Obx(() {
            if (controller.isLoading.value) {
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
                        onPressed: () => controller.fetchMyLetters(),
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

            if (controller.letters.isEmpty) {
              return ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mail_outline, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text(
                          'No letters or documents issued yet.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF74808F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Any official letters from HR will appear here.',
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
              itemCount: controller.letters.length,
              itemBuilder: (context, index) {
                final letter = controller.letters[index];
                return _buildLetterCard(context, letter);
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildLetterCard(BuildContext context, Map<String, dynamic> letter) {
    final template = letter['template_id'] as Map<String, dynamic>?;
    final templateName = template?['name'] ?? 'Official Document';
    final templateType = template?['template_type'] ?? 'other';
    final docNumber = letter['document_number'] ?? 'N/A';
    
    // Formatting date
    String dateStr = 'N/A';
    if (letter['generated_date'] != null) {
      try {
        final parsedDate = DateTime.parse(letter['generated_date']);
        dateStr = DateFormat('MMM dd, yyyy').format(parsedDate);
      } catch (_) {}
    }

    // Determine leading icon and color based on template type
    IconData leadingIcon;
    Color accentColor;
    switch (templateType.toString().toLowerCase()) {
      case 'offer':
        leadingIcon = Icons.card_membership_outlined;
        accentColor = const Color(0xFF52B447); // Green
        break;
      case 'appointment':
        leadingIcon = Icons.assignment_outlined;
        accentColor = const Color(0xFF6E3EB5); // Purple
        break;
      case 'experience':
        leadingIcon = Icons.work_history_outlined;
        accentColor = Colors.teal;
        break;
      case 'increment':
        leadingIcon = Icons.trending_up_outlined;
        accentColor = Colors.orange;
        break;
      case 'promotion':
        leadingIcon = Icons.military_tech_outlined;
        accentColor = Colors.blue;
        break;
      case 'warning':
        leadingIcon = Icons.warning_amber_outlined;
        accentColor = Colors.red;
        break;
      default:
        leadingIcon = Icons.description_outlined;
        accentColor = const Color(0xFF74808F);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: InkWell(
        borderRadius: BorderRadius.circular(15.0),
        onTap: () => _downloadLetter(letter),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(leadingIcon, color: accentColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      templateName,
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
                      'Ref: $docNumber',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF74808F),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Issued: $dateStr',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFA9B7A0),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.download_for_offline, color: Color(0xFF6E3EB5), size: 28),
                onPressed: () => _downloadLetter(letter),
                tooltip: 'Download PDF',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadLetter(Map<String, dynamic> letter) async {
    final token = await ApiService.getToken();
    if (token == null) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Authorization token not found. Please log in again.',
      );
      return;
    }

    final documentId = letter['_id'];
    final url = '${ApiService.baseUrl}/employeeUser/letters/download/$documentId?token=$token';
    final uri = Uri.parse(url);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        CustomSnackbar.showError(
          title: 'Error',
          message: 'Could not download the document.',
        );
      }
    } catch (e) {
      debugPrint('Download error: $e');
      CustomSnackbar.showError(
        title: 'Error',
        message: 'An error occurred while launching download.',
      );
    }
  }
}
