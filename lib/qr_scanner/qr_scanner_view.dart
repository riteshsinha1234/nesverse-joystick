import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nes_joystick/component/colors.dart';
import 'package:nes_joystick/component/text.dart';
import 'package:nes_joystick/component/widget.dart';
import 'package:nes_joystick/joystick/joystick_controller.dart';
import 'package:nes_joystick/qr_scanner/qr_scanner_controller.dart';

class QRScannerView extends StatelessWidget {
  final JoystickController ctrl;

  QRScannerView({super.key, required this.ctrl});

  final QRScannerController controller = Get.put(QRScannerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: textPrimary,
        elevation: 0,
        title: customTxt('SCAN QR CODE', 16, textPrimary, FontWeight.bold),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  MobileScanner(
                    controller: controller.scannerController,
                    onDetect: (capture) {
                      controller.onDetect(capture, ctrl);
                    },
                  ),

                  // Dark overlay with transparent QR scanning area
                  IgnorePointer(
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        black.withValues(alpha: 0.55),
                        BlendMode.srcOut,
                      ),
                      child: Stack(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              backgroundBlendMode: BlendMode.dstOut,
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // QR scanning frame
                  IgnorePointer(
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryColor, width: 4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  // Scanning instruction - disappears after 10 seconds
                  Positioned(
                    bottom: 35,
                    left: 20,
                    right: 20,
                    child: Obx(
                      () => IgnorePointer(
                        child: AnimatedOpacity(
                          opacity: controller.showInstruction.value ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 600),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: surfaceColor.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: customParaTxt(
                              'Position the QR code inside the scanning frame.',
                              8,
                              textSecondary,
                              FontWeight.w500,
                              TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Processing indicator
                  Obx(
                    () => controller.isProcessing.value
                        ? Container(
                            color: black.withValues(alpha: 0.65),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: customButton(
                      50,
                      double.infinity,
                      surfaceColor,
                      borderLight,
                      8,
                      () => Get.back(),
                      customTxt(
                        'CANCEL SCANNING',
                        12,
                        textPrimary,
                        FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Flashlight button
                  Obx(
                    () => customButton(
                      50,
                      55,
                      controller.isTorchOn.value ? primaryColor : surfaceColor,
                      borderLight,
                      8,
                      controller.toggleFlash,
                      Icon(
                        controller.isTorchOn.value
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        color: textPrimary,
                        size: 23,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
