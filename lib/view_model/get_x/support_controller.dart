import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scupporo_crew_app/model/support_settings_model.dart';
import 'package:scupporo_crew_app/model/policy_model.dart';
import 'package:scupporo_crew_app/services/support_service.dart';

class SupportController extends GetxController {
  final SupportService _supportService = SupportService();
  var isLoading = false.obs;
  var isPolicyLoading = false.obs;
  var supportData = Rxn<SupportSettingsData>();
  var policyData = Rxn<PolicyData>();

  Future<void> fetchSupportSettings() async {
    try {
      isLoading.value = true;
      final response = await _supportService.getSupportSettings();
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        supportData.value = SupportSettingsModel.fromJson(data).data;
      } else {
        Get.snackbar(
          "Error",
          data['message'] ?? "Failed to load support data",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      debugPrint("Error fetching support settings: $e");
      Get.snackbar(
        "Error",
        "Something went wrong while fetching support info",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPolicies() async {
    try {
      isPolicyLoading.value = true;
      final response = await _supportService.getPolicies();
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        policyData.value = PolicyModel.fromJson(data).data;
      } else {
        Get.snackbar(
          "Error",
          data['message'] ?? "Failed to load policies",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      debugPrint("Error fetching policies: $e");
      Get.snackbar(
        "Error",
        "Something went wrong while fetching policies",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isPolicyLoading.value = false;
    }
  }
}
