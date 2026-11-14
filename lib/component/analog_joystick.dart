import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nes_joystick/component/colors.dart';
import 'package:nes_joystick/joystick/joystick_controller.dart';

class AnalogJoystick extends StatelessWidget {
  final double size;
  final Color activeColor;
  final JoystickController controller;

  const AnalogJoystick({
    super.key,
    this.size = 160,
    this.activeColor = primaryColor,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: GestureDetector(
        onPanDown: (details) {
          controller.updateJoystickPosition(details.localPosition, size);
        },
        onPanUpdate: (details) {
          controller.updateJoystickPosition(details.localPosition, size);
        },
        onPanEnd: (_) => controller.resetJoystick(),
        onPanCancel: controller.resetJoystick,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer joystick base
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [joystickBaseStart, joystickBaseEnd],
                ),
                border: Border.all(color: joystickBorder, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.08),
                    blurRadius: 25,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),

            // Inner circular track
            Container(
              width: size * 0.68,
              height: size * 0.68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: joystickTrackBorder, width: 2),
              ),
            ),

            // Joystick knob
            Obx(() {
              final position = controller.joystickPosition.value;

              return Transform.translate(
                offset: Offset(
                  position.dx * size * 0.25,
                  position.dy * size * 0.25,
                ),
                child: Container(
                  width: size * 0.42,
                  height: size * 0.42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        activeColor.withValues(alpha: 0.9),
                        joystickKnobEnd,
                      ],
                    ),
                    border: Border.all(
                      color: activeColor.withValues(alpha: 0.8),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.25),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: size * 0.12,
                      height: size * 0.12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: white.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
