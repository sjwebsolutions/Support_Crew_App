import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:scupporo_crew_app/model/attendance_clock_model.dart';
import 'package:scupporo_crew_app/services/attendance_service.dart';
import 'package:scupporo_crew_app/view/screens/qr_scanner_screen.dart';
import 'package:scupporo_crew_app/view_model/get_x/dashboard_controller.dart';

class AttendanceController extends GetxController {
  final AttendanceService _attendanceService = AttendanceService();

  var isLoading = false.obs;
  var isGettingLocation = false.obs;
  var attendanceData = Rxn<AttendanceClockData>();
  var message = "".obs;
  var currentLatitude = Rxn<double>();
  var currentLongitude = Rxn<double>();

  // Reset local attendance data so UI stays in sync with backend database
  void resetAttendanceData() {
    attendanceData.value = null;
    currentLatitude.value = null;
    currentLongitude.value = null;
  }

  // Determine current position using Geolocator
  Future<Position?> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      isGettingLocation.value = true;
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("❌ Location services are disabled.");
        Get.snackbar(
          "Location Disabled",
          "Please enable Location/GPS services on your device.",
          backgroundColor: Colors.orangeAccent.withValues(alpha: 0.85),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          icon: const Icon(Icons.location_off, color: Colors.white),
        );
        return null;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint("❌ Location permission denied.");
          Get.snackbar(
            "Permission Denied",
            "Location permission is required to mark attendance.",
            backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(16),
            icon: const Icon(Icons.location_off, color: Colors.white),
          );
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint("❌ Location permission permanently denied.");
        Get.snackbar(
          "Permission Permanently Denied",
          "Location permissions are permanently denied. Please enable them in app settings.",
          backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          icon: const Icon(Icons.settings, color: Colors.white),
        );
        return null;
      }

      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );

      currentLatitude.value = position.latitude;
      currentLongitude.value = position.longitude;

      debugPrint("📍 [LOCATION ACQUIRED]");
      debugPrint("Latitude: ${position.latitude}");
      debugPrint("Longitude: ${position.longitude}");

      return position;
    } catch (e) {
      debugPrint("❌ Error fetching location: $e");
      Get.snackbar(
        "Location Error",
        "Could not get current location: $e",
        backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return null;
    } finally {
      isGettingLocation.value = false;
    }
  }

  // Mark attendance with auto-fetched location from Geolocator
  Future<bool> markAttendanceWithCurrentLocation({
    String qrToken = "b9e4857e-9efa-4f77-ad23-2ec1454a0302",
    String actionType = "Clock In",
  }) async {
    final position = await determinePosition();
    if (position == null) {
      return false;
    }

    return await markAttendance(
      qrToken: qrToken,
      latitude: position.latitude,
      longitude: position.longitude,
      actionType: actionType,
    );
  }

  // Helper to format error titles cleanly
  String _getAttendanceErrorTitle(String rawMsg, String actionType) {
    final lower = rawMsg.toLowerCase();
    if (lower.contains("2 min") ||
        lower.contains("minute") ||
        lower.contains("wait") ||
        lower.contains("time") ||
        lower.contains("early") ||
        lower.contains("cannot") ||
        actionType.toLowerCase().contains("out")) {
      return "Clock Out Restricted";
    }
    if (lower.contains("already clock") || lower.contains("already marked")) {
      return "Already Recorded";
    }
    if (lower.contains("qr") || lower.contains("token") || lower.contains("invalid")) {
      return "Invalid QR Code";
    }
    return "Attendance Failed";
  }

  // Helper to format error messages politely and clearly
  String _formatAttendanceErrorMessage(String rawMsg, String actionType) {
    String msg = rawMsg.trim();
    final lower = msg.toLowerCase();

    // 2-minute / early clock out restriction check
    if (lower.contains("2 min") ||
        lower.contains("2min") ||
        (lower.contains("minute") &&
            (lower.contains("clock") ||
                lower.contains("wait") ||
                lower.contains("time") ||
                lower.contains("after") ||
                lower.contains("before") ||
                lower.contains("early") ||
                lower.contains("cannot") ||
                lower.contains("can't") ||
                lower.contains("not allowed"))) ||
        (actionType.toLowerCase().contains("out") &&
            (lower.contains("wait") || lower.contains("minute") || lower.contains("time")))) {
      return "Please wait 2 minutes after Clock In before Clocking Out.";
    }

    if (msg.isEmpty) {
      return "Unable to process attendance. Please try again.";
    }

    // Capitalize first character and ensure punctuation
    String formatted = msg[0].toUpperCase() + msg.substring(1);
    if (!formatted.endsWith(".") && !formatted.endsWith("!")) {
      formatted = "$formatted.";
    }
    return formatted;
  }

  // Mark attendance with given coordinates
  Future<bool> markAttendance({
    required String qrToken,
    required double latitude,
    required double longitude,
    String actionType = "Clock In",
  }) async {
    try {
      isLoading.value = true;
      final request = AttendanceClockRequest(
        qrToken: qrToken,
        latitude: latitude,
        longitude: longitude,
      );

      debugPrint("➡️ Initiating clockAttendance call for $actionType...");
      final response = await _attendanceService.clockAttendance(request);
      final data = jsonDecode(response.body);

      debugPrint("⬅️ API Result Parsed: $data");

      final String rawMsg = (data['message'] ?? data['error'] ?? "").toString();
      final lowerMsg = rawMsg.toLowerCase();

      // Check for 2-minute restriction keywords from backend
      final bool isTimeRestricted = lowerMsg.contains("2 min") ||
          lowerMsg.contains("2min") ||
          (lowerMsg.contains("minute") &&
              (lowerMsg.contains("clock") ||
                  lowerMsg.contains("wait") ||
                  lowerMsg.contains("time") ||
                  lowerMsg.contains("after") ||
                  lowerMsg.contains("before") ||
                  lowerMsg.contains("early") ||
                  lowerMsg.contains("cannot") ||
                  lowerMsg.contains("can't") ||
                  lowerMsg.contains("not allowed")));

      // Check if user attempted Clock Out, but clock_out is not recorded in data
      final bool isClockOutAttempt = actionType.toLowerCase().contains("out");
      final bool clockOutNotRecorded = isClockOutAttempt &&
          (data['data'] == null ||
              data['data'] is! Map ||
              data['data']['clock_out'] == null);

      if (isTimeRestricted || (isClockOutAttempt && clockOutNotRecorded && lowerMsg.isNotEmpty)) {
        debugPrint("⛔ [ATTENDANCE RESTRICTED - 2 MIN RULE]: $rawMsg");

        Get.snackbar(
          "Clock Out Restricted",
          "Please wait 2 minutes after Clock In before Clocking Out.",
          backgroundColor: const Color(0xFFDC2626), // Solid Red
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: 14,
          duration: const Duration(seconds: 4),
          icon: const Icon(
            Icons.timer_outlined,
            color: Colors.white,
            size: 28,
          ),
        );
        return false;
      }

      final isSuccess = (response.statusCode == 200 || response.statusCode == 201) &&
          (data['success'] == true || data['status'] == true) &&
          data['data'] != null;

      if (isSuccess) {
        final clockResponse = AttendanceClockResponse.fromJson(data);
        attendanceData.value = clockResponse.data;
        message.value = clockResponse.message ?? "Attendance marked successfully!";

        debugPrint("✅ Attendance Success: ${message.value}");
        debugPrint("Data: ${clockResponse.data?.toJson()}");

        Get.snackbar(
          "Attendance Success",
          message.value,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: 14,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 26),
        );

        // Refresh dashboard data to sync stats & attendance today info
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().fetchDashboardData(isRefresh: true);
        }

        return true;
      } else {
        final rawErrorMsg = data['message']?.toString() ??
            data['error']?.toString() ??
            "Failed to mark attendance";
        final formattedErrorMsg = _formatAttendanceErrorMessage(rawErrorMsg, actionType);
        final title = _getAttendanceErrorTitle(rawErrorMsg, actionType);

        debugPrint("❌ Attendance Failed: $rawErrorMsg -> Formatted: $formattedErrorMsg");

        Get.snackbar(
          title,
          formattedErrorMsg,
          backgroundColor: const Color(0xFFDC2626), // Solid Red
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: 14,
          duration: const Duration(seconds: 4),
          icon: const Icon(
            Icons.cancel_rounded,
            color: Colors.white,
            size: 26,
          ),
        );
        return false;
      }
    } catch (e) {
      debugPrint("❌ Exception in markAttendance: $e");
      final String errStr = e.toString().toLowerCase();
      final bool isNetErr = errStr.contains("socketexception") ||
          errStr.contains("clientexception") ||
          errStr.contains("timeoutexception") ||
          errStr.contains("failed host lookup") ||
          errStr.contains("no address associated") ||
          errStr.contains("network is unreachable") ||
          errStr.contains("connection refused");

      Get.snackbar(
        isNetErr ? "No Internet Connection" : "Attendance Error",
        isNetErr
            ? "Please check your mobile data or Wi-Fi connection and try again."
            : "Something went wrong while marking attendance. Please try again.",
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 14,
        duration: const Duration(seconds: 4),
        icon: Icon(
          isNetErr ? Icons.wifi_off_rounded : Icons.cancel_rounded,
          color: Colors.white,
          size: 26,
        ),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Opens QR Scanner screen, grabs scanned token, fetches GPS location, and marks attendance
  Future<void> scanAndMarkAttendance({
    required BuildContext context,
    String actionType = "Clock In",
  }) async {
    await Get.to(
      () => QRScannerScreen(
        title: "$actionType Scan".toUpperCase(),
        actionType: actionType,
        onScanned: (scannedToken) async {
          debugPrint("📷 [SCANNED TOKEN FOR $actionType]: $scannedToken");
          await markAttendanceWithCurrentLocation(
            qrToken: scannedToken,
            actionType: actionType,
          );
        },
      ),
    );
  }
}
