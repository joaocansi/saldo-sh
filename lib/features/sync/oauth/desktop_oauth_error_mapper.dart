import 'dart:async';
import 'dart:io';

import 'package:oauth2/oauth2.dart' as oauth2;

import 'drive_auth_service.dart';

class DesktopOAuthErrorMapper {
  const DesktopOAuthErrorMapper();

  DriveAuthException map(Object error) {
    if (error is DriveAuthException) return error;
    if (error is oauth2.AuthorizationException) {
      return _authorizationError(error.error);
    }
    if (error is TimeoutException) {
      return const DriveAuthException(
        'A autorização expirou. Volte ao aplicativo e tente novamente.',
      );
    }
    if (error is SocketException) {
      return const DriveAuthException(
        'Sem conexão ao trocar a autorização com o Google.',
      );
    }
    if (error is FormatException) {
      final message = error.message.toString().toLowerCase();
      if (message.contains('state')) {
        return const DriveAuthException(
          'A resposta de segurança do Google não corresponde à solicitação. '
          'Feche as abas antigas e tente conectar novamente.',
        );
      }
      return const DriveAuthException(
        'O Google retornou uma resposta OAuth inválida. Confirme que o Client '
        'ID usado no Windows é do tipo “App para computador”.',
      );
    }
    return const DriveAuthException(
      'Não foi possível concluir a autorização com o Google.',
    );
  }

  DriveAuthException _authorizationError(String code) => switch (code) {
    'invalid_client' || 'unauthorized_client' => const DriveAuthException(
      'O Google recusou as credenciais OAuth do Windows. Confirme o Client ID '
      'do tipo “App para computador” e, se essa credencial possuir um secret, '
      'recompile também com GOOGLE_DESKTOP_CLIENT_SECRET.',
    ),
    'invalid_grant' => const DriveAuthException(
      'O código de autorização expirou, já foi usado ou pertence a outro '
      'Client ID. Tente novamente com um Client ID do tipo “App para '
      'computador”.',
    ),
    'access_denied' => const DriveAuthException(
      'A autorização do Google Drive foi cancelada ou negada.',
    ),
    'redirect_uri_mismatch' => const DriveAuthException(
      'O Client ID não aceita o callback local. Use uma credencial OAuth do '
      'tipo “App para computador”.',
    ),
    _ => DriveAuthException(
      'O Google recusou a autorização OAuth (${_safeCode(code)}).',
    ),
  };

  String _safeCode(String value) {
    final sanitized = value.replaceAll(RegExp(r'[^a-zA-Z0-9_.-]'), '');
    return sanitized.isEmpty ? 'erro desconhecido' : sanitized;
  }
}
