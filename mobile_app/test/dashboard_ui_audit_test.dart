import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/app/app_router.dart';
import 'package:mobile_app/app/app_theme.dart';
import 'package:mobile_app/features/dashboard/dashboard_screen.dart';
import 'package:mobile_app/models/dashboard_payload.dart';
import 'package:mobile_app/services/app_script_dashboard_service.dart';

void main() {
  testWidgets('dashboard shell keeps core Esquilo structure on mobile', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final payload = _fixturePayload();
    final service = _FakeDashboardService(payload);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.themeData,
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case AppRouter.dashboardRoute:
              return MaterialPageRoute<void>(
                builder: (_) => DashboardScreen(service: service),
                settings: settings,
              );
            default:
              return AppRouter.onGenerateRoute(settings);
          }
        },
        initialRoute: AppRouter.dashboardRoute,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Esquilo Invest'), findsOneWidget);
    expect(find.text('Resumo executivo'), findsWidgets);
    expect(find.text('Alocacao da carteira'), findsOneWidget);
    expect(find.text('Visao geral'), findsOneWidget);
    expect(find.text('Categorias'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);

    final logoImage = tester.widget<Image>(find.byType(Image).first);
    expect(logoImage.image, isA<AssetImage>());
    expect((logoImage.image as AssetImage).assetName, 'assets/brand/esquilo.png');

    await tester.scrollUntilVisible(find.text('Radar da carteira'), 240);
    await tester.pumpAndSettle();
    expect(find.text('Radar da carteira'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Plano de acao'), 240);
    await tester.pumpAndSettle();
    expect(find.text('Plano de acao'), findsOneWidget);

    await tester.tap(find.text('Categorias'));
    await tester.pumpAndSettle();

    expect(find.text('Detalhe por categoria'), findsOneWidget);
    expect(find.text('Acoes'), findsOneWidget);

    await tester.tap(find.text('Acoes').first);
    await tester.pumpAndSettle();

    expect(find.text('Detalhe da categoria'), findsOneWidget);
    expect(find.text('PETR4'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();

    expect(find.text('Score da carteira'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Esquilo IA'), 240);
    await tester.pumpAndSettle();
    expect(find.text('Esquilo IA'), findsOneWidget);
  });
}

class _FakeDashboardService extends AppScriptDashboardService {
  _FakeDashboardService(this.payload) : super();

  final DashboardPayload payload;

  @override
  bool get isConfigured => true;

  @override
  Future<DashboardPayload> fetchDashboard() async => payload;

  @override
  Future<String> fetchAiAnalysis() async => 'Leitura validada para a rodada.';

  @override
  void dispose() {}
}

DashboardPayload _fixturePayload() {
  return DashboardPayload.fromJson(<String, dynamic>{
    'summary': <String, dynamic>{
      'total': 'R\$ 100.000,00',
      'totalRaw': 100000,
      'totalPerformanceRaw': 0.12,
      'acoes': 'R\$ 40.000,00',
      'fundos': 'R\$ 35.000,00',
      'previdencia': 'R\$ 25.000,00',
    },
    'score': <String, dynamic>{
      'score': 82,
      'status': 'Seguro',
      'explanation': 'Carteira equilibrada para a rodada.',
      'breakdown': <String, dynamic>{
        'capitalPoints': 20,
        'categoryPoints': 21,
        'institutionPoints': 19,
        'healthPoints': 22,
      },
    },
    'messaging': <String, dynamic>{
      'executiveSummary': <String, dynamic>{
        'statusText': 'Carteira equilibrada no ciclo atual.',
        'performanceText': '+12,0% no round',
        'scoreStatusText': 'Leitura segura',
      },
      'primaryRecommendation': <String, dynamic>{
        'title': 'Manter plano',
        'reason': 'Sem desvios criticos nas macroclasses.',
        'impact': 'Mantem a consistencia do portifolio.',
        'actionText': 'Seguir monitoramento',
        'asset': 'PETR4',
      },
      'supportNotes': <String, dynamic>{
        'scoreNote': 'Score sustentado pela diversificacao atual.',
        'squadTip': 'Revisar concentracao mensalmente.',
      },
      'alertsSummary': <String, dynamic>{
        'headline': 'Sem alertas graves.',
        'lines': <String>['Acoes sob controle', 'Fundos estaveis'],
      },
    },
    'actionPlan': <String, dynamic>{
      'acao_principal': 'Manter plano',
      'prioridade': 'Baixa',
      'justificativa': 'Carteira aderente ao perfil e sem pressao critica.',
    },
    'portfolioDecision': <String, dynamic>{
      'actionText': 'Manter posicoes e revisar concentracao.',
      'focusCategoryLabel': 'Acoes',
      'urgency': 'Baixa',
      'status': 'Controlado',
      'criticalPoint': 'Nenhum ponto critico',
    },
    'categorySnapshots': <Map<String, dynamic>>[
      <String, dynamic>{
        'key': 'acoes',
        'label': 'Acoes',
        'totalLabel': 'R\$ 40.000,00',
        'shareLabel': '40,0%',
        'shareRaw': 0.4,
        'performanceLabel': '+14,0%',
        'status': 'Seguro',
        'recommendation': 'Manter',
        'color': '#F59E0B',
      },
      <String, dynamic>{
        'key': 'fundos',
        'label': 'Fundos',
        'totalLabel': 'R\$ 35.000,00',
        'shareLabel': '35,0%',
        'shareRaw': 0.35,
        'performanceLabel': '+10,0%',
        'status': 'Seguro',
        'recommendation': 'Manter',
        'color': '#38BDF8',
      },
      <String, dynamic>{
        'key': 'previdencia',
        'label': 'Previdencia',
        'totalLabel': 'R\$ 25.000,00',
        'shareLabel': '25,0%',
        'shareRaw': 0.25,
        'performanceLabel': '+8,0%',
        'status': 'Seguro',
        'recommendation': 'Manter',
        'color': '#6EE7B7',
      },
    ],
    'categories': <String, dynamic>{
      'actions': <String, dynamic>{
        'label': 'Acoes',
        'status': 'Seguro',
        'risk': 'Controlado',
        'recommendation': 'Manter',
        'primaryIssue': <String, dynamic>{
          'asset': 'PETR4',
          'message': 'Acompanhamento em linha com o plano.',
        },
      },
      'funds': <String, dynamic>{
        'label': 'Fundos',
        'status': 'Seguro',
        'risk': 'Controlado',
        'recommendation': 'Manter',
        'primaryIssue': <String, dynamic>{
          'asset': 'KNSC11',
          'message': 'Fundos aderentes ao mandato atual.',
        },
      },
      'previdencia': <String, dynamic>{
        'label': 'Previdencia',
        'status': 'Seguro',
        'risk': 'Controlado',
        'recommendation': 'Manter',
        'primaryIssue': <String, dynamic>{
          'asset': 'Plano XP',
          'message': 'Previdencia dentro da faixa planejada.',
        },
      },
    },
    'actions': <Map<String, dynamic>>[
      <String, dynamic>{
        'ticker': 'PETR4',
        'name': 'Petrobras',
        'institution': 'XP',
        'positionValue': 'R\$ 20.000,00',
        'rendimentoPct': '+18,0%',
        'rent': 0.18,
        'portfolioShareLabel': '20,0%',
        'portfolioShareRaw': 0.2,
        'recommendation': 'Manter',
        'statusLabel': 'Comprado',
        'currentPrice': 'R\$ 36,00',
        'avgPrice': 'PM R\$ 30,00',
        'qty': '400 cotas',
        'chartUrl': 'https://example.com',
      },
      <String, dynamic>{
        'ticker': 'ITSA4',
        'name': 'Itausa',
        'institution': 'BTG',
        'positionValue': 'R\$ 20.000,00',
        'rendimentoPct': '+10,0%',
        'rent': 0.10,
        'portfolioShareLabel': '20,0%',
        'portfolioShareRaw': 0.2,
        'recommendation': 'Manter',
        'statusLabel': 'Comprado',
        'currentPrice': 'R\$ 10,00',
        'avgPrice': 'PM R\$ 9,20',
        'qty': '2000 cotas',
        'chartUrl': 'https://example.com',
      },
    ],
    'investments': <Map<String, dynamic>>[
      <String, dynamic>{
        'name': 'KNSC11',
        'classification': 'FII Papel',
        'strategy': 'Renda',
        'institution': 'XP',
        'valorAtual': 'R\$ 35.000,00',
        'performanceLabel': '+10,0%',
        'rentPct': '+10,0%',
        'rentRaw': 0.10,
        'portfolioShareLabel': '35,0%',
        'portfolioShareRaw': 0.35,
        'recommendation': 'Manter',
        'statusLabel': 'Ativo',
        'benchmark': 'IFIX',
        'profileLabel': 'Moderado',
        'detailUrl': 'https://example.com',
      },
    ],
    'previdencias': <Map<String, dynamic>>[
      <String, dynamic>{
        'name': 'Plano XP',
        'classification': 'Previdencia',
        'profileLabel': 'Longo prazo',
        'institution': 'XP',
        'valorAtual': 'R\$ 25.000,00',
        'performanceLabel': '+8,0%',
        'rentPct': '+8,0%',
        'rentRaw': 0.08,
        'portfolioShareLabel': '25,0%',
        'portfolioShareRaw': 0.25,
        'recommendation': 'Manter',
        'statusLabel': 'Ativo',
        'detailUrl': 'https://example.com',
      },
    ],
    'dataSource': 'spreadsheet-fallback',
    'sourceWarning': '',
    'generalAdvice': 'Carteira em linha com o plano atual.',
    'updatedAt': '2026-03-28T01:00:00.000Z',
  });
}
