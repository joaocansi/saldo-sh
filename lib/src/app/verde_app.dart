import 'dart:async';

import 'package:flutter/material.dart';

import '../features/finance/presentation/finance_shell.dart';
import '../features/onboarding/presentation/onboarding_page.dart';
import 'app_dependencies.dart';
import 'app_theme.dart';
import 'windows_title_bar.dart';

class VerdeApp extends StatefulWidget {
  const VerdeApp({
    super.key,
    this.initialDark = false,
    required this.initialDisplayName,
    required this.dependencies,
  });

  final bool initialDark;
  final String? initialDisplayName;
  final AppDependencies dependencies;

  @override
  State<VerdeApp> createState() => _VerdeAppState();
}

class _VerdeAppState extends State<VerdeApp> {
  late ThemeMode _themeMode;
  late String? _displayName;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialDark ? ThemeMode.dark : ThemeMode.light;
    _displayName = widget.initialDisplayName;
    unawaited(WindowsTitleBar.apply(dark: _themeMode == ThemeMode.dark));
  }

  Future<void> _completeOnboarding(String name) async {
    await widget.dependencies.settingsRepository.saveDisplayName(name);
    if (!mounted) return;
    setState(() => _displayName = name);
  }

  void _completeFactoryReset() {
    if (!mounted) return;
    setState(() {
      _themeMode = ThemeMode.light;
      _displayName = null;
    });
    unawaited(WindowsTitleBar.apply(dark: false));
  }

  Future<void> _toggleTheme() async {
    final next = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    setState(() => _themeMode = next);
    unawaited(WindowsTitleBar.apply(dark: next == ThemeMode.dark));
    await widget.dependencies.financeRepository.saveDarkTheme(
      next == ThemeMode.dark,
    );
  }

  void _applySyncedTheme(bool dark) {
    final next = dark ? ThemeMode.dark : ThemeMode.light;
    if (_themeMode == next) return;
    setState(() => _themeMode = next);
    unawaited(WindowsTitleBar.apply(dark: dark));
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'saldo.sh',
    themeMode: _themeMode,
    theme: AppTheme.build(Brightness.light),
    darkTheme: AppTheme.build(Brightness.dark),
    home: _displayName == null
        ? OnboardingPage(onCompleted: _completeOnboarding)
        : FinanceShell(
            dark: _themeMode == ThemeMode.dark,
            displayName: _displayName!,
            onTheme: _toggleTheme,
            onSyncedTheme: _applySyncedTheme,
            onFactoryReset: _completeFactoryReset,
            dependencies: widget.dependencies,
          ),
  );
}
