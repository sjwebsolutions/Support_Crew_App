import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:scupporo_crew_app/model/otp_request_model.dart';
import 'package:scupporo_crew_app/model/otp_verify_request.dart';
import 'package:scupporo_crew_app/services/notification_service.dart';
import 'package:scupporo_crew_app/utils/constants/app_colors.dart';
import 'package:scupporo_crew_app/utils/widgets/custom_back_button.dart';
import 'package:scupporo_crew_app/view_model/get_x/auth_controller.dart';
import 'package:device_info_plus/device_info_plus.dart';

class OtpScreen extends StatefulWidget {
  final String whatsappNumber;
  const OtpScreen({super.key, required this.whatsappNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  Timer? _timer;
  int _start = 120;
  bool _canResend = false;

  void startTimer() {
    setState(() {
      _start = 120;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _canResend = true;
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _resendOtp() async {
    final authController = Get.find<AuthController>();
    
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

    final request = OtpRequest(
      whatsappNumber: widget.whatsappNumber,
      deviceUuid: deviceUuid,
      deviceName: deviceName,
      deviceOs: deviceOs,
    );

    await authController.requestOtp(request);
    startTimer();
    _otpController.clear();
  }

  Future<void> _verify() async {
    final authController = Get.find<AuthController>();
    if (_otpController.text.length < 6) return;

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
      whatsappNumber: widget.whatsappNumber,
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
      width: 48,
      height: 56,
      textStyle: GoogleFonts.poppins(
        fontSize: 20,
        color: const Color(0xFF0F172A),
        fontWeight: FontWeight.w700,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primaryColor, width: 2),
        color: Colors.white,
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CustomBackButton(),
                  ),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E293B).withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Verify OTP",
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Enter the 6-digit code sent to\n+91 ${widget.whatsappNumber}",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF64748B),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 32),

                          Pinput(
                            length: 6,
                            controller: _otpController,
                            defaultPinTheme: defaultPinTheme,
                            focusedPinTheme: focusedPinTheme,
                            onCompleted: (pin) => _verify(),
                          ),

                          const SizedBox(height: 32),

                          // Timer & Resend
                          _canResend
                              ? ElevatedButton(
                                  onPressed: _resendOtp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                                  ),
                                  child: Text(
                                    "Resend OTP",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.timer_outlined, size: 18, color: Color(0xFF64748B)),
                                    const SizedBox(width: 8),
                                    RichText(
                                      text: TextSpan(
                                        text: "OTP expires in ",
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF64748B),
                                          fontSize: 14,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: "${(_start ~/ 60).toString().padLeft(2, '0')}:${(_start % 60).toString().padLeft(2, '0')}",
                                            style: const TextStyle(
                                              color: AppColors.primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
          // Loading Overlay
          Obx(() => authController.isLoading.value
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
