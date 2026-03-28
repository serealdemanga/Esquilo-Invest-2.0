import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/app_environment.dart';
import '../models/dashboard_payload.dart';

class AppScriptApiException implements Exception {
  const AppScriptApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AppScriptDashboardService {
  AppScriptDashboardService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  bool get isConfigured => AppEnvironment.appScriptBaseUrl.trim().isNotEmpty;

  Future<DashboardPayload> fetchDashboard() async {
    final body = await _getResource('dashboard');
    final data = _mapFrom(body['data']);
    return DashboardPayload.fromJson(data);
  }

  Future<String> fetchAiAnalysis() async {
    final body = await _getResource('ai-analysis');
    final data = _mapFrom(body['data']);
    final analysis = data['analysis'];
    if (analysis is String && analysis.trim().isNotEmpty) {
      return analysis.trim();
    }
    throw const AppScriptApiException('A resposta da Esquilo IA veio vazia.');
  }

  void dispose() {
    _client.close();
  }

  Future<Map<String, dynamic>> _getResource(String resource) async {
    if (!isConfigured) {
      throw const AppScriptApiException(
        'Defina APP_SCRIPT_BASE_URL para conectar o AppScript.',
      );
    }

    final uri = _buildUri(resource);
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppScriptApiException(
        'O AppScript respondeu com HTTP ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const AppScriptApiException(
        'O AppScript nao retornou um envelope JSON valido.',
      );
    }

    final body = decoded.map((key, value) => MapEntry(key.toString(), value));

    if (body['ok'] == true) {
      return body;
    }

    throw AppScriptApiException(
      _stringFrom(body['error'], fallback: 'Falha ao consultar o AppScript.'),
    );
  }

  Uri _buildUri(String resource) {
    final baseUri = Uri.parse(AppEnvironment.appScriptBaseUrl);
    final query = <String, String>{
      ...baseUri.queryParameters,
      'format': 'json',
      'resource': resource,
    };

    if (AppEnvironment.appScriptApiToken.isNotEmpty) {
      query['token'] = AppEnvironment.appScriptApiToken;
    }

    return baseUri.replace(queryParameters: query);
  }

  Map<String, dynamic> _mapFrom(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, data) => MapEntry(key.toString(), data));
    }
    return const <String, dynamic>{};
  }

  String _stringFrom(Object? value, {String fallback = ''}) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    if (value is num || value is bool) {
      return value.toString();
    }
    return fallback;
  }
}
