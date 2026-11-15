import 'dart:async';

import 'package:nes_joystick/network/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ControllerService {
  ControllerService._();

  static final ControllerService instance = ControllerService._();

  RealtimeChannel? _channel;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<void> connect(String sessionId) async {
    // Disconnect any previous session.
    await disconnect();

    final channel = SupabaseConfig.client.channel('controller:$sessionId');

    _channel = channel;
    _isConnected = false;

    final completer = Completer<void>();

    channel.subscribe((status, [error]) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        _isConnected = true;

        if (!completer.isCompleted) {
          completer.complete();
        }
      } else if (status == RealtimeSubscribeStatus.channelError ||
          status == RealtimeSubscribeStatus.timedOut ||
          status == RealtimeSubscribeStatus.closed) {
        _isConnected = false;

        if (!completer.isCompleted) {
          completer.completeError(
            Exception(
              error?.toString() ?? 'Supabase connection failed: $status',
            ),
          );
        }
      }
    });

    try {
      // Wait until Supabase confirms the subscription.
      await completer.future.timeout(const Duration(seconds: 15));
    } catch (e) {
      if (identical(_channel, channel)) {
        _isConnected = false;
        _channel = null;
        await SupabaseConfig.client.removeChannel(channel);
      }

      rethrow;
    }
  }

  Future<void> sendJoystick({required double x, required double y}) async {
    if (_channel == null || !_isConnected) return;

    await _channel!.sendBroadcastMessage(
      event: 'controller_input',
      payload: {'type': 'joystick', 'x': x, 'y': y},
    );
  }

  Future<void> sendButton({
    required String button,
    required bool pressed,
  }) async {
    if (_channel == null || !_isConnected) return;

    await _channel!.sendBroadcastMessage(
      event: 'controller_input',
      payload: {'type': 'button', 'button': button, 'pressed': pressed},
    );
  }

  Future<void> disconnect() async {
    final channel = _channel;

    if (channel == null) return;

    _isConnected = false;
    _channel = null;

    await SupabaseConfig.client.removeChannel(channel);
  }
}
