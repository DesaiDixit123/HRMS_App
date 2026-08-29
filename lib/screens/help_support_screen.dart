import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hrms_app/components/app_header.dart';
import 'package:hrms_app/utils/custom_snackbar.dart';
import 'package:animate_do/animate_do.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _makeCall() async {
    final Uri url = Uri.parse('tel:+919712356799');
    try {
      await launchUrl(url);
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Could not launch dialer: $e',
      );
    }
  }

  Future<void> _sendEmail() async {
    final Uri url = Uri.parse('mailto:team.hr@policyexperts.co.in?subject=HRMS%20Support%20Request');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Could not launch email client: $e',
      );
    }
  }

  Future<void> _openWhatsApp() async {
    final Uri url = Uri.parse('https://wa.me/919712356799?text=Hello%20HR%20Team,');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Could not launch WhatsApp: $e',
      );
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    CustomSnackbar.showSuccess(
      title: 'Copied',
      message: '$label copied to clipboard!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF5),
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                const AppHeader(
                  title: 'Help & Support',
                  subtitle: 'How can we assist you today?',
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Support Illustration Banner
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1EBFB),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.headset_mic_rounded,
                                size: 52,
                                color: Color(0xFF52B447),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'HR & IT Help Desk',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2430),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Need help with payroll, policies, leaves, or anything else? Get in touch with our HR Team directly using the options below.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF74808F),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Contact Channels Section Header
                    FadeInLeft(
                      duration: const Duration(milliseconds: 500),
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Direct Contact Channels',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2430),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Phone & WhatsApp Contact Card
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE8F5E9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.phone_rounded,
                                      color: Color(0xFF52B447),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Phone & WhatsApp',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF74808F),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        InkWell(
                                          onLongPress: () => _copyToClipboard('+919712356799', 'Phone number'),
                                          child: const Text(
                                            '+91 9712356799',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1F2430),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy_rounded, color: Color(0xFFA9B7A0), size: 20),
                                    onPressed: () => _copyToClipboard('+919712356799', 'Phone number'),
                                    tooltip: 'Copy Number',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _makeCall,
                                      icon: const Icon(Icons.call, size: 18),
                                      label: const Text('Call HR'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF52B447),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _openWhatsApp,
                                      icon: const Icon(Icons.chat_bubble, size: 18),
                                      label: const Text('WhatsApp'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF25D366),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email Contact Card
                    FadeInUp(
                      duration: const Duration(milliseconds: 700),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF1EBFB),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.email_outlined,
                                      color: Color(0xFF52B447),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Email Support',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF74808F),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        InkWell(
                                          onLongPress: () => _copyToClipboard('team.hr@policyexperts.co.in', 'Email address'),
                                          child: const Text(
                                            'team.hr@policyexperts.co.in',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1F2430),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy_rounded, color: Color(0xFFA9B7A0), size: 20),
                                    onPressed: () => _copyToClipboard('team.hr@policyexperts.co.in', 'Email address'),
                                    tooltip: 'Copy Email',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _sendEmail,
                                  icon: const Icon(Icons.send_rounded, size: 18),
                                  label: const Text('Send Email to HR'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF52B447),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Nice Footer/Availability Note
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.info_outline_rounded, color: Color(0xFF64748B), size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Support is available Monday to Friday from 9:30 AM to 6:30 PM.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
