import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../models/dashboard_payload.dart';
import '../../widgets/allocation_ring.dart';
import '../../widgets/tactical_card.dart';
import 'dashboard_presentation.dart';

class DashboardHomeTab extends StatelessWidget {
  const DashboardHomeTab({
    super.key,
    required this.payload,
    required this.onRefresh,
    required this.onOpenCategory,
    required this.onOpenAi,
    required this.isAiLoading,
  });

  final DashboardPayload payload;
  final Future<void> Function() onRefresh;
  final void Function(String categoryKey) onOpenCategory;
  final VoidCallback onOpenAi;
  final bool isAiLoading;

  @override
  Widget build(BuildContext context) {
    final categories = payload.categorySnapshots.where((CategorySnapshot item) {
      return item.shareRaw > 0;
    }).toList();

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppPalette.brand,
      backgroundColor: AppPalette.panel,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: <Widget>[
          _HeroPanel(payload: payload, categories: categories),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: _AiTriggerButton(isLoading: isAiLoading, onTap: onOpenAi),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.spaceBetween,
            children: categories
                .map(
                  (CategorySnapshot snapshot) => SizedBox(
                    width: 104,
                    child: _CategoryQuickLink(
                      snapshot: snapshot,
                      onTap: () => onOpenCategory(snapshot.key),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          TacticalCard(
            title: 'Portfolio Scan',
            accent: AppPalette.cobalt,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _scanLines()
                  .map(
                    (String line) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        '> $line',
                        style: AppTheme.mono(
                          size: 12,
                          color: AppPalette.textPrimary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _scanLines() {
    final insights = <String>[];

    if (payload.mobileHome.insights.isNotEmpty) {
      insights.addAll(
        payload.mobileHome.insights.map(
          (MobileInsightSnapshot item) => item.body,
        ),
      );
    }

    if (payload.primaryAlert.text.isNotEmpty) {
      insights.add(payload.primaryAlert.text);
    }

    if (payload.orders.buy != null) {
      insights.add(
        'Compra sugerida em ${payload.orders.buy!.symbol} por ${payload.orders.buy!.value}.',
      );
    }

    if (payload.orders.sell != null) {
      insights.add(
        'Reducao sugerida em ${payload.orders.sell!.symbol} por ${payload.orders.sell!.value}.',
      );
    }

    if (payload.sourceWarning.isNotEmpty) {
      insights.add('Fonte atual: ${payload.dataSourceLabel}.');
    }

    if (insights.isEmpty) {
      insights.add('Carteira sem alertas de leitura nesta rodada.');
    }

    return insights.take(3).toList();
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.payload, required this.categories});

  final DashboardPayload payload;
  final List<CategorySnapshot> categories;

  @override
  Widget build(BuildContext context) {
    final segments = categories
        .map(
          (CategorySnapshot item) => AllocationRingSegment(
            label: item.label,
            weight: item.shareRaw,
            color: categoryAccent(item.key),
          ),
        )
        .toList();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppPalette.border),
        gradient: const LinearGradient(
          colors: <Color>[AppPalette.panel, AppPalette.backgroundAlt],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppPalette.shadow,
            blurRadius: 32,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Text(
            'Patrimonio liquido',
            style: AppTheme.tacticalLabel(
              size: 12,
              color: AppPalette.textMuted,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            payload.summary.totalLabel,
            textAlign: TextAlign.center,
            style: AppTheme.hudStyle(size: 26, color: AppPalette.brandStrong),
          ),
          const SizedBox(height: 6),
          Text(
            payload.summary.totalPerformanceRaw >= 0
                ? '${payload.mobileHome.variation.label} geral'
                : payload.mobileHome.variation.label,
            style: AppTheme.tacticalLabel(
              size: 14,
              color: payload.summary.totalPerformanceRaw >= 0
                  ? AppPalette.green
                  : AppPalette.red,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          AllocationRing(
            segments: segments,
            centerLabel: payload.mobileHome.variation.label,
            centerSupportLabel: 'Rentabilidade total',
          ),
        ],
      ),
    );
  }
}

class _AiTriggerButton extends StatelessWidget {
  const _AiTriggerButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Consultar Esquilo IA do backend',
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppPalette.panelSoft,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppPalette.border),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppPalette.brand,
                  ),
          ),
        ),
      ),
    );
  }
}

class _CategoryQuickLink extends StatelessWidget {
  const _CategoryQuickLink({required this.snapshot, required this.onTap});

  final CategorySnapshot snapshot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = categoryAccent(snapshot.key);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: <Widget>[
          Ink(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: accent.withValues(alpha: 0.28)),
            ),
            child: Icon(categoryIcon(snapshot.key), color: accent, size: 30),
          ),
          const SizedBox(height: 10),
          Text(
            snapshot.label,
            textAlign: TextAlign.center,
            style: AppTheme.tacticalLabel(
              size: 12,
              color: AppPalette.textPrimary,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            snapshot.performanceLabel,
            style: AppTheme.tacticalLabel(
              size: 12,
              color: accent,
              weight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
