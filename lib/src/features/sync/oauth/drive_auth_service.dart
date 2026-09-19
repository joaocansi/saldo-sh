import 'package:http/http.dart' as http;

class DriveAuthSession {
  DriveAuthSession({required this.client, this.accountEmail});

  final http.Client client;
  final String? accountEmail;

  void close() => client.close();
}

abstract interface class DriveAuthService {
  Future<DriveAuthSession> connect();
  Future<DriveAuthSession?> restore();
  Future<void> invalidateCachedSession();
  Future<void> disconnect();
}

class DriveAuthException implements Exception {
  const DriveAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
