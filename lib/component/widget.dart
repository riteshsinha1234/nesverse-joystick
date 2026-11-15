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

      gapH(15),
    ],
  );
}

// Right action buttons
Widget _buildRightSection(JoystickController ctrl) {
  Widget buildActionButton(String button) {
    final buttonData = {
      'A': [actionOrange, customSpTxt('A', 20, white, FontWeight.w900)],
      'B': [actionRed, customSpTxt('B', 20, white, FontWeight.w900)],
      'X': [actionBlue, customSpTxt('X', 20, white, FontWeight.w900)],
      'Y': [actionGreen, customSpTxt('Y', 20, white, FontWeight.w900)],
    };

    final data = buttonData[button]!;

    return customHoldButton(
      50,
      50,
      data[0] as Color,
      borderLight,
      50,
      button,
      ctrl,
      data[1] as Widget,
    );
  }

  void showButtonSettings() {
    final screenWidth = Get.width;
    final dialogWidth = screenWidth > 600 ? 420.0 : screenWidth * 0.85;

    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderLight),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: dialogWidth,
            maxHeight: Get.height * 0.75,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Centered title
                Center(
                  child: customSpTxt(
                    'BUTTON SETTINGS',
                    16,
                    white,
                    FontWeight.w900,
                  ),
                ),

                gapH(12),

                customParaTxt(
                  'Customize your action button arrangement.',
                  12,
                  textMuted,
                  FontWeight.w500,
                  TextAlign.center,
                ),

                gapH(24),

                // Swap and Rotate buttons
                Row(
                  children: [
                    Expanded(
                      child: customButton(
                        46,
                        screenWidth,
                        actionBlue,
                        borderLight,
                        10,
                        () => ctrl.swapActionButtons(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.swap_horiz,
                              color: white,
                              size: 20,
                            ),
                            gapW(8),
                            customSpTxt(
                              'SWAP A / B',
                              12,
                              white,
                              FontWeight.bold,
                            ),
                          ],
                        ),
                      ),
                    ),

                    gapW(12),

                    Expanded(
                      child: customButton(
                        46,
                        screenWidth,
                        actionGreen,
                        borderLight,
                        10,
                        () => ctrl.rotateActionButtons(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.rotate_right,
                              color: white,
                              size: 20,
                            ),
                            gapW(8),
                            customSpTxt(
                              'ROTATE LAYOUT',
                              12,
                              white,
                              FontWeight.bold,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                gapH(12),

                // Reset layout
                customButton(
                  42,
                  screenWidth,
                  const Color(0xFF292929),
                  borderLight,
                  10,
                  () => ctrl.resetActionButtons(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.restart_alt, color: white, size: 20),
                      gapW(8),
                      customSpTxt('RESET DEFAULT', 12, white, FontWeight.bold),
                    ],
                  ),
                ),

                gapH(20),

                // Cancel and Done buttons
                Row(
                  children: [
                    Expanded(
                      child: customButton(
                        42,
                        screenWidth,
                        const Color(0xFF292929),
                        borderLight,
                        10,
                        () => Get.back(),
                        customSpTxt('CANCEL', 12, white, FontWeight.bold),
                      ),
                    ),

                    gapW(12),

                    Expanded(
                      child: customButton(
                        42,
                        screenWidth,
                        actionOrange,
                        borderLight,
                        10,
                        () => Get.back(),
                        customSpTxt('DONE', 12, white, FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  return Obx(() {
    final buttons = ctrl.actionButtonOrder;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            customSpTxt('ACTION', 10, textMuted, FontWeight.bold),
            const SizedBox(width: 8),

            GestureDetector(
              onTap: showButtonSettings,
              child: const Icon(
                Icons.settings,
                color: Colors.white70,
                size: 17,
              ),
            ),
          ],
        ),

        gapH(18),

        // Top button
        buildActionButton(buttons[0]),

        gapH(8),

        // Middle buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildActionButton(buttons[1]),
            gapW(65),
            buildActionButton(buttons[2]),
          ],
        ),

        gapH(8),

        // Bottom button
        buildActionButton(buttons[3]),
      ],
    );
  });
}
