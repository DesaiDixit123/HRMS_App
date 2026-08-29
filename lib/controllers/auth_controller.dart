import 'dart:async';
import 'package:get/get.dart';
import 'package:hrms_app/services/auth_service.dart';
import 'package:hrms_app/services/api_service.dart';
import 'package:hrms_app/utils/custom_snackbar.dart';
import 'package:hrms_app/services/notification_service.dart';

class AuthController extends GetxController {
  final mobileController = ''.obs;
  final isLoading = false.obs;
  final lastSentOtp = ''.obs;
  final resendCountdown = 0.obs;
  Timer? _resendTimer;

  // ─── Send OTP ───────────────────────────────────────────────
  Future<bool> sendOtp(String mobile) async {
    isLoading.value = true;
    try {
      final response = await AuthService.sendOtp(mobile);
      final otp = response['Data']?['lastsentotp'] as String? ?? '';
      lastSentOtp.value = otp;
      _startResendTimer();
      return true;
    } on ApiException catch (e) {
      CustomSnackbar.showError(title: 'Error', message: e.message);
      return false;
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Network error. Please try again.',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Verify OTP ─────────────────────────────────────────────
  Future<bool> verifyOtp(String mobile, String otp) async {
    isLoading.value = true;
    try {
      final fcmToken = await NotificationService.getToken();
      await AuthService.verifyOtp(mobile, otp, fcmToken: fcmToken);
      return true;
    } on ApiException catch (e) {
      CustomSnackbar.showError(title: 'Error', message: e.message);
      return false;
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Network error. Please try again.',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Resend Timer ───────────────────────────────────────────
  void _startResendTimer() {
    resendCountdown.value = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown.value <= 1) {
        timer.cancel();
        resendCountdown.value = 0;
      } else {
        resendCountdown.value--;
      }
    });
  }

  // ─── Resend OTP ─────────────────────────────────────────────
  Future<void> resendOtp(String mobile) async {
    try {
      final response = await AuthService.sendOtp(mobile);
      final otp = response['Data']?['lastsentotp'] as String? ?? '';
      lastSentOtp.value = otp;
      _startResendTimer();
      CustomSnackbar.showSuccess(
        title: 'Success',
        message: 'OTP resent to your number',
      );
    } catch (e) {
      CustomSnackbar.showError(title: 'Error', message: 'Failed to resend OTP');
    }
  }

  // ─── Logout ─────────────────────────────────────────────────
  Future<void> logout() async {
    await AuthService.logout();
    Get.offAllNamed('/login');
  }

  // ─── Check Login ────────────────────────────────────────────
  Future<bool> checkLogin() async {
    return await AuthService.isLoggedIn();
  }

  // ─── Reset State ────────────────────────────────────────────
  void resetState() {
    isLoading.value = false;
    lastSentOtp.value = '';
    resendCountdown.value = 0;
    _resendTimer?.cancel();
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    super.onClose();
  }
}
