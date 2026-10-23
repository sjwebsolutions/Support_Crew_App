import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scupporo_crew_app/model/announcement_model.dart';
import 'package:scupporo_crew_app/services/announcement_service.dart';
import 'package:scupporo_crew_app/services/notification_service.dart';
import 'package:scupporo_crew_app/view_model/get_x/notification_controller.dart';

class AnnouncementController extends GetxController {
  final AnnouncementService _announcementService = AnnouncementService();

  var isLoading = false.obs;
  var announcementList = <AnnouncementItem>[].obs;
  var message = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements({bool isRefresh = false}) async {
    try {
      if (!isRefresh && announcementList.isEmpty) {
        isLoading.value = true;
      }
      message.value = "";

      final response = await _announcementService.getAnnouncements();
      debugPrint("📩 [ANNOUNCEMENTS] Status Code: ${response.statusCode}, Body: ${response.body}");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final dynamic decoded = jsonDecode(response.body);
        List<AnnouncementItem> newList = [];

        if (decoded is List) {
          newList = decoded
              .map((v) => AnnouncementItem.fromJson(Map<String, dynamic>.from(v as Map)))
              .toList();
        } else if (decoded is Map) {
          final Map<String, dynamic> map = Map<String, dynamic>.from(decoded);
          final bool isApiSuccess = map['success'] == true ||
              map['status'] == true ||
              map['success']?.toString().toLowerCase() == "true" ||
              map['status']?.toString().toLowerCase() == "true" ||
              map['status']?.toString().toLowerCase() == "success" ||
              map['data'] != null ||
              map['announcements'] != null;

          if (isApiSuccess) {
            final rawData = map['data'] ?? map['announcements'] ?? map['result'];
            if (rawData is List) {
              newList = rawData
                  .map((v) => AnnouncementItem.fromJson(Map<String, dynamic>.from(v as Map)))
                  .toList();
            } else if (rawData is Map && rawData['announcements'] != null && rawData['announcements'] is List) {
              newList = (rawData['announcements'] as List)
                  .map((v) => AnnouncementItem.fromJson(Map<String, dynamic>.from(v as Map)))
                  .toList();
            }
          }
        }

        if (newList.length > announcementList.length && announcementList.isNotEmpty) {
          try {
            final first = newList.first;
            NotificationService().showNotification(
              title: "📢 ${first.title ?? 'New Announcement'}",
              body: first.description ?? "You have a new announcement.",
            );
            if (Get.isRegistered<NotificationController>()) {
              Get.find<NotificationController>().resetViewedStatus();
            }
          } catch (notifErr) {
            debugPrint("⚠️ [ANNOUNCEMENTS] Notification failed: $notifErr");
          }
        }

        announcementList.assignAll(newList);
        announcementList.refresh();
        debugPrint("✅ [ANNOUNCEMENTS] Successfully updated announcementList with ${announcementList.length} items.");
      } else {
        message.value = "Failed to load announcements (${response.statusCode})";
      }
    } catch (e, stackTrace) {
      debugPrint("❌ [ANNOUNCEMENTS] Error fetching announcements: $e\n$stackTrace");
      message.value = "Something went wrong while fetching announcements";
    } finally {
      isLoading.value = false;
    }
  }
}
