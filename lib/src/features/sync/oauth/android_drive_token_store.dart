import 'dart:convert';

import '../../../core/security/secret_store.dart';

class AndroidDriveAuthorization {
  const AndroidDriveAuthorization({
    required this.accessToken,
    required this.accountEmail,
    required this.savedAt,
  });

  final String accessToken;
  final String accountEmail;
  final DateTime savedAt;
}

class AndroidDriveTokenStore {
  AndroidDriveTokenStore(
    this._secrets, {
    DateTime Function()? clock,
    this.maximumAge = const Duration(minutes: 50),
  }) : _clock = clock ?? DateTime.now;

  final SecretStore _secrets;
  final DateTime Function() _clock;
  final Duration maximumAge;

  Future<void> save({
    required String accessToken,
    required String accountEmail,
  }) async {
    if (accessToken.isEmpty || accountEmail.isEmpty) return;
    await Future.wait([
      _secrets.write(
        SecretKeys.driveAndroidAuthorization,
        jsonEncode({
          'access_token': accessToken,
          'account_email': accountEmail,
          'saved_at': _clock().toUtc().millisecondsSinceEpoch,
        }),
      ),
      _secrets.write(SecretKeys.driveAndroidAccountEmail, accountEmail),
    ]);
  }

  Future<AndroidDriveAuthorization?> readValid() async {
    final raw = await _secrets.read(SecretKeys.driveAndroidAuthorization);
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final token = json['access_token'];
      final email = json['account_email'];
      final savedAtMilliseconds = json['saved_at'];
      if (token is! String ||
          token.isEmpty ||
          token.length > 8192 ||
          email is! String ||
          email.isEmpty ||
          email.length > 320 ||
          savedAtMilliseconds is! int) {
        await clearAuthorization();
        return null;
      }
      final savedAt = DateTime.fromMillisecondsSinceEpoch(
        savedAtMilliseconds,
        isUtc: true,
      );
      final age = _clock().toUtc().difference(savedAt);
      if (age.isNegative || age >= maximumAge) {
        await clearAuthorization();
        return null;
      }
      return AndroidDriveAuthorization(
        accessToken: token,
        accountEmail: email,
        savedAt: savedAt,
      );
    } catch (_) {
      await clearAuthorization();
      return null;
    }
  }

  Future<String?> readAccountEmail() async {
    final email = await _secrets.read(SecretKeys.driveAndroidAccountEmail);
    if (email == null || email.isEmpty || email.length > 320) return null;
    return email;
  }

  Future<String?> readAccessToken() async {
    final raw = await _secrets.read(SecretKeys.driveAndroidAuthorization);
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final token = json['access_token'];
      if (token is! String || token.isEmpty || token.length > 8192) return null;
      return token;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAuthorization() =>
      _secrets.delete(SecretKeys.driveAndroidAuthorization);

  Future<void> clear() => Future.wait([
    clearAuthorization(),
    _secrets.delete(SecretKeys.driveAndroidAccountEmail),
  ]);
}
