class DashboardPayload {
  const DashboardPayload({
    required this.summary,
    required this.score,
    required this.messaging,
    required this.actionPlan,
    required this.portfolioDecision,
    required this.categorySnapshots,
    required this.categories,
    required this.holdingsByCategory,
    required this.dataSource,
    required this.sourceWarning,
    required this.generalAdvice,
    required this.updatedAt,
  });

  factory DashboardPayload.fromJson(Map<String, dynamic> json) {
    return DashboardPayload(
      summary: PortfolioSummary.fromJson(_asMap(json['summary'])),
      score: PortfolioScore.fromJson(_asMap(json['score'])),
      messaging: PortfolioMessaging.fromJson(_asMap(json['messaging'])),
      actionPlan: ActionPlan.fromJson(_asMap(json['actionPlan'])),
      portfolioDecision: PortfolioDecision.fromJson(
        _asMap(json['portfolioDecision']),
      ),
      categorySnapshots: _asMapList(
        json['categorySnapshots'],
      ).map(CategorySnapshot.fromJson).toList(),
      categories: CategoryHealthSet.fromJson(_asMap(json['categories'])),
      holdingsByCategory: {
        'acoes': _asMapList(
          json['actions'],
        ).map(PortfolioHolding.fromActionJson).toList(),
        'fundos': _asMapList(
          json['investments'],
        ).map(PortfolioHolding.fromFundJson).toList(),
        'previdencia': _asMapList(
          json['previdencias'],
        ).map(PortfolioHolding.fromPensionJson).toList(),
      },
      dataSource: _stringFrom(json['dataSource']),
      sourceWarning: _stringFrom(json['sourceWarning']),
      generalAdvice: _stringFrom(json['generalAdvice']),
      updatedAt: _dateFrom(json['updatedAt']),
    );
  }

  final PortfolioSummary summary;
  final PortfolioScore score;
  final PortfolioMessaging messaging;
  final ActionPlan actionPlan;
  final PortfolioDecision portfolioDecision;
  final List<CategorySnapshot> categorySnapshots;
  final CategoryHealthSet categories;
  final Map<String, List<PortfolioHolding>> holdingsByCategory;
  final String dataSource;
  final String sourceWarning;
  final String generalAdvice;
  final DateTime? updatedAt;

  String get dataSourceLabel {
    switch (dataSource) {
      case 'bigquery':
        return 'BigQuery';
      case 'spreadsheet-fallback':
        return 'Sheets fallback';
      default:
        return dataSource.isEmpty ? 'Fonte nao informada' : dataSource;
    }
  }

  String get executiveStatusText {
    return messaging.executiveSummary.statusText.isNotEmpty
        ? messaging.executiveSummary.statusText
        : 'Leitura operacional em progresso.';
  }

  String get performanceText {
    if (messaging.executiveSummary.performanceText.isNotEmpty) {
      return messaging.executiveSummary.performanceText;
    }

    return _buildPerformanceBadge(summary.totalPerformanceRaw);
  }

  String get missionTitle {
    if (actionPlan.actionLabel.isNotEmpty) {
      return actionPlan.actionLabel;
    }
    if (messaging.primaryRecommendation.title.isNotEmpty) {
      return messaging.primaryRecommendation.title;
    }
    return 'Manter plano';
  }

  String get missionSupport {
    if (actionPlan.justification.isNotEmpty) {
      return actionPlan.justification;
    }
    if (messaging.primaryRecommendation.reason.isNotEmpty) {
      return messaging.primaryRecommendation.reason;
    }
    return executiveStatusText;
  }

  List<PortfolioHolding> holdingsFor(String categoryKey) {
    return holdingsByCategory[categoryKey] ?? const <PortfolioHolding>[];
  }

  CategorySnapshot? snapshotFor(String categoryKey) {
    for (final snapshot in categorySnapshots) {
      if (snapshot.key == categoryKey) {
        return snapshot;
      }
    }
    return null;
  }

  CategoryHealth? healthFor(String categoryKey) =>
      categories.forKey(categoryKey);
}

class PortfolioSummary {
  const PortfolioSummary({
    required this.totalLabel,
    required this.totalRaw,
    required this.totalPerformanceRaw,
    required this.actionsLabel,
    required this.fundsLabel,
    required this.pensionLabel,
  });

