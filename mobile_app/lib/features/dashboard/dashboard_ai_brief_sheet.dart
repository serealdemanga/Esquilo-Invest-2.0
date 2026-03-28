import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/utils/app_formatters.dart';
import '../../models/dashboard_payload.dart';

class DashboardAiBriefSheet extends StatelessWidget {
  const DashboardAiBriefSheet({
    super.key,
    required this.payload,
    required this.aiAnalysis,
    required this.aiErrorMessage,
    required this.isAiLoading,
    required this.onRetry,
  });

  final DashboardPayload payload;
  final String? aiAnalysis;
  final String? aiErrorMessage;
  final bool isAiLoading;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final summary = _buildAiSummary(
      payload,
      aiAnalysis: aiAnalysis,
      aiErrorMessage: aiErrorMessage,
    );

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.84,
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: const BoxDecoration(
          color: AppPalette.backgroundAlt,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppPalette.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppPalette.panelSoft,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppPalette.border),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppPalette.brand,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Esquilo IA', style: AppTheme.hudStyle(size: 16)),
                      const SizedBox(height: 4),
                      Text(
                        summary.sourceLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppPalette.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                _AiSourcePill(
                  label: summary.sourcePillLabel,
                  accent: summary.sourceAccent,
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (aiErrorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _WarningBox(message: aiErrorMessage!),
              ),
            if (isAiLoading)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: <Widget>[
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Consultando a IA do backend com o contexto atual da carteira.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppPalette.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _BriefSection(
                      title: 'Avaliacao Geral',
                      lines: summary.generalLines,
                    ),
                    const SizedBox(height: 14),
                    _BriefSection(
                      title: 'O que fazer',
                      lines: summary.actionLines,
                    ),
                    const SizedBox(height: 14),
                    _OpportunityLine(line: summary.opportunityLine),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: isAiLoading ? null : onRetry,
                icon: Icon(
                  isAiLoading
                      ? Icons.hourglass_top_rounded
                      : Icons.sync_rounded,
                ),
                label: Text(
                  isAiLoading ? 'Consultando...' : 'Consultar IA do backend',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiSourcePill extends StatelessWidget {
  const _AiSourcePill({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: AppTheme.tacticalLabel(
          size: 11,
          color: accent,
          weight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _WarningBox extends StatelessWidget {
  const _WarningBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.gold.withValues(alpha: 0.26)),
      ),
      child: Text(
        'IA do backend indisponivel nesta rodada. Mantive abaixo uma leitura objetiva da carteira para nao deixar a consulta morta.\n\n$message',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppPalette.textPrimary,
          height: 1.45,
        ),
      ),
    );
  }
}

class _BriefSection extends StatelessWidget {
  const _BriefSection({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.panel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: AppTheme.hudStyle(size: 14)),
          const SizedBox(height: 12),
          ...lines.map(
            (String line) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 7),
                    decoration: const BoxDecoration(
                      color: AppPalette.brand,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      line,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPalette.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpportunityLine extends StatelessWidget {
  const _OpportunityLine({required this.line});

  final String line;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.panel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Oportunidades', style: AppTheme.hudStyle(size: 14)),
          const SizedBox(height: 12),
          Text(
            line,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppPalette.textPrimary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiSummary {
  const _AiSummary({
    required this.generalLines,
    required this.actionLines,
    required this.opportunityLine,
    required this.sourceLabel,
    required this.sourcePillLabel,
    required this.sourceAccent,
  });

  final List<String> generalLines;
  final List<String> actionLines;
  final String opportunityLine;
  final String sourceLabel;
  final String sourcePillLabel;
  final Color sourceAccent;
}

_AiSummary _buildAiSummary(
  DashboardPayload payload, {
  required String? aiAnalysis,
  required String? aiErrorMessage,
}) {
  final fallbackGeneral = <String>[
    'Rentabilidade total em ${formatPercentValue(payload.summary.totalPerformanceRaw)} com patrimonio em ${payload.summary.totalLabel}.',
    'Maior concentracao hoje em ${_topCategory(payload).label} com ${_topCategory(payload).shareLabel} da carteira.',
    'Score atual em ${payload.mobileHome.score.valueLabel} com status ${compactText(payload.score.status)}.',
    compactText(payload.generalAdvice, fallback: payload.executiveStatusText),
  ];

  final fallbackActions = <String>[
    compactText(
      payload.actionPlan.actionLabel,
      fallback: payload.messaging.primaryRecommendation.actionText,
    ),
    _resolveNextStep(payload),
  ];

  final fallbackOpportunity = _resolveOpportunity(payload);
  final parsedLines = _extractCandidateLines(aiAnalysis);

  return _AiSummary(
    generalLines: _mergeLines(parsedLines, 0, 4, fallbackGeneral),
    actionLines: _mergeLines(parsedLines, 4, 2, fallbackActions),
    opportunityLine: parsedLines.length > 6
        ? parsedLines[6]
        : fallbackOpportunity,
    sourceLabel: aiAnalysis != null && aiAnalysis.trim().isNotEmpty
        ? 'Consulta remota concluida com o motor do backend.'
        : aiErrorMessage == null
        ? 'Consulta sob demanda pronta para o motor do backend.'
        : 'Consulta remota falhou; leitura local de apoio aplicada.',
    sourcePillLabel: aiAnalysis != null && aiAnalysis.trim().isNotEmpty
        ? 'Backend'
        : aiErrorMessage == null
        ? 'Sob demanda'
        : 'Fallback local',
    sourceAccent: aiAnalysis != null && aiAnalysis.trim().isNotEmpty
        ? AppPalette.green
        : aiErrorMessage == null
        ? AppPalette.brand
        : AppPalette.gold,
  );
}

List<String> _mergeLines(
  List<String> parsedLines,
  int start,
  int length,
  List<String> fallback,
) {
  final lines = <String>[];
  for (var index = 0; index < length; index += 1) {
    final parsedIndex = start + index;
    if (parsedIndex < parsedLines.length) {
      lines.add(parsedLines[parsedIndex]);
      continue;
    }
    if (index < fallback.length) {
      lines.add(fallback[index]);
    }
  }
  return lines;
}

CategorySnapshot _topCategory(DashboardPayload payload) {
  final categories = payload.categorySnapshots.toList()
    ..sort(
      (CategorySnapshot a, CategorySnapshot b) =>
          b.shareRaw.compareTo(a.shareRaw),
    );
  if (categories.isEmpty) {
    return const CategorySnapshot(
      key: 'carteira',
      label: 'Carteira',
      totalLabel: 'Sem dados',
      totalRaw: 0,
      shareLabel: '0,0%',
      shareRaw: 0,
      performanceLabel: '0,0%',
      performanceRaw: 0,
      status: 'Sem leitura',
      recommendation: 'Monitorar',
      colorHex: '#FF6A1F',
      sourceType: '',
      trend: '',
    );
  }
  return categories.first;
}

String _resolveNextStep(DashboardPayload payload) {
  if (payload.actionPlan.justification.isNotEmpty) {
    return payload.actionPlan.justification;
  }
  if (payload.orders.buy != null) {
    return 'Executar compra planejada em ${payload.orders.buy!.symbol} dentro do valor de ${payload.orders.buy!.value}.';
  }
  if (payload.orders.sell != null) {
    return 'Executar reducao planejada em ${payload.orders.sell!.symbol} dentro do valor de ${payload.orders.sell!.value}.';
  }
  return compactText(
    payload.messaging.primaryRecommendation.reason,
    fallback:
        'Manter monitoramento da carteira sem acao emergencial nesta rodada.',
  );
}

String _resolveOpportunity(DashboardPayload payload) {
  final topOpportunity = payload.assetRanking.topOpportunity;
  if (topOpportunity != null) {
    return 'Acao: observar ${topOpportunity.ticker} e ${compactText(topOpportunity.recommendation, fallback: topOpportunity.smartRecommendation.action).toLowerCase()} se o contexto permanecer favoravel.';
  }
  if (payload.actionPlan.context.topOpportunityAsset.isNotEmpty) {
    return 'Acao: revisar ${payload.actionPlan.context.topOpportunityAsset} como melhor ponto de oportunidade desta rodada.';
  }
  return 'Acao: manter caixa e monitorar a melhor oportunidade da carteira na proxima leitura.';
}

List<String> _extractCandidateLines(String? aiAnalysis) {
  final value = aiAnalysis?.trim() ?? '';
  if (value.isEmpty) return const <String>[];

  final normalized = value
      .replaceAll('\r', '\n')
      .replaceAll('•', '\n')
      .replaceAll('>', '\n')
      .replaceAll(' - ', '\n')
      .replaceAll(';', '.');

  final lines = <String>[];
  for (final chunk in normalized.split('\n')) {
    final trimmedChunk = chunk.trim();
    if (trimmedChunk.isEmpty) continue;
    for (final sentence in trimmedChunk.split('. ')) {
      final normalizedSentence = sentence.trim();
      if (normalizedSentence.isEmpty) continue;
      lines.add(_normalizeSentence(normalizedSentence));
    }
  }
  return lines;
}

String _normalizeSentence(String value) {
  final trimmed = value.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (trimmed.isEmpty) return '';
  return trimmed.endsWith('.') ? trimmed : '$trimmed.';
}
