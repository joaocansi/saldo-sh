import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/presentation/widgets/app_select_field.dart';
import '../../sync/application/drive_sync_controller.dart';
import '../../sync/domain/sync_models.dart';
import '../application/settings_controller.dart';
import '../domain/app_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.controller,
    required this.sync,
    required this.dark,
    required this.onTheme,
    required this.onFactoryReset,
  });

  final SettingsController controller;
  final DriveSyncController sync;
  final bool dark;
  final VoidCallback onTheme;
  final Future<void> Function() onFactoryReset;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _endpoint;
  late final TextEditingController _model;
  final _apiKey = TextEditingController();
  late String _provider;
  bool _connectingDrive = false;
  bool _resettingApp = false;

  @override
  void initState() {
    super.initState();
    _provider = widget.controller.ai.provider;
    _endpoint = TextEditingController(text: widget.controller.ai.endpoint);
    _model = TextEditingController(text: widget.controller.ai.model);
  }

  @override
  void dispose() {
    _endpoint.dispose();
    _model.dispose();
    _apiKey.dispose();
    super.dispose();
  }

  Future<void> _saveAI({bool test = false}) async {
    try {
      await widget.controller.saveAI(
        AISettings(
          provider: _provider,
          endpoint: _endpoint.text.trim(),
          model: _model.text.trim(),
        ),
        apiKey: _apiKey.text,
      );
      _apiKey.clear();
      if (test) await widget.controller.testAIConnection();
      if (mounted) setState(() {});
    } on FormatException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _connectDrive() async {
    if (_connectingDrive) return;
    final password = await _askSyncPassword();
    if (password == null || !mounted) return;
    setState(() => _connectingDrive = true);
    try {
      try {
        await widget.sync.connect(password);
      } on AccountChangeConfirmationRequired catch (change) {
        if (!mounted) return;
        final confirmed = await _confirmAccountChange(change);
        if (confirmed && mounted) {
          await widget.sync.connect(password, allowAccountChange: true);
        }
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.sync.errorMessage ?? 'Não foi possível conectar ao Drive.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _connectingDrive = false);
    }
  }

  Future<void> _reconnectDrive() async {
    if (_connectingDrive) return;
    setState(() => _connectingDrive = true);
    try {
      await widget.sync.reconnect();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.sync.errorMessage ??
                'Não foi possível reconectar ao Google Drive.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _connectingDrive = false);
    }
  }

  Future<String?> _askSyncPassword() async {
    final route = DialogRoute<String>(
      context: context,
      builder: (_) => const _SyncPasswordDialog(),
    );
    final value = await Navigator.of(
      context,
      rootNavigator: true,
    ).push<String>(route);
    await route.completed;
    return value;
  }

  Future<bool> _confirmAccountChange(
    AccountChangeConfirmationRequired change,
  ) async {
    final route = DialogRoute<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Trocar conta Google?'),
        content: Text(
          'A conta ${change.previous} será trocada por ${change.next}. '
          'Confirme antes de mesclar dados de outro Drive.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Trocar e mesclar'),
          ),
        ],
      ),
    );
    final confirmed = await Navigator.of(
      context,
      rootNavigator: true,
    ).push<bool>(route);
    await route.completed;
    return confirmed ?? false;
  }

  Future<void> _resetApp() async {
    if (_resettingApp) return;
    final route = DialogRoute<bool>(
      context: context,
      builder: (_) => const _FactoryResetDialog(),
    );
    final confirmed = await Navigator.of(
      context,
      rootNavigator: true,
    ).push<bool>(route);
    await route.completed;
    if (confirmed != true || !mounted) return;
    setState(() => _resettingApp = true);
    try {
      await widget.onFactoryReset();
    } catch (_) {
      if (!mounted) return;
      setState(() => _resettingApp = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.sync.errorMessage ?? 'Não foi possível concluir o reset. Seus dados foram preservados.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => AbsorbPointer(
    absorbing: _resettingApp || widget.sync.status == SyncStatus.resetting,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        _Section(
          title: 'Geral',
          icon: Icons.tune_rounded,
          children: [
            SwitchListTile(
              value: widget.dark,
              onChanged: (_) => widget.onTheme(),
              title: const Text('Tema escuro'),
              subtitle: const Text(
                'Esta preferência também pode ser sincronizada.',
              ),
            ),
          ],
        ),
        _Section(
          title: 'Inteligência Artificial',
          icon: Icons.auto_awesome_rounded,
          children: [
            AppSelectField<String>(
              value: _provider,
              label: 'Provedor',
              options: const [
                AppSelectOption(value: 'openai', label: 'OpenAI'),
                AppSelectOption(value: 'openrouter', label: 'OpenRouter'),
                AppSelectOption(
                  value: 'custom',
                  label: 'Compatível personalizado',
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _provider = value;
                  if (value == 'openai') {
                    _endpoint.text = 'https://api.openai.com/v1';
                  } else if (value == 'openrouter') {
                    _endpoint.text = 'https://openrouter.ai/api/v1';
                  }
                });
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _endpoint,
              decoration: const InputDecoration(labelText: 'Endpoint HTTPS'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _model,
              decoration: const InputDecoration(labelText: 'Modelo'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _apiKey,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: widget.controller.hasAIKey
                    ? 'API key (já configurada)'
                    : 'API key',
                hintText: widget.controller.hasAIKey ? '••••••••••••' : null,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(onPressed: _saveAI, child: const Text('Salvar')),
                OutlinedButton.icon(
                  onPressed: () => _saveAI(test: true),
                  icon: const Icon(Icons.wifi_tethering_rounded),
                  label: const Text('Testar conexão'),
                ),
                if (widget.controller.hasAIKey)
                  TextButton(
                    onPressed: widget.controller.removeAIKey,
                    child: const Text('Remover chave'),
                  ),
              ],
            ),
            if (widget.controller.aiStatus case final status?) ...[
              const SizedBox(height: 8),
              Text(status),
            ],
          ],
        ),
        _Section(
          title: 'Sincronização',
          icon: Icons.cloud_sync_rounded,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_syncStatus(widget.sync.status)),
              subtitle: Text(
                (widget.sync.status == SyncStatus.error
                        ? widget.sync.errorMessage
                        : null) ??
                    widget.sync.settings.accountEmail ??
                    widget.sync.errorMessage ??
                    'Google Drive · pasta privada do aplicativo',
              ),
              trailing: _SyncStatusIcon(status: widget.sync.status),
            ),
            if (widget.sync.settings.enabled)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: widget.sync.settings.autoSync,
                onChanged: widget.sync.setAutoSync,
                title: const Text('Sincronizar automaticamente'),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (!widget.sync.settings.enabled)
                  FilledButton.icon(
                    onPressed: _connectingDrive ? null : _connectDrive,
                    icon: _connectingDrive
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_to_drive_rounded),
                    label: Text(
                      _connectingDrive
                          ? 'Conectando…'
                          : 'Conectar Google Drive',
                    ),
                  )
                else ...[
                  FilledButton.icon(
                    onPressed:
                        widget.sync.status == SyncStatus.syncing ||
                            widget.sync.status == SyncStatus.resetting ||
                            _connectingDrive
                        ? null
                        : widget.sync.needsGoogleReconnect
                        ? _reconnectDrive
                        : widget.sync.syncNow,
                    icon: _connectingDrive
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            widget.sync.needsGoogleReconnect
                                ? Icons.login_rounded
                                : Icons.sync_rounded,
                          ),
                    label: Text(
                      widget.sync.needsGoogleReconnect
                          ? _connectingDrive
                                ? 'Reconectando…'
                                : 'Reconectar Google'
                          : 'Sincronizar agora',
                    ),
                  ),
                  TextButton(
                    onPressed: widget.sync.disconnect,
                    child: const Text('Desconectar'),
                  ),
                ],
              ],
            ),
          ],
        ),
        _ConflictsSection(sync: widget.sync),
        _Section(
          title: 'Segurança',
          icon: Icons.security_rounded,
          children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.lock_outline_rounded),
              title: Text('Segredos protegidos pelo sistema'),
              subtitle: Text(
                'API key, tokens OAuth e chave de sincronização não entram no '
                'SQLite, logs, exportações ou Google Drive.',
              ),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.cloud_done_outlined),
              title: Text('Drive criptografado'),
              subtitle: Text(
                'Argon2id + AES-256-GCM, com nonce novo a cada envio.',
              ),
            ),
            const Divider(height: 28),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.delete_forever_outlined,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Resetar aplicativo',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: const Text(
                'Apaga todos os dados, configurações e conexões. Se o Drive '
                'estiver ligado, o arquivo remoto será resetado primeiro.',
              ),
              trailing: _resettingApp
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : OutlinedButton(
                      onPressed: _resetApp,
                      child: const Text('Resetar'),
                    ),
            ),
          ],
        ),
      ],
    ),
  );

  String _syncStatus(SyncStatus status) => switch (status) {
    SyncStatus.disconnected => 'Desconectado',
    SyncStatus.syncing => 'Sincronizando…',
    SyncStatus.synced => 'Sincronizado',
    SyncStatus.pending => 'Alterações pendentes',
    SyncStatus.conflict => 'Conflito precisa de revisão',
    SyncStatus.error => 'Erro de sincronização',
    SyncStatus.resetting => 'Resetando Drive…',
  };
}

