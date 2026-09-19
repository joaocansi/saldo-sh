import 'package:flutter/material.dart';

class AppSelectOption<T> {
  const AppSelectOption({
    required this.value,
    required this.label,
    this.enabled = true,
  });

  final T value;
  final String label;
  final bool enabled;
}

/// Campo de seleção controlado cujo menu é ancorado abaixo do input.
///
/// O [DropdownButtonFormField] posiciona o item selecionado sobre o campo por
/// padrão. Além de esconder o input, esse comportamento fica especialmente
/// confuso em telas pequenas. Este componente mantém a aparência de formulário
/// e usa o posicionamento "under" do menu em todos os pontos do aplicativo.
class AppSelectField<T> extends StatefulWidget {
  const AppSelectField({
    super.key,
    required this.value,
    required this.label,
    required this.options,
    required this.onChanged,
    this.hint,
    this.errorText,
    this.menuMaxHeight = 320,
  });

  final T? value;
  final String label;
  final String? hint;
  final String? errorText;
  final List<AppSelectOption<T>> options;
  final ValueChanged<T>? onChanged;
  final double menuMaxHeight;

  @override
  State<AppSelectField<T>> createState() => _AppSelectFieldState<T>();
}

class _AppSelectFieldState<T> extends State<AppSelectField<T>> {
  bool _menuOpen = false;

  AppSelectOption<T>? get _selectedOption {
    for (final option in widget.options) {
      if (option.value == widget.value) return option;
    }
    return null;
  }

  void _setMenuOpen(bool value) {
    if (!mounted || _menuOpen == value) return;
    setState(() => _menuOpen = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onChanged != null && widget.options.isNotEmpty;
    final selected = _selectedOption;

    return PopupMenuButton<T>(
      enabled: enabled,
      initialValue: widget.value,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 6),
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          final scheme = Theme.of(context).colorScheme;
          if (states.contains(WidgetState.pressed)) {
            return scheme.primary.withValues(alpha: .12);
          }
          if (states.contains(WidgetState.focused) ||
              states.contains(WidgetState.hovered)) {
            return scheme.primary.withValues(alpha: .08);
          }
          return null;
        }),
      ),
      tooltip: widget.label,
      constraints: BoxConstraints(
        maxWidth: 360,
        maxHeight: widget.menuMaxHeight,
      ),
      onOpened: () => _setMenuOpen(true),
      onCanceled: () => _setMenuOpen(false),
      onSelected: (value) {
        _setMenuOpen(false);
        widget.onChanged?.call(value);
      },
      itemBuilder: (context) => [
        for (final option in widget.options)
          PopupMenuItem<T>(
            value: option.value,
            enabled: option.enabled,
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: option.value == widget.value
                      ? Icon(
                          Icons.check_rounded,
                          size: 19,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),
                Expanded(
                  child: Text(
                    option.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Semantics(
        button: true,
        expanded: _menuOpen,
        label: widget.label,
        value: selected?.label,
        child: InputDecorator(
          isEmpty: selected == null,
          isFocused: _menuOpen,
          decoration: InputDecoration(
            labelText: widget.label,
            enabled: enabled,
            errorText: widget.errorText,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selected?.label ?? widget.hint ?? 'Selecione',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: selected == null
                      ? TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: _menuOpen ? .5 : 0,
                duration: const Duration(milliseconds: 160),
                child: const Icon(Icons.arrow_drop_down_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
