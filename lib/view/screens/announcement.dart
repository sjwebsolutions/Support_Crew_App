import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scupporo_crew_app/model/announcement_model.dart';
import 'package:scupporo_crew_app/utils/constants/app_colors.dart';
import 'package:scupporo_crew_app/view/screens/banners.dart';
import 'package:scupporo_crew_app/view_model/get_x/announcement_controller.dart';

class AnnouncementScreen extends StatelessWidget {
  const AnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnnouncementController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "ANNOUNCEMENTS",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
            fontSize: 20,
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
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              );
            }

            if (controller.announcementList.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => controller.fetchAnnouncements(isRefresh: true),
                color: AppColors.primaryColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE64A19).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.campaign_rounded,
                              color: Color(0xFFE64A19),
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "NO ANNOUNCEMENTS",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.message.value.isNotEmpty
                                ? controller.message.value
                                : "Stay tuned! Important updates will appear here.",
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => controller.fetchAnnouncements(),
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: Text(
                                "Refresh",
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
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

            return RefreshIndicator(
              onRefresh: () => controller.fetchAnnouncements(isRefresh: true),
              color: AppColors.primaryColor,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                itemCount: controller.announcementList.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final announcement = controller.announcementList[index];
                  return _buildAnnouncementCard(context, announcement);
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(BuildContext context, AnnouncementItem item) {
    final bool hasImage = item.imageUrl != null &&
        item.imageUrl!.trim().isNotEmpty &&
        item.imageUrl != "null";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Header
          if (hasImage)
            GestureDetector(
              onTap: () {
                final heroTag = 'announcement_card_${item.id}_${item.imageUrl?.trim()}';
                openFullScreenBannerImage(
                  context,
                  item.imageUrl?.trim(),
                  item.title,
                  description: item.description,
                  dateInfo: _buildDateString(item),
                  heroTag: heroTag,
                  appBarTitle: "Announcements Dashboard",
                );
              },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      item.imageUrl!.trim(),
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.fill,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 160,
                          color: const Color(0xFFF8FAFC),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 140,
                        width: double.infinity,
                        color: const Color(0xFFFBE9E7),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image_rounded, color: Color(0xFFE64A19), size: 36),
                            SizedBox(height: 4),
                            Text("Failed to load image", style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fullscreen_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type Tag & Created By
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (item.type != null && item.type!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBE9E7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.type!.toUpperCase(),
                            softWrap: true,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFE64A19),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      if (item.createdBy != null && item.createdBy!.isNotEmpty)
                        Text(
                          "By: ${item.createdBy!}",
                          softWrap: true,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Title
                if (item.title != null && item.title!.isNotEmpty)
                  Text(
                    item.title!,
                    softWrap: true,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),

                // Description
                if (item.description != null && item.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    softWrap: true,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ],

                // Dates info
                if ((item.fromDate != null && item.fromDate!.isNotEmpty) ||
                    (item.toDate != null && item.toDate!.isNotEmpty)) ...[
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFFE2E8F0), height: 1),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.date_range_rounded, size: 12, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _buildDateString(item),
                          softWrap: true,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildDateString(AnnouncementItem item) {
    if (item.fromDate != null && item.toDate != null) {
      return "${item.fromDate} to ${item.toDate}";
    } else if (item.fromDate != null) {
      return "From: ${item.fromDate}";
    } else if (item.toDate != null) {
      return "Until: ${item.toDate}";
    }
    return "";
  }
}
