import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:scupporo_crew_app/model/otp_verify_request.dart';
import 'package:scupporo_crew_app/services/notification_service.dart';
import 'package:scupporo_crew_app/utils/constants/app_colors.dart';
import 'package:scupporo_crew_app/utils/widgets/custom_back_button.dart';
import 'package:scupporo_crew_app/view_model/get_x/auth_controller.dart';

class ManualOtpScreen extends StatefulWidget {
  final String whatsappNumber;
  const ManualOtpScreen({super.key, required this.whatsappNumber});

  @override
  State<ManualOtpScreen> createState() => _ManualOtpScreenState();
}

class _ManualOtpScreenState extends State<ManualOtpScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.whatsappNumber;
  }

  Future<void> _handleManualLogin() async {
    final authController = Get.find<AuthController>();

    if (_phoneController.text.length != 10) {
      Get.snackbar(
        "Error",
        "Enter a valid 10-digit mobile number",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (_otpController.text.length < 6) {
      Get.snackbar(
        "Error",
        "Enter 6-digit OTP",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    String deviceUuid = "unknown_uuid";
    String deviceName = "unknown_device";
    String deviceOs = Platform.operatingSystem;

    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceUuid = androidInfo.id;
        deviceName = androidInfo.model;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceUuid = iosInfo.identifierForVendor ?? "unknown";
        deviceName = iosInfo.name;
      }
    } catch (e) {
      print("Error getting device info: $e");
    }

    String? fcmToken;
    try {
      fcmToken = await NotificationService().getToken();
    } catch (e) {
      print("Error getting FCM token: $e");
    }

    final request = OtpVerifyRequest(
      whatsappNumber: _phoneController.text,
      otpCode: _otpController.text,
      deviceUuid: deviceUuid,
      deviceName: deviceName,
      deviceOs: deviceOs,
      fcmToken: fcmToken ?? "",
    );

    authController.verifyOtp(request);
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    final defaultPinTheme = PinTheme(
      width: 42,
      height: 48,
      textStyle: GoogleFonts.poppins(
        fontSize: 20,
        color: const Color(0xFF0F172A),
        fontWeight: FontWeight.w700,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Back Button
                const CustomBackButton(),
                const SizedBox(height: 28),

                // Header
                Text(
                  "Manual OTP Login",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Contact Your School Administration To Get a Temporary OTP",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),

                // Attention Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB45309).withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Attention Required",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF92400E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Use This Option Only If You Did Not Receive Your WhatsApp OTP. Contact School Admin With Registered Mobile Number To Get a Temporary OTP.",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFFB45309),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Main Form Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E293B).withValues(alpha: 0.07),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mobile Input
                      Text(
                        "Registered Mobile Number",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                        ),
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          style: GoogleFonts.poppins(color: const Color(0xFF0F172A), fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: "Enter mobile number",
                            hintStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8)),
                            prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: Color(0xFF64748B)),
                            border: InputBorder.none,
                            counterText: "",
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // OTP Input
                      Text(
                        "Temporary OTP (From School Admin)",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 6),
                            const Icon(Icons.confirmation_num_outlined, color: Color(0xFF64748B), size: 22),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Pinput(
                                length: 6,
                                controller: _otpController,
                                defaultPinTheme: defaultPinTheme,
                                focusedPinTheme: defaultPinTheme.copyWith(
                                  decoration: defaultPinTheme.decoration!.copyWith(
                                    border: Border.all(color: AppColors.primaryColor, width: 1.8),
                                  ),
                                ),
                                preFilledWidget: Text("-", style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF94A3B8))),
                                separatorBuilder: (index) => const SizedBox(width: 6),
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: Obx(() => ElevatedButton(
                          onPressed: authController.isLoading.value ? null : _handleManualLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                            shadowColor: AppColors.primaryColor.withValues(alpha: 0.3),
                          ),
                          child: authController.isLoading.value
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Login With Manual OTP",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Info Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Manual OTP Is Valid For Limited Time And Single Use Only.",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
