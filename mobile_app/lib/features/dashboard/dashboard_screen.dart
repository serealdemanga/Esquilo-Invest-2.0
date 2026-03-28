import 'package:flutter/material.dart';

import '../../app/app_router.dart';
import '../../app/app_theme.dart';
import '../../core/config/app_environment.dart';
import '../../core/utils/app_formatters.dart';
import '../../models/dashboard_payload.dart';
import '../../services/app_script_dashboard_service.dart';
import '../../widgets/allocation_ring.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/tactical_card.dart';
import 'category_detail_screen.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardController _controller;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController(AppScriptDashboardService());
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

        return Scaffold(
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  Color(0xFF03070B),
                  Color(0xFF071018),
                  Color(0xFF0A1722),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  _HeaderBar(
                    payload: payload,
                    isLoading: _controller.isLoading,
                    onRefresh: _controller.loadDashboard,
                  ),
                  if (_controller.errorMessage != null && payload != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                      child: _InlineWarning(message: _controller.errorMessage!),
                    ),
                  Expanded(child: _buildBody(context, payload)),
                ],
              ),
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int value) {
              setState(() {
                _selectedIndex = value;
              });
            },
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.space_dashboard_outlined),
                selectedIcon: Icon(Icons.space_dashboard_rounded),
                label: 'Visao',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_tree_outlined),
                selectedIcon: Icon(Icons.account_tree_rounded),
                label: 'Carteira',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_awesome_outlined),
                selectedIcon: Icon(Icons.auto_awesome_rounded),
                label: 'Insights',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, DashboardPayload? payload) {
    if (payload == null) {
      if (_controller.isLoading) {
        return const _LoadingState();
      }

      return _ConfigurationState(
        isConfigured: _controller.isConfigured,
        message:
            _controller.errorMessage ??
            'Configure o endpoint do AppScript para carregar a carteira.',
      );
    }

    final tabs = <Widget>[
      _OverviewTab(payload: payload, onRefresh: _controller.loadDashboard),
      _PortfolioTab(
        payload: payload,
        onOpenCategory: (String key) => _openCategory(context, payload, key),
      ),
      _InsightsTab(
        payload: payload,
        aiAnalysis: _controller.aiAnalysis,
        isAiLoading: _controller.isAiLoading,
        onRefresh: _controller.loadDashboard,
        onLoadAi: _controller.refreshAiAnalysis,
      ),
    ];

    return IndexedStack(index: _selectedIndex, children: tabs);
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
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({
    required this.payload,
    required this.isLoading,
    required this.onRefresh,
  });

  final DashboardPayload? payload;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppPalette.panel.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppPalette.border),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Pocket Ops', style: AppTheme.hudStyle(size: 18)),
                  const SizedBox(height: 4),
                  Text(
                    AppEnvironment.releaseLabel,
                    style: AppTheme.tacticalLabel(size: 12),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      StatusChip(
                        label: payload?.dataSourceLabel ?? 'Aguardando backend',
                        tone: StatusChipTone.info,
                      ),
                      StatusChip(
                        label: 'Sync ${formatUpdatedAt(payload?.updatedAt)}',
                        tone: StatusChipTone.neutral,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              onPressed: isLoading ? null : onRefresh,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.payload, required this.onRefresh});

  final DashboardPayload payload;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          _HeroCard(payload: payload),
          const SizedBox(height: 14),
          _AllocationSection(payload: payload),
          const SizedBox(height: 14),
          _RadarSection(payload: payload),
          const SizedBox(height: 14),
          _MissionSection(payload: payload),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.payload});

  final DashboardPayload payload;

  @override
  Widget build(BuildContext context) {
    return TacticalCard(
      title: 'Painel de campo',
      subtitle: payload.executiveStatusText,
      accent: AppPalette.amber,
      trailing: StatusChip(
        label: '${payload.score.value}/100',
        tone: toneForText(payload.score.status),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(payload.summary.totalLabel, style: AppTheme.hudStyle(size: 28)),
          const SizedBox(height: 6),
          Text(
            payload.performanceText,
            style: AppTheme.tacticalLabel(size: 14, color: AppPalette.cyan),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _MetricPill(label: 'Acoes', value: payload.summary.actionsLabel),
              _MetricPill(label: 'Fundos', value: payload.summary.fundsLabel),
              _MetricPill(
                label: 'Previdencia',
                value: payload.summary.pensionLabel,
              ),
            ],
          ),
          if (payload.sourceWarning.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            _InlineWarning(message: payload.sourceWarning),
          ],
        ],
      ),
    );
  }
}

