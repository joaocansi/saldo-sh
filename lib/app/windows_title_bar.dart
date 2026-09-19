import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Keeps the native Windows frame visually aligned with the Flutter theme.
abstract final class WindowsTitleBar {
  static const MethodChannel _channel = MethodChannel('saldo.sh/window');

  static Future<void> apply({required bool dark}) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.windows) return;

    try {
      await _channel.invokeMethod<void>('setTitleBarTheme', {'dark': dark});
    } on MissingPluginException {
      // Allows tests and unsupported runners to use the same application code.
    } on PlatformException {
      // Older Windows versions may not expose the requested DWM attributes.
    }
  }
}