  factory PortfolioSummary.fromJson(Map<String, dynamic> json) {
    return PortfolioSummary(
      totalLabel: _stringFrom(json['total'], fallback: 'Sem dados'),
      totalRaw: _doubleFrom(json['totalRaw']),
      totalPerformanceRaw: _doubleFrom(json['totalPerformanceRaw']),
      actionsLabel: _stringFrom(json['acoes'], fallback: 'Sem dados'),
      fundsLabel: _stringFrom(json['fundos'], fallback: 'Sem dados'),
      pensionLabel: _stringFrom(json['previdencia'], fallback: 'Sem dados'),
    );
  }

  final String totalLabel;
  final double totalRaw;
  final double totalPerformanceRaw;
  final String actionsLabel;
  final String fundsLabel;
  final String pensionLabel;
}

class PortfolioScore {
  const PortfolioScore({
    required this.value,
    required this.status,
    required this.explanation,
    required this.breakdown,
  });

  factory PortfolioScore.fromJson(Map<String, dynamic> json) {
    return PortfolioScore(
      value: _intFrom(json['score']),
      status: _stringFrom(json['status'], fallback: 'Em leitura'),
      explanation: _stringFrom(json['explanation']),
      breakdown: ScoreBreakdown.fromJson(_asMap(json['breakdown'])),
    );
  }

  final int value;
  final String status;
  final String explanation;
  final ScoreBreakdown breakdown;
}

class ScoreBreakdown {
  const ScoreBreakdown({
    required this.capitalPoints,
    required this.categoryPoints,
    required this.institutionPoints,
    required this.healthPoints,
  });

  factory ScoreBreakdown.fromJson(Map<String, dynamic> json) {
    return ScoreBreakdown(
      capitalPoints: _intFrom(json['capitalPoints']),
      categoryPoints: _intFrom(json['categoryPoints']),
      institutionPoints: _intFrom(json['institutionPoints']),
      healthPoints: _intFrom(json['healthPoints']),
    );
  }

  final int capitalPoints;
  final int categoryPoints;
  final int institutionPoints;
  final int healthPoints;
}

class PortfolioMessaging {
  const PortfolioMessaging({
    required this.executiveSummary,
    required this.primaryRecommendation,
    required this.supportNotes,
    required this.alertsSummary,
  });

  factory PortfolioMessaging.fromJson(Map<String, dynamic> json) {
    return PortfolioMessaging(
      executiveSummary: ExecutiveSummary.fromJson(
        _asMap(json['executiveSummary']),
      ),
      primaryRecommendation: PrimaryRecommendation.fromJson(
        _asMap(json['primaryRecommendation']),
      ),
      supportNotes: SupportNotes.fromJson(_asMap(json['supportNotes'])),
      alertsSummary: AlertsSummary.fromJson(_asMap(json['alertsSummary'])),
    );
  }

  final ExecutiveSummary executiveSummary;
  final PrimaryRecommendation primaryRecommendation;
  final SupportNotes supportNotes;
  final AlertsSummary alertsSummary;
}

class ExecutiveSummary {
  const ExecutiveSummary({
    required this.statusText,
    required this.performanceText,
    required this.scoreStatusText,
  });

  factory ExecutiveSummary.fromJson(Map<String, dynamic> json) {
    return ExecutiveSummary(
      statusText: _stringFrom(json['statusText']),
      performanceText: _stringFrom(json['performanceText']),
      scoreStatusText: _stringFrom(json['scoreStatusText']),
    );
  }

  final String statusText;
  final String performanceText;
  final String scoreStatusText;
}

class PrimaryRecommendation {
  const PrimaryRecommendation({
    required this.title,
    required this.reason,
    required this.impact,
    required this.actionText,
    required this.asset,
  });

  factory PrimaryRecommendation.fromJson(Map<String, dynamic> json) {
    return PrimaryRecommendation(
      title: _stringFrom(json['title']),
      reason: _stringFrom(json['reason']),
      impact: _stringFrom(json['impact']),
      actionText: _stringFrom(json['actionText']),
      asset: _stringFrom(json['asset']),
    );
  }

  final String title;
  final String reason;
  final String impact;
  final String actionText;
  final String asset;
}

