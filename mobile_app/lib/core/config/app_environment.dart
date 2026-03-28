class AppEnvironment {
  static const String releaseName = 'Pocket Ops';
  static const String version = '2.0.0';
  static const String appScriptBaseUrl = String.fromEnvironment(
    'APP_SCRIPT_BASE_URL',
  );
  static const String appScriptApiToken = String.fromEnvironment(
    'APP_SCRIPT_API_TOKEN',
  );

  static String get releaseLabel => '$releaseName v$version';
}