class _FactoryResetDialog extends StatefulWidget {
  const _FactoryResetDialog();

  @override
  State<_FactoryResetDialog> createState() => _FactoryResetDialogState();
}

class _FactoryResetDialogState extends State<_FactoryResetDialog> {
  final _controller = TextEditingController();
  bool get _confirmed => _controller.text.trim() == 'RESETAR';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    icon: Icon(
      Icons.warning_amber_rounded,
      color: Theme.of(context).colorScheme.error,
    ),
    title: const Text('Resetar todo o aplicativo?'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Essa ação apaga finanças, nome, tema, IA e conexão Google. '
          'Ela não pode ser desfeita.',
        ),
        const SizedBox(height: 14),
        const Text('Digite RESETAR para confirmar.'),
        const SizedBox(height: 8),
        TextField(
          key: const ValueKey('factory-reset-confirmation'),
          controller: _controller,
          autofocus: true,
          autocorrect: false,
          enableSuggestions: false,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(labelText: 'Confirmação'),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: _confirmed ? () => Navigator.pop(context, true) : null,
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
        ),
        child: const Text('Apagar tudo'),
      ),
    ],
  );
}

class _SyncPasswordDialog extends StatefulWidget {
  const _SyncPasswordDialog();

  @override
  State<_SyncPasswordDialog> createState() => _SyncPasswordDialogState();
}

