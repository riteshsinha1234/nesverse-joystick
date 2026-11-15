import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static Future<void> initialize() async {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabasePublishableKey = dotenv.env['SUPABASE_PUBLISHABLE_KEY'];

    if (supabaseUrl == null ||
        supabasePublishableKey == null ||
        supabaseUrl.isEmpty ||
        supabasePublishableKey.isEmpty) {
      throw Exception('Supabase credentials are missing in the .env file.');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabasePublishableKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
