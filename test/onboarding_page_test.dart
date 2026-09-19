import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/app_theme.dart';
import 'package:flutter_application_1/features/onboarding/presentation/onboarding_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget app(Widget child, {bool disableAnimations = false}) => MaterialApp(
    theme: AppTheme.build(Brightness.light),
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: child,
    ),
  );

  testWidgets(
    'assembles the saldo.sh mark and accepts a normalized local name',
    (tester) async {
      String? savedName;
      await tester.pumpWidget(
        app(OnboardingPage(onCompleted: (name) async => savedName = name)),
      );

      final initialCrescent = _center(tester, 'saldo-crescent');
      expect(_opacity(tester, 'saldo-crescent'), 0);

      await tester.pump(const Duration(milliseconds: 420));
      final movingCrescent = _center(tester, 'saldo-crescent');
      expect(_opacity(tester, 'saldo-crescent'), greaterThan(0));
      expect(_opacity(tester, 'saldo-coin'), 0);
      expect(_opacity(tester, 'saldo-prompt'), 0);
      expect(movingCrescent.dx, greaterThan(initialCrescent.dx));

      await tester.pump(const Duration(milliseconds: 420));
      final settledCrescent = _center(tester, 'saldo-crescent');
      expect(settledCrescent.dx, greaterThan(movingCrescent.dx + 25));

      await tester.pump(const Duration(milliseconds: 420));
      expect(_opacity(tester, 'saldo-coin'), greaterThan(0));
      expect(_opacity(tester, 'saldo-prompt'), 0);

      await tester.pump(const Duration(milliseconds: 2240));
      expect(find.text('Como você deseja ser chamado?'), findsOneWidget);

      await tester.tap(find.text('Continuar'));
      await tester.pump();
      expect(
        find.text('Informe como você deseja ser chamado.'),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const ValueKey('onboarding-name')),
        '  Maria   da Silva  ',
      );
      await tester.tap(find.text('Continuar'));
      await tester.pump();

      expect(savedName, 'Maria da Silva');
    },
  );

  testWidgets('skips the introduction when animations are disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(OnboardingPage(onCompleted: (_) async {}), disableAnimations: true),
    );

    expect(_opacity(tester, 'saldo-crescent'), 1);
    expect(_opacity(tester, 'saldo-coin'), 1);
    expect(_opacity(tester, 'saldo-prompt'), 1);
    expect(find.text('Como você deseja ser chamado?'), findsOneWidget);
  });
}

double _opacity(WidgetTester tester, String key) {
  final finder = find.descendant(
    of: find.byKey(ValueKey(key)),
    matching: find.byType(Opacity),
  );
  return tester.widget<Opacity>(finder).opacity;
}

Offset _center(WidgetTester tester, String key) {
  final finder = find.descendant(
    of: find.byKey(ValueKey(key)),
    matching: find.byType(CustomPaint),
  );
  return tester.getCenter(finder);
}
