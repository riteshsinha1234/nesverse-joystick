import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nes_joystick/component/colors.dart';
import 'package:nes_joystick/component/text.dart';
import 'package:nes_joystick/component/widget.dart';
import 'package:nes_joystick/splash/splash_controller.dart';

class SplashView extends StatelessWidget {
  SplashView({super.key});

  final SplashController controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
          child: Row(
            children: [
              // Left branding section
              Expanded(
                flex: 3,
                child: FadeTransition(
                  opacity: controller.fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      customSpTxt('WELCOME TO', 11, textMuted, FontWeight.bold),
                      gapH(10),
                      customSpTxt('NESVERSE', 30, textPrimary, FontWeight.w900),
                      gapH(5),
                      customSpTxt(
                        'JOYSTICK',
                        15,
                        primaryColor,
                        FontWeight.bold,
                      ),
                      gapH(15),
                      Container(
                        width: 65,
                        height: 3,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      gapH(15),
                      customTxt(
                        'YOUR GAME. YOUR CONTROL.',
                        10,
                        textSecondary,
                        FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ),

              // Center animated gamepad
              Expanded(
                flex: 4,
                child: AnimatedBuilder(
                  animation: controller.animationController,
                  builder: (context, child) {
                    return Center(
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer orbit
                            Transform.rotate(
                              angle: controller.rotationAnimation.value,
                              child: Container(
                                width: 190,
                                height: 190,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: joystickBorder,
                                    width: 1.5,
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    width: 13,
                                    height: 13,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: primaryColor,
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withValues(
                                            alpha: 0.7,
                                          ),
                                          blurRadius: 15,
                                          spreadRadius: 3,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Inner orbit
                            Transform.rotate(
                              angle: -controller.rotationAnimation.value * 1.5,
                              child: Container(
                                width: 155,
                                height: 155,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: borderLight,
                                    width: 1,
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: actionOrange,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Glowing gamepad
                            ScaleTransition(
                              scale: controller.scaleAnimation,
                              child: Container(
                                width: 115,
                                height: 115,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const RadialGradient(
                                    colors: [
                                      joystickBaseStart,
                                      joystickBaseEnd,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: primaryColor,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.gamepad_rounded,
                                    color: primaryColor,
                                    size: 65,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Right loading section
              Expanded(
                flex: 3,
                child: FadeTransition(
                  opacity: controller.fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      customSpTxt(
                        'PLAYER 01',
                        11,
                        primaryColor,
                        FontWeight.bold,
                      ),
                      gapH(12),
                      customTxt(
                        'GET READY TO PLAY',
                        13,
                        textPrimary,
                        FontWeight.bold,
                      ),
                      gapH(15),

                      SizedBox(
                        width: 145,
                        child: AnimatedBuilder(
                          animation: controller.animationController,
                          builder: (context, child) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: controller.animationController.value,
                                minHeight: 5,
                                backgroundColor: surfaceColor,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  primaryColor,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      gapH(10),
                      customTxt(
                        'POWERING UP...',
                        9,
                        textMuted,
                        FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
