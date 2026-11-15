import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nes_joystick/component/toast.dart';
import 'package:nes_joystick/joystick/joystick_controller.dart';

class QRScannerController extends GetxController {
  final MobileScannerController scannerController = MobileScannerController();

  final RxBool isProcessing = false.obs;
  final RxBool isTorchOn = false.obs;
  final RxBool showInstruction = true.obs;

  Timer? instructionTimer;

  @override
  void onInit() {
    super.onInit();

    instructionTimer = Timer(const Duration(seconds: 10), () {
      showInstruction.value = false;
    });
  }

  Future<void> onDetect(
    BarcodeCapture capture,
    JoystickController joystickController,
  ) async {
    if (isProcessing.value) return;

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;

      if (rawValue == null || rawValue.trim().isEmpty) continue;

      isProcessing.value = true;

      try {
        final decoded = jsonDecode(rawValue.trim());

        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('QR code must contain valid JSON.');
        }

        final sessionId = decoded['sessionId'];

        if (sessionId is! String || sessionId.trim().isEmpty) {
          throw const FormatException(
            'Session ID is missing from the QR code.',
          );
        }

        await scannerController.stop();

        await joystickController.connectToSession(sessionId.trim());

        if (isClosed) return;

        Get.back();

        // Show success notification after closing the scanner screen.
        await Future.delayed(const Duration(milliseconds: 400));

        AppToast.success('Successfully connected to NESVERSE.');

        return;
      } catch (e) {
        if (isClosed) return;

        isProcessing.value = false;

        AppToast.error(e.toString().replaceFirst('Exception: ', ''));

        try {
          await scannerController.start();
        } catch (cameraError) {
          debugPrint('Camera restart failed: $cameraError');
        }

        return;
      }
    }
  }

  Future<void> toggleFlash() async {
    await scannerController.toggleTorch();
    isTorchOn.toggle();
  }

  @override
  void onClose() {
    instructionTimer?.cancel();
    scannerController.dispose();
    super.onClose();
  }
}
