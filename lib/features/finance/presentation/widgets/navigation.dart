import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/saldo_mark.dart';

const financePageNames = [
  'Início',
  'Transações',
  'Contas e cartões',
  'Orçamento',
  'Relatórios',
  'Assistente',
  'Configurações',
];

const financePageIcons = [
  Icons.grid_view_rounded,
  Icons.receipt_long_rounded,
  Icons.credit_card_rounded,
  Icons.pie_chart_rounded,
  Icons.bar_chart_rounded,
  Icons.auto_awesome_rounded,
  Icons.settings_outlined,
];

class FinanceSidebar extends StatefulWidget {
  const FinanceSidebar({
    super.key,
    required this.selected,
    required this.dark,
    required this.displayName,
    required this.onTheme,
    required this.onSelect,
  });
  final int selected;
  final bool dark;
  final String displayName;
  final VoidCallback onTheme;
  final ValueChanged<int> onSelect;

  @override
  State<FinanceSidebar> createState() => _FinanceSidebarState();
}

class _FinanceSidebarState extends State<FinanceSidebar> {
  static const _contentPadding = EdgeInsets.fromLTRB(16, 22, 16, 16);
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 250,
    child: DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          interactive: true,
          radius: const Radius.circular(4),
          thickness: 7,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context)
                .copyWith(scrollbars: false),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: _contentPadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 10, bottom: 30),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Brand(),
                            ),
                          ),
                          ...List.generate(
                            financePageNames.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: ListTile(
                                selected: widget.selected == index,
                                selectedTileColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                leading: Icon(
                                  financePageIcons[index],
                                  size: 21,
                                ),
                                title: Text(
                                  financePageNames[index],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onTap: () => widget.onSelect(index),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.lock_outline_rounded, size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Dados salvos localmente;\n'
                                    'sincronização opcional com Drive',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            leading: Icon(
                              widget.dark
                                  ? Icons.light_mode_outlined
                                  : Icons.dark_mode_outlined,
                            ),
                            title: Text(
                              widget.dark ? 'Modo claro' : 'Modo escuro',
                              style: const TextStyle(fontSize: 13),
                            ),
                            onTap: widget.onTheme,
                          ),
                          ListTile(
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              child: Text(
                                _initials(widget.displayName),
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              widget.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: const Text(
                              'Dados locais',
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return 'V';
  if (parts.length == 1) {
    return parts.first.characters.take(2).toString().toUpperCase();
  }
  return '${parts.first.characters.first}${parts.last.characters.first}'
      .toUpperCase();
}

class Brand extends StatelessWidget {
  const Brand({super.key});
  @override
  Widget build(BuildContext context) => const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SaldoMark(size: 34),
      SizedBox(width: 9),
      Flexible(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: SaldoWordmark(),
        ),
      ),
    ],
  );
}

class FinanceTopBar extends StatelessWidget {
  const FinanceTopBar({
    super.key,
    required this.desktop,
    required this.dark,
    required this.onTheme,
    required this.onPage,
  });
  final bool desktop, dark;
  final VoidCallback onTheme;
  final ValueChanged<int> onPage;
  @override
  Widget build(BuildContext context) {
    if (desktop) return const SizedBox.shrink();
    final content = Row(
      children: [
        const Brand(),
        const Spacer(),
        IconButton(
          onPressed: onTheme,
          icon: Icon(
            dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
        ),
        PopupMenuButton<int>(
          icon: const Icon(Icons.more_horiz_rounded),
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          position: PopupMenuPosition.under,
          offset: const Offset(0, 6),
          tooltip: 'Abrir mais opções',
          onSelected: onPage,
          itemBuilder: (_) => const [
            PopupMenuItem(value: 3, child: Text('Orçamento')),
            PopupMenuItem(value: 4, child: Text('Relatórios')),
            PopupMenuItem(value: 6, child: Text('Configurações')),
          ],
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 8),
      child: content,
    );
  }
}
