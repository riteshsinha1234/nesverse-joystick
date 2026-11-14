//screen size
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nes_joystick/component/analog_joystick.dart';
import 'package:nes_joystick/component/colors.dart';
import 'package:nes_joystick/component/text.dart';
import 'package:nes_joystick/joystick/joystick_controller.dart';

SizedBox gapH(double value) => SizedBox(height: value);
SizedBox gapW(double value) => SizedBox(width: value);
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

//Buttons
MaterialButton customButton(
  double ht,
  double wt,
  Color btnclr,
  Color bdrclr,
  double rdus,
  VoidCallback clk,
  Widget widget,
) {
  return MaterialButton(
    highlightColor: black,
    elevation: 0.0,
    height: ht,
    minWidth: wt,
    color: btnclr,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(rdus),
      side: BorderSide(color: bdrclr),
    ),
    onPressed: clk,
    child: widget,
  );
}

// Game header
Widget gameHeader(JoystickController ctrl) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    child: Row(
      children: [
        const Icon(Icons.gamepad_rounded, color: primaryColor, size: 28),
        gapW(8),
        customSpTxt('NES JOYSTICK', 18, textPrimary, FontWeight.bold),
        const Spacer(),

        // Bluetooth status
        Obx(() {
          final isBluetoothOn = ctrl.bluetoothEnabled.value;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderLight),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  color: isBluetoothOn ? successColor : textMuted,
                  size: 8,
                ),
                gapW(8),
                customSpTxt(
                  isBluetoothOn ? 'BLUETOOTH ON' : 'BLUETOOTH OFF',
                  10,
                  textSecondary,
                  FontWeight.bold,
                ),
              ],
            ),
          );
        }),

        gapW(10),

        // Settings dropdown
        PopupMenuButton<String>(
          color: surfaceColor,
          icon: const Icon(
            Icons.settings_rounded,
            color: textSecondary,
            size: 23,
          ),
          onSelected: (value) {
            if (value == 'bluetooth') {
              ctrl.toggleBluetooth();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'bluetooth',
              child: Obx(() {
                final isBluetoothOn = ctrl.bluetoothEnabled.value;

                return Row(
                  children: [
                    Icon(
                      Icons.bluetooth,
                      color: isBluetoothOn ? primaryColor : textSecondary,
                      size: 20,
                    ),
                    gapW(10),
                    customTxt('Bluetooth', 14, textPrimary, FontWeight.w600),
                    const Spacer(),
                    Icon(
                      isBluetoothOn ? Icons.toggle_on : Icons.toggle_off,
                      color: isBluetoothOn ? successColor : textMuted,
                      size: 28,
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ],
    ),
  );
}

// Main controller area
Widget controllerPad(BuildContext context, JoystickController ctrl) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        width: screenWidth(context),
        decoration: BoxDecoration(
          color: surfaceColor.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Expanded(child: _buildJoystickSection(ctrl)),
            Expanded(child: _buildCenterSection(ctrl)),
            Expanded(child: _buildRightSection(ctrl)),
          ],
        ),
      ),
    ),
  );
}

// Left joystick section
Widget _buildJoystickSection(JoystickController ctrl) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      customSpTxt('MOVEMENT', 10, textMuted, FontWeight.bold),
      gapH(15),
      AnalogJoystick(controller: ctrl, size: 160, activeColor: primaryColor),
    ],
  );
}

// Center controls - Select, Start and Vibration
Widget _buildCenterSection(JoystickController ctrl) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      customSpTxt('CONTROLS', 10, textMuted, FontWeight.bold),
      gapH(18),
      Obx(() {
        final bool isVibrationOn = ctrl.vibrationEnabled.value;

        return customButton(
          32,
          115,
          isVibrationOn ? successColor : controlButtonColor,
          isVibrationOn ? successColor : borderLight,
          18,
          ctrl.toggleVibration,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.vibration_rounded, color: textPrimary, size: 15),
              gapW(6),
              customSpTxt(
                isVibrationOn ? 'Analog ON' : 'Analog OFF',
                8,
                textPrimary,
                FontWeight.bold,
              ),
            ],
          ),
        );
      }),
      gapH(10),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          customButton(
            32,
            65,
            controlButtonColor,
            borderLight,
            18,
            () => ctrl.pressButton('SELECT'),
            customSpTxt('SELECT', 9, textPrimary, FontWeight.bold),
          ),
          gapW(8),
          customButton(
            32,
            65,
            controlButtonColor,
            borderLight,
            18,
            () => ctrl.pressButton('START'),
            customSpTxt('START', 9, textPrimary, FontWeight.bold),
          ),
        ],
      ),
    ],
  );
}

// Right action buttons
Widget _buildRightSection(JoystickController ctrl) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      customSpTxt('ACTION', 10, textMuted, FontWeight.bold),
      gapH(18),

      // Top button - X
      customButton(
        50,
        50,
        actionBlue,
        borderLight,
        50,
        () => ctrl.pressButton('X'),
        customSpTxt('X', 20, white, FontWeight.w900),
      ),

      gapH(8),

      // Middle buttons - Y and A
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          customButton(
            50,
            50,
            actionGreen,
            borderLight,
            50,
            () => ctrl.pressButton('Y'),
            customSpTxt('Y', 20, white, FontWeight.w900),
          ),
          gapW(65),
          customButton(
            50,
            50,
            actionOrange,
            borderLight,
            50,
            () => ctrl.pressButton('A'),
            customSpTxt('A', 20, white, FontWeight.w900),
          ),
        ],
      ),

      gapH(8),

      // Bottom button - B
      customButton(
        50,
        50,
        actionRed,
        borderLight,
        50,
        () => ctrl.pressButton('B'),
        customSpTxt('B', 20, white, FontWeight.w900),
      ),
    ],
  );
}
