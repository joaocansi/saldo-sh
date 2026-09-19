import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

import '../domain/sync_models.dart';

class GoogleDriveRemoteStore implements DriveRemoteStore {
  GoogleDriveRemoteStore(this._client) : _api = drive.DriveApi(_client);

  static const fileName = 'verde-sync-v1.bin';

  final http.Client _client;
  final drive.DriveApi _api;

  @override
  Future<RemoteSnapshot?> download() => _translateErrors(() async {
    final files = await _api.files
        .list(
          spaces: 'appDataFolder',
          q: "name = '$fileName' and trashed = false",
          pageSize: 2,
          $fields: 'files(id,name,version)',
        )
        .timeout(const Duration(seconds: 30));
    if ((files.files?.length ?? 0) > 1) {
      throw const DriveRemoteException(
        'Há mais de um snapshot do saldo.sh no Drive.',
      );
    }
    final file = files.files?.firstOrNull;
    final id = file?.id;
    if (id == null) return null;
    final version = file?.version;
    if (version == null || version.isEmpty) {
      throw const DriveRemoteException(
        'O Drive não retornou a versão do arquivo de sincronização.',
      );
    }
    final response = await _client
        .get(
          Uri.parse('https://www.googleapis.com/drive/v3/files/$id?alt=media'),
        )
        .timeout(const Duration(seconds: 30));
    _ensureSuccess(response);
    return RemoteSnapshot(
      fileId: id,
      bytes: response.bodyBytes,
      version: version,
    );
  });

  @override
  Future<void> upload(Uint8List bytes, {RemoteSnapshot? previous}) =>
      _translateErrors(() async {
        if (bytes.length > 50 * 1024 * 1024) {
          throw const FormatException('Snapshot acima do limite de 50 MB.');
        }
        if (previous == null) {
          await _create(bytes);
          return;
        }
        final current =
            await _api.files
                    .get(previous.fileId, $fields: 'id,version')
                    .timeout(const Duration(seconds: 30))
                as drive.File;
        if (current.version == null || current.version!.isEmpty) {
          throw const DriveRemoteException(
            'O Drive não retornou a versão do arquivo de sincronização.',
          );
        }
        if (current.version != previous.version) {
          throw const RemotePreconditionFailed();
        }
        final response = await _client
            .patch(
              Uri.parse(
                'https://www.googleapis.com/upload/drive/v3/files/'
                '${previous.fileId}?uploadType=media',
              ),
              headers: {'content-type': 'application/octet-stream'},
              body: bytes,
            )
            .timeout(const Duration(seconds: 30));
        if (response.statusCode == 412) throw const RemotePreconditionFailed();
        _ensureSuccess(response);
      });

  Future<void> _create(Uint8List bytes) async {
    final boundary = 'verde-${Random.secure().nextInt(1 << 32)}';
    final metadata = jsonEncode({
      'name': fileName,
      'parents': ['appDataFolder'],
      'mimeType': 'application/octet-stream',
    });
    final prefix = utf8.encode(
      '--$boundary\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n'
      '$metadata\r\n--$boundary\r\nContent-Type: application/octet-stream\r\n\r\n',
    );
    final suffix = utf8.encode('\r\n--$boundary--\r\n');
    final request =
        http.Request(
            'POST',
            Uri.parse(
              'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart',
            ),
          )
          ..headers['content-type'] = 'multipart/related; boundary=$boundary'
          ..bodyBytes = Uint8List.fromList([...prefix, ...bytes, ...suffix]);
    final streamed = await _client
        .send(request)
        .timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed)
        .timeout(const Duration(seconds: 30));
    _ensureSuccess(response);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _driveError(
        response.statusCode,
        _errorReason(response.body),
        response.body,
      );
    }
  }

  Future<T> _translateErrors<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DriveRemoteException {
      rethrow;
    } on RemotePreconditionFailed {
      rethrow;
    } on drive.DetailedApiRequestError catch (error) {
      throw _driveError(
        error.status,
        error.errors.firstOrNull?.reason,
        error.message,
      );
    } on drive.ApiRequestError catch (error) {
      throw DriveRemoteException(
        'O Google Drive recusou a solicitação.',
        reason: error.message,
      );
    } on TimeoutException {
      throw const DriveRemoteException('A conexão com o Google Drive expirou.');
    } on SocketException {
      throw const DriveRemoteException('Sem conexão com o Google Drive.');
    } on http.ClientException {
      throw const DriveRemoteException(
        'Falha de rede ao acessar o Google Drive.',
      );
    }
  }

  DriveRemoteException _driveError(
    int? status,
    String? reason,
    String? rawMessage,
  ) {
    final normalizedReason = reason?.toLowerCase() ?? '';
    final normalizedMessage = rawMessage?.toLowerCase() ?? '';
    if (status == 401) {
      return DriveRemoteException(
        'A sessão Google expirou. Desconecte e conecte novamente.',
        status: status,
        reason: reason,
      );
    }
    if (status == 403 &&
        (normalizedReason == 'accessnotconfigured' ||
            normalizedMessage.contains('has not been used') ||
            normalizedMessage.contains('is disabled'))) {
      return DriveRemoteException(
        'Ative a Google Drive API no mesmo projeto do Client ID OAuth.',
        status: status,
        reason: reason,
      );
    }
    if (status == 403) {
      return DriveRemoteException(
        'Acesso ao Drive negado. Autorize novamente o escopo drive.appdata.',
        status: status,
        reason: reason,
      );
    }
    if (status == 404) {
      return DriveRemoteException(
        'O arquivo de sincronização não foi encontrado no Drive.',
        status: status,
        reason: reason,
      );
    }
    if (status == 429) {
      return DriveRemoteException(
        'Limite temporário do Google Drive atingido. Tente mais tarde.',
        status: status,
        reason: reason,
      );
    }
    if (status != null && status >= 500) {
      return DriveRemoteException(
        'O Google Drive está temporariamente indisponível (HTTP $status).',
        status: status,
        reason: reason,
      );
    }
    return DriveRemoteException(
      'Google Drive retornou HTTP ${status ?? 'desconhecido'}.',
      status: status,
      reason: reason,
    );
  }

  String? _errorReason(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map) return null;
      final error = decoded['error'];
      if (error is! Map) return null;
      final errors = error['errors'];
      if (errors is! List || errors.isEmpty || errors.first is! Map) {
        return null;
      }
      return (errors.first as Map)['reason']?.toString();
    } catch (_) {
      return null;
    }
  }
}

class DriveRemoteException implements Exception {
  const DriveRemoteException(this.message, {this.status, this.reason});

  final String message;
  final int? status;
  final String? reason;

  @override
  String toString() => message;
}
