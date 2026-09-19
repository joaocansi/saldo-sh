class GoogleOAuthClientId {
  const GoogleOAuthClientId._();

  static final _pattern = RegExp(
    r'^\d+-[a-zA-Z0-9_-]+\.apps\.googleusercontent\.com$',
  );

  static bool isValid(String value) => _pattern.hasMatch(value.trim());
}
