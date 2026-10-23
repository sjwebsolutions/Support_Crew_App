import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scupporo_crew_app/model/auth_model.dart';
import 'package:scupporo_crew_app/model/otp_request_model.dart';
import 'package:scupporo_crew_app/model/otp_verify_request.dart';
import 'package:scupporo_crew_app/services/auth_service.dart';
import 'package:scupporo_crew_app/utils/token_manager.dart';
import 'package:scupporo_crew_app/view/screens/main_screen.dart';
import '../../view/screens/auth/otp_screen.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  var isLoading = false.obs;
  var token = "".obs;

  void _showSnackbar({
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: isSuccess
          ? const Color(0xFF16A34A)
          : const Color(0xFFDC2626),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      icon: Icon(
        isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
        color: Colors.white,
      ),
      duration: const Duration(seconds: 4),
    );
  }

  Future<void> requestOtp(OtpRequest request) async {
    isLoading.value = true;
    debugPrint("Requesting OTP for: ${request.whatsappNumber}");
    try {
      final response = await _authService.requestOtp(request);
      debugPrint("Response status: ${response.statusCode}, body: ${response.body}");

      final String bodyText = response.body.trim();

      if (response.statusCode == 403) {
        _showSnackbar(
          title: "Access Blocked (403)",
          message: "Server security/firewall ne access block kar diya hai. Kripya kuch samay baad try karein.",
          isSuccess: false,
        );
        return;
      }

      if (bodyText.startsWith('<') || response.statusCode < 200 || response.statusCode >= 300) {
        _showSnackbar(
          title: "Server Issue",
          message: "Server currently unreachable hai (Status ${response.statusCode}). Kripya kuch samay baad try karein.",
          isSuccess: false,
        );
        return;
      }

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        _showSnackbar(
          title: "Server Error",
          message: "Server se sahi response nahi mil raha. Kripya dobara try karein.",
          isSuccess: false,
        );
        return;
      }

      if (data['success'] == true) {
        Get.to(() => OtpScreen(whatsappNumber: request.whatsappNumber!));
        _showSnackbar(
          title: "OTP Sent",
          message: data['message'] ?? "Aapke WhatsApp number par OTP bhej diya gaya hai.",
          isSuccess: true,
        );
      } else {
        _showSnackbar(
          title: "Request Failed",
          message: data['message'] ?? "Mobile number check karein ya kripya dobara try karein.",
          isSuccess: false,
        );
      }
    } catch (e) {
      debugPrint("Error during OTP request: $e");
      _showSnackbar(
        title: "Connection Error",
        message: "Internet connection check karein aur dobara try karein.",
        isSuccess: false,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(OtpVerifyRequest request) async {
    isLoading.value = true;
    debugPrint("Verifying OTP for ${request.whatsappNumber}");
    try {
      final response = await _authService.verifyOtp(request);
      debugPrint("Verify OTP Status: ${response.statusCode}");

      final String bodyText = response.body.trim();

      if (response.statusCode == 403) {
        _showSnackbar(
          title: "Access Blocked (403)",
          message: "Server security/firewall ne access block kar diya hai. Kripya kuch samay baad try karein.",
          isSuccess: false,
        );
        return;
      }

      if (bodyText.startsWith('<') || response.statusCode < 200 || response.statusCode >= 300) {
        _showSnackbar(
          title: "Server Issue",
          message: "Server unreachable hai (Status ${response.statusCode}). Kripya kuch samay baad try karein.",
          isSuccess: false,
        );
        return;
      }

      Map<String, dynamic> rawData = {};
      try {
        rawData = jsonDecode(response.body);
      } catch (_) {
        _showSnackbar(
          title: "Server Error",
          message: "Server se sahi response nahi mila. Kripya dobara try karein.",
          isSuccess: false,
        );
        return;
      }

      if (rawData['success'] == true) {
        final loginResponse = LoginResponse.fromJson(rawData);
        if (loginResponse.data?.token != null) {
          debugPrint("Login successful, saving token...");
          await TokenManager.saveToken(loginResponse.data!.token!);
          token.value = loginResponse.data!.token!;
          
          Get.offAll(() => const MainScreen());
          _showSnackbar(
            title: "Success",
            message: loginResponse.message ?? "Login successful!",
            isSuccess: true,
          );
        } else {
          _showSnackbar(
            title: "Login Error",
            message: "Authentication token nahi mila. Kripya dobara login karein.",
            isSuccess: false,
          );
        }
      } else {
        _showSnackbar(
          title: "Invalid OTP",
          message: rawData['message'] ?? "Kripya sahi OTP enter karein.",
          isSuccess: false,
        );
      }
    } catch (e) {
      debugPrint("Error during OTP verification: $e");
      _showSnackbar(
        title: "Connection Error",
        message: "Internet connection check karein aur dobara try karein.",
        isSuccess: false,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