class SupportNotes {
  const SupportNotes({required this.scoreNote, required this.squadTip});

  factory SupportNotes.fromJson(Map<String, dynamic> json) {
    return SupportNotes(
      scoreNote: _stringFrom(json['scoreNote']),
      squadTip: _stringFrom(json['squadTip']),
    );
  }

  final String scoreNote;
  final String squadTip;
}

class AlertsSummary {
  const AlertsSummary({required this.headline, required this.lines});

  factory AlertsSummary.fromJson(Map<String, dynamic> json) {
    return AlertsSummary(
      headline: _stringFrom(json['headline']),
      lines: _dynamicListFrom(json['lines'])
          .map((item) => _stringFrom(item))
          .where((line) => line.isNotEmpty)
          .toList(),
    );
  }

  final String headline;
  final List<String> lines;
}

class ActionPlan {
  const ActionPlan({
    required this.actionLabel,
    required this.priority,
    required this.justification,
  });

  factory ActionPlan.fromJson(Map<String, dynamic> json) {
    return ActionPlan(
      actionLabel: _stringFrom(json['acao_principal']),
      priority: _stringFrom(json['prioridade']),
      justification: _stringFrom(json['justificativa']),
    );
  }

  final String actionLabel;
  final String priority;
  final String justification;
}

class PortfolioDecision {
  const PortfolioDecision({
    required this.actionText,
    required this.focusCategoryLabel,
    required this.urgency,
    required this.status,
    required this.criticalPoint,
  });

  factory PortfolioDecision.fromJson(Map<String, dynamic> json) {
    return PortfolioDecision(
      actionText: _stringFrom(json['actionText']),
      focusCategoryLabel: _stringFrom(json['focusCategoryLabel']),
      urgency: _stringFrom(json['urgency']),
      status: _stringFrom(json['status']),
      criticalPoint: _stringFrom(json['criticalPoint']),
    );
  }

  final String actionText;
  final String focusCategoryLabel;
  final String urgency;
  final String status;
  final String criticalPoint;
}

class CategorySnapshot {
  const CategorySnapshot({
    required this.key,
    required this.label,
    required this.totalLabel,
    required this.shareLabel,
    required this.shareRaw,
    required this.performanceLabel,
    required this.status,
    required this.recommendation,
    required this.colorHex,
  });

  factory CategorySnapshot.fromJson(Map<String, dynamic> json) {
    return CategorySnapshot(
      key: _stringFrom(json['key']),
      label: _stringFrom(json['label']),
      totalLabel: _stringFrom(json['totalLabel'], fallback: 'Sem dados'),
      shareLabel: _stringFrom(json['shareLabel'], fallback: '0,0%'),
      shareRaw: _doubleFrom(json['shareRaw']),
      performanceLabel: _stringFrom(
        json['performanceLabel'],
        fallback: _buildPerformanceCompact(_doubleFrom(json['performanceRaw'])),
      ),
      status: _stringFrom(json['status'], fallback: 'Seguro'),
      recommendation: _stringFrom(json['recommendation'], fallback: 'Manter'),
      colorHex: _stringFrom(json['color'], fallback: '#68D8FF'),
    );
  }

  final String key;
  final String label;
  final String totalLabel;
  final String shareLabel;
  final double shareRaw;
  final String performanceLabel;
  final String status;
  final String recommendation;
  final String colorHex;
}

class CategoryHealthSet {
  const CategoryHealthSet({
    required this.actions,
    required this.funds,
    required this.pension,
  });

  factory CategoryHealthSet.fromJson(Map<String, dynamic> json) {
    return CategoryHealthSet(
      actions: CategoryHealth.fromJson('acoes', _asMap(json['actions'])),
      funds: CategoryHealth.fromJson('fundos', _asMap(json['funds'])),
      pension: CategoryHealth.fromJson(
        'previdencia',
        _asMap(json['previdencia']),
      ),
    );
  }

  final CategoryHealth actions;
  final CategoryHealth funds;
  final CategoryHealth pension;

  CategoryHealth? forKey(String key) {
    switch (key) {
      case 'acoes':
        return actions;
      case 'fundos':
        return funds;
      case 'previdencia':
        return pension;
      default:
        return null;
    }
  }
}

