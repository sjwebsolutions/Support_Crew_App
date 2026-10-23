import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scupporo_crew_app/model/announcement_model.dart';
import 'package:scupporo_crew_app/model/banner_model.dart';
import 'package:scupporo_crew_app/model/dashboard_model.dart';
import 'package:scupporo_crew_app/services/app_update_service.dart';
import 'package:scupporo_crew_app/utils/constants/app_colors.dart';
import 'package:scupporo_crew_app/view/screens/banners.dart';
import 'package:scupporo_crew_app/view/screens/notification_screen.dart';
import 'package:scupporo_crew_app/view/widgets/modules.dart';
import 'package:scupporo_crew_app/view_model/get_x/announcement_controller.dart';
import 'package:scupporo_crew_app/view_model/get_x/attendance_controller.dart';
import 'package:scupporo_crew_app/view_model/get_x/banner_controller.dart';
import 'package:scupporo_crew_app/view_model/get_x/dashboard_controller.dart';
import 'package:scupporo_crew_app/view_model/get_x/notification_controller.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _profileCardKey = GlobalKey();
  final GlobalKey _attendanceCardKey = GlobalKey();
  final GlobalKey _modulesCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdateService().checkForUpdates(context);
    });
  }

  void _scrollToKey(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    final attendanceController = Get.put(AttendanceController());
    final bannerController = Get.put(BannerController());
    final announcementController = Get.put(AnnouncementController());
    final notificationController = Get.put(NotificationController());

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      drawerEnableOpenDragGesture: false,
      drawer: Obx(() => _buildDashboardDrawer(
        controller.dashboardData.value,
        attendanceController,
      )),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Top App Bar / Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Row(
                  children: [
                    // Menu Icon Button
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.menu_rounded,
                        color: Color(0xFF0F172A),
                        size: 28,
                      ),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "DASHBOARD",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                     
                          ),
                        ),
                      ),
                    ),
                    Obx(() {
                      final int totalCount = announcementController.announcementList.length +
                          bannerController.bannerList.length;

                      final int unreadCount = notificationController.isViewed.value ? 0 : totalCount;

                      return IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: unreadCount > 0
                            ? Badge(
                                label: Text(
                                  '$unreadCount',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: const Color(0xFFDC2626),
                                child: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: Color(0xFF0F172A),
                                  size: 26,
                                ),
                              )
                            : const Icon(
                                Icons.notifications_none_rounded,
                                color: Color(0xFF0F172A),
                                size: 26,
                              ),
                        onPressed: () {
                          notificationController.markAsViewed();
                          Get.to(() => const NotificationScreen());
                        },
                      );
                    }),
                  ],
                ),
              ),

              // Main Content Area Bounded by Expanded
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryColor),
                    );
                  }

                  final data = controller.dashboardData.value;
                  if (data == null) {
                    final bool isOffline = controller.isNetworkError.value;
                    final String titleText = isOffline
                        ? "No Internet Connection"
                        : "Unable to Load Data";
                    final String subTitleText = controller.message.value.isNotEmpty
                        ? controller.message.value
                        : (isOffline
                            ? "Please check your mobile data or Wi-Fi connection and try again."
                            : "Could not retrieve dashboard information. Please try again.");

                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E293B).withValues(alpha: 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isOffline
                                      ? const Color(0xFFFEE2E2)
                                      : AppColors.primaryColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isOffline
                                      ? Icons.wifi_off_rounded
                                      : Icons.cloud_off_rounded,
                                  color: isOffline
                                      ? const Color(0xFFDC2626)
                                      : AppColors.primaryColor,
                                  size: 34,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                titleText,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                subTitleText,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              if (isOffline) ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.info_outline_rounded,
                                        size: 18,
                                        color: Color(0xFF475569),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "Turn on Mobile Data or Wi-Fi to load dashboard.",
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF475569),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                height: 38,
                                child: ElevatedButton.icon(
                                  onPressed: () => controller.fetchDashboardData(),
                                  icon: const Icon(Icons.refresh_rounded, size: 20),
                                  label: Text(
                                    "Retry",
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
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await Future.wait([
                        controller.fetchDashboardData(isRefresh: true),
                        bannerController.fetchBanners(isRefresh: true),
                        announcementController.fetchAnnouncements(isRefresh: true),
                      ]);
                    },
                    color: AppColors.primaryColor,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width > 600 ? 24.0 : 12.0,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 2),

                              // Banners Box Section directly above Profile Card
                              Obx(() {
                                final banners = bannerController.bannerList.toList();
                                if (banners.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: DashboardBannerSection(
                                    key: ValueKey('banners_${banners.length}_${banners.map((e) => e.id ?? '').join('_')}'),
                                    banners: banners,
                                  ),
                                );
                              }),

                              // Announcements Box Section directly below Banners Card
                              Obx(() {
                                final announcements = announcementController.announcementList.toList();
                                if (announcements.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: DashboardAnnouncementSection(
                                    key: ValueKey('announcements_${announcements.length}_${announcements.map((e) => e.id ?? '').join('_')}'),
                                    announcements: announcements,
                                  ),
                                );
                              }),

                              // Unified Profile & School Card
                              KeyedSubtree(
                                key: _profileCardKey,
                                child: _buildProfileHeader(data),
                              ),
                              const SizedBox(height: 10),

                              // Attendance Status Card
                              KeyedSubtree(
                                key: _attendanceCardKey,
                                child: _buildAttendanceStatusCard(
                                  context: context,
                                  attendance: data.attendanceToday,
                                  todayInfo: data.todayInfo,
                                  attendanceController: attendanceController,
                                ),
                              ),
                              const SizedBox(height: 10),

                              KeyedSubtree(
                                key: _modulesCardKey,
                                child: const ModulesWidget(),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                  
                  
                  
                  
                  
                  
                  
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardDrawer(
    DashboardData? data,
    AttendanceController attendanceController,
  ) {
    final liveAttendance = attendanceController.attendanceData.value;
    final statusStr = (data?.attendanceToday?.status ?? liveAttendance?.status)?.toString().capitalizeFirst ?? "Not Yet Marked";

    final thumbnail = data?.supportCrew?.thumbnail;
    final bool hasValidImage = thumbnail != null &&
        thumbnail.trim().isNotEmpty &&
        thumbnail != "null" &&
        (thumbnail.startsWith("http://") || thumbnail.startsWith("https://"));

    return Drawer(
      backgroundColor: const Color(0xFFD7E5FD),
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // List of Cards with Live Data Summary
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  children: [
                    _buildDrawerCardTile(
                      titleWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              data?.supportCrew?.name ?? 'User',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Image.asset(
                            'assets/images/blue_tick.png',
                            width: 15,
                            height: 15,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.verified,
                              color: Color(0xFF1DA1F2),
                              size: 15,
                            ),
                          ),
                        ],
                      ),
                      subtitle: "ID: ${data?.supportCrew?.teacherUniqueId ?? 'N/A'}",
                      customLeading: Container(
                        width: 42,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: hasValidImage
                              ? Image.network(
                                  thumbnail.trim(),
                                  width: 42,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: const Color(0xFFEDE7F6),
                                    child: const Icon(Icons.person, color: AppColors.primaryColor, size: 22),
                                  ),
                                )
                              : Container(
                                  color: const Color(0xFFEDE7F6),
                                  child: const Icon(Icons.person, color: AppColors.primaryColor, size: 22),
                                ),
                        ),
                      ),
                      onTap: () {
                        Get.back();
                        _scrollToKey(_profileCardKey);
                      },
                    ),
                    const SizedBox(height: 10),

                    _buildDrawerCardTile(
                      title: "Attendance Status Card",
                      subtitle: "Today's Status: $statusStr",
                      icon: Icons.access_time_filled_rounded,
                      iconColor: const Color(0xFF16A34A),
                      bgColor: const Color(0xFFDCFCE7),
                      onTap: () {
                        Get.back();
                        _scrollToKey(_attendanceCardKey);
                      },
                    ),
                    const SizedBox(height: 10),

                    _buildDrawerCardTile(
                      title: "Notice & Communication",
                      subtitle: "Announcements & Banners",
                      icon: Icons.campaign_rounded,
                      iconColor: const Color(0xFF0891B2),
                      bgColor: const Color(0xFFECFEFF),
                      onTap: () {
                        Get.back();
                        _scrollToKey(_modulesCardKey);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerCardTile({
    String? title,
    Widget? titleWidget,
    required String subtitle,
    IconData? icon,
    Color? iconColor,
    Color? bgColor,
    Widget? customLeading,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: customLeading ??
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor ?? const Color(0xFFEDE7F6),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor ?? AppColors.primaryColor, size: 22),
            ),
        title: titleWidget ??
            Text(
              title ?? '',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: const Color(0xFF64748B),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
      ),
    );
  }

  Widget _buildAttendanceStatusCard({
    required BuildContext context,
    required AttendanceToday? attendance,
    required TodayInfo? todayInfo,
    required AttendanceController attendanceController,
  }) {
    final liveAttendance = attendanceController.attendanceData.value;

    final rawClockIn = attendance?.clockIn ?? liveAttendance?.clockIn;
    final rawClockOut = attendance?.clockOut ?? liveAttendance?.clockOut;

    final String? clockInTime = (rawClockIn != null &&
            rawClockIn.trim().isNotEmpty &&
            rawClockIn != "null" &&
            rawClockIn != "--:--")
        ? rawClockIn.trim()
        : null;

    final String? clockOutTime = (rawClockOut != null &&
            rawClockOut.trim().isNotEmpty &&
            rawClockOut != "null" &&
            rawClockOut != "--:--")
        ? rawClockOut.trim()
        : null;

    final statusStr = (attendance?.status ?? liveAttendance?.status)?.toString().toLowerCase();
    final labelText = attendance?.label;

    final bool isClockedIn = clockInTime != null && clockInTime.isNotEmpty;
    final bool isClockedOut = clockOutOut(clockOutTime);

    String label = "Not Yet Marked";
    Color statusBgColor = const Color(0xFFFEF3C7);
    Color statusTextColor = const Color(0xFFD97706);
    IconData statusIcon = Icons.info_outline_rounded;

    if (isClockedIn) {
      if (statusStr == "present") {
        label = "Present";
        statusBgColor = const Color(0xFFDCFCE7);
        statusTextColor = const Color(0xFF16A34A);
        statusIcon = Icons.check_circle_outline_rounded;
      } else if (statusStr == "absent") {
        label = "Absent";
        statusBgColor = const Color(0xFFFEE2E2);
        statusTextColor = const Color(0xFFDC2626);
        statusIcon = Icons.cancel_outlined;
      } else if (labelText != null && labelText.isNotEmpty) {
        label = labelText;
        statusBgColor = const Color(0xFFEDE7F6);
        statusTextColor = const Color(0xFF3949AB);
        statusIcon = Icons.event_available_rounded;
      } else if (statusStr != null && statusStr.isNotEmpty) {
        label = statusStr.capitalizeFirst ?? statusStr;
        statusBgColor = const Color(0xFFEDE7F6);
        statusTextColor = const Color(0xFF3949AB);
        statusIcon = Icons.event_available_rounded;
      } else {
        label = "Present";
        statusBgColor = const Color(0xFFDCFCE7);
        statusTextColor = const Color(0xFF16A34A);
        statusIcon = Icons.check_circle_outline_rounded;
      }
    } else {
      label = "Not Yet Marked";
      statusBgColor = const Color(0xFFFEF3C7);
      statusTextColor = const Color(0xFFD97706);
      statusIcon = Icons.info_outline_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(12),
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
          // Attendance, Date & Status Header Inside Card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE7F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.how_to_reg_rounded,
                        color: AppColors.primaryColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        "SCAN ATTENDANCE",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusTextColor.withValues(alpha: 0.25), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusTextColor, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        color: statusTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Color(0xFFE2E8F0), height: 1, thickness: 1),
          ),

          // Dual Pill Buttons Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // CLOCK IN BUTTON
                Expanded(
                  child: _buildClockPillButton(
                    title: "CLOCK IN",
                    time: clockInTime,
                    isEnabled: !isClockedIn,
                    isCompleted: isClockedIn,
                    icon: Icons.qr_code_scanner_rounded,
                    activeBgColor: const Color(0xFFDCFCE7),
                    activeTextColor: const Color(0xFF15803D),
                    activeIconColor: const Color(0xFF15803D),
                    disabledBgColor: const Color(0xFFF0FDF4),
                    disabledTextColor: const Color(0xFF16A34A),
                    disabledIconColor: const Color(0xFF16A34A),
                    onTap: () {
                      attendanceController.scanAndMarkAttendance(
                        context: context,
                        actionType: "Clock In",
                      );
                    },
                  ),
                ),

                const SizedBox(width: 8),

                // CLOCK OUT BUTTON
                Expanded(
                  child: _buildClockPillButton(
                    title: "CLOCK OUT",
                    time: clockOutTime,
                    isEnabled: isClockedIn && !isClockedOut,
                    isCompleted: isClockedOut,
                    icon: Icons.qr_code_scanner_rounded,
                    activeBgColor: const Color(0xFFFEE2E2),
                    activeTextColor: const Color(0xFFDC2626),
                    activeIconColor: const Color(0xFFDC2626),
                    disabledBgColor: const Color(0xFFFEF2F2),
                    disabledTextColor: const Color(0xFFFCA5A5),
                    disabledIconColor: const Color(0xFFFCA5A5),
                    onTap: () {
                      attendanceController.scanAndMarkAttendance(
                        context: context,
                        actionType: "Clock Out",
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          if (attendanceController.currentLatitude.value != null &&
              attendanceController.currentLongitude.value != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Center(
                child: Text(
                  "Last Location: ${attendanceController.currentLatitude.value!.toStringAsFixed(5)}, ${attendanceController.currentLongitude.value!.toStringAsFixed(5)}",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF94A3B8),
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool clockOutOut(String? time) {
    return time != null &&
        time.trim().isNotEmpty &&
        time != "null" &&
        time != "--:--";
  }

  Widget _buildClockPillButton({
    required String title,
    required String? time,
    required bool isEnabled,
    required bool isCompleted,
    required IconData icon,
    required Color activeBgColor,
    required Color activeTextColor,
    required Color activeIconColor,
    required Color disabledBgColor,
    required Color disabledTextColor,
    required Color disabledIconColor,
    required VoidCallback onTap,
  }) {
    final bool hasTime = isCompleted &&
        time != null &&
        time.trim().isNotEmpty &&
        time != "null" &&
        time != "--:--";
    final String formattedTime = _formatTime(time);

    final Color bgColor = isCompleted
        ? activeBgColor
        : (isEnabled ? activeBgColor : disabledBgColor);

    final Color textColor = isCompleted
        ? activeTextColor
        : (isEnabled ? activeTextColor : disabledTextColor);

    final Color iconColor = isCompleted
        ? activeIconColor
        : (isEnabled ? activeIconColor : disabledIconColor);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(6),
        splashColor: isEnabled ? activeTextColor.withValues(alpha: 0.15) : Colors.transparent,
        highlightColor: isEnabled ? activeTextColor.withValues(alpha: 0.08) : Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle_rounded : icon,
                    color: iconColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: textColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (hasTime) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    formattedTime,
                    style: GoogleFonts.poppins(
                      color: textColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.trim().isEmpty || dateTimeStr == "null") {
      return "--:--";
    }
    final raw = dateTimeStr.trim();

    final upper = raw.toUpperCase();
    if (upper.contains("AM") || upper.contains("PM")) {
      return upper;
    }

    try {
      DateTime dt = DateTime.parse(raw.contains('T') ? raw : raw.replaceAll(' ', 'T'));
      if (raw.endsWith('Z') || raw.contains('+') || dt.isUtc) {
        dt = dt.toLocal();
      }
      int hour = dt.hour;
      final int minute = dt.minute;
      final String period = hour >= 12 ? "PM" : "AM";
      hour = hour % 12;
      if (hour == 0) hour = 12;
      final String hourStr = hour < 10 ? "0$hour" : "$hour";
      final String minStr = minute < 10 ? "0$minute" : "$minute";
      return "$hourStr:$minStr $period";
    } catch (_) {}

    try {
      final parts = raw.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0].trim());
        int minute = int.parse(parts[1].trim());
        final String period = hour >= 12 ? "PM" : "AM";
        hour = hour % 12;
        if (hour == 0) hour = 12;
        final String hourStr = hour < 10 ? "0$hour" : "$hour";
        final String minStr = minute < 10 ? "0$minute" : "$minute";
        return "$hourStr:$minStr $period";
      }
    } catch (_) {}

    return raw;
  }

  Widget _buildProfileHeader(DashboardData data) {
    final thumbnail = data.supportCrew?.thumbnail;
    final bool hasValidImage = thumbnail != null &&
        thumbnail.trim().isNotEmpty &&
        thumbnail != "null" &&
        (thumbnail.startsWith("http://") || thumbnail.startsWith("https://"));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(12),
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
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.5),
                  child: hasValidImage
                      ? Image.network(
                          thumbnail.trim(),
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFFEDE7F6),
                            child: const Icon(Icons.person, color: AppColors.primaryColor, size: 26),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFEDE7F6),
                          child: const Icon(Icons.person, color: AppColors.primaryColor, size: 26),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            data.supportCrew?.name ?? "User",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF0F172A),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Image.asset(
                          'assets/images/blue_tick.png',
                          width: 18,
                          height: 18,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.verified,
                            color: Color(0xFF1DA1F2),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      "ID: ${data.supportCrew?.teacherUniqueId ?? "N/A"}",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Color(0xFFE2E8F0), height: 1, thickness: 1),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.school_rounded, color: AppColors.primaryColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "School Name",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF64748B),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            data.school?.schoolName ?? "N/A",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF0F172A),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Image.asset(
                          'assets/images/blue_tick.png',
                          width: 15,
                          height: 15,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.verified,
                            color: Color(0xFF1DA1F2),
                            size: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardBannerSection extends StatelessWidget {
  final List<BannerItem> banners;
  const DashboardBannerSection({super.key, required this.banners});

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final double outerSize = (screenWidth * 0.20).clamp(76.0, 92.0);
    final double avatarRadius = (outerSize - 8) / 2;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(12),
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE7F6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.view_carousel_rounded,
                      color: AppColors.primaryColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Banners",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${banners.length}",
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // CircleAvatar Row for Banners
          SizedBox(
            height: outerSize + 4,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: banners.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final banner = banners[index];
                final thumbnail = banner.imageUrl;
                final bool hasValidImage = thumbnail != null &&
                    thumbnail.trim().isNotEmpty &&
                    thumbnail != "null" &&
                    (thumbnail.startsWith("http://") || thumbnail.startsWith("https://"));

                final heroTag = 'dashboard_banner_${banner.id ?? index}_${thumbnail?.trim()}';

                return GestureDetector(
                  onTap: () {
                    final String title = banner.name ?? banner.wishing ?? "Banner";
                    final String? desc = (banner.wishing != null && banner.wishing != banner.name) ? banner.wishing : null;
                    final String? date = banner.publishedAt;

                    openFullScreenBannerImage(
                      context,
                      thumbnail?.trim(),
                      title,
                      description: desc,
                      dateInfo: date,
                      heroTag: heroTag,
                      appBarTitle: "BANNERS",
                    );
                  },
                  child: Container(
                    width: outerSize,
                    height: outerSize,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryColor, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(1.5),
                      child: Hero(
                        tag: heroTag,
                        child: CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: const Color(0xFFEDE7F6),
                          backgroundImage: hasValidImage
                              ? NetworkImage(thumbnail.trim())
                              : null,
                          child: !hasValidImage
                              ? const Icon(
                                  Icons.view_carousel_rounded,
                                  color: AppColors.primaryColor,
                                  size: 28,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardAnnouncementSection extends StatelessWidget {
  final List<AnnouncementItem> announcements;
  const DashboardAnnouncementSection({super.key, required this.announcements});

  @override
  Widget build(BuildContext context) {
    if (announcements.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final double outerSize = (screenWidth * 0.20).clamp(76.0, 92.0);
    final double avatarRadius = (outerSize - 8) / 2;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(12),
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEDEA),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.campaign_rounded,
                      color: Color(0xFFE64A19),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Announcements",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDEA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${announcements.length}",
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE64A19),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // CircleAvatar Row for Announcements
          SizedBox(
            height: outerSize + 4,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: announcements.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = announcements[index];
                final thumbnail = item.imageUrl;
                final bool hasValidImage = thumbnail != null &&
                    thumbnail.trim().isNotEmpty &&
                    thumbnail != "null" &&
                    (thumbnail.startsWith("http://") || thumbnail.startsWith("https://"));

                final heroTag = 'dashboard_announcement_${item.id ?? index}_${thumbnail?.trim()}';

                return GestureDetector(
                  onTap: () {
                    final String title = item.title ?? "Announcement";
                    final String? desc = item.description;
                    String? date;
                    if (item.fromDate != null && item.fromDate!.isNotEmpty) {
                      date = "${item.fromDate ?? ''} ${item.fromTime ?? ''}".trim();
                    }

                    openFullScreenBannerImage(
                      context,
                      thumbnail?.trim(),
                      title,
                      description: desc,
                      dateInfo: date,
                      heroTag: heroTag,
                      appBarTitle: "ANNOUNCEMENTS",
                    );
                  },
                  child: Container(
                    width: outerSize,
                    height: outerSize,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF97316), Color(0xFFFB923C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF97316).withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(1.5),
                      child: Hero(
                        tag: heroTag,
                        child: CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: const Color(0xFFFFEDEA),
                          backgroundImage: hasValidImage
                              ? NetworkImage(thumbnail.trim())
                              : null,
                          child: !hasValidImage
                              ? const Icon(
                                  Icons.campaign_rounded,
                                  color: Color(0xFFE64A19),
                                  size: 28,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
