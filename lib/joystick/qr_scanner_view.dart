import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nes_joystick/component/colors.dart';
import 'package:nes_joystick/joystick/joystick_controller.dart';

class QRScannerView extends StatefulWidget {
  final JoystickController ctrl;

  const QRScannerView({super.key, required this.ctrl});

  @override
  State<QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  final MobileScannerController scannerController = MobileScannerController();

  bool isProcessing = false;

  Future<void> onDetect(BarcodeCapture capture) async {
    if (isProcessing) return;

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;

      if (rawValue == null || rawValue.isEmpty) continue;

      isProcessing = true;

      try {
        final decoded = jsonDecode(rawValue);

        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Invalid QR code format.');
        }

        final sessionId = decoded['sessionId'];

        if (sessionId is! String || sessionId.trim().isEmpty) {
          throw const FormatException('Session ID is missing.');
        }

        await scannerController.stop();

        await widget.ctrl.connectToSession(sessionId.trim());

        if (!mounted) return;

        Get.back();

        Get.snackbar(
          'Connected',
          'Successfully connected to NESVERSE.',
          backgroundColor: successColor,
          colorText: white,
          snackPosition: SnackPosition.BOTTOM,
        );

        return;
      } catch (e) {
        if (!mounted) return;

        isProcessing = false;

        Get.snackbar(
          'Pairing failed',
          e.toString(),
          backgroundColor: actionRed,
          colorText: white,
          snackPosition: SnackPosition.BOTTOM,
        );

        await scannerController.start();
        return;
      }
    }
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: textPrimary,
        title: const Text(
          'SCAN QR CODE',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  controller: scannerController,
                  onDetect: onDetect,
                ),

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

                Positioned(
                  bottom: 35,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Position the NESVERSE QR code '
                      'inside the scanning frame.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () => scannerController.toggleTorch(),
                  icon: const Icon(
                    Icons.flash_on_rounded,
                    color: textPrimary,
                    size: 28,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(
                      color: textSecondary,
                      fontWeight: FontWeight.bold,
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
