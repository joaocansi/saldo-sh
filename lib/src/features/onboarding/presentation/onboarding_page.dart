import 'package:flutter/material.dart';

import '../../../core/presentation/widgets/saldo_mark.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.onCompleted});

  final Future<void> Function(String name) onCompleted;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late final AnimationController _animation;
  bool _started = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _animation.value = 1;
    } else {
      _animation.forward();
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.onCompleted(_normalizedName(_nameController.text));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, _) {
                    final value = _animation.value;
                    final reveal = Curves.easeOutCubic.transform(
                      ((value - .82) / .18).clamp(0, 1),
                    );
                    return SizedBox(
                      height: 470,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Positioned(
                            top: 148 - (112 * reveal),
                            child: SaldoMark(
                              size: 92,
                              progress: value,
                              showEntrancePath: true,
                            ),
                          ),
                          Positioned(
                            top: 136,
                            child: Opacity(
                              opacity: reveal,
                              child: const SaldoWordmark(fontSize: 24),
                            ),
                          ),
                          Positioned(
                            top: 180,
                            left: 0,
                            right: 0,
                            child: IgnorePointer(
                              ignoring: reveal < 1,
                              child: Opacity(
                                opacity: reveal,
                                child: Transform.translate(
                                  offset: Offset(0, 22 * (1 - reveal)),
                                  child: _buildForm(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildForm() => Form(
    key: _formKey,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Como você deseja ser chamado?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -.5),
        ),
        const SizedBox(height: 8),
        Text(
          'Esse nome fica somente neste dispositivo.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          key: const ValueKey('onboarding-name'),
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _continue(),
          validator: _validateName,
          decoration: const InputDecoration(
            labelText: 'Seu nome',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saving ? null : _continue,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Continuar'),
            ),
          ),
        ),
      ],
    ),
  );

  String? _validateName(String? value) {
    final name = _normalizedName(value ?? '');
    if (name.isEmpty) return 'Informe como você deseja ser chamado.';
    if (name.length > 60) return 'Use no máximo 60 caracteres.';
    if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(name)) {
      return 'O nome contém caracteres inválidos.';
    }
    return null;
  }

  String _normalizedName(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');
}
