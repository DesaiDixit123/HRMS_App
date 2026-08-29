import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:hrms_app/components/app_header.dart';
import 'package:hrms_app/components/info_item.dart';
import 'package:hrms_app/controllers/auth_controller.dart';
import 'package:hrms_app/controllers/profile_controller.dart';
import 'package:hrms_app/utils/custom_snackbar.dart';
import 'package:hrms_app/screens/edit_profile_screen.dart';
import 'package:hrms_app/screens/help_support_screen.dart';
import 'package:hrms_app/screens/my_letters_screen.dart';
import 'package:hrms_app/screens/hr_policy_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

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
                      onPressed: controller.fetchProfile,
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await controller.fetchProfile();
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  AppHeader(title: 'Profile', subtitle: 'Account information'),
                  SizedBox(height: 25),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Card
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
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
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Color(0xFFDCE6D8),
                                    width: 3,
                                  ),
                                  color: Color(0xFFF5F5F5),
                                ),
                                child: ClipOval(
                                  child: controller.profilePhotoUrl.isNotEmpty
                                      ? Image.network(
                                          controller.profilePhotoUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Icon(
                                                    Icons.person,
                                                    size: 60,
                                                    color: Color(0xFFA9B7A0),
                                                  ),
                                        )
                                      : Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Color(0xFFA9B7A0),
                                        ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                controller.fullName,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2430),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                controller.designation,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF74808F),
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: controller.isActive
                                          ? Color(0xFFE8F5E9)
                                          : Color(0xFFFFEBEE),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      controller.isActive
                                          ? 'Active'
                                          : 'Inactive',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: controller.isActive
                                            ? Color(0xFF52B447)
                                            : Color(0xFFFF3B30),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF1EBFB),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      controller.role,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6E3EB5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2430),
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  Get.to(() => EditProfileScreen()),
                              icon: Icon(Icons.edit, color: Color(0xFF52B447)),
                              tooltip: 'Edit Profile',
                            ),
                          ],
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
                              InfoItem(
                                icon: Icons.email,
                                iconColor: Color(0xFF6E3EB5),
                                iconBgColor: Color(0xFFF1EBFB),
                                label: 'Email',
                                value: controller.email,
                              ),
                              _infoDivider(),
                              InfoItem(
                                icon: Icons.phone,
                                iconColor: Color(0xFF52B447),
                                iconBgColor: Color(0xFFE8F5E9),
                                label: 'Phone',
                                value: '+91 ${controller.phone}',
                              ),
                              _infoDivider(),
                              InfoItem(
                                icon: Icons.cake,
                                iconColor: Color(0xFFE91E63),
                                iconBgColor: Color(0xFFFCE4EC),
                                label: 'Date of Birth',
                                value: controller.dob,
                              ),
                              _infoDivider(),
                              InfoItem(
                                icon: Icons.person_outline,
                                iconColor: Color(0xFF6E3EB5),
                                iconBgColor: Color(0xFFF3E5F5),
                                label: 'Gender',
                                value: controller.gender,
                              ),
                              _infoDivider(),
                              InfoItem(
                                icon: Icons.location_on,
                                iconColor: Color(0xFFFF5722),
                                iconBgColor: Color(0xFFFBE9E7),
                                label: 'Address',
                                value: controller.address,
                              ),
                              _infoDivider(),
                              InfoItem(
                                icon: Icons.emergency,
                                iconColor: Color(0xFFFF3B30),
                                iconBgColor: Color(0xFFFFEBEE),
                                label: 'Emergency Contact',
                                value:
                                    '${controller.emergencyContactName} (${controller.emergencyContactNumber})',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        // Professional Information
                        Text(
                          'Professional Information',
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
                              InfoItem(
                                icon: Icons.shield,
                                iconColor: Color(0xFF1F2430),
                                iconBgColor: Color(0xFFECEFF1),
                                label: 'Employee Code',
                                value: controller.employeeCode,
                              ),
                              _infoDivider(),
                              InfoItem(
                                icon: Icons.business,
                                iconColor: Color(0xFFFFA500),
                                iconBgColor: Color(0xFFFFF3E0),
                                label: 'Department',
                                value: controller.department,
                              ),
                              _infoDivider(),
                              InfoItem(
                                icon: Icons.work,
                                iconColor: Color(0xFF6E3EB5),
                                iconBgColor: Color(0xFFF1EBFB),
                                label: 'Designation',
                                value: controller.designation,
                              ),
                              _infoDivider(),
                              InfoItem(
                                icon: Icons.badge,
                                iconColor: Color(0xFF00BCD4),
                                iconBgColor: Color(0xFFE0F7FA),
                                label: 'Employment Type',
                                value: controller.employmentType,
                              ),
                              _infoDivider(),
                              InfoItem(
                                icon: Icons.event,
                                iconColor: Color(0xFF4CAF50),
                                iconBgColor: Color(0xFFE8F5E9),
                                label: 'Joining Date',
                                value: controller.joiningDate,
                              ),
                              _infoDivider(),
                              InfoItem(
                                icon: Icons.supervisor_account,
                                iconColor: Color(0xFF795548),
                                iconBgColor: Color(0xFFEFEBE9),
                                label: 'Reporting Manager',
                                value: controller.reportingManager,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        // Quick Actions
                        Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2430),
                          ),
                        ),
                        SizedBox(height: 15),
                        _actionItem(
                          context: context,
                          icon: Icons.description,
                          label: 'My Documents',
                          onTap: () {
                            _showDocumentsSheet(context, controller);
                          },
                        ),
                        SizedBox(height: 12),
                        _actionItem(
                          context: context,
                          icon: Icons.mail_outline,
                          label: 'All My Letters',
                          onTap: () {
                            Get.to(() => const MyLettersScreen());
                          },
                        ),
                        SizedBox(height: 12),
                        _actionItem(
                          context: context,
                          icon: Icons.gavel,
                          label: 'HR Policies',
                          onTap: () {
                            Get.to(() => const HRPolicyScreen());
                          },
                        ),
                        SizedBox(height: 12),
                        _actionItem(
                          context: context,
                          icon: Icons.help,
                          label: 'Help & Support',
                          isHighlighted: true,
                          onTap: () {
                            Get.to(() => const HelpSupportScreen());
                          },
                        ),
                        SizedBox(height: 30),
                        // // App Version
                        // Center(
                        //   child: Container(
                        //     padding: EdgeInsets.all(16),
                        //     decoration: BoxDecoration(
                        //       color: Color(0xFFF5F5F5),
                        //       borderRadius: BorderRadius.circular(15),
                        //     ),
                        //     child: Column(
                        //       children: [
                        //         Text(
                        //           'App Version',
                        //           style: TextStyle(
                        //             fontSize: 14,
                        //             color: Color(0xFF74808F),
                        //           ),
                        //         ),
                        //         SizedBox(height: 8),
                        //         Text(
                        //           'v1.0.0',
                        //           style: TextStyle(
                        //             fontSize: 18,
                        //             fontWeight: FontWeight.bold,
                        //             color: Color(0xFF1F2430),
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        SizedBox(height: 20),
                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Text('Logout'),
                                  content: Text(
                                    'Are you sure you want to logout?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Get.find<AuthController>().logout();
                                      },
                                      child: Text('Logout'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFF3B30),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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

  Widget _actionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHighlighted ? Color(0xFFF1EBFB) : Colors.white,
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
            Icon(
              icon,
              size: 24,
              color: isHighlighted ? Color(0xFF6E3EB5) : Color(0xFF1F2430),
            ),
            SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isHighlighted ? Color(0xFF6E3EB5) : Color(0xFF1F2430),
              ),
            ),
            Spacer(),
            Icon(
              Icons.chevron_right,
              color: isHighlighted ? Color(0xFF6E3EB5) : Color(0xFFA9B7A0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoDivider() {
    return Divider(
      height: 1,
      color: Color(0xFFDCE6D8),
      indent: 16,
      endIndent: 16,
    );
  }

  void _showDocumentsSheet(BuildContext context, ProfileController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final docs = controller.documents;
        if (docs.isEmpty) {
          return Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.folder_off, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text('No documents found.', style: TextStyle(fontSize: 16)),
                SizedBox(height: 24),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'My Documents',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2430),
                ),
              ),
              SizedBox(height: 20),
              ...docs.entries.map((e) {
                if (e.value == null || e.value.toString().isEmpty) {
                  return SizedBox.shrink();
                }
                final url =
                    'https://hrms-khushi.s3.ap-south-1.amazonaws.com/${e.value}';
                final fileName = e.key.replaceAll('_', ' ').toUpperCase();

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFFF1EBFB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.insert_drive_file,
                      color: Color(0xFF6E3EB5),
                    ),
                  ),
                  title: Text(
                    fileName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2430),
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFFA9B7A0),
                  ),
                  onTap: () async {
                    final uri = Uri.parse(url);
                    try {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (e) {
                      CustomSnackbar.showError(
                        title: 'Error',
                        message: 'Could not open document',
                      );
                    }
                  },
                );
              }),
              SizedBox(height: 50),
            ],
          ),
        );
      },
    );
  }
}
