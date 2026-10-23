import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:scupporo_crew_app/model/banner_model.dart';
import 'package:scupporo_crew_app/utils/constants/app_colors.dart';
import 'package:scupporo_crew_app/view_model/get_x/banner_controller.dart';
import 'package:share_plus/share_plus.dart';

class BannersScreen extends StatelessWidget {
  const BannersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BannerController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "BANNERS",
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

            if (controller.bannerList.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => controller.fetchBanners(isRefresh: true),
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
                              color: const Color(0xFF3949AB).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.collections_outlined,
                              color: Color(0xFF3949AB),
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "NO BANNERS FOUND",
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
                                : "There are no active banners available right now.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => controller.fetchBanners(),
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
              onRefresh: () => controller.fetchBanners(isRefresh: true),
              color: AppColors.primaryColor,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                itemCount: controller.bannerList.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final banner = controller.bannerList[index];
                  return _buildBannerCard(context, banner);
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildBannerCard(BuildContext context, BannerItem banner) {
    final bool hasImage = banner.imageUrl != null &&
        banner.imageUrl!.trim().isNotEmpty &&
        banner.imageUrl != "null";

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
          // Banner Image Header
          if (hasImage)
            GestureDetector(
              onTap: () {
                final heroTag = 'banner_card_${banner.id}_${banner.imageUrl?.trim()}';
                openFullScreenBannerImage(
                  context,
                  banner.imageUrl?.trim(),
                  banner.name ?? banner.wishing,
                  description: (banner.wishing != null && banner.wishing != banner.name) ? banner.wishing : null,
                  dateInfo: banner.publishedAt,
                  heroTag: heroTag,
                  appBarTitle: "Banners Dashboard",
                );
              },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      banner.imageUrl!.trim(),
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
                          color: const Color(0xFFEDE7F6),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image_rounded, color: Color(0xFF3949AB), size: 36),
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
                // Category & Type Tags
                Row(
                  children: [
                    if (banner.category != null && banner.category!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE7F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          banner.category!.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF3949AB),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (banner.type != null && banner.type!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          banner.type!,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Name
                if (banner.name != null && banner.name!.isNotEmpty)
                  Text(
                    banner.name!,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),

                // Wishing / Description
                if (banner.wishing != null && banner.wishing!.isNotEmpty && banner.wishing != banner.name) ...[
                  const SizedBox(height: 4),
                  Text(
                    banner.wishing!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ],

                // Footer Info (Published date & Display Days)
                const SizedBox(height: 8),
                const Divider(color: Color(0xFFE2E8F0), height: 1),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (banner.publishedAt != null && banner.publishedAt!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(
                            banner.publishedAt!,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    if (banner.displayDays != null)
                      Text(
                        "${banner.displayDays} day(s) display",
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void openFullScreenBannerImage(
  BuildContext context,
  String? imageUrl,
  String? title, {
  String? description,
  String? dateInfo,
  String? heroTag,
  String? appBarTitle,
}) {
  Get.to(
    () => FullScreenImageViewer(
      imageUrl: imageUrl,
      title: title,
      description: description,
      dateInfo: dateInfo,
      heroTag: heroTag,
      appBarTitle: appBarTitle,
    ),
    transition: Transition.fade,
  );
}

class FullScreenImageViewer extends StatefulWidget {
  final String? imageUrl;
  final String? title;
  final String? description;
  final String? dateInfo;
  final String? heroTag;
  final String? appBarTitle;

  const FullScreenImageViewer({
    super.key,
    this.imageUrl,
    this.title,
    this.description,
    this.dateInfo,
    this.heroTag,
    this.appBarTitle,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final String heroTag = widget.heroTag ?? widget.imageUrl ?? 'preview_${DateTime.now().millisecondsSinceEpoch}';
    final bool hasValidImage = widget.imageUrl != null &&
        widget.imageUrl!.trim().isNotEmpty &&
        widget.imageUrl != "null" &&
        (widget.imageUrl!.startsWith("http://") || widget.imageUrl!.startsWith("https://"));

    final bool hasDetails = (widget.title != null && widget.title!.trim().isNotEmpty) ||
        (widget.description != null && widget.description!.trim().isNotEmpty) ||
        (widget.dateInfo != null && widget.dateInfo!.trim().isNotEmpty);

    final String displayAppBarTitle = widget.appBarTitle ?? widget.title ?? "Details";

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
        title: Text(
          displayAppBarTitle,
          style: GoogleFonts.poppins(
            color: const Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (hasValidImage)
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.55,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: InteractiveViewer(
                              panEnabled: true,
                              minScale: 0.5,
                              maxScale: 4.0,
                              child: Hero(
                                tag: heroTag,
                                child: Image.network(
                                  widget.imageUrl!.trim(),
                                  fit: BoxFit.contain,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(32.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const CircularProgressIndicator(
                                              color: AppColors.primaryColor,
                                            ),
                                            const SizedBox(height: 14),
                                            Text(
                                              "Loading image...",
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF0F172A),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) => Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.broken_image_rounded, color: Color(0xFF3949AB), size: 60),
                                        const SizedBox(height: 12),
                                        Text(
                                          "Failed to load image",
                                          style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      if (hasValidImage && hasDetails) const SizedBox(height: 14),

                      if (hasDetails)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E293B).withValues(alpha: 0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.title != null && widget.title!.trim().isNotEmpty) ...[
                                Text(
                                  widget.title!.trim(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 6),
                              ],
                              if (widget.description != null &&
                                  widget.description!.trim().isNotEmpty &&
                                  widget.description!.trim() != widget.title?.trim()) ...[
                                Text(
                                  widget.description!.trim(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: const Color(0xFF334155),
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (widget.dateInfo != null && widget.dateInfo!.trim().isNotEmpty) ...[
                                const Divider(color: Color(0xFFE2E8F0), height: 1),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded, size: 13, color: Color(0xFF64748B)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        widget.dateInfo!.trim(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF64748B),
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
                ),
              ),

              if (hasValidImage)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSharing
                          ? null
                          : () async {
                              setState(() {
                                _isSharing = true;
                              });
                              await shareBannerImage(
                                widget.imageUrl!.trim(),
                                widget.title ?? widget.description,
                              );
                              if (mounted) {
                                setState(() {
                                  _isSharing = false;
                                });
                              }
                            },
                      icon: _isSharing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.share_rounded, size: 20),
                      label: Text(
                        _isSharing ? "Sharing..." : "Share Image",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: Colors.black12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> shareBannerImage(String imageUrl, String? name) async {
  try {
    debugPrint("📤 [SHARE BANNER] Preparing to share banner image URL: $imageUrl");

    Get.snackbar(
      "Success",
      "Preparing image for sharing...",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );

    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final fileName = 'banner_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);

      debugPrint("📤 [SHARE BANNER] Image downloaded and saved locally at: ${file.path}");

      final xFile = XFile(file.path);
      await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          text: name != null && name.isNotEmpty ? name : "Check out this banner!",
        ),
      );
      debugPrint("📤 [SHARE BANNER] Share dialog opened successfully.");
    } else {
      debugPrint("❌ [SHARE BANNER] Failed to download image. Status Code: ${response.statusCode}");
      Get.snackbar(
        "Error",
        "Unable to download image. Please try again.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  } catch (e, stackTrace) {
    debugPrint("❌ [SHARE BANNER] Exception occurred while sharing: $e\n$stackTrace");
    Get.snackbar(
      "Error",
      "Something went wrong. Please try again.",
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFD32F2F),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }
}