class _AllocationSection extends StatelessWidget {
  const _AllocationSection({required this.payload});

  final DashboardPayload payload;

  @override
  Widget build(BuildContext context) {
    return TacticalCard(
      title: 'Alocacao por macroclasse',
      subtitle: 'Leitura principal da carteira no mobile',
      accent: AppPalette.cyan,
      child: Column(
        children: <Widget>[
          AllocationRing(
            segments: payload.categorySnapshots,
            centerLabel: payload.summary.totalLabel,
            centerSupportLabel: 'Patrimonio total',
          ),
          const SizedBox(height: 18),
          ...payload.categorySnapshots.map(
            (snapshot) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CategoryRow(snapshot: snapshot),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.snapshot});

  final CategorySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(snapshot.colorHex);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.panelAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.border),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(snapshot.label, style: AppTheme.hudStyle(size: 13)),
                const SizedBox(height: 4),
                Text(
                  '${snapshot.totalLabel} • ${snapshot.shareLabel}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppPalette.textMuted),
                ),
              ],
            ),
          ),
          StatusChip(
            label: snapshot.performanceLabel,
            tone: toneForText(snapshot.performanceLabel),
          ),
        ],
      ),
    );
  }
}

class _RadarSection extends StatelessWidget {
  const _RadarSection({required this.payload});

  final DashboardPayload payload;

  @override
  Widget build(BuildContext context) {
    final entries = _buildRadarEntries(payload);
    return TacticalCard(
      title: 'Radar da carteira',
      subtitle: 'O que merece leitura rapida agora',
      accent: AppPalette.amber,
      child: Column(
        children: entries
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RadarEntryCard(entry: entry),
              ),
            )
            .toList(),
      ),
    );
  }

  List<_RadarEntry> _buildRadarEntries(DashboardPayload payload) {
    final entries = payload.categorySnapshots.map((snapshot) {
      final health = payload.healthFor(snapshot.key);
      return _RadarEntry(
        label: snapshot.label,
        headline: health?.recommendation.isNotEmpty == true
            ? health!.recommendation
            : snapshot.recommendation,
        support: health?.primaryMessage.isNotEmpty == true
            ? health!.primaryMessage
            : '${snapshot.label} ocupa ${snapshot.shareLabel} da carteira.',
        tone: toneForText(health?.status ?? snapshot.status),
      );
    }).toList();

    entries.sort((a, b) => a.priority.compareTo(b.priority));
    return entries;
  }
}

class _RadarEntryCard extends StatelessWidget {
  const _RadarEntryCard({required this.entry});

