import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scupporo_crew_app/model/dashboard_model.dart';
import 'package:scupporo_crew_app/services/dashboard_service.dart';
import 'package:scupporo_crew_app/utils/token_manager.dart';
import 'package:scupporo_crew_app/view/screens/auth/login_screen.dart';
import 'package:scupporo_crew_app/view_model/get_x/announcement_controller.dart';
import 'package:scupporo_crew_app/view_model/get_x/attendance_controller.dart';
import 'package:scupporo_crew_app/view_model/get_x/banner_controller.dart';
import '../../utils/constants/app_constants.dart';

class DashboardController extends GetxController with WidgetsBindingObserver {
  final _dashboardService = DashboardService();
  var isLoading = true.obs;
  var isRefreshing = false.obs;
  var dashboardData = Rxn<DashboardData>();
  var message = "".obs;
  var isNetworkError = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDashboardData();
      _fetchBannersAndAnnouncements();
    });
  }

  void _fetchBannersAndAnnouncements({bool isRefresh = false}) {
    if (Get.isRegistered<BannerController>()) {
      Get.find<BannerController>().fetchBanners(isRefresh: isRefresh);
    }
    if (Get.isRegistered<AnnouncementController>()) {
      Get.find<AnnouncementController>().fetchAnnouncements(isRefresh: isRefresh);
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchDashboardData(isRefresh: true);
      _fetchBannersAndAnnouncements(isRefresh: true);
    }
  }

  Future<void> fetchDashboardData({bool isRefresh = false}) async {
    try {
      if (!isRefresh && dashboardData.value == null) {
        isLoading.value = true;
      } else {
        isRefreshing.value = true;
      }

      final token = await TokenManager.getToken();
      if (token == null || token.trim().isEmpty || token == "null") {
        debugPrint("⚠️ [DASHBOARD] No auth token found. User must log in.");
        message.value = "Please log in to view dashboard.";
        if (!isRefresh) {
          Get.offAll(() => const LoginScreen());
        }
        return;
      }

      debugPrint("🚀 [DASHBOARD] Fetching data from: ${AppConstants.dashboard}");
      final response = await _dashboardService.getDashboardData();
      debugPrint("📩 [DASHBOARD] Response Code: ${response.statusCode}");
      debugPrint("📄 [DASHBOARD] Body: ${response.body}");

      if (response.statusCode == 408) {
        isNetworkError.value = true;
        message.value = "No internet connection. Please check your mobile data or Wi-Fi and try again.";
        if (!isRefresh || dashboardData.value == null) {
          Get.snackbar(
            "No Internet Connection",
            "Please check your mobile data or Wi-Fi and try again.",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
        }
        return;
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint("⛔ [DASHBOARD] 401/403 Unauthorized. Logging out user.");
        await TokenManager.clearToken();
        message.value = "Session expired. Please log in again.";
        Get.offAll(() => const LoginScreen());
        Get.snackbar(
          "Session Expired",
          "Your session has expired. Please log in again.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      if (response.body.isEmpty) {
        throw Exception("Empty response from server");
      }

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception("Invalid JSON structure from server");
      }

      final Map<String, dynamic> data = decoded;

      final bool isApiSuccess = response.statusCode == 200 &&
          (data['success'] == true ||
              data['status'] == true ||
              data['success']?.toString().toLowerCase() == "true" ||
              data['status']?.toString().toLowerCase() == "true");

      if (isApiSuccess) {
        final model = DashboardModel.fromJson(data);
        if (model.data != null) {
          dashboardData.value = model.data;
          dashboardData.refresh();
          message.value = "";
          isNetworkError.value = false;
          debugPrint("✅ [DASHBOARD] Data loaded for: ${model.data?.supportCrew?.name ?? 'User'} (School: ${model.data?.school?.schoolName ?? 'N/A'})");

          if (Get.isRegistered<AttendanceController>()) {
            Get.find<AttendanceController>().resetAttendanceData();
          }
        } else {
          debugPrint("⚠️ [DASHBOARD] Model.data is null after parsing. Raw data: $data");
          message.value = data['message']?.toString() ?? "Dashboard data is empty";
          isNetworkError.value = false;
        }
      } else {
        final errorMsg = (data['message'] ?? data['error'] ?? "Failed to load dashboard data").toString();
        debugPrint("❌ [DASHBOARD] API Error: $errorMsg");
        message.value = errorMsg;
        isNetworkError.value = false;
        if (!isRefresh || dashboardData.value == null) {
          Get.snackbar(
            "Notice",
            errorMsg,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orangeAccent.withValues(alpha: 0.85),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint("🔥 [DASHBOARD] Crash/Exception: $e\n$stackTrace");
      final String errStr = e.toString().toLowerCase();
      final bool isNetErr = errStr.contains("socketexception") ||
          errStr.contains("clientexception") ||
          errStr.contains("timeoutexception") ||
          errStr.contains("handshakeexception") ||
          errStr.contains("failed host lookup") ||
          errStr.contains("no address associated") ||
          errStr.contains("network is unreachable") ||
          errStr.contains("connection refused") ||
          errStr.contains("connection closed") ||
          errStr.contains("os error");

      if (isNetErr) {
        isNetworkError.value = true;
        message.value = "No internet connection. Please check your mobile data or Wi-Fi and try again.";
      } else {
        isNetworkError.value = false;
        message.value = "Unable to connect: $e";
      }

      if (!isRefresh || dashboardData.value == null) {
        if (isNetErr) {
          Get.snackbar(
            "No Internet Connection",
            "Please check your mobile data or Wi-Fi connection and try again.",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
        } else {
          Get.snackbar(
            "Connection Error",
            "Unable to load dashboard data. Please pull down to refresh.",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
        }
      }
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }
  }


