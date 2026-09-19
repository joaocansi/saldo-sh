import 'package:flutter_application_1/features/sync/oauth/google_oauth_client_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts a complete Google OAuth client ID', () {
    expect(
      GoogleOAuthClientId.isValid(
        '269181570829-example123.apps.googleusercontent.com',
      ),
      isTrue,
    );
  });

  test('rejects an ID missing the numeric project prefix', () {
    expect(
      GoogleOAuthClientId.isValid('example123.apps.googleusercontent.com'),
      isFalse,
    );
  });

  test('rejects empty and unrelated values', () {
    expect(GoogleOAuthClientId.isValid(''), isFalse);
    expect(GoogleOAuthClientId.isValid('not-a-client-id'), isFalse);
  });
}
