import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scupporo_crew_app/view/screens/announcement.dart';
import 'package:scupporo_crew_app/view/screens/banners.dart';

class ModulesWidget extends StatelessWidget {
  const ModulesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    int crossAxisCount = 3;
    double childAspectRatio = 1.15;
    double cardPaddingH = 10;
    double cardPaddingV = 12;

    if (screenWidth > 900 || (isLandscape && screenWidth > 700)) {
      crossAxisCount = 5;
      childAspectRatio = 1.25;
      cardPaddingH = 16;
      cardPaddingV = 16;
    } else if (screenWidth > 600 || isLandscape) {
      crossAxisCount = 4;
      childAspectRatio = 1.2;
      cardPaddingH = 14;
      cardPaddingV = 14;
    } else if (screenWidth < 350) {
      crossAxisCount = 3;
      childAspectRatio = 1.0;
      cardPaddingH = 8;
      cardPaddingV = 10;
    }

    final categories = [
      {
        'title': 'NOTICE & COMMUNICATION',
        'icon': Icons.campaign_outlined,
        'headerIconBg': const Color(0xFFECFEFF),
        'headerIconColor': const Color(0xFF0891B2),
        'items': [
          {
            'title': 'Announcements',
            'icon': Icons.campaign_rounded,
            'iconColor': const Color(0xFF0891B2),
            'iconCircleBg': const Color(0xFFCFFAFE),
            'tileBg': const Color(0xFFECFEFF),
            'onTap': () => Get.to(() => const AnnouncementScreen()),
          },
          {
            'title': 'Banners',
            'icon': Icons.collections_outlined,
            'iconColor': const Color(0xFFE11D48),
            'iconCircleBg': const Color(0xFFFECDD3),
            'tileBg': const Color(0xFFFFF1F2),
            'onTap': () => Get.to(() => const BannersScreen()),
          },
        ],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories.map((category) {
        final items = category['items'] as List<Map<String, dynamic>>;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.symmetric(
            horizontal: cardPaddingH,
            vertical: cardPaddingV,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E293B).withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: category['headerIconBg'] as Color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        category['icon'] as IconData,
                        color: category['headerIconColor'] as Color,
                        size: screenWidth < 350 ? 18 : 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        category['title'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth < 350 ? 12 : 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Modules Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: screenWidth < 350 ? 6 : 8,
                  mainAxisSpacing: screenWidth < 350 ? 6 : 8,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildModuleCard(
                    context: context,
                    title: item['title'] as String,
                    icon: item['icon'] as IconData,
                    iconColor: item['iconColor'] as Color,
                    iconCircleBg: item['iconCircleBg'] as Color,
                    tileBg: item['tileBg'] as Color,
                    onTap: item['onTap'] as VoidCallback,
                    badgeCount: item['badgeCount'] as int?,
                  );
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModuleCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconCircleBg,
    required Color tileBg,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final textScale = mediaQuery.textScaler.scale(1.0);
    final isSmallScreen = screenWidth < 350;

    final double iconSize = isSmallScreen ? 18 : 20;
    final double iconPadding = isSmallScreen ? 6 : 7;
    final double fontSize = (isSmallScreen ? 9.5 : 10.5) / (textScale > 1.2 ? 1.1 : 1.0);

    return Container(
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: iconColor.withValues(alpha: 0.15),
          highlightColor: iconColor.withValues(alpha: 0.08),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? 4 : 6,
              horizontal: 4,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: EdgeInsets.all(iconPadding),
                      decoration: BoxDecoration(
                        color: iconCircleBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: iconSize,
                      ),
                    ),
                    if (badgeCount != null && badgeCount > 0)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 15,
                            minHeight: 15,
                          ),
                          child: Text(
                            '$badgeCount',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 3 : 4),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    height: 1.15,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
