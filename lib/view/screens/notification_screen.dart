import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scupporo_crew_app/model/announcement_model.dart';
import 'package:scupporo_crew_app/model/banner_model.dart';
import 'package:scupporo_crew_app/utils/constants/app_colors.dart';
import 'package:scupporo_crew_app/view_model/get_x/announcement_controller.dart';
import 'package:scupporo_crew_app/view_model/get_x/banner_controller.dart';
import 'package:scupporo_crew_app/view_model/get_x/notification_controller.dart';

enum NotificationType { banner, announcement }

class NotificationItemData {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final NotificationType notificationType;
  final DateTime dateTime;
  final String formattedTimeOrDate;

  NotificationItemData({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.notificationType,
    required this.dateTime,
    required this.formattedTimeOrDate,
  });
}

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final announcementController = Get.put(AnnouncementController());
    final bannerController = Get.put(BannerController());
    final notificationController = Get.put(NotificationController());

    // Mark notifications as viewed when screen opens
    notificationController.markAsViewed();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "NOTIFICATIONS",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 15),
              onPressed: () => Get.back(),
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Obx(() {
            final bool isLoading =
                announcementController.isLoading.value || bannerController.isLoading.value;

            if (isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              );
            }

            final List<NotificationItemData> notifications = _buildNotificationList(
              announcementController.announcementList,
              bannerController.bannerList,
            );

            if (notifications.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    announcementController.fetchAnnouncements(isRefresh: true),
                    bannerController.fetchBanners(isRefresh: true),
                  ]);
                },
                color: AppColors.primaryColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E293B).withValues(alpha: 0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_off_rounded,
                              color: AppColors.primaryColor,
                              size: 42,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No Notifications Yet",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "You are all caught up! New notifications and updates will appear here.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFF64748B),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 42,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await Future.wait([
                                  announcementController.fetchAnnouncements(isRefresh: true),
                                  bannerController.fetchBanners(isRefresh: true),
                                ]);
                              },
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: Text(
                                "Refresh",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            final bool isRead = notificationController.isViewed.value;

            return RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  announcementController.fetchAnnouncements(isRefresh: true),
                  bannerController.fetchBanners(isRefresh: true),
                ]);
              },
              color: AppColors.primaryColor,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                itemCount: notifications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return _buildNotificationCard(context, item, isRead);
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationItemData item,
    bool isRead,
  ) {
    final bool isBanner = item.notificationType == NotificationType.banner;
    final bool hasValidImage = item.imageUrl != null &&
        item.imageUrl!.trim().isNotEmpty &&
        item.imageUrl != "null" &&
        (item.imageUrl!.startsWith("http://") || item.imageUrl!.startsWith("https://"));

    final IconData typeIcon = isBanner ? Icons.view_carousel_rounded : Icons.campaign_rounded;
    final Color iconColor = isBanner ? AppColors.primaryColor : const Color(0xFFE64A19);
    final Color iconBgColor = isBanner ? const Color(0xFFEDE7F6) : const Color(0xFFFFEDEA);
    final Color iconBorderColor = isBanner ? const Color(0xFFD1C4E9) : const Color(0xFFFFDCD6);

    final String typeName = isBanner ? "BANNER" : "ANNOUNCEMENT";
    final Color tagBgColor = isBanner ? const Color(0xFFEDE7F6) : const Color(0xFFFFEDEA);
    final Color tagTextColor = isBanner ? const Color(0xFF3949AB) : const Color(0xFFE64A19);

    // Status Dot Color: Green if View/Read, Red if Unread/Not Viewed
    final Color dotColor = isRead ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Icon Container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: iconBorderColor, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: hasValidImage
                    ? Image.network(
                        item.imageUrl!.trim(),
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          typeIcon,
                          color: iconColor,
                          size: 24,
                        ),
                      )
                    : Icon(
                        typeIcon,
                        color: iconColor,
                        size: 24,
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Content Column (Tag, Title, Desc, Time, Dot)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Type Tag Name & Read/Unread Status Dot
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: tagBgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          typeName,
                          style: GoogleFonts.poppins(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: tagTextColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            item.formattedTimeOrDate,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Title
                  Text(
                    item.title,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Description if present
                  if (item.description != null && item.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      item.description!.trim(),
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: const Color(0xFF475569),
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<NotificationItemData> _buildNotificationList(
    List<AnnouncementItem> announcements,
    List<BannerItem> banners,
  ) {
    final List<NotificationItemData> list = [];

    // Process Announcements
    for (int i = 0; i < announcements.length; i++) {
      final a = announcements[i];
      final String id = 'announcement_${a.id ?? i}';
      final String title = a.title ?? "Announcement";
      final String? desc = a.description;
      final String? img = a.imageUrl;

      DateTime dt = DateTime.now();
      if (a.fromDate != null && a.fromDate!.trim().isNotEmpty) {
        final parsed = DateTime.tryParse(a.fromDate!.trim());
        if (parsed != null) dt = parsed;
      }

      final timeStr = _formatNotificationTime(dt, a.fromDate, a.fromTime);

      list.add(
        NotificationItemData(
          id: id,
          title: title,
          description: desc,
          imageUrl: img,
          notificationType: NotificationType.announcement,
          dateTime: dt,
          formattedTimeOrDate: timeStr,
        ),
      );
    }

    // Process Banners
    for (int i = 0; i < banners.length; i++) {
      final b = banners[i];
      final String id = 'banner_${b.id ?? i}';
      final String title = b.name ?? b.wishing ?? "Banner";
      final String? desc = (b.wishing != null && b.wishing != b.name) ? b.wishing : null;
      final String? img = b.imageUrl;

      DateTime dt = DateTime.now();
      if (b.publishedAt != null && b.publishedAt!.trim().isNotEmpty) {
        final parsed = DateTime.tryParse(b.publishedAt!.trim());
        if (parsed != null) dt = parsed;
      }

      final timeStr = _formatNotificationTime(dt, b.publishedAt, null);

      list.add(
        NotificationItemData(
          id: id,
          title: title,
          description: desc,
          imageUrl: img,
          notificationType: NotificationType.banner,
          dateTime: dt,
          formattedTimeOrDate: timeStr,
        ),
      );
    }

    // Sort by DateTime descending
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return list;
  }

  String _formatNotificationTime(DateTime dt, String? rawDateStr, String? rawTimeStr) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inDays < 1 && now.day == dt.day && now.month == dt.month && now.year == dt.year) {
      if (rawTimeStr != null && rawTimeStr.trim().isNotEmpty && rawTimeStr != "null") {
        return rawTimeStr.trim();
      }
      final int hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final String minute = dt.minute < 10 ? '0${dt.minute}' : '${dt.minute}';
      final String period = dt.hour >= 12 ? 'PM' : 'AM';
      return "$hour:$minute $period";
    } else {
      if (rawDateStr != null && rawDateStr.trim().isNotEmpty && rawDateStr != "null") {
        return rawDateStr.trim();
      }
      final List<String> months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
    }
  }
}
