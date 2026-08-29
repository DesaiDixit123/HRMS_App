import 'package:get/get.dart';
import 'package:hrms_app/services/api_service.dart';

class NotificationController extends GetxController {
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final notifications = <Map<String, dynamic>>[].obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await ApiService.get(
        '/employeeUser/notifications/list',
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true && response['Data'] != null) {
        final list = response['Data'] as List<dynamic>;
        notifications.value = list
            .map((e) => e as Map<String, dynamic>)
            .toList();
        _updateUnreadCount();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load notifications';
      print('Error fetching notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await ApiService.post(
        '/employeeUser/notifications/mark-read',
        body: {'notificationId': notificationId},
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true) {
        // Update local state
        final index = notifications.indexWhere(
          (n) => n['_id'] == notificationId,
        );
        if (index != -1) {
          final updatedNotification = Map<String, dynamic>.from(
            notifications[index],
          );
          updatedNotification['is_read'] = true;
          notifications[index] = updatedNotification;
          _updateUnreadCount();
        }
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await ApiService.post(
        '/employeeUser/notifications/mark-all-read',
        body: {},
        requiresAuth: true,
      );
      if (response['IsSuccess'] == true) {
        // Update local state
        for (int i = 0; i < notifications.length; i++) {
          final updatedNotification = Map<String, dynamic>.from(
            notifications[i],
          );
          updatedNotification['is_read'] = true;
          notifications[i] = updatedNotification;
        }
        _updateUnreadCount();
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications
        .where((n) => n['is_read'] == false)
        .length;
  }
}
