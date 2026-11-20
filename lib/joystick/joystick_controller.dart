import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nes_joystick/network/controller_service.dart';

class JoystickController extends GetxController {
  final Rx<Offset> joystickPosition = Offset.zero.obs;
  final RxSet<String> pressedButtons = <String>{}.obs;
  final RxList<String> actionButtonOrder = ['Y', 'B', 'X', 'A'].obs;

  // P1 and P2 visibility
  final RxBool showP1 = true.obs;
  final RxBool showP2 = true.obs;

  // Supabase connection state
  final RxBool networkConnected = false.obs;
  final RxBool isConnecting = false.obs;
  final RxString connectionError = ''.obs;

  final ControllerService _controllerService = ControllerService.instance;

  // Turbo button mapping
  // X = Turbo Jump (A)
  // Y = Turbo Attack (B)
  static const Map<String, String> _turboButtonMap = {'X': 'A', 'Y': 'B'};

  // Combination button mapping
  // P1 = A + B
  // P2 = X + Y
  static const Map<String, List<String>> _comboButtonMap = {
    'P1': ['A', 'B'],
    'P2': ['X', 'Y'],
  };

  // Turbo timing
  static const Duration _turboPressDuration = Duration(milliseconds: 50);
  static const Duration _turboReleaseDuration = Duration(milliseconds: 50);

  // Track active turbo buttons and their timers
  final Set<String> _activeTurboButtons = {};
  final Map<String, Timer> _turboTimers = {};

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
    await _releaseAllPressedButtons();

    await _controllerService.disconnect();

    networkConnected.value = false;
    connectionError.value = '';
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

  // Button press
  void pressButton(String button) {
    if (!pressedButtons.add(button)) return;

    // Combination buttons
    final comboButtons = _comboButtonMap[button];

    if (comboButtons != null) {
      for (final comboButton in comboButtons) {
        pressButton(comboButton);
      }
      return;
    }

    // Turbo buttons
    if (_turboButtonMap.containsKey(button)) {
      _startTurboButton(button);
      return;
    }

    // Normal button press
    unawaited(_controllerService.sendButton(button: button, pressed: true));
  }

  // Button release
  void releaseButton(String button) {
    if (!pressedButtons.remove(button)) return;

    // Combination buttons
    final comboButtons = _comboButtonMap[button];

    if (comboButtons != null) {
      for (final comboButton in comboButtons) {
        releaseButton(comboButton);
      }
      return;
    }

    // Turbo buttons
    if (_turboButtonMap.containsKey(button)) {
      unawaited(_stopTurboButton(button));
      return;
    }

    // Normal button release
    unawaited(_controllerService.sendButton(button: button, pressed: false));
  }

  // Start turbo
  void _startTurboButton(String turboButton) {
    if (!_activeTurboButtons.add(turboButton)) return;

    final targetButton = _turboButtonMap[turboButton]!;

    unawaited(_runTurboCycle(turboButton, targetButton));
  }

  // Repeated press/release cycle
  Future<void> _runTurboCycle(String turboButton, String targetButton) async {
    if (!_activeTurboButtons.contains(turboButton)) return;

    await _controllerService.sendButton(button: targetButton, pressed: true);

    if (!_activeTurboButtons.contains(turboButton)) {
      await _controllerService.sendButton(button: targetButton, pressed: false);
      return;
    }

    await Future.delayed(_turboPressDuration);

    await _controllerService.sendButton(button: targetButton, pressed: false);

    if (!_activeTurboButtons.contains(turboButton)) return;

    _turboTimers[turboButton] = Timer(_turboReleaseDuration, () {
      _turboTimers.remove(turboButton);

      unawaited(_runTurboCycle(turboButton, targetButton));
    });
  }

  // Stop one turbo button
  Future<void> _stopTurboButton(String turboButton) async {
    _activeTurboButtons.remove(turboButton);

    _turboTimers.remove(turboButton)?.cancel();

    final targetButton = _turboButtonMap[turboButton];

    if (targetButton != null) {
      await _controllerService.sendButton(button: targetButton, pressed: false);
    }
  }

  // Release every currently pressed button
  Future<void> _releaseAllPressedButtons() async {
    final buttons = pressedButtons.toList();

    for (final button in buttons) {
      releaseButton(button);
    }

    // Ensure all turbo buttons are stopped
    await _stopAllTurboButtons();

    pressedButtons.clear();
  }

  // Stop all turbo buttons
  Future<void> _stopAllTurboButtons() async {
    final activeButtons = _activeTurboButtons.toList();

    for (final button in activeButtons) {
      await _stopTurboButton(button);
    }
  }

  // Swap A and B positions
  void swapActionButtons() {
    final aIndex = actionButtonOrder.indexOf('A');
    final bIndex = actionButtonOrder.indexOf('B');

    actionButtonOrder[aIndex] = 'B';
    actionButtonOrder[bIndex] = 'A';
  }

  // Rotate action buttons
  void rotateActionButtons() {
    final first = actionButtonOrder.removeAt(0);
    actionButtonOrder.add(first);
  }

  // Reset action button positions
  void resetActionButtons() {
    actionButtonOrder.assignAll(['Y', 'B', 'X', 'A']);
    showP1.value = true;
    showP2.value = true;
  }

  // Toggle P1 visibility
  void toggleP1Visibility() {
    showP1.value = !showP1.value;
  }

  // Toggle P2 visibility
  void toggleP2Visibility() {
    showP2.value = !showP2.value;
  }

  // Reset P1 and P2 visibility
  void resetExtraButtonVisibility() {
    showP1.value = true;
    showP2.value = true;
  }

  bool isButtonPressed(String button) {
    return pressedButtons.contains(button);
  }

  @override
  void onClose() {
    // Cancel all scheduled turbo timers
    for (final timer in _turboTimers.values) {
      timer.cancel();
    }

    _turboTimers.clear();
    _activeTurboButtons.clear();

    // Release mapped game buttons
    for (final targetButton in _turboButtonMap.values) {
      unawaited(
        _controllerService.sendButton(button: targetButton, pressed: false),
      );
    }

    // Release normal combination buttons
    unawaited(_controllerService.sendButton(button: 'A', pressed: false));

    unawaited(_controllerService.sendButton(button: 'B', pressed: false));

    super.onClose();
  }
}
