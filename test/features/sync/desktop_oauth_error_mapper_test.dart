import 'dart:async';

import 'package:saldo_sh/src/features/sync/oauth/desktop_oauth_error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

void main() {
  const mapper = DesktopOAuthErrorMapper();

  test('explains invalid desktop OAuth client configuration', () {
    final result = mapper.map(
      oauth2.AuthorizationException('invalid_client', null, null),
    );

    expect(result.message, contains('App para computador'));
    expect(result.message, contains('GOOGLE_DESKTOP_CLIENT_SECRET'));
  });

  test('explains expired or reused authorization codes', () {
    final result = mapper.map(
      oauth2.AuthorizationException('invalid_grant', null, null),
    );

    expect(result.message, contains('expirou'));
    expect(result.message, contains('Client ID'));
  });

  test('does not expose arbitrary provider descriptions', () {
    final result = mapper.map(
      oauth2.AuthorizationException(
        'custom error <script>',
        'sensitive provider description',
        null,
      ),
    );

    expect(result.message, isNot(contains('sensitive')));
    expect(result.message, isNot(contains('<script>')));
  });

  test('maps callback timeout to an actionable message', () {
    final result = mapper.map(TimeoutException('raw timeout'));

    expect(result.message, contains('expirou'));
    expect(result.message, isNot(contains('raw timeout')));
  });
}
