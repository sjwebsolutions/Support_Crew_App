import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scupporo_crew_app/utils/constants/app_colors.dart';
import 'package:scupporo_crew_app/utils/token_manager.dart';
import 'package:scupporo_crew_app/view/screens/auth/login_screen.dart';
import 'package:scupporo_crew_app/view/screens/main_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _containerController;
  late Animation<Offset> _containerSlide;

  @override
  void initState() {
    super.initState();

    _updateSystemUI();
    _setupAnimation();
    _startAnimation();
    _startTimer();
  }

  void _updateSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.scaffoldBackground,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void _setupAnimation() {
    _containerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _containerSlide = Tween<Offset>(
      begin: const Offset(0, 2.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _containerController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  void _startAnimation() {
    _containerController.forward();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 3), () async {
      try {
        String? token = await TokenManager.getToken();

        if (!mounted) return;

        if (token != null && token.isNotEmpty) {
          Get.offAll(() => const MainScreen());
        } else {
          Get.offAll(() => const LoginScreen());
        }
      } catch (e) {
        if (!mounted) return;

        Get.offAll(() => const LoginScreen());
      }
    });
  }

  @override
  void dispose() {
    _containerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCEEFE),
      body: Stack(
        children: [


          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: AppColors.appBackgroundDecoration,
          ),


          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SlideTransition(
                      position: _containerSlide,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ==================================================
                            // GLASS LOGO CONTAINER
                            // ==================================================

                            Center(
                              child: Image.asset(
                                "assets/images/splash_logo.png",
                                width: 200,
                                height: 200,
                                fit: BoxFit.contain,
                                errorBuilder: (
                                    context,
                                    error,
                                    stackTrace,
                                    ) {
                                  return const Icon(
                                    Icons.school_rounded,
                                    size: 100,
                                    color: Colors.white,
                                  );
                                },
                              ),
                            ),



                            // ==================================================
                            // APP NAME
                            // ==================================================
                            Text(
                              "Smart AIG - Support Crew",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                color: AppColors.primaryColor,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Administrative Info Group",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.primaryColor,
                                letterSpacing: 5.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                      
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ============================================================
                // GLASS PROGRESS CONTAINER
                // ============================================================

                Padding(
                  padding: const EdgeInsets.only(
                    left: 70,
                    right: 70,
                    bottom: 55,
                  ),
                  child: Container(
                    height: 12,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.60),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: const LinearProgressIndicator(
                        color: AppColors.primaryColor,
                        backgroundColor: Colors.transparent,
                        minHeight: 5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}