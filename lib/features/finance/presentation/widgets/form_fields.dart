import 'package:flutter/material.dart';

import '../../domain/models.dart';

class DateButton extends StatelessWidget {
  const DateButton({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorText,
  });
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final String? errorText;
  @override
  Widget build(BuildContext context) {
    final firstDate = DateTime(2000);
    final lastDate = DateTime(2100, 12, 31);
    final initialDate = value.isBefore(firstDate)
        ? firstDate
        : value.isAfter(lastDate)
        ? lastDate
        : value;
    return Semantics(
      button: true,
      label: label,
      value: shortDate(value),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            firstDate: firstDate,
            lastDate: lastDate,
            initialDate: initialDate,
          );
          if (picked != null) onChanged(picked);
        },
        borderRadius: BorderRadius.circular(14),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.calendar_today_outlined),
            errorText: errorText,
          ),
          child: Text(
            shortDate(value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class NumberField extends StatelessWidget {
  const NumberField({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });
  final String label;
  final int value, min, max;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: InputDecoration(labelText: label),
    child: Row(
      children: [
        IconButton(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          tooltip: 'Diminuir $label',
          icon: const Icon(Icons.remove_circle_outline_rounded),
        ),
        Expanded(
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        IconButton(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          tooltip: 'Aumentar $label',
          icon: const Icon(Icons.add_circle_outline_rounded),
        ),
      ],
    ),
  );
}
