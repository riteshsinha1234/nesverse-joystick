import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JoystickController extends GetxController {
  // Analog joystick state
  final Rx<Offset> joystickPosition = Offset.zero.obs;

  // Control and action button states
  final RxSet<String> pressedButtons = <String>{}.obs;

  final RxBool vibrationEnabled = false.obs;

  void toggleVibration() {
    vibrationEnabled.toggle();
  }

  // Bluetooth UI state
  final RxBool bluetoothEnabled = false.obs;

  void toggleBluetooth() {
    bluetoothEnabled.toggle();
  }

  // Update analog joystick position
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

    joystickPosition.value = Offset(offset.dx / radius, offset.dy / radius);
  }

  // Reset analog joystick
  void resetJoystick() {
    joystickPosition.value = Offset.zero;
  }

  // Press a control or action button
  void pressButton(String button) {
    pressedButtons.add(button);
  }

  // Release a control or action button
  void releaseButton(String button) {
    pressedButtons.remove(button);
  }

  // Check whether a button is currently pressed
  bool isButtonPressed(String button) {
    return pressedButtons.contains(button);
  }
}
