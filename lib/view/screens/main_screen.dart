import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:scupporo_crew_app/view/screens/dashboard.dart';
import 'package:scupporo_crew_app/view/screens/setting_screen.dart';
import 'package:scupporo_crew_app/view_model/get_x/dashboard_controller.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    Dashboard(),
    SettingScreen(),
  ];

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xFFD7E5FD),
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    final Widget navBar = Padding(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        bottom: isIOS ? 25 : 0,
        top: 10,
      ),
      child: Container(
        height: isIOS ? 70 : 60,
        decoration: const BoxDecoration(
          color: Color(0xFF233263),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildNavItem(
              icon: Icons.dashboard,
              activeIcon: Icons.dashboard,
              label: "Dashboard",
              index: 0,
            ),
            _buildNavItem(
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings,
              label: "Setting",
              index: 1,
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFD7E5FD),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: isIOS ? navBar : SafeArea(child: navBar),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (_selectedIndex != index) {
            setState(() {
              _selectedIndex = index;
            });
            if (index == 0 && Get.isRegistered<DashboardController>()) {
              Get.find<DashboardController>().fetchDashboardData(isRefresh: true);
            }
          } else if (index == 0 && Get.isRegistered<DashboardController>()) {
            Get.find<DashboardController>().fetchDashboardData(isRefresh: true);
          }
        },
        splashColor: const Color(0xFFD7E5FD),
        highlightColor: const Color(0xFFD7E5FD),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 24,
              color: isSelected ? Colors.white: Colors.white54,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}