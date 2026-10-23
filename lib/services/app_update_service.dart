import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants/app_colors.dart';

class AppUpdateService {
  static final AppUpdateService _instance = AppUpdateService._internal();
  factory AppUpdateService() => _instance;
  AppUpdateService._internal();

  bool _hasChecked = false;

  /// Call this method on Dashboard init / post-frame callback
  Future<void> checkForUpdates(BuildContext context, {bool forceCheck = false}) async {
    // Only check once per session unless forceCheck is passed
    if (_hasChecked && !forceCheck) return;
    _hasChecked = true;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;
      final String packageName = packageInfo.packageName;

      debugPrint("Current Installed App Version: $currentVersion ($packageName)");

      String? storeVersion;
      String? storeUrl;

      // Check Store Version based on Platform
      if (Platform.isIOS) {
        final iosData = await _fetchIosStoreVersion(packageName);
        storeVersion = iosData['version'];
        storeUrl = iosData['url'] ?? "https://apps.apple.com/app/$packageName";
      } else if (Platform.isAndroid) {
        final androidData = await _fetchAndroidStoreVersion(packageName);
        storeVersion = androidData['version'];
        storeUrl = androidData['url'] ?? "https://play.google.com/store/apps/details?id=$packageName";
      }

      debugPrint("Store Version: $storeVersion, Store URL: $storeUrl");

      if (storeVersion != null && _isVersionGreater(storeVersion, currentVersion)) {
        if (context.mounted) {
          _showUpdateDialog(
            context: context,
            currentVersion: currentVersion,
            storeVersion: storeVersion,
            storeUrl: storeUrl ?? (Platform.isIOS
                ? "https://apps.apple.com/app/$packageName"
                : "https://play.google.com/store/apps/details?id=$packageName"),
          );
        }
      }
    } catch (e) {
      debugPrint("Error checking app updates: $e");
    }
  }

  /// Fetches App Store version details via iTunes lookup
  Future<Map<String, String?>> _fetchIosStoreVersion(String bundleId) async {
    try {
      final response = await http.get(
        Uri.parse("https://itunes.apple.com/lookup?bundleId=$bundleId"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['resultCount'] != null && data['resultCount'] > 0) {
          final result = data['results'][0];
          return {
            'version': result['version'] as String?,
            'url': result['trackViewUrl'] as String?,
          };
        }
      }
    } catch (e) {
      debugPrint("Error fetching iOS store version: $e");
    }
    return {'version': null, 'url': null};
  }

  /// Fetches Play Store version details
  Future<Map<String, String?>> _fetchAndroidStoreVersion(String packageName) async {
    try {
      final url = "https://play.google.com/store/apps/details?id=$packageName";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final body = response.body;
        final RegExp versionRegExp = RegExp(r'\[\[\["([0-9]+\.[0-9]+\.[0-9]+)"\]\]');
        final match = versionRegExp.firstMatch(body);
        if (match != null && match.groupCount >= 1) {
          return {
            'version': match.group(1),
            'url': url,
          };
        }
      }
    } catch (e) {
      debugPrint("Error fetching Android store version: $e");
    }
    return {
      'version': null,
      'url': "https://play.google.com/store/apps/details?id=$packageName",
    };
  }

  /// Compares version strings (e.g. "1.0.7" > "1.0.6")
  bool _isVersionGreater(String newVersion, String currentVersion) {
    try {
      final String cleanNew = newVersion.split(' ').first.trim();
      final String cleanCurrent = currentVersion.split(' ').first.trim();

      List<int> newParts = cleanNew.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      List<int> currentParts = cleanCurrent.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      int maxLength = newParts.length > currentParts.length ? newParts.length : currentParts.length;

      for (int i = 0; i < maxLength; i++) {
        int n = i < newParts.length ? newParts[i] : 0;
        int c = i < currentParts.length ? currentParts[i] : 0;

        if (n > c) return true;
        if (n < c) return false;
      }
    } catch (e) {
      debugPrint("Version parsing error: $e");
    }
    return false;
  }

  /// Displays the custom update dialog
  void _showUpdateDialog({
    required BuildContext context,
    required String currentVersion,
    required String storeVersion,
    required String storeUrl,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Icon Badge
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3949AB), Color(0xFF5C6BC0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3949AB).withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.system_update_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 18),

                // Title
                Text(
                  "New Update Available! 🚀",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Version Badges Row (Current Installed Version -> New Store Version)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                      ),
                      child: Text(
                        "Current: $currentVersion",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF86EFAC), width: 1),
                      ),
                      child: Text(
                        "New: $storeVersion",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Description
                Text(
                  "A new version of Scupporo Support Crew App is available on ${Platform.isIOS ? 'App Store' : 'Play Store'}. Please update to enjoy the latest features, enhancements, and performance improvements.",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Action Buttons Row
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Update Now Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          final Uri url = Uri.parse(storeUrl);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            debugPrint("Could not launch $storeUrl");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Update Now",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
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
        );
      },
    );
  }
}