class CategoryHealth {
  const CategoryHealth({
    required this.key,
    required this.label,
    required this.status,
    required this.risk,
    required this.recommendation,
    required this.primaryAsset,
    required this.primaryMessage,
  });

  factory CategoryHealth.fromJson(String key, Map<String, dynamic> json) {
    final primaryIssue = _asMap(json['primaryIssue']);
    return CategoryHealth(
      key: key,
      label: _stringFrom(json['label'], fallback: _defaultCategoryLabel(key)),
      status: _stringFrom(json['status'], fallback: 'Seguro'),
      risk: _stringFrom(json['risk'], fallback: 'Controlado'),
      recommendation: _stringFrom(json['recommendation'], fallback: 'Manter'),
      primaryAsset: _stringFrom(primaryIssue['asset']),
      primaryMessage: _stringFrom(primaryIssue['message']),
    );
  }

  final String key;
  final String label;
  final String status;
  final String risk;
  final String recommendation;
  final String primaryAsset;
  final String primaryMessage;
}

class PortfolioHolding {
  const PortfolioHolding({
    required this.id,
    required this.categoryKey,
    required this.title,
    required this.subtitle,
    required this.institution,
    required this.currentValueLabel,
    required this.performanceLabel,
    required this.performanceRaw,
    required this.shareLabel,
    required this.shareRaw,
    required this.recommendation,
    required this.statusLabel,
    required this.tagLabel,
    required this.supportLabel,
    required this.detailUrl,
  });

  factory PortfolioHolding.fromActionJson(Map<String, dynamic> json) {
    return PortfolioHolding(
      id: _stringFrom(
        json['ticker'],
        fallback: _stringFrom(json['name'], fallback: 'acao'),
      ),
      categoryKey: 'acoes',
      title: _stringFrom(
        json['ticker'],
        fallback: _stringFrom(json['name'], fallback: 'Ativo'),
      ),
      subtitle: _stringFrom(json['name']),
      institution: _stringFrom(json['institution']),
      currentValueLabel: _stringFrom(
        json['positionValue'],
        fallback: 'Sem dados',
      ),
      performanceLabel: _stringFrom(
        json['rendimentoPct'],
        fallback: _buildPerformanceCompact(_doubleFrom(json['rent'])),
      ),
      performanceRaw: _doubleFrom(json['rent']),
      shareLabel: _stringFrom(json['portfolioShareLabel']),
      shareRaw: _doubleFrom(json['portfolioShareRaw']),
      recommendation: _stringFrom(
        json['recommendation'],
        fallback: 'Monitorar',
      ),
      statusLabel: _stringFrom(json['statusLabel'], fallback: 'Comprado'),
      tagLabel: _stringFrom(json['currentPrice'], fallback: 'Mercado'),
      supportLabel: [
        _stringFrom(json['avgPrice']),
        _stringFrom(json['qty']),
      ].where((value) => value.isNotEmpty).join(' | '),
      detailUrl: _stringFrom(json['chartUrl']),
    );
  }

  factory PortfolioHolding.fromFundJson(Map<String, dynamic> json) {
    return PortfolioHolding(
      id: _stringFrom(json['name'], fallback: 'fundo'),
      categoryKey: 'fundos',
      title: _stringFrom(json['name'], fallback: 'Fundo'),
      subtitle: _stringFrom(
        json['classification'],
        fallback: _stringFrom(json['strategy']),
      ),
      institution: _stringFrom(json['institution']),
      currentValueLabel: _stringFrom(json['valorAtual'], fallback: 'Sem dados'),
      performanceLabel: _stringFrom(
        json['performanceLabel'],
        fallback: _stringFrom(
          json['rentPct'],
          fallback: _buildPerformanceCompact(_doubleFrom(json['rentRaw'])),
        ),
      ),
      performanceRaw: _doubleFrom(json['rentRaw']),
      shareLabel: _stringFrom(json['portfolioShareLabel']),
      shareRaw: _doubleFrom(json['portfolioShareRaw']),
      recommendation: _stringFrom(
        json['recommendation'],
        fallback: 'Monitorar',
      ),
      statusLabel: _stringFrom(json['statusLabel'], fallback: 'Ativo'),
      tagLabel: _stringFrom(json['benchmark'], fallback: 'Fundo'),
      supportLabel: [
        _stringFrom(json['strategy']),
        _stringFrom(json['profileLabel']),
      ].where((value) => value.isNotEmpty).join(' | '),
      detailUrl: _stringFrom(json['detailUrl']),
    );
  }

