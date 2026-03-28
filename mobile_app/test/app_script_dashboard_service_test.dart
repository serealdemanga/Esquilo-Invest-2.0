import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mobile_app/services/app_script_dashboard_service.dart';

void main() {
  test('fetchAiAnalysis requests mobile-brief profile and returns analysis', () async {
    late Uri requestedUri;

    final client = MockClient((http.Request request) async {
      requestedUri = request.url;
      return http.Response(
        jsonEncode(<String, dynamic>{
          'ok': true,
          'resource': 'ai-analysis',
          'data': <String, dynamic>{
            'analysis': 'Linha 1\nLinha 2\nLinha 3\nLinha 4\nLinha 5\nLinha 6\nLinha 7',
          },
        }),
        200,
        headers: <String, String>{'content-type': 'application/json'},
      );
    });

    final service = AppScriptDashboardService(
      client: client,
      baseUrl: 'https://example.com/exec',
      apiToken: 'token-123',
    );

    final analysis = await service.fetchAiAnalysis();

    expect(analysis, contains('Linha 7'));
    expect(requestedUri.host, 'example.com');
    expect(requestedUri.path, '/exec');
    expect(requestedUri.queryParameters['resource'], 'ai-analysis');
    expect(requestedUri.queryParameters['format'], 'json');
    expect(requestedUri.queryParameters['profile'], 'mobile-brief');
    expect(requestedUri.queryParameters['token'], 'token-123');
  });
}
