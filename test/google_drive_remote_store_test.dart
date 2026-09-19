import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_application_1/features/sync/data/google_drive_remote_store.dart';
import 'package:flutter_application_1/features/sync/domain/sync_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('explains when the Google Drive API is disabled', () async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({
          'error': {
            'code': 403,
            'message': 'Google Drive API has not been used in project or it is disabled',
            'errors': [
              {'reason': 'accessNotConfigured'},
            ],
          },
        }),
        403,
        headers: {'content-type': 'application/json'},
      ),
    );
    addTearDown(client.close);

    await expectLater(
      GoogleDriveRemoteStore(client).download(),
      throwsA(
        isA<DriveRemoteException>()
            .having((error) => error.status, 'status', 403)
            .having(
              (error) => error.message,
              'message',
              contains('Ative a Google Drive API'),
            ),
      ),
    );
  });

  test('rejects upload when the remote version changed', () async {
    var patchCalled = false;
    final client = MockClient((request) async {
      if (request.method == 'GET' &&
          request.url.path == '/drive/v3/files/file-1') {
        return http.Response(
          jsonEncode({'id': 'file-1', 'version': '8'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      if (request.method == 'PATCH') patchCalled = true;
      return http.Response('{}', 200);
    });
    addTearDown(client.close);

    await expectLater(
      GoogleDriveRemoteStore(client).upload(
        Uint8List.fromList([1, 2, 3]),
        previous: RemoteSnapshot(
          fileId: 'file-1',
          bytes: Uint8List(0),
          version: '7',
        ),
      ),
      throwsA(isA<RemotePreconditionFailed>()),
    );
    expect(patchCalled, isFalse);
  });
}