  factory PortfolioHolding.fromPensionJson(Map<String, dynamic> json) {
    return PortfolioHolding(
      id: _stringFrom(json['name'], fallback: 'previdencia'),
      categoryKey: 'previdencia',
      title: _stringFrom(json['name'], fallback: 'Plano'),
      subtitle: _stringFrom(
        json['classification'],
        fallback: _stringFrom(json['profileLabel']),
      ),
      institution: _stringFrom(json['institution']),
      currentValueLabel: _stringFrom(json['valorAtual'], fallback: 'Sem dados'),
      performanceLabel: _stringFrom(
        json['performanceLabel'],
        fallback: _stringFrom(
          json['rentPct'],
          fallback: _buildPerformanceCompact(_doubleFrom(json['rentRaw'])),
        ),
      ),
      performanceRaw: _doubleFrom(json['rentRaw']),
      shareLabel: _stringFrom(json['portfolioShareLabel']),
      shareRaw: _doubleFrom(json['portfolioShareRaw']),
      recommendation: _stringFrom(
        json['recommendation'],
        fallback: 'Monitorar',
      ),
      statusLabel: _stringFrom(json['statusLabel'], fallback: 'Ativo'),
      tagLabel: _stringFrom(json['profileLabel'], fallback: 'Previdencia'),
      supportLabel: [
        _stringFrom(json['classification']),
        _stringFrom(json['institution']),
      ].where((value) => value.isNotEmpty).join(' | '),
      detailUrl: _stringFrom(json['detailUrl']),
    );
  }

  final String id;
  final String categoryKey;
  final String title;
  final String subtitle;
  final String institution;
  final String currentValueLabel;
  final String performanceLabel;
  final double performanceRaw;
  final String shareLabel;
  final double shareRaw;
  final String recommendation;
  final String statusLabel;
  final String tagLabel;
  final String supportLabel;
  final String detailUrl;
}

Map<String, dynamic> _asMap(Object? source) {
  if (source is Map<String, dynamic>) return source;
  if (source is Map) {
    return source.map((key, value) => MapEntry(key.toString(), value));
  }
  return const <String, dynamic>{};
}

List<Map<String, dynamic>> _asMapList(Object? source) {
  return _dynamicListFrom(source).map(_asMap).toList();
}

List<dynamic> _dynamicListFrom(Object? source) {
  if (source is List<dynamic>) return source;
  if (source is List) return List<dynamic>.from(source);
  return const <dynamic>[];
}

String _stringFrom(Object? source, {String fallback = ''}) {
  if (source == null) return fallback;
  if (source is String) {
    final trimmed = source.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }
  if (source is num || source is bool) return source.toString();
  return fallback;
}

double _doubleFrom(Object? source, {double fallback = 0}) {
  if (source is num) return source.toDouble();
  if (source is String) {
    final normalized = source.replaceAll('%', '').replaceAll(',', '.').trim();
    return double.tryParse(normalized) ?? fallback;
  }
  return fallback;
}

int _intFrom(Object? source, {int fallback = 0}) {
  if (source is int) return source;
  return _doubleFrom(source, fallback: fallback.toDouble()).round();
}

DateTime? _dateFrom(Object? source) {
  final value = _stringFrom(source);
  return value.isEmpty ? null : DateTime.tryParse(value);
}

String _buildPerformanceCompact(double value) {
  final pct = (value * 100).toStringAsFixed(1).replaceAll('.', ',');
  if (value > 0) return '+$pct%';
  if (value < 0) return '$pct%';
  return '0,0%';
}

String _buildPerformanceBadge(double value) {
  final pct = _buildPerformanceCompact(value);
  return '$pct no round';
}

String _defaultCategoryLabel(String key) {
  switch (key) {
    case 'acoes':
      return 'Acoes';
    case 'fundos':
      return 'Fundos';
    case 'previdencia':
      return 'Previdencia';
    default:
      return 'Carteira';
  }
}
