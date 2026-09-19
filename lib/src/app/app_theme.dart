import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;

import '../core/presentation/widgets/saldo_mark.dart';

abstract final class AppTheme {
  static ThemeData build(Brightness brightness, {TargetPlatform? platform}) {
    final target = platform ?? defaultTargetPlatform;
    final windows = target == TargetPlatform.windows;
    final light = brightness == Brightness.light;
    final scheme = _brandScheme(brightness);
    final background = light
        ? SaldoBrandColors.ivory
        : SaldoBrandColors.graphite;
    final surface = light ? const Color(0xffFCFBF7) : const Color(0xff1E2429);
    final inputFill = light ? const Color(0xffE9E6DD) : const Color(0xff252C31);
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: scheme.outline.withValues(alpha: windows ? .72 : .5),
      ),
    );
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    final buttonOverlay = _interactiveOverlay(scheme.onPrimary, windows);
    final surfaceOverlay = _interactiveOverlay(scheme.primary, windows);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: surface,
      focusColor: scheme.primary.withValues(alpha: windows ? .12 : .10),
      hoverColor: scheme.primary.withValues(alpha: windows ? .08 : .07),
      splashColor: scheme.primary.withValues(alpha: .12),
      extensions: [FinanceColors.forPlatform(target, brightness)],
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: scheme.outline.withValues(alpha: windows ? .42 : .25),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dialogTheme: DialogThemeData(backgroundColor: surface, elevation: 8),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        elevation: windows ? 5 : 8,
        shape: RoundedRectangleBorder(
          side: windows
              ? BorderSide(color: scheme.outline.withValues(alpha: .45))
              : BorderSide.none,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        focusColor: scheme.primary.withValues(alpha: .08),
        hoverColor: scheme.primary.withValues(alpha: windows ? .06 : .05),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 1.3),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 1.7),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(scheme.primary),
          foregroundColor: WidgetStatePropertyAll(scheme.onPrimary),
          minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
          shape: WidgetStatePropertyAll(buttonShape),
          overlayColor: buttonOverlay,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
          shape: WidgetStatePropertyAll(buttonShape),
          overlayColor: surfaceOverlay,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(buttonShape),
          overlayColor: surfaceOverlay,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(CircleBorder()),
          overlayColor: surfaceOverlay,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        focusElevation: 3,
        hoverElevation: 4,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: light
            ? SaldoBrandColors.graphite
            : const Color(0xff30383E),
        contentTextStyle: const TextStyle(color: SaldoBrandColors.ivory),
        actionTextColor: SaldoBrandColors.amber,
        behavior: SnackBarBehavior.floating,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
      ),
      listTileTheme: ListTileThemeData(
        selectedColor: scheme.onPrimaryContainer,
        iconColor: scheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline.withValues(alpha: windows ? .42 : .3),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: surface,
        indicatorColor: scheme.primaryContainer,
      ),
    );
  }

  static WidgetStateProperty<Color?> _interactiveOverlay(
    Color color,
    bool windows,
  ) => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return null;
    if (states.contains(WidgetState.pressed)) {
      return color.withValues(alpha: .14);
    }
    if (states.contains(WidgetState.focused)) {
      return color.withValues(alpha: windows ? .12 : .10);
    }
    if (states.contains(WidgetState.hovered)) {
      return color.withValues(alpha: windows ? .08 : .07);
    }
    return null;
  });

  static ColorScheme _brandScheme(Brightness brightness) {
    final light = brightness == Brightness.light;
    return ColorScheme.fromSeed(
      seedColor: SaldoBrandColors.amber,
      brightness: brightness,
    ).copyWith(
      primary: SaldoBrandColors.amber,
      onPrimary: SaldoBrandColors.graphite,
      primaryContainer: light
          ? const Color(0xffF5DDAF)
          : const Color(0xff503C1B),
      onPrimaryContainer: light
          ? const Color(0xff3A290C)
          : const Color(0xffFFE3AE),
      secondary: light ? const Color(0xff657368) : SaldoBrandColors.sage,
      onSecondary: light ? SaldoBrandColors.ivory : SaldoBrandColors.graphite,
      secondaryContainer: light
          ? const Color(0xffDDE3DC)
          : const Color(0xff39443D),
      surfaceDim: light ? const Color(0xffDEDCD4) : const Color(0xff151A1E),
      surfaceBright: light ? const Color(0xffFFFEFA) : const Color(0xff333A3F),
      surface: light ? const Color(0xffFCFBF7) : const Color(0xff1E2429),
      surfaceContainerLowest: light
          ? const Color(0xffFFFFFF)
          : const Color(0xff111519),
      surfaceContainerLow: light
          ? const Color(0xffF7F5EE)
          : const Color(0xff1A2025),
      surfaceContainer: light
          ? const Color(0xffE9E6DD)
          : const Color(0xff252C31),
      surfaceContainerHigh: light
          ? const Color(0xffE5E2D9)
          : const Color(0xff2A3136),
      surfaceContainerHighest: light
          ? const Color(0xffE1DED5)
          : const Color(0xff30373C),
      outline: light ? const Color(0xffBBB8AE) : const Color(0xff4A535A),
      onSurface: light ? SaldoBrandColors.graphite : SaldoBrandColors.ivory,
      onSurfaceVariant: light
          ? const Color(0xff5D6062)
          : const Color(0xffB9BCB8),
      error: light ? const Color(0xffA84248) : const Color(0xffE58B8E),
    );
  }
}

@immutable
class FinanceColors extends ThemeExtension<FinanceColors> {
  const FinanceColors({
    required this.income,
    required this.expense,
    required this.transfer,
    required this.warning,
    required this.installment,
    required this.food,
    required this.leisure,
  });

  final Color income;
  final Color expense;
  final Color transfer;
  final Color warning;
  final Color installment;
  final Color food;
  final Color leisure;

  static FinanceColors of(BuildContext context) =>
      Theme.of(context).extension<FinanceColors>()!;

  factory FinanceColors.forPlatform(
    TargetPlatform platform,
    Brightness brightness,
  ) {
    final dark = brightness == Brightness.dark;
    return FinanceColors(
      income: dark ? const Color(0xff91B69E) : const Color(0xff4D755F),
      expense: dark ? const Color(0xffDD8589) : const Color(0xffAD4F55),
      transfer: dark ? const Color(0xff88A9C0) : const Color(0xff547C98),
      warning: dark ? SaldoBrandColors.amber : const Color(0xff9B6518),
      installment: dark ? const Color(0xffACA2C7) : const Color(0xff756A91),
      food: dark ? const Color(0xffD9A95C) : const Color(0xff9B6518),
      leisure: dark ? const Color(0xffD68B8F) : const Color(0xffA9585C),
    );
  }

  @override
  FinanceColors copyWith({
    Color? income,
    Color? expense,
    Color? transfer,
    Color? warning,
    Color? installment,
    Color? food,
    Color? leisure,
  }) => FinanceColors(
    income: income ?? this.income,
    expense: expense ?? this.expense,
    transfer: transfer ?? this.transfer,
    warning: warning ?? this.warning,
    installment: installment ?? this.installment,
    food: food ?? this.food,
    leisure: leisure ?? this.leisure,
  );

  @override
  FinanceColors lerp(covariant FinanceColors? other, double t) {
    if (other == null) return this;
    return FinanceColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      transfer: Color.lerp(transfer, other.transfer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      installment: Color.lerp(installment, other.installment, t)!,
      food: Color.lerp(food, other.food, t)!,
      leisure: Color.lerp(leisure, other.leisure, t)!,
    );
  }
}
