import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nes_joystick/network/controller_service.dart';

class JoystickController extends GetxController {
  final Rx<Offset> joystickPosition = Offset.zero.obs;
  final RxSet<String> pressedButtons = <String>{}.obs;

  final RxBool vibrationEnabled = false.obs;

  // Supabase connection state
  final RxBool networkConnected = false.obs;
  final RxBool isConnecting = false.obs;
  final RxString connectionError = ''.obs;

  final ControllerService _controllerService = ControllerService.instance;

  Future<void> connectToSession(String sessionId) async {
    isConnecting.value = true;
    connectionError.value = '';

    try {
      await _controllerService.connect(sessionId);

      networkConnected.value = _controllerService.isConnected;
    } catch (e) {
      networkConnected.value = false;
      connectionError.value = e.toString();
      rethrow;
    } finally {
      isConnecting.value = false;
    }
  }

  Future<void> disconnectFromSession() async {
    await _controllerService.disconnect();

    networkConnected.value = false;
    connectionError.value = '';
  }

  void toggleVibration() {
    vibrationEnabled.toggle();
  }

  // Analog joystick movement
  void updateJoystickPosition(Offset localPosition, double size) {
    final center = Offset(size / 2, size / 2);
    final radius = size * 0.25;

    Offset offset = localPosition - center;
    final distance = offset.distance;

    if (distance > radius) {
      offset = Offset(
        offset.dx / distance * radius,
        offset.dy / distance * radius,
      );
    }

    final normalizedPosition = Offset(offset.dx / radius, offset.dy / radius);

    joystickPosition.value = normalizedPosition;

    unawaited(
      _controllerService.sendJoystick(
        x: normalizedPosition.dx,
        y: normalizedPosition.dy,
      ),
    );
  }

  void resetJoystick() {
    joystickPosition.value = Offset.zero;

    unawaited(_controllerService.sendJoystick(x: 0, y: 0));
  }

  void pressButton(String button) {
    if (pressedButtons.add(button)) {
      unawaited(_controllerService.sendButton(button: button, pressed: true));
    }
  }

  void releaseButton(String button) {
    if (pressedButtons.remove(button)) {
      unawaited(_controllerService.sendButton(button: button, pressed: false));
    }
  }

  bool isButtonPressed(String button) {
    return pressedButtons.contains(button);
  }
}
