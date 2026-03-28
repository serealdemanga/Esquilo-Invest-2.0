import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/utils/app_formatters.dart';
import '../../models/dashboard_payload.dart';
import '../../widgets/passive_info_panel.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/tactical_card.dart';
import 'dashboard_presentation.dart';

class DashboardPortfolioTab extends StatelessWidget {
  const DashboardPortfolioTab({
    super.key,
    required this.payload,
    required this.onRefresh,
    required this.onOpenCategory,
    required this.onOpenHolding,
    required this.onOpenTicker,
    required this.onOpenCreate,
  });

  final DashboardPayload payload;
  final Future<void> Function() onRefresh;
  final void Function(String categoryKey) onOpenCategory;
  final void Function(PortfolioHolding holding) onOpenHolding;
  final void Function(String ticker) onOpenTicker;
  final VoidCallback onOpenCreate;

  @override
  Widget build(BuildContext context) {
    final holdings =
        <PortfolioHolding>[
          ...payload.actions,
          ...payload.investments,
          ...payload.previdencias,
        ]..sort(
          (PortfolioHolding a, PortfolioHolding b) =>
              b.currentValueRaw.compareTo(a.currentValueRaw),
        );

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppPalette.brand,
      backgroundColor: AppPalette.panel,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: <Widget>[
          TacticalCard(
            title: 'Carteira completa',
            subtitle: 'Leitura consolidada por blocos e posicoes.',
            accent: AppPalette.brand,
            trailing: payload.operations.canCreate
                ? IconButton.filledTonal(
                    onPressed: onOpenCreate,
                    tooltip: 'Novo item',
                    icon: const Icon(Icons.add_rounded),
                  )
                : null,
            child: Column(
              children: payload.categorySnapshots
                  .map(
                    (CategorySnapshot snapshot) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CategoryPortfolioTile(
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
          if (payload.orders.hasSuggestions) ...<Widget>[
            const SizedBox(height: 14),
            TacticalCard(
              title: 'Ordens sugeridas',
              subtitle: 'Movimentos que o backend ja consegue entregar hoje.',
              accent: AppPalette.gold,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (payload.orders.buy != null)
                    _OrderTile(
                      label: 'Compra sugerida',
                      symbol: payload.orders.buy!.symbol,
                      value: payload.orders.buy!.value,
                      accent: AppPalette.green,
                    ),
                  if (payload.orders.sell != null) ...<Widget>[
                    if (payload.orders.buy != null) const SizedBox(height: 10),
                    _OrderTile(
                      label: 'Reducao sugerida',
                      symbol: payload.orders.sell!.symbol,
                      value: payload.orders.sell!.value,
                      accent: AppPalette.red,
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (payload.intelligentAlerts.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            TacticalCard(
              title: 'Alertas da carteira',
              subtitle: 'Sinais prontos vindos do backend.',
              accent: AppPalette.gold,
              child: Column(
                children: payload.intelligentAlerts
                    .map(
                      (IntelligentAlert alert) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _AlertTile(alert: alert),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: 14),
          TacticalCard(
            title: 'Maiores posicoes',
            subtitle: 'Entradas reais prontas para abrir detalhe.',
            accent: AppPalette.cobalt,
            child: Column(
              children: holdings
                  .take(6)
                  .map(
                    (PortfolioHolding holding) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _HoldingPreviewTile(
                        holding: holding,
                        onTap: () => onOpenHolding(holding),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          if (payload.assetRanking.items.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            TacticalCard(
              title: 'Ranking de ativos',
              subtitle: 'Melhores leituras e pontos de atencao do backend.',
              accent: AppPalette.cobalt,
              child: Column(
                children: payload.assetRanking.items
                    .take(5)
                    .map(
                      (RankedAsset item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _RankingTile(
                          item: item,
                          onTap: () => onOpenTicker(item.ticker),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: TacticalCard(
                  title: 'Top fundos',
                  subtitle: 'Maiores pesos do bloco.',
                  accent: AppPalette.cobalt,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: payload.topFunds.isEmpty
                        ? <Widget>[
                            Text(
                              'Sem destaque nesta leitura.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppPalette.textMuted),
                            ),
                          ]
                        : payload.topFunds
                              .map(
                                (TopFundEntry item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    '${item.name}  ${item.value}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppPalette.textPrimary,
                                          height: 1.4,
                                        ),
                                  ),
                                ),
                              )
                              .toList(),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TacticalCard(
                  title: 'Previdencia',
                  subtitle: 'Resumo operacional do bloco.',
                  accent: AppPalette.teal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        compactText(
                          payload.previdenciaInfo.platform,
                          fallback: 'Plataforma nao informada',
                        ),
                        style: AppTheme.tacticalLabel(
                          size: 14,
                          color: AppPalette.textPrimary,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        compactText(
                          payload.previdenciaInfo.platformValue,
                          fallback: 'Sem valor',
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppPalette.textMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        compactText(
                          payload.previdenciaInfo.topPlan,
                          fallback: 'Sem plano lider',
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppPalette.textPrimary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        compactText(
                          payload.previdenciaInfo.topPlanValue,
                          fallback: 'Sem valor',
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppPalette.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (payload.decisionHistory.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            TacticalCard(
              title: 'Historico de decisao',
              subtitle: 'Registro do motor tatico ja exposto pelo backend.',
              accent: AppPalette.teal,
              child: Column(
                children: payload.decisionHistory
                    .take(4)
                    .map(
                      (DecisionRecord item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _DecisionTile(item: item),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryPortfolioTile extends StatelessWidget {
  const _CategoryPortfolioTile({
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
    final accent = categoryAccent(snapshot.key);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppPalette.panelSoft,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppPalette.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(categoryIcon(snapshot.key), color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(snapshot.label, style: AppTheme.hudStyle(size: 14)),
                      const SizedBox(height: 4),
                      Text(
                        '$holdingCount itens | ${snapshot.totalLabel}',
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
                  label: snapshot.performanceLabel,
                  tone: toneForText(snapshot.performanceLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HoldingPreviewTile extends StatelessWidget {
  const _HoldingPreviewTile({required this.holding, required this.onTap});

  final PortfolioHolding holding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppPalette.panelSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppPalette.border),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(holding.title, style: AppTheme.hudStyle(size: 13)),
                  const SizedBox(height: 4),
                  Text(
                    holding.currentValueLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppPalette.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  holding.performanceLabel,
                  style: AppTheme.tacticalLabel(
                    size: 13,
                    color:
                        toneForText(holding.performanceLabel) ==
                            StatusChipTone.danger
                        ? AppPalette.red
                        : categoryAccent(holding.categoryKey),
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  compactText(holding.shareLabel),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppPalette.textMuted),
                ),
              ],
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppPalette.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({
    required this.label,
    required this.symbol,
    required this.value,
    required this.accent,
  });

  final String label;
  final String symbol;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return PassiveInfoPanel(
      accent: accent,
      child: Row(
        children: <Widget>[
          Icon(Icons.swap_vert_circle_rounded, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppPalette.textMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  '$symbol  $value',
                  style: AppTheme.tacticalLabel(
                    size: 14,
                    color: AppPalette.textPrimary,
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});

  final IntelligentAlert alert;

  @override
  Widget build(BuildContext context) {
    return PassiveInfoPanel(
      accent: alert.type.toLowerCase().contains('oportun')
          ? AppPalette.green
          : AppPalette.gold,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: categoryAccent('acoes').withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              alert.type.toLowerCase().contains('oportun')
                  ? Icons.flash_on_rounded
                  : Icons.priority_high_rounded,
              color: alert.type.toLowerCase().contains('oportun')
                  ? AppPalette.green
                  : AppPalette.gold,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(alert.title, style: AppTheme.hudStyle(size: 13)),
                const SizedBox(height: 4),
                Text(
                  alert.message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppPalette.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingTile extends StatelessWidget {
  const _RankingTile({required this.item, required this.onTap});

  final RankedAsset item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppPalette.panelSoft,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppPalette.border),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(item.ticker, style: AppTheme.hudStyle(size: 13)),
                  const SizedBox(height: 4),
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppPalette.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                StatusChip(
                  label: 'Score ${item.score}',
                  tone: toneForText(item.status),
                ),
                const SizedBox(height: 6),
                Text(
                  formatPercentValue(item.rent),
                  style: AppTheme.tacticalLabel(
                    size: 13,
                    color: item.rent >= 0 ? AppPalette.green : AppPalette.red,
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppPalette.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _DecisionTile extends StatelessWidget {
  const _DecisionTile({required this.item});

  final DecisionRecord item;

  @override
  Widget build(BuildContext context) {
    return PassiveInfoPanel(
      accent: toneForText(item.status) == StatusChipTone.danger
          ? AppPalette.red
          : AppPalette.teal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(item.action, style: AppTheme.hudStyle(size: 13)),
              ),
              StatusChip(
                label: compactText(item.status),
                tone: toneForText(item.status),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${compactText(item.asset)} | ${formatUpdatedAt(item.date)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppPalette.textMuted),
          ),
          if (item.context.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              item.context,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppPalette.textPrimary,
                height: 1.4,
              ),
            ),
          ],
          if (item.outcome.summary.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              '${item.outcome.label}: ${item.outcome.summary}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppPalette.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
