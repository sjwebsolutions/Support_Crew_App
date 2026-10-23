import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scupporo_crew_app/model/banner_model.dart';
import 'package:scupporo_crew_app/services/banner_service.dart';
import 'package:scupporo_crew_app/services/notification_service.dart';
import 'package:scupporo_crew_app/view_model/get_x/notification_controller.dart';

class BannerController extends GetxController {
  final BannerService _bannerService = BannerService();

  var isLoading = false.obs;
  var bannerList = <BannerItem>[].obs;
  var message = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
  }

  Future<void> fetchBanners({bool isRefresh = false}) async {
    try {
      if (!isRefresh && bannerList.isEmpty) {
        isLoading.value = true;
      }
      message.value = "";

      final response = await _bannerService.getBanners();
      debugPrint("📩 [BANNERS] Status Code: ${response.statusCode}, Body: ${response.body}");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final dynamic decoded = jsonDecode(response.body);
        List<BannerItem> newList = [];

        if (decoded is List) {
          newList = decoded
              .map((v) => BannerItem.fromJson(Map<String, dynamic>.from(v as Map)))
              .toList();
        } else if (decoded is Map) {
          final Map<String, dynamic> map = Map<String, dynamic>.from(decoded);
          final bool isApiSuccess = map['success'] == true ||
              map['status'] == true ||
              map['success']?.toString().toLowerCase() == "true" ||
              map['status']?.toString().toLowerCase() == "true" ||
              map['status']?.toString().toLowerCase() == "success" ||
              map['data'] != null ||
              map['banners'] != null;

          if (isApiSuccess) {
            final rawData = map['data'] ?? map['banners'] ?? map['result'];
            if (rawData is List) {
              newList = rawData
                  .map((v) => BannerItem.fromJson(Map<String, dynamic>.from(v as Map)))
                  .toList();
            } else if (rawData is Map && rawData['banners'] != null && rawData['banners'] is List) {
              newList = (rawData['banners'] as List)
                  .map((v) => BannerItem.fromJson(Map<String, dynamic>.from(v as Map)))
                  .toList();
            }
          }
        }

        if (newList.length > bannerList.length && bannerList.isNotEmpty) {
          try {
            final first = newList.first;
            NotificationService().showNotification(
              title: "🖼️ ${first.name ?? first.wishing ?? 'New Banner'}",
              body: first.wishing ?? "New banner update available.",
            );
            if (Get.isRegistered<NotificationController>()) {
              Get.find<NotificationController>().resetViewedStatus();
            }
          } catch (notifErr) {
            debugPrint("⚠️ [BANNERS] Notification failed: $notifErr");
          }
        }

        bannerList.assignAll(newList);
        bannerList.refresh();
        debugPrint("✅ [BANNERS] Successfully updated bannerList with ${bannerList.length} items.");
      } else {
        message.value = "Failed to load banners (${response.statusCode})";
      }
    } catch (e, stackTrace) {
      debugPrint("❌ [BANNERS] Error fetching banners: $e\n$stackTrace");
      message.value = "Something went wrong while fetching banners";
    } finally {
      isLoading.value = false;
    }
  }
}
