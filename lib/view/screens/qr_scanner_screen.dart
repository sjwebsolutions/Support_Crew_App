import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scupporo_crew_app/utils/constants/app_colors.dart';

class QRScannerScreen extends StatefulWidget {
  final String title;
  final String actionType;
  final Future<void> Function(String scannedCode)? onScanned;

  const QRScannerScreen({
    super.key,
    this.title = "CLOCK IN SCAN",
    this.actionType = "Clock In",
    this.onScanned,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  late AnimationController _animController;
  late Animation<double> _anim;
  bool _isProcessing = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    for (final barcode in capture.barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        setState(() {
          _isProcessing = true;
        });
        debugPrint("📷 [QR DETECTED]: $code");

        if (widget.onScanned != null) {
          try {
            await widget.onScanned!(code);
          } catch (e) {
            debugPrint("❌ Error in onScanned: $e");
          }
        } else {
          await Future.delayed(const Duration(milliseconds: 500));
        }

        if (mounted) {
          Navigator.of(context).pop(code);
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: AppColors.appBackgroundDecoration,
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // Top Bar Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Center(
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF1E293B),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Scanner Box Container
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        height: 300,
                        constraints: const BoxConstraints(
                          maxWidth: 330,
                          maxHeight: 300,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.16),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // 1. Camera Viewfinder
                              MobileScanner(
                                controller: _controller,
                                onDetect: _onDetect,
                              ),

                              // 2. Animated Overlay with Corner Brackets & Laser Line
                              AnimatedBuilder(
                                animation: _anim,
                                builder: (context, child) {
                                  return CustomPaint(
                                    painter: _ScannerOverlayPainter(
                                      scanProgress: _anim.value,
                                      cornerColor: const Color(0xFF10B981),
                                    ),
                                  );
                                },
                              ),

                              // 3. Top-Right Floating Torch Button
                              Positioned(
                                top: 12,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () async {
                                    await _controller.toggleTorch();
                                    setState(() {
                                      _isTorchOn = !_isTorchOn;
                                    });
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFF59E0B)
                                              .withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _isTorchOn
                                          ? Icons.flash_on_rounded
                                          : Icons.flash_off_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),

                              // 4. Bottom Floating Pill Badge
                              Positioned(
                                bottom: 12,
                                left: 14,
                                right: 14,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F1E28)
                                          .withValues(alpha: 0.88),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFF10B981)
                                            .withValues(alpha: 0.35),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.25),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF10B981),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0xFF10B981),
                                                blurRadius: 5,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Align ${widget.actionType} QR in Frame",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bottom Red Cancel Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 330),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _isProcessing ? null : () => Get.back(),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: Text(
                              "Cancel",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Processing Overlay Loader when QR Code is scanned
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.75),
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 44,
                        height: 44,
                        child: CircularProgressIndicator(
                          strokeWidth: 3.5,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        "${widget.actionType}...",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Please wait...",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final double scanProgress;
  final Color cornerColor;

  _ScannerOverlayPainter({
    required this.scanProgress,
    this.cornerColor = const Color(0xFF10B981),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scanSize = min(size.width, size.height) * 0.60;
    final Rect scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 10),
      width: scanSize,
      height: scanSize,
    );

    // 1. Semi-transparent overlay outside scan reticle
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final scanPath = Path()
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(18)));
    final overlayPath =
        Path.combine(PathOperation.difference, backgroundPath, scanPath);

    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.42);
    canvas.drawPath(overlayPath, overlayPaint);

    // 2. Corner Brackets
    final cornerPaint = Paint()
      ..color = cornerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    const double cornerRadius = 16;
    const double cornerLength = 26;

    // Top-Left Corner
    final tlPath = Path()
      ..moveTo(scanRect.left, scanRect.top + cornerLength)
      ..lineTo(scanRect.left, scanRect.top + cornerRadius)
      ..arcToPoint(
        Offset(scanRect.left + cornerRadius, scanRect.top),
        radius: const Radius.circular(cornerRadius),
      )
      ..lineTo(scanRect.left + cornerLength, scanRect.top);
    canvas.drawPath(tlPath, cornerPaint);

    // Top-Right Corner
    final trPath = Path()
      ..moveTo(scanRect.right - cornerLength, scanRect.top)
      ..lineTo(scanRect.right - cornerRadius, scanRect.top)
      ..arcToPoint(
        Offset(scanRect.right, scanRect.top + cornerRadius),
        radius: const Radius.circular(cornerRadius),
      )
      ..lineTo(scanRect.right - cornerLength, scanRect.top);
    canvas.drawPath(trPath, cornerPaint);

    // Bottom-Left Corner
    final blPath = Path()
      ..moveTo(scanRect.left, scanRect.bottom - cornerLength)
      ..lineTo(scanRect.left, scanRect.bottom - cornerRadius)
      ..arcToPoint(
        Offset(scanRect.left + cornerRadius, scanRect.bottom),
        radius: const Radius.circular(cornerRadius),
      )
      ..lineTo(scanRect.left + cornerLength, scanRect.bottom);
    canvas.drawPath(blPath, cornerPaint);

    // Bottom-Right Corner
    final brPath = Path()
      ..moveTo(scanRect.right - cornerLength, scanRect.bottom)
      ..lineTo(scanRect.right - cornerRadius, scanRect.bottom)
      ..arcToPoint(
        Offset(scanRect.right, scanRect.bottom - cornerRadius),
        radius: const Radius.circular(cornerRadius),
      )
      ..lineTo(scanRect.right - cornerLength, scanRect.bottom);
    canvas.drawPath(brPath, cornerPaint);

    // 3. Laser scan line
    final double laserY = scanRect.top + (scanRect.height * scanProgress);

    // Laser glow gradient
    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          cornerColor.withValues(alpha: 0.0),
          cornerColor.withValues(alpha: 0.35),
          cornerColor.withValues(alpha: 0.0),
        ],
      ).createShader(
          Rect.fromLTWH(scanRect.left, laserY - 8, scanRect.width, 16));
    canvas.drawRect(
      Rect.fromLTWH(
          scanRect.left + 4, laserY - 8, scanRect.width - 8, 16),
      glowPaint,
    );

    // Main sharp laser line
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          cornerColor.withValues(alpha: 0.15),
          cornerColor,
          cornerColor.withValues(alpha: 0.15),
        ],
      ).createShader(Rect.fromLTWH(scanRect.left, laserY, scanRect.width, 2.5))
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(scanRect.left + 8, laserY),
      Offset(scanRect.right - 8, laserY),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanProgress != scanProgress;
  }
}
