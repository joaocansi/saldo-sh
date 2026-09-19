import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/security/secret_store.dart';
import 'android_drive_token_store.dart';
import 'desktop_oauth_error_mapper.dart';
import 'drive_auth_service.dart';
import 'google_oauth_client_id.dart';

class GoogleDriveAuthService implements DriveAuthService {
  GoogleDriveAuthService(this._secretStore)
    : _androidTokens = AndroidDriveTokenStore(_secretStore);

  static const _scopes = [drive.DriveApi.driveAppdataScope];
  static const _authorizationEndpoint =
      'https://accounts.google.com/o/oauth2/v2/auth';
  static const _tokenEndpoint = 'https://oauth2.googleapis.com/token';
  static const _androidServerClientId = String.fromEnvironment(
    'GOOGLE_ANDROID_SERVER_CLIENT_ID',
  );
  static const _desktopClientId = String.fromEnvironment(
    'GOOGLE_DESKTOP_CLIENT_ID',
  );
  static const _desktopClientSecret = String.fromEnvironment(
    'GOOGLE_DESKTOP_CLIENT_SECRET',
  );
  static const _desktopErrorMapper = DesktopOAuthErrorMapper();

  final SecretStore _secretStore;
  final AndroidDriveTokenStore _androidTokens;
  bool _androidInitialized = false;

  @override
  Future<DriveAuthSession> connect() {
    if (Platform.isAndroid) return _connectAndroid();
    if (Platform.isWindows) return _connectWindows();
    throw UnsupportedError(
      'Google Drive está disponível no Android e Windows.',
    );
  }

  @override
  Future<DriveAuthSession?> restore() async {
    if (Platform.isAndroid) return _restoreAndroid();
    if (!Platform.isWindows || _desktopClientId.isEmpty) return null;
    final raw = await _secretStore.read(SecretKeys.driveCredentials);
    if (raw == null || raw.isEmpty) return null;
    try {
      final credentials = oauth2.Credentials.fromJson(raw);
      final client = oauth2.Client(
        credentials,
        identifier: _desktopClientId,
        secret: _desktopClientSecret.isEmpty ? null : _desktopClientSecret,
        basicAuth: false,
        onCredentialsRefreshed: _saveCredentials,
      );
      return DriveAuthSession(
        client: client,
        accountEmail: await _driveAccountEmail(client),
      );
    } catch (_) {
      await _secretStore.delete(SecretKeys.driveCredentials);
      return null;
    }
  }

  @override
  Future<void> invalidateCachedSession() async {
    if (Platform.isAndroid) {
      final accessToken = await _androidTokens.readAccessToken();
      await _androidTokens.clearAuthorization();
      if (accessToken != null) {
        try {
          await _initializeAndroid();
          await GoogleSignIn.instance.authorizationClient
              .clearAuthorizationToken(accessToken: accessToken);
        } catch (_) {
          // Clearing our own cache is sufficient to require a fresh restore.
        }
      }
    } else if (Platform.isWindows) {
      await _secretStore.delete(SecretKeys.driveCredentials);
    }
  }

  Future<DriveAuthSession?> _restoreAndroid() async {
    final cached = await _androidTokens.readValid();
    if (cached != null) {
      return DriveAuthSession(
        client: _BearerClient(cached.accessToken),
        accountEmail: cached.accountEmail,
      );
    }

    try {
      await _initializeAndroid();
      final authorization = await GoogleSignIn.instance.authorizationClient
          .authorizationForScopes(_scopes);
      if (authorization == null) return null;

      final client = _BearerClient(authorization.accessToken);
      final accountEmail =
          await _driveAccountEmail(client) ??
          await _androidTokens.readAccountEmail();
      if (accountEmail == null || accountEmail.isEmpty) {
        client.close();
        return null;
      }
      await _androidTokens.save(
        accessToken: authorization.accessToken,
        accountEmail: accountEmail,
      );
      return DriveAuthSession(client: client, accountEmail: accountEmail);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> disconnect() async {
    await _secretStore.delete(SecretKeys.driveCredentials);
    await _androidTokens.clear();
    if (Platform.isAndroid) {
      await _initializeAndroid();
      await GoogleSignIn.instance.disconnect();
    }
  }

  Future<DriveAuthSession> _connectAndroid() async {
    if (_androidServerClientId.isEmpty) {
      throw const DriveAuthException(
        'Client ID Web ausente. Recompile com '
        'GOOGLE_ANDROID_SERVER_CLIENT_ID.',
      );
    }
    if (!GoogleOAuthClientId.isValid(_androidServerClientId)) {
      throw const DriveAuthException(
        'GOOGLE_ANDROID_SERVER_CLIENT_ID está incompleto. Use o Client ID Web '
        'inteiro: ele deve começar com o número do projeto, seguido de hífen, '
        'e terminar em .apps.googleusercontent.com.',
      );
    }
    try {
      await _initializeAndroid();
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        throw const DriveAuthException(
          'Login Google indisponível neste dispositivo.',
        );
      }
      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: _scopes,
      );
      final authorization =
          await account.authorizationClient.authorizationForScopes(_scopes) ??
          await account.authorizationClient.authorizeScopes(_scopes);
      await _androidTokens.save(
        accessToken: authorization.accessToken,
        accountEmail: account.email,
      );
      return DriveAuthSession(
        client: authorization.authClient(scopes: _scopes),
        accountEmail: account.email,
      );
    } on GoogleSignInException catch (error) {
      throw DriveAuthException(_googleErrorMessage(error));
    }
  }

