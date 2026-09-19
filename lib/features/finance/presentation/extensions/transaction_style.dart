import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../domain/entities/finance_transaction.dart';

extension TransactionStyle on FinanceTransaction {
  IconData get icon => isCardPayment
      ? Icons.account_balance_wallet_rounded
      : switch (category) {
          'Alimentação' => Icons.shopping_basket_rounded,
          'Moradia' => Icons.home_rounded,
          'Transporte' => Icons.directions_car_rounded,
          'Lazer' => Icons.celebration_rounded,
          'Saúde' => Icons.favorite_rounded,
          'Educação' => Icons.school_rounded,
          'Assinaturas' => Icons.subscriptions_rounded,
          'Salário' => Icons.account_balance_wallet_rounded,
          _ => isTransfer ? Icons.swap_horiz_rounded : Icons.receipt_rounded,
        };

  Color color(BuildContext context) {
    final colors = FinanceColors.of(context);
    return isCardPayment
        ? colors.transfer
        : isIncome
        ? colors.income
        : isTransfer
        ? colors.transfer
        : switch (category) {
            'Alimentação' => colors.food,
            'Transporte' => colors.installment,
            'Lazer' => colors.leisure,
            'Moradia' => colors.transfer,
            _ => colors.expense,
          };
  }
}
