import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nes_joystick/component/colors.dart';
import 'package:nes_joystick/component/widget.dart';
import 'package:nes_joystick/joystick/joystick_controller.dart';

class JoystickView extends StatelessWidget {
  JoystickView({super.key});
  final JoystickController controller = Get.put(JoystickController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            gameHeader(controller),
            controllerPad(context, controller),
          ],
        ),
      ),
    );
  }
}