  String _googleErrorMessage(GoogleSignInException error) =>
      switch (error.code) {
        GoogleSignInExceptionCode.canceled => 'Login Google cancelado.',
        GoogleSignInExceptionCode.interrupted =>
          'O login Google foi interrompido. Tente novamente.',
        GoogleSignInExceptionCode.clientConfigurationError ||
        GoogleSignInExceptionCode.providerConfigurationError =>
          'Configuração OAuth Android inválida. Verifique o Client ID Web '
              'completo, o cliente Android, package e SHA-1.',
        GoogleSignInExceptionCode.uiUnavailable =>
          'Não foi possível abrir o seletor de conta Google.',
        GoogleSignInExceptionCode.userMismatch =>
          'A conta selecionada não corresponde à sessão Google atual.',
        _ => _unknownGoogleError(error.description),
      };

  String _unknownGoogleError(String? description) {
    final normalized = description?.toLowerCase() ?? '';
    if (normalized.contains('developer console') ||
        normalized.contains('28444') ||
        normalized.contains('audience')) {
      return 'O Google rejeitou a configuração OAuth. Confirme o Client ID '
          'Web completo e que o cliente Android está no mesmo projeto.';
    }
    return 'Não foi possível autenticar com o Google. Confira a conta Google '
        'do aparelho e a configuração OAuth Android.';
  }

  Future<void> _initializeAndroid() async {
    if (_androidInitialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: _androidServerClientId.isEmpty
          ? null
          : _androidServerClientId,
    );
    _androidInitialized = true;
  }

  Future<DriveAuthSession> _connectWindows() async {
    if (_desktopClientId.isEmpty) {
      throw const FormatException(
        'Defina GOOGLE_DESKTOP_CLIENT_ID no build do Windows.',
      );
    }
    if (!GoogleOAuthClientId.isValid(_desktopClientId)) {
      throw const DriveAuthException(
        'GOOGLE_DESKTOP_CLIENT_ID está incompleto ou inválido.',
      );
    }
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    try {
      final redirect = Uri.parse(
        'http://127.0.0.1:${server.port}/oauth2/callback',
      );
      final grant = oauth2.AuthorizationCodeGrant(
        _desktopClientId,
        Uri.parse(_authorizationEndpoint),
        Uri.parse(_tokenEndpoint),
        secret: _desktopClientSecret.isEmpty ? null : _desktopClientSecret,
        basicAuth: false,
        onCredentialsRefreshed: _saveCredentials,
      );
      final state = _randomState();
      final baseUrl = grant.getAuthorizationUrl(
        redirect,
        scopes: _scopes,
        state: state,
      );
      final authorizationUrl = baseUrl.replace(
        queryParameters: {
          ...baseUrl.queryParameters,
          'access_type': 'offline',
          'prompt': 'consent',
        },
      );
      if (!await launchUrl(
        authorizationUrl,
        mode: LaunchMode.externalApplication,
      )) {
        throw StateError('Não foi possível abrir o navegador.');
      }
      final request = await server.first.timeout(const Duration(minutes: 3));
      if (request.uri.path != '/oauth2/callback') {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        throw const FormatException('Callback OAuth inválido.');
      }
      try {
        final client = await grant.handleAuthorizationResponse(
          request.uri.queryParameters,
        );
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.html
          ..write(
            '<!doctype html><meta charset="utf-8">'
            '<title>saldo.sh</title><p>Conta conectada. Você pode fechar esta aba.</p>',
          );
        await request.response.close();
        await _saveCredentials(client.credentials);
        return DriveAuthSession(
          client: client,
          accountEmail: await _driveAccountEmail(client),
        );
      } catch (error) {
        final authError = _desktopErrorMapper.map(error);
        request.response
          ..statusCode = HttpStatus.badRequest
          ..headers.contentType = ContentType.html
          ..write(_authorizationFailurePage(authError.message));
        await request.response.close();
        throw authError;
      }
    } finally {
      await server.close(force: true);
    }
  }

  Future<void> _saveCredentials(oauth2.Credentials credentials) =>
      _secretStore.write(SecretKeys.driveCredentials, credentials.toJson());

  Future<String?> _driveAccountEmail(http.Client client) async {
    try {
      final about = await drive.DriveApi(client).about
          .get($fields: 'user(emailAddress)');
      return about.user?.emailAddress;
    } catch (_) {
      return null;
    }
  }

  String _randomState() {
    final random = Random.secure();
    return base64UrlEncode(List<int>.generate(32, (_) => random.nextInt(256)))
        .replaceAll('=', '');
  }

  String _authorizationFailurePage(String message) {
    final escaped = const HtmlEscape(HtmlEscapeMode.element).convert(message);
    return '<!doctype html><meta charset="utf-8"><title>saldo.sh</title>'
        '<h1>Falha na autorização</h1><p>$escaped</p>'
        '<p>Volte ao saldo.sh para tentar novamente.</p>';
  }
}

class _BearerClient extends http.BaseClient {
  _BearerClient(this._accessToken, [http.Client? inner])
    : _inner = inner ?? http.Client();

  final String _accessToken;
  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['authorization'] = 'Bearer $_accessToken';
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}