  final _RadarEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.panelAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(entry.label, style: AppTheme.hudStyle(size: 13)),
              ),
              StatusChip(label: entry.headline, tone: entry.tone),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.support,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppPalette.textMuted,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionSection extends StatelessWidget {
  const _MissionSection({required this.payload});

  final DashboardPayload payload;

  @override
  Widget build(BuildContext context) {
    final progress = clampUnit(payload.score.value / 100);
    return TacticalCard(
      title: 'Missao do mes',
      subtitle: payload.missionSupport,
      accent: AppPalette.cyan,
      trailing: StatusChip(
        label: payload.portfolioDecision.urgency.isEmpty
            ? 'Baixa'
            : payload.portfolioDecision.urgency,
        tone: toneForText(payload.portfolioDecision.urgency),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(payload.missionTitle, style: AppTheme.hudStyle(size: 20)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: AppPalette.border.withValues(alpha: 0.45),
              valueColor: const AlwaysStoppedAnimation<Color>(AppPalette.amber),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Prontidao atual ${payload.score.value}/100',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppPalette.textMuted),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _MissionCell(
                label: 'Foco',
                value: payload.portfolioDecision.focusCategoryLabel.isEmpty
                    ? 'Carteira'
                    : payload.portfolioDecision.focusCategoryLabel,
              ),
              _MissionCell(
                label: 'Status',
                value: payload.portfolioDecision.status.isEmpty
                    ? payload.score.status
                    : payload.portfolioDecision.status,
              ),
              _MissionCell(
                label: 'Acao',
                value: payload.portfolioDecision.actionText.isEmpty
                    ? payload.messaging.primaryRecommendation.actionText
                    : payload.portfolioDecision.actionText,
              ),
              _MissionCell(
                label: 'Ponto quente',
                value: payload.portfolioDecision.criticalPoint.isEmpty
                    ? 'Sem pressao critica'
                    : payload.portfolioDecision.criticalPoint,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MissionCell extends StatelessWidget {
  const _MissionCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 152,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPalette.panelAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: AppTheme.tacticalLabel(size: 11)),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppPalette.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioTab extends StatelessWidget {
  const _PortfolioTab({required this.payload, required this.onOpenCategory});

  final DashboardPayload payload;
  final void Function(String categoryKey) onOpenCategory;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: <Widget>[
        TacticalCard(
          title: 'Blocos operacionais',
          subtitle: 'Cada card abre um detalhe independente da categoria.',
          accent: AppPalette.amber,
          child: Column(
            children: payload.categorySnapshots
                .map(
                  (snapshot) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CategoryTile(
                      snapshot: snapshot,
                      health: payload.healthFor(snapshot.key),
                      holdingCount: payload.holdingsFor(snapshot.key).length,
                      onTap: () => onOpenCategory(snapshot.key),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.snapshot,
    required this.health,
    required this.holdingCount,
    required this.onTap,
  });

  final CategorySnapshot snapshot;
  final CategoryHealth? health;
  final int holdingCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppPalette.panelAlt,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppPalette.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(snapshot.label, style: AppTheme.hudStyle(size: 15)),
                      const SizedBox(height: 4),
                      Text(
                        '$holdingCount itens • ${snapshot.totalLabel}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppPalette.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppPalette.textMuted,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                StatusChip(
                  label: snapshot.shareLabel,
                  tone: StatusChipTone.info,
                ),
                StatusChip(
                  label: health?.status ?? snapshot.status,
                  tone: toneForText(health?.status ?? snapshot.status),
                ),
                StatusChip(
                  label: health?.recommendation ?? snapshot.recommendation,
                  tone: toneForText(
                    health?.recommendation ?? snapshot.recommendation,
                  ),
                ),
              ],
            ),
            if ((health?.primaryMessage ?? '').isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                health!.primaryMessage,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppPalette.textMuted,
                  height: 1.45,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InsightsTab extends StatelessWidget {
  const _InsightsTab({
    required this.payload,
    required this.aiAnalysis,
    required this.isAiLoading,
    required this.onRefresh,
    required this.onLoadAi,
  });

  final DashboardPayload payload;
  final String? aiAnalysis;
  final bool isAiLoading;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadAi;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          TacticalCard(
            title: 'Score operacional',
            subtitle: payload.score.explanation,
            accent: AppPalette.cyan,
            trailing: StatusChip(
              label: payload.score.status,
              tone: toneForText(payload.score.status),
            ),
            child: Column(
              children: <Widget>[
                _ScoreBar(
                  label: 'Capital',
                  value: payload.score.breakdown.capitalPoints,
                ),
                _ScoreBar(
                  label: 'Classes',
                  value: payload.score.breakdown.categoryPoints,
                ),
                _ScoreBar(
                  label: 'Instituicoes',
                  value: payload.score.breakdown.institutionPoints,
                ),
                _ScoreBar(
                  label: 'Saude',
                  value: payload.score.breakdown.healthPoints,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TacticalCard(
            title: 'Proxima jogada',
            subtitle: payload.messaging.primaryRecommendation.reason,
            accent: AppPalette.amber,
            trailing: StatusChip(
              label: payload.messaging.primaryRecommendation.title.isEmpty
                  ? 'Manter plano'
                  : payload.messaging.primaryRecommendation.title,
              tone: toneForText(
                payload.messaging.primaryRecommendation.actionText,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (payload.messaging.primaryRecommendation.impact.isNotEmpty)
                  Text(
                    payload.messaging.primaryRecommendation.impact,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppPalette.textPrimary,
                    ),
                  ),
                const SizedBox(height: 12),
                if (payload.messaging.supportNotes.scoreNote.isNotEmpty)
                  Text(
                    payload.messaging.supportNotes.scoreNote,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppPalette.textMuted,
                    ),
                  ),
                if (payload
                    .messaging
                    .supportNotes
                    .squadTip
                    .isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    payload.messaging.supportNotes.squadTip,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppPalette.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          TacticalCard(
            title: 'Esquilo IA',
            subtitle: aiAnalysis == null
                ? 'Consulta sob demanda usando o mesmo contexto do AppScript.'
                : 'Leitura remota atualizada para a rodada atual.',
            accent: const Color(0xFF9C8CFF),
            trailing: StatusChip(
              label: isAiLoading ? 'Em leitura' : 'Pronto',
              tone: isAiLoading
                  ? StatusChipTone.warning
                  : StatusChipTone.positive,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151B31),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppPalette.border),
                  ),
                  child: Text(
                    aiAnalysis ?? _fallbackAiText(payload),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppPalette.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.tonalIcon(
                  onPressed: isAiLoading ? null : onLoadAi,
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: Text(isAiLoading ? 'Lendo...' : 'Atualizar leitura'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fallbackAiText(DashboardPayload payload) {
    if (payload.generalAdvice.trim().isNotEmpty) {
      return payload.generalAdvice;
    }
    if (payload.messaging.alertsSummary.headline.trim().isNotEmpty) {
      return payload.messaging.alertsSummary.headline;
    }
    return 'A leitura detalhada fica disponivel quando o AppScript responder a Esquilo IA.';
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final progress = clampUnit(value / 25);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(label, style: AppTheme.tacticalLabel(size: 12)),
              ),
              Text(
                '$value/25',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppPalette.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: AppPalette.border.withValues(alpha: 0.45),
              valueColor: const AlwaysStoppedAnimation<Color>(AppPalette.cyan),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPalette.panelAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: AppTheme.tacticalLabel(size: 11)),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppPalette.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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
        color: const Color(0x22FFB347),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x55FFB347)),
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

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: 14),
          Text('Carregando operacao...'),
        ],
      ),
    );
  }
}

class _ConfigurationState extends StatelessWidget {
  const _ConfigurationState({
    required this.isConfigured,
    required this.message,
  });

  final bool isConfigured;
  final String message;

  @override
  Widget build(BuildContext context) {
    final title = isConfigured
        ? 'Falha ao consultar o AppScript'
        : 'Configurar backend';
    final hint =
        'flutter run --dart-define=APP_SCRIPT_BASE_URL=https://script.google.com/.../exec '
        '--dart-define=APP_SCRIPT_API_TOKEN=seu_token';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: TacticalCard(
          title: title,
          subtitle: message,
          accent: AppPalette.amber,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Comando base', style: AppTheme.tacticalLabel(size: 11)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppPalette.panelAlt,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppPalette.border),
                ),
                child: Text(
                  hint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppPalette.textPrimary,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadarEntry {
  const _RadarEntry({
    required this.label,
    required this.headline,
    required this.support,
    required this.tone,
  });

  final String label;
  final String headline;
  final String support;
  final StatusChipTone tone;

  int get priority {
    switch (tone) {
      case StatusChipTone.danger:
        return 0;
      case StatusChipTone.warning:
        return 1;
      case StatusChipTone.info:
        return 2;
      case StatusChipTone.positive:
        return 3;
      case StatusChipTone.neutral:
        return 4;
    }
  }
}
