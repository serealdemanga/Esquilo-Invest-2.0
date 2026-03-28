import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_router.dart';
import '../../app/app_theme.dart';
import '../../models/dashboard_payload.dart';
import '../../services/app_script_dashboard_service.dart';
import '../dashboard/dashboard_ai_brief_sheet.dart';
import '../dashboard/category_detail_screen.dart';
import '../dashboard/dashboard_home_tab.dart';
import '../dashboard/dashboard_intelligence_tab.dart';
import '../dashboard/dashboard_portfolio_tab.dart';
import '../dashboard/dashboard_profile_tab.dart';
import '../dashboard/dashboard_controller.dart';
import '../dashboard/dashboard_shell.dart';
import '../dashboard/holding_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    this.service,
    this.initialTabIndex = dashboardHomeTabIndex,
    this.openAiOnStart = false,
  });

  final AppScriptDashboardService? service;
  final int initialTabIndex;
  final bool openAiOnStart;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardController _controller;
  late int _selectedIndex;
  late int _lastPrimaryIndex;
  late bool _pendingAiOpen;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
    _lastPrimaryIndex = widget.initialTabIndex.clamp(
      dashboardHomeTabIndex,
      dashboardPortfolioTabIndex,
    );
    _pendingAiOpen = widget.openAiOnStart;
    _controller = DashboardController(
      widget.service ?? AppScriptDashboardService(),
    );
    _controller.loadDashboard();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final payload = _controller.dashboard;
        if (payload != null && _pendingAiOpen) {
          _pendingAiOpen = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _openAiBrief(context, payload);
          });
        }

        return Scaffold(
          extendBody: true,
          body: DashboardShellBackground(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: <Widget>[
                  DashboardHeaderBar(
                    subtitle:
                        _selectedIndex == dashboardProfileTabIndex
                            ? 'Base operacional'
                            : 'Leitura inteligente da carteira',
                    trailing: IconButton.filledTonal(
                      onPressed: _openBaseView,
                      tooltip: 'Abrir Base',
                      icon: const Icon(Icons.person_rounded),
                    ),
                  ),
                  if (_controller.dashboardErrorMessage != null &&
                      payload != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: _InlineWarning(
                        message: _userFacingDashboardMessage(
                          _controller.dashboardErrorMessage!,
                          isConfigured: true,
                        ),
                      ),
                    ),
                  Expanded(
                    child: payload == null
                        ? _DashboardStateView(
                            isLoading: _controller.isLoading,
                            isConfigured: _controller.isConfigured,
                            message: _userFacingDashboardMessage(
                              _controller.dashboardErrorMessage,
                              isConfigured: _controller.isConfigured,
                            ),
                            onRefresh: _controller.loadDashboard,
                          )
                        : IndexedStack(
                            index: _selectedIndex,
                            children: <Widget>[
                              DashboardHomeTab(
                                payload: payload,
                                onRefresh: _controller.loadDashboard,
                                onOpenCategory: (String key) =>
                                    _openCategory(context, payload, key),
                                onOpenAi: () => _openAiBrief(context, payload),
                                isAiLoading: _controller.isAiLoading,
                              ),
                              DashboardIntelligenceTab(
                                payload: payload,
                                aiAnalysis: _controller.aiAnalysis,
                                aiErrorMessage: _controller.aiErrorMessage,
                                isAiLoading: _controller.isAiLoading,
                                onRefresh: _controller.loadDashboard,
                                onLoadAi: _controller.refreshAiAnalysis,
                                onOpenCategory: (String key) =>
                                    _openCategory(context, payload, key),
                                onOpenTicker: (String ticker) =>
                                    _openTicker(context, payload, ticker),
                              ),
                              DashboardPortfolioTab(
                                payload: payload,
                                onRefresh: _controller.loadDashboard,
                                onOpenCategory: (String key) =>
                                    _openCategory(context, payload, key),
                                onOpenHolding: (PortfolioHolding holding) =>
                                    _openHolding(context, payload, holding),
                                onOpenTicker: (String ticker) =>
                                    _openTicker(context, payload, ticker),
                              ),
                              DashboardProfileTab(
                                payload: payload,
                                backendHealth: _controller.backendHealth,
                                onRefresh: _controller.loadDashboard,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: DashboardBottomDock(
            selectedIndex: _lastPrimaryIndex,
            onSelected: _setPrimaryNavigationIndex,
            onOpenAi:
                payload == null ? () {} : () => _openAiBrief(context, payload),
          ),
        );
      },
    );
  }

  void _openCategory(
    BuildContext context,
    DashboardPayload payload,
    String categoryKey,
  ) {
    final snapshot = payload.snapshotFor(categoryKey);
    if (snapshot == null) return;

    Navigator.of(context).pushNamed(
      AppRouter.categoryDetailRoute,
      arguments: CategoryDetailArgs(
        snapshot: snapshot,
        health: payload.healthFor(categoryKey),
        holdings: payload.holdingsFor(categoryKey),
        ranking: payload.assetRanking,
      ),
    );
  }

  void _openHolding(
    BuildContext context,
    DashboardPayload payload,
    PortfolioHolding holding,
  ) {
    Navigator.of(context).pushNamed(
      AppRouter.holdingDetailRoute,
      arguments: HoldingDetailArgs(
        holding: holding,
        snapshot: payload.snapshotFor(holding.categoryKey),
        health: payload.healthFor(holding.categoryKey),
        ranking: payload.rankingForTicker(holding.id),
      ),
    );
  }

  void _openTicker(
    BuildContext context,
    DashboardPayload payload,
    String ticker,
  ) {
    final normalized = ticker.trim().toLowerCase();
    if (normalized.isEmpty) {
      _setPrimaryNavigationIndex(dashboardPortfolioTabIndex);
      return;
    }

    for (final holdings in payload.holdingsByCategory.values) {
      for (final holding in holdings) {
        if (holding.id.trim().toLowerCase() == normalized) {
          _openHolding(context, payload, holding);
          return;
        }
      }
    }

    _setPrimaryNavigationIndex(dashboardPortfolioTabIndex);
  }

  void _setPrimaryNavigationIndex(int index) {
    setState(() {
      _selectedIndex = index;
      _lastPrimaryIndex = index;
    });
  }

  void _openBaseView() {
    setState(() {
      _selectedIndex = dashboardProfileTabIndex;
    });
  }

  Future<void> _openAiBrief(
    BuildContext context,
    DashboardPayload payload,
  ) async {
    unawaited(_controller.refreshAiAnalysis());

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return DashboardAiBriefSheet(
              payload: payload,
              aiAnalysis: _controller.aiAnalysis,
              aiErrorMessage: _controller.aiErrorMessage,
              isAiLoading: _controller.isAiLoading,
              onRetry: _controller.refreshAiAnalysis,
            );
          },
        );
      },
    );
  }
}

