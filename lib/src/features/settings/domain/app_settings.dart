class AISettings {
  const AISettings({
    this.provider = 'openai',
    this.endpoint = 'https://api.openai.com/v1',
    this.model = 'gpt-4.1-mini',
  });

  factory AISettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AISettings();
    return AISettings(
      provider: json['provider'] as String? ?? 'openai',
      endpoint: json['endpoint'] as String? ?? 'https://api.openai.com/v1',
      model: json['model'] as String? ?? 'gpt-4.1-mini',
    );
  }

  final String provider;
  final String endpoint;
  final String model;

  AISettings copyWith({String? provider, String? endpoint, String? model}) =>
      AISettings(
        provider: provider ?? this.provider,
        endpoint: endpoint ?? this.endpoint,
        model: model ?? this.model,
      );

  Map<String, dynamic> toJson() => {
    'provider': provider,
    'endpoint': endpoint,
    'model': model,
  };
}

class SyncSettings {
  const SyncSettings({
    this.enabled = false,
    this.autoSync = true,
    this.accountEmail,
  });

  factory SyncSettings.fromJson(Map<String, dynamic>? json) => SyncSettings(
    enabled: json?['enabled'] as bool? ?? false,
    autoSync: json?['autoSync'] as bool? ?? true,
    accountEmail: json?['accountEmail'] as String?,
  );

  final bool enabled;
  final bool autoSync;
  final String? accountEmail;

  SyncSettings copyWith({
    bool? enabled,
    bool? autoSync,
    String? accountEmail,
    bool clearAccount = false,
  }) => SyncSettings(
    enabled: enabled ?? this.enabled,
    autoSync: autoSync ?? this.autoSync,
    accountEmail: clearAccount ? null : accountEmail ?? this.accountEmail,
  );

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'autoSync': autoSync,
    'accountEmail': accountEmail,
  };
}
