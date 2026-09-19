import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses the saldo.sh Windows light palette', () {
    final theme = AppTheme.build(
      Brightness.light,
      platform: TargetPlatform.windows,
    );

    expect(theme.colorScheme.primary, const Color(0xffE9B45C));
    expect(theme.scaffoldBackgroundColor, const Color(0xffF3F1E9));
    expect(theme.cardTheme.color, const Color(0xffFCFBF7));
    expect(theme.inputDecorationTheme.fillColor, const Color(0xffE9E6DD));
    expect(theme.colorScheme.outline, const Color(0xffBBB8AE));
    expect(theme.colorScheme.surfaceContainerLowest, const Color(0xffFFFFFF));
    expect(theme.colorScheme.surfaceContainerLow, const Color(0xffF7F5EE));
    expect(theme.colorScheme.surfaceContainerHigh, const Color(0xffE5E2D9));
    expect(theme.extension<FinanceColors>()!.expense, const Color(0xffAD4F55));
    expect(theme.cardTheme.clipBehavior, Clip.antiAlias);

    final focusedFilledShape = theme.filledButtonTheme.style?.shape?.resolve({
      WidgetState.focused,
    });
    final focusedOutlinedShape = theme.outlinedButtonTheme.style?.shape
        ?.resolve({WidgetState.focused});
    expect(
      (focusedFilledShape as RoundedRectangleBorder).borderRadius,
      BorderRadius.circular(12),
    );
    expect(
      (focusedOutlinedShape as RoundedRectangleBorder).borderRadius,
      BorderRadius.circular(12),
    );

    final focusedInput = theme.inputDecorationTheme.focusedBorder;
    expect(
      (focusedInput as OutlineInputBorder).borderRadius,
      BorderRadius.circular(14),
    );
  });

  test('uses the saldo.sh Windows dark palette', () {
    final theme = AppTheme.build(
      Brightness.dark,
      platform: TargetPlatform.windows,
    );

    expect(theme.colorScheme.primary, const Color(0xffE9B45C));
    expect(theme.scaffoldBackgroundColor, const Color(0xff171B20));
    expect(theme.cardTheme.color, const Color(0xff1E2429));
    expect(theme.inputDecorationTheme.fillColor, const Color(0xff252C31));
    expect(theme.colorScheme.outline, const Color(0xff4A535A));
    expect(theme.colorScheme.onSurface, const Color(0xffF3F1E9));
    expect(theme.colorScheme.surfaceContainerLowest, const Color(0xff111519));
    expect(theme.colorScheme.surfaceContainerLow, const Color(0xff1A2025));
    expect(theme.colorScheme.surfaceContainerHigh, const Color(0xff2A3136));
  });

  test('uses the saldo.sh palette on Android', () {
    final theme = AppTheme.build(
      Brightness.light,
      platform: TargetPlatform.android,
    );
    final finance = theme.extension<FinanceColors>()!;

    expect(theme.colorScheme.primary, const Color(0xffE9B45C));
    expect(theme.scaffoldBackgroundColor, const Color(0xffF3F1E9));
    expect(finance.income, const Color(0xff4D755F));
    expect(finance.expense, const Color(0xffAD4F55));
  });
}