class _SyncPasswordDialogState extends State<_SyncPasswordDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Senha de sincronização'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Use a mesma senha nos dispositivos. Ela deve ter ao menos 12 '
          'caracteres e não pode ser recuperada pelo Google.',
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          autofocus: true,
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          onSubmitted: (value) => Navigator.pop(context, value),
          decoration: const InputDecoration(labelText: 'Senha'),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _controller.text),
        child: const Text('Continuar'),
      ),
    ],
  );
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 14),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    ),
  );
}

class _ConflictsSection extends StatefulWidget {
  const _ConflictsSection({required this.sync});
  final DriveSyncController sync;

  @override
  State<_ConflictsSection> createState() => _ConflictsSectionState();
}

class _ConflictsSectionState extends State<_ConflictsSection> {
  @override
  Widget build(BuildContext context) => _Section(
    title: 'Conflitos',
    icon: Icons.compare_arrows_rounded,
    children: [
      FutureBuilder<List<SyncConflictRecord>>(
        future: widget.sync.readConflicts(),
        builder: (context, snapshot) {
          final conflicts = snapshot.data ?? const [];
          if (conflicts.isEmpty) {
            return const Text('Nenhum conflito pendente.');
          }
          return Column(
            children: [
              for (final conflict in conflicts)
                _ConflictCard(
                  conflict: conflict,
                  onResolved: () => setState(() {}),
                  sync: widget.sync,
                ),
            ],
          );
        },
      ),
    ],
  );
}

class _ConflictCard extends StatelessWidget {
  const _ConflictCard({
    required this.conflict,
    required this.sync,
    required this.onResolved,
  });
  final SyncConflictRecord conflict;
  final DriveSyncController sync;
  final VoidCallback onResolved;

  @override
  Widget build(BuildContext context) {
    final local = Map<String, dynamic>.from(
      jsonDecode(conflict.localJson) as Map,
    );
    final remote = Map<String, dynamic>.from(
      jsonDecode(conflict.remoteJson) as Map,
    );
    final differences = local.keys
        .where(
          (key) =>
              !{'updatedAt', 'originDeviceId', 'vectorClock'}.contains(key) &&
              local[key] != remote[key],
        )
        .take(6)
        .map((key) => '$key: ${local[key]} → ${remote[key]}')
        .join('\n');
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${conflict.entityType} · ${conflict.entityId}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(differences),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    await sync.resolveConflict(conflict, useRemote: false);
                    onResolved();
                  },
                  child: const Text('Manter deste dispositivo'),
                ),
                FilledButton.tonal(
                  onPressed: () async {
                    await sync.resolveConflict(conflict, useRemote: true);
                    onResolved();
                  },
                  child: const Text('Usar versão do Drive'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncStatusIcon extends StatelessWidget {
  const _SyncStatusIcon({required this.status});
  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == SyncStatus.syncing) {
      return const SizedBox.square(
        dimension: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return Icon(switch (status) {
      SyncStatus.synced => Icons.cloud_done_rounded,
      SyncStatus.pending => Icons.cloud_upload_outlined,
      SyncStatus.conflict => Icons.warning_amber_rounded,
      SyncStatus.error => Icons.cloud_off_rounded,
      SyncStatus.resetting => Icons.delete_sweep_outlined,
      SyncStatus.disconnected => Icons.cloud_off_outlined,
      SyncStatus.syncing => Icons.sync_rounded,
    });
  }
}
