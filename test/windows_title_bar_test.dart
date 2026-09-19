import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/app/windows_title_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sends the current theme to the native Windows title bar', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    const channel = MethodChannel('saldo.sh/window');
    MethodCall? received;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          received = call;
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    await WindowsTitleBar.apply(dark: true);

    expect(received?.method, 'setTitleBarTheme');
    expect(received?.arguments, {'dark': true});
  });
}
