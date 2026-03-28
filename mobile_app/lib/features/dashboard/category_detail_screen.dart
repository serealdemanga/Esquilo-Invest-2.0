import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/utils/app_formatters.dart';
import '../../models/dashboard_payload.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/tactical_card.dart';

class CategoryDetailArgs {
  const CategoryDetailArgs({
    required this.snapshot,
    required this.health,
    required this.holdings,
  });

  final CategorySnapshot snapshot;
  final CategoryHealth? health;
  final List<PortfolioHolding> holdings;
}

class CategoryDetailScreen extends StatelessWidget {
  const CategoryDetailScreen({super.key, required this.args});

  final CategoryDetailArgs args;

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(args.snapshot.colorHex);
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFF04090E), AppPalette.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Row(
                  children: <Widget>[
                    IconButton.filledTonal(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            args.snapshot.label,
                            style: AppTheme.hudStyle(size: 19),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Detalhe da categoria',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppPalette.textMuted),
                          ),
                        ],
                      ),
                    ),
                    StatusChip(
                      label: args.health?.status ?? args.snapshot.status,
                      tone: toneForText(
                        args.health?.status ?? args.snapshot.status,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: <Widget>[
                    TacticalCard(
                      title: args.snapshot.totalLabel,
                      subtitle: 'Participacao atual da categoria',
                      accent: color,
                      trailing: StatusChip(
                        label: args.snapshot.shareLabel,
                        tone: StatusChipTone.info,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: <Widget>[
                              StatusChip(
                                label: args.snapshot.performanceLabel,
                                tone: toneForText(
                                  args.snapshot.performanceLabel,
                                ),
                              ),
                              StatusChip(
                                label:
                                    args.health?.recommendation ??
                                    args.snapshot.recommendation,
                                tone: toneForText(
                                  args.health?.recommendation ??
                                      args.snapshot.recommendation,
                                ),
                              ),
                              StatusChip(
                                label: args.health?.risk ?? 'Controlado',
                                tone: toneForText(args.health?.risk ?? ''),
                              ),
                            ],
                          ),
                          if ((args.health?.primaryMessage ?? '')
                              .isNotEmpty) ...<Widget>[
                            const SizedBox(height: 14),
                            Text(
                              args.health!.primaryMessage,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppPalette.textPrimary),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Posicoes', style: AppTheme.hudStyle(size: 15)),
                    const SizedBox(height: 10),
                    ...args.holdings.map(
                      (holding) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HoldingCard(holding: holding),
                      ),
                    ),
                    if (args.holdings.isEmpty) const _EmptyHoldingsState(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoldingCard extends StatelessWidget {
  const _HoldingCard({required this.holding});

  final PortfolioHolding holding;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(holding.title, style: AppTheme.hudStyle(size: 14)),
                    if (holding.subtitle.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(
                        holding.subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppPalette.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              StatusChip(
                label: holding.recommendation,
                tone: toneForText(holding.recommendation),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              StatusChip(
                label: holding.currentValueLabel,
                tone: StatusChipTone.info,
              ),
              if (holding.shareLabel.isNotEmpty)
                StatusChip(
                  label: holding.shareLabel,
                  tone: StatusChipTone.neutral,
                ),
              if (holding.performanceLabel.isNotEmpty)
                StatusChip(
                  label: holding.performanceLabel,
                  tone: toneForText(holding.performanceLabel),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            [
              if (holding.institution.isNotEmpty) holding.institution,
              if (holding.supportLabel.isNotEmpty) holding.supportLabel,
            ].join(' | '),
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

class _EmptyHoldingsState extends StatelessWidget {
  const _EmptyHoldingsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppPalette.panelAlt,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppPalette.border),
      ),
      child: Text(
        'Nenhuma posicao disponivel neste bloco na rodada atual.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppPalette.textMuted),
      ),
    );
  }
}

StatusChipTone toneForText(String value) {
  final normalized = value.toLowerCase();
  if (normalized.contains('crit')) return StatusChipTone.danger;
  if (normalized.contains('aten') ||
      normalized.contains('media') ||
      normalized.contains('revis') ||
      normalized.contains('redistrib')) {
    return StatusChipTone.warning;
  }
  if (normalized.contains('+') ||
      normalized.contains('forte') ||
      normalized.contains('saud')) {
    return StatusChipTone.positive;
  }
  if (normalized.contains('segur') ||
      normalized.contains('controlado') ||
      normalized.contains('manter')) {
    return StatusChipTone.info;
  }
  return StatusChipTone.neutral;
}
