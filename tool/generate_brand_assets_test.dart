import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/presentation/widgets/saldo_mark.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('generate launcher assets from the in-app saldo.sh mark', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final directory = Directory('assets/icon')..createSync(recursive: true);
      await _writeIcon(
        File('${directory.path}/saldo_sh_icon.png'),
        showBackground: true,
      );
      await _writeIcon(
        File('${directory.path}/saldo_sh_icon_foreground.png'),
        showBackground: false,
      );
      await _writeIcon(
        File('${directory.path}/saldo_sh_icon_monochrome.png'),
        showBackground: false,
        monochrome: true,
      );
    });
  });
}

Future<void> _writeIcon(
  File file, {
  required bool showBackground,
  bool monochrome = false,
}) async {
  const size = 1024.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  paintSaldoMarkAsset(
    canvas,
    size,
    showBackground: showBackground,
    monochrome: monochrome,
  );
  final image = await recorder.endRecording().toImage(
    size.toInt(),
    size.toInt(),
  );
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  if (bytes == null) throw StateError('Não foi possível gerar o ícone.');
  await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
}
