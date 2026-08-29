import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrms_app/controllers/notification_controller.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());

    return Scaffold(
      backgroundColor: Color(0xFFF7FAF5),
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF1F2430),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF1F2430)),
        actions: [
          Obx(
            () => controller.unreadCount.value > 0
                ? IconButton(
                    icon: Icon(Icons.done_all, color: Color(0xFF6E3EB5)),
                    onPressed: () {
                      controller.markAllAsRead();
                    },
                    tooltip: 'Mark all as read',
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage.value),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchNotifications,
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchNotifications,
          child: controller.notifications.isEmpty
              ? ListView(
                  children: [
                    SizedBox(height: 100),
                    Center(
                      child: Text(
                        'No notifications found.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemCount: controller.notifications.length,
                  itemBuilder: (context, index) {
                    final item = controller.notifications[index];
                    final title = item['title'] ?? 'Notification';
                    final message = item['message'] ?? '';
                    final isRead = item['is_read'] ?? true;
                    final dateStr = item['createdAt'] ?? '';

                    String timeAgo = '';
                    try {
                      if (dateStr.isNotEmpty) {
                        final date = DateTime.parse(dateStr);
                        final difference = DateTime.now().difference(date);
                        if (difference.inDays > 1) {
                          timeAgo = DateFormat('MMM d, yyyy').format(date);
                        } else if (difference.inDays == 1) {
                          timeAgo = '1 day ago';
                        } else if (difference.inHours > 0) {
                          timeAgo = '${difference.inHours} hours ago';
                        } else if (difference.inMinutes > 0) {
                          timeAgo = '${difference.inMinutes} mins ago';
                        } else {
                          timeAgo = 'Just now';
                        }
                      }
                    } catch (_) {}

                    return GestureDetector(
                      onTap: () {
                        if (!isRead) {
                          controller.markAsRead(item['_id']);
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isRead ? Colors.white : Color(0xFFF0F7FF),
                          borderRadius: BorderRadius.circular(15),
                          border: isRead
                              ? null
                              : Border.all(
                                  color: Color(0xFF6E3EB5).withOpacity(0.3),
                                ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color(0xFFF1EBFB),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.notifications_none,
                                color: Color(0xFF6E3EB5),
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isRead
                                          ? FontWeight.w600
                                          : FontWeight.bold,
                                      color: Color(0xFF1F2430),
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    message,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isRead
                                          ? Colors.grey[600]
                                          : Color(0xFF1F2430),
                                      height: 1.4,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    timeAgo,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 10,
                                height: 10,
                                margin: EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  color: Color(0xFF6E3EB5),
                                  shape: BoxShape.circle,
                                ),
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
}
