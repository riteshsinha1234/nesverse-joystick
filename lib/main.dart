import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:nes_joystick/joystick/joystick_view.dart';
import 'package:nes_joystick/network/supabase_config.dart';
import 'package:nes_joystick/splash/splash_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
    await SupabaseConfig.initialize();

    debugPrint('SUPABASE INITIALIZED SUCCESSFULLY');
  } catch (e, stackTrace) {
    debugPrint('SUPABASE INITIALIZATION FAILED: $e');
    debugPrintStack(stackTrace: stackTrace);
  }

  // Start the Flutter application even if Supabase initialization fails.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'NES Joystick',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => SplashView()),
        GetPage(name: '/joystick', page: () => JoystickView()),
      ],
    );
  }
}
