import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nes_joystick/component/analog_joystick.dart';
import 'package:nes_joystick/component/colors.dart';
import 'package:nes_joystick/component/text.dart';
import 'package:nes_joystick/joystick/joystick_controller.dart';
import 'package:nes_joystick/qr_scanner/qr_scanner_view.dart';

// Screen size
SizedBox gapH(double value) => SizedBox(height: value);
SizedBox gapW(double value) => SizedBox(width: value);

double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

// Normal button
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

// Hold button - Press and Release
Widget customHoldButton(
  double ht,
  double wt,
  Color btnclr,
  Color bdrclr,
  double rdus,
  String button,
  JoystickController ctrl,
  Widget widget,
) {
  return Listener(
    behavior: HitTestBehavior.opaque,
    onPointerDown: (_) => ctrl.pressButton(button),
    onPointerUp: (_) => ctrl.releaseButton(button),
    onPointerCancel: (_) => ctrl.releaseButton(button),
    child: SizedBox(
      width: wt,
      height: ht,
      child: Material(
        color: btnclr,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rdus),
          side: BorderSide(color: bdrclr),
        ),
        child: Center(child: widget),
      ),
    ),
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

        // Supabase connection status
        Obx(() {
          final connected = ctrl.networkConnected.value;
          final connecting = ctrl.isConnecting.value;

          final statusText = connecting
              ? 'CONNECTING'
              : connected
              ? 'CONNECTED'
              : 'NOT CONNECTED';

          final statusColor = connecting
              ? Colors.orange
              : connected
              ? successColor
              : textMuted;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderLight),
            ),
            child: Row(
              children: [
                Icon(Icons.circle, color: statusColor, size: 8),
                gapW(7),
                customSpTxt(statusText, 9, textSecondary, FontWeight.bold),
              ],
            ),
          );
        }),

        gapW(8),

        // Scan QR button
        Obx(() {
          return ElevatedButton.icon(
            onPressed: ctrl.isConnecting.value
                ? null
                : () {
                    Get.to(() => QRScannerView(ctrl: ctrl));
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
            label: customSpTxt('SCAN QR', 10, white, FontWeight.bold),
          );
        }),
        gapW(3),
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

      // Vibration toggle
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
              const Icon(Icons.vibration_rounded, color: textPrimary, size: 15),
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

      // Select and Start
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          customHoldButton(
            32,
            65,
            controlButtonColor,
            borderLight,
            18,
            'SELECT',
            ctrl,
            customSpTxt('SELECT', 9, textPrimary, FontWeight.bold),
          ),
          gapW(8),
          customHoldButton(
            32,
            65,
            controlButtonColor,
            borderLight,
            18,
            'START',
            ctrl,
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
      customHoldButton(
        50,
        50,
        actionBlue,
        borderLight,
        50,
        'X',
        ctrl,
        customSpTxt('X', 20, white, FontWeight.w900),
      ),

      gapH(8),

      // Middle buttons - Y and A
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          customHoldButton(
            50,
            50,
            actionGreen,
            borderLight,
            50,
            'Y',
            ctrl,
            customSpTxt('Y', 20, white, FontWeight.w900),
          ),
          gapW(65),
          customHoldButton(
            50,
            50,
            actionOrange,
            borderLight,
            50,
            'A',
            ctrl,
            customSpTxt('A', 20, white, FontWeight.w900),
          ),
        ],
      ),

      gapH(8),

      // Bottom button - B
      customHoldButton(
        50,
        50,
        actionRed,
        borderLight,
        50,
        'B',
        ctrl,
        customSpTxt('B', 20, white, FontWeight.w900),
      ),
    ],
  );
}
