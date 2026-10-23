import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:scupporo_crew_app/services/app_update_service.dart';
import 'package:scupporo_crew_app/utils/constants/app_colors.dart';
import 'package:scupporo_crew_app/utils/token_manager.dart';
import 'package:scupporo_crew_app/view/screens/auth/login_screen.dart';
import 'package:scupporo_crew_app/view_model/get_x/dashboard_controller.dart';
import 'package:scupporo_crew_app/view_model/get_x/support_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String _appVersion = "1.0.6";

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = info.version;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<DashboardController>();

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Center(
                child: Text(
                  "SETTING",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                final crew = dashboardController.dashboardData.value?.supportCrew;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSettingCard(
                        icon: Icons.phone_android_outlined,
                        title: "Registered Mobile",
                        subtitle: crew?.whatsappNumber ?? "9999999999",
                        onTap: () {},
                      ),
                      const SizedBox(height: 10),

                      _buildSettingCard(
                        icon: Icons.info_outline,
                        title: "App Version",
                        subtitle: "Tap to check for updates",
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE7F6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _appVersion,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        onTap: () {
                          AppUpdateService().checkForUpdates(context, forceCheck: true);
                        },
                      ),
                      const SizedBox(height: 10),

                      _buildSettingCard(
                        icon: Icons.alternate_email,
                        title: "Privacy Policy",
                        onTap: () => _showPolicyDialog(context, "Privacy Policy"),
                      ),
                      const SizedBox(height: 10),

                      _buildSettingCard(
                        icon: Icons.assignment_outlined,
                        title: "Terms of Use",
                        onTap: () => _showPolicyDialog(context, "Terms of Use"),
                      ),
                      const SizedBox(height: 10),

                      _buildSettingCard(
                        icon: Icons.headset_mic_outlined,
                        title: "Contact Support",
                        onTap: () => _showSupportDialog(context),
                      ),
                      const SizedBox(height: 10),

                      _buildSettingCard(
                        icon: Icons.logout,
                        iconColor: const Color(0xFFEF4444),
                        title: "Logout",
                        titleColor: const Color(0xFFEF4444),
                        subtitle: "Sign out from this device",
                        onTap: () => _showLogoutDialog(context),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    final Color effectiveIconColor = iconColor ?? AppColors.primaryColor;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: effectiveIconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: effectiveIconColor, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: titleColor ?? const Color(0xFF0F172A),
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              )
            : null,
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: Color(0xFF94A3B8)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout, color: Colors.red, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  "Confirm Logout",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E232C),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Are you sure you want to logout from the app?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(
                            color: Colors.black45,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await TokenManager.clearToken();
                          Get.offAll(() => const LoginScreen());
                          Get.snackbar(
                            "Logged Out",
                            "Successfully signed out from your account",
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Logout",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPolicyDialog(BuildContext context, String title) {
    final supportController = Get.find<SupportController>();
    supportController.fetchPolicies();

    Get.dialog(
      Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black45),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const Divider(),
                Flexible(
                  child: SingleChildScrollView(
                    child: Obx(() {
                      if (supportController.isPolicyLoading.value) {
                        return const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final data = supportController.policyData.value;
                      if (data == null) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text("No policy content available"),
                        );
                      }

                      String htmlContent = title == "Privacy Policy"
                          ? data.privacyPolicy ?? ""
                          : data.termsOfUse ?? "";

                      return HtmlWidget(
                        htmlContent,
                        textStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Got it", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    final supportController = Get.put(SupportController());
    supportController.fetchSupportSettings();

    Get.dialog(
      Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            child: Obx(() {
              if (supportController.isLoading.value) {
                return const SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final data = supportController.supportData.value;
              if (data == null) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("No support data available"),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Get.back(),
                      child: const Text("Close"),
                    )
                  ],
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.headset_mic, color: AppColors.primaryColor, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data.name ?? "Support",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E232C),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSupportCard(
                    icon: Icons.phone,
                    label: "Call Us",
                    value: data.mobile ?? "N/A",
                    color: Colors.blue,
                    onTap: () => _launchURL("tel:${data.mobile}"),
                  ),
                  const SizedBox(height: 10),
                  _buildSupportCard(
                    icon: FontAwesomeIcons.whatsapp,
                    label: "WhatsApp",
                    value: data.whatsapp ?? "N/A",
                    color: Colors.green,
                    onTap: () {
                      String phone = data.whatsapp?.replaceAll(RegExp(r'[^0-9]'), '') ?? "";
                      _launchURL("https://wa.me/$phone");
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildSupportCard(
                    icon: Icons.email,
                    label: "Email",
                    value: data.email ?? "N/A",
                    color: Colors.orange,
                    onTap: () => _launchURL("mailto:${data.email}"),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Close",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildSupportCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E232C),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new, size: 14, color: color.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        "Error",
        "Could not launch $url",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}
