import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nes_joystick/joystick/joystick_view.dart';
import 'package:nes_joystick/splash/splash_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? startupError;

  try {
    await dotenv.load(fileName: '.env');

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseUrl.trim().isEmpty) {
      throw Exception('Supabase URL is missing.');
    }

    if (supabaseKey == null || supabaseKey.trim().isEmpty) {
      throw Exception('Supabase anon key is missing.');
    }

    await Supabase.initialize(
      url: supabaseUrl.trim(),
      anonKey: supabaseKey.trim(),
    );
  } catch (e) {
    startupError = e;
  }

  runApp(MyApp(startupError: startupError));
}

class MyApp extends StatelessWidget {
  final Object? startupError;

  const MyApp({super.key, this.startupError});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'NES Joystick',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      initialRoute: startupError == null ? '/' : '/startup-error',
      getPages: [
        GetPage(name: '/', page: () => SplashView()),
        GetPage(name: '/joystick', page: () => JoystickView()),
        GetPage(
          name: '/startup-error',
          page: () => StartupErrorView(error: startupError.toString()),
        ),
      ],
    );
  }
}

class StartupErrorView extends StatelessWidget {
  final String error;

  const StartupErrorView({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 20),
              const Text(
                'INITIALIZATION FAILED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