class _DashboardStateView extends StatelessWidget {
  const _DashboardStateView({
    required this.isLoading,
    required this.isConfigured,
    required this.message,
    required this.onRefresh,
  });

  final bool isLoading;
  final bool isConfigured;
  final String message;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppPalette.panel,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppPalette.border),
          ),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 12),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppPalette.panelSoft,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  isLoading
                      ? Icons.sync_rounded
                      : Icons.wifi_tethering_error_rounded,
                  color: AppPalette.brand,
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                isLoading
                    ? 'Carregando carteira'
                    : isConfigured
                    ? 'Atualizacao indisponivel'
                    : 'Ambiente sem conexao',
                style: AppTheme.hudStyle(size: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppPalette.textMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: isLoading ? null : onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InlineWarning extends StatelessWidget {
  const _InlineWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPalette.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.gold.withValues(alpha: 0.28)),
      ),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppPalette.textPrimary),
      ),
    );
  }
}

String _userFacingDashboardMessage(
  String? rawMessage, {
  required bool isConfigured,
}) {
  final normalized = (rawMessage ?? '').toLowerCase();

  if (!isConfigured) {
    return 'A carteira ainda nao esta pronta para leitura neste ambiente.';
  }

  if (normalized.contains('token') ||
      normalized.contains('http') ||
      normalized.contains('json') ||
      normalized.contains('google') ||
      normalized.contains('auth') ||
      normalized.contains('html')) {
    return 'Nao foi possivel atualizar sua carteira agora. Tente novamente em alguns instantes.';
  }

  return 'A carteira nao foi atualizada nesta tentativa. Tente novamente em alguns instantes.';
}
