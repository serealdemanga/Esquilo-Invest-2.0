import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mobile_app/models/holding_operation_request.dart';
import 'package:mobile_app/services/app_script_dashboard_service.dart';

void main() {
  test(
    'fetchAiAnalysis requests mobile-brief profile and returns analysis',
    () async {
      late Uri requestedUri;

      final client = MockClient((http.Request request) async {
        requestedUri = request.url;
        return http.Response(
          jsonEncode(<String, dynamic>{
            'ok': true,
            'resource': 'ai-analysis',
            'data': <String, dynamic>{
              'analysis':
                  'Linha 1\nLinha 2\nLinha 3\nLinha 4\nLinha 5\nLinha 6\nLinha 7',
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
    },
  );

  test('createHolding posts operational payload to mobile API', () async {
    late http.Request capturedRequest;

    final client = MockClient((http.Request request) async {
      capturedRequest = request;
      return http.Response(
        jsonEncode(<String, dynamic>{
          'ok': true,
          'resource': 'operations',
          'data': <String, dynamic>{
            'message': 'Registro criado com sucesso.',
            'operation': 'insert',
            'table': 'Acoes',
            'keyValue': 'PETR4',
            'affectedRows': 1,
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

    final result = await service.createHolding(
      const HoldingOperationRequest(
        type: 'acoes',
        code: 'PETR4',
        platform: 'XP',
        status: 'Comprado',
        investedValue: '1000',
        currentValue: '1100',
        quantity: '10',
        averagePrice: '100',
        observation: 'Entrada de teste',
        descriptor: 'Swing',
      ),
    );

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.url.queryParameters['resource'], 'operations');
    expect(capturedRequest.url.queryParameters['token'], 'token-123');
    expect(capturedRequest.bodyFields['action'], 'create');
    expect(capturedRequest.bodyFields['type'], 'acoes');
    expect(capturedRequest.bodyFields['ativo'], 'PETR4');
    expect(capturedRequest.bodyFields['quantidade'], '10');
    expect(result.keyValue, 'PETR4');
    expect(result.affectedRows, 1);
  });

  test('updateHoldingStatus posts status action to mobile API', () async {
    late http.Request capturedRequest;

    final client = MockClient((http.Request request) async {
      capturedRequest = request;
      return http.Response(
        jsonEncode(<String, dynamic>{
          'ok': true,
          'resource': 'operations',
          'data': <String, dynamic>{
            'message': 'Status atualizado com sucesso.',
            'operation': 'update',
            'table': 'Acoes',
            'keyValue': 'PETR4',
            'affectedRows': 1,
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

    final result = await service.updateHoldingStatus(
      type: 'acoes',
      code: 'PETR4',
      status: 'Venda',
    );

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.bodyFields['action'], 'status');
    expect(capturedRequest.bodyFields['type'], 'acoes');
    expect(capturedRequest.bodyFields['code'], 'PETR4');
    expect(capturedRequest.bodyFields['status'], 'Venda');
    expect(result.message, 'Status atualizado com sucesso.');
  });
}
