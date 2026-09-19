import 'package:flutter/widgets.dart';

import 'app/app_dependencies.dart';
import 'app/verde_app.dart';

export 'app/verde_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppDependencies.create();
  final isDarkTheme = await dependencies.financeRepository.readDarkTheme();
  final displayName = await dependencies.settingsRepository.readDisplayName();
  runApp(
    VerdeApp(
      initialDark: isDarkTheme,
      initialDisplayName: displayName,
      dependencies: dependencies,
    ),
  );
}
