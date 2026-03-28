import 'dashboard_payload.dart';

class HoldingOperationRequest {
  const HoldingOperationRequest({
    required this.type,
    required this.code,
    this.platform = '',
    this.status = '',
    this.investedValue = '',
    this.currentValue = '',
    this.quantity = '',
    this.averagePrice = '',
    this.date = '',
    this.observation = '',
    this.descriptor = '',
  });

  factory HoldingOperationRequest.fromHolding(PortfolioHolding holding) {
    return HoldingOperationRequest(
      type: crudTypeFromCategory(holding.categoryKey),
      code: holding.id,
      platform: holding.institution,
      status: holding.statusLabel,
      investedValue: _formatRawNumber(holding.investedValueRaw),
      currentValue: _formatRawNumber(holding.currentValueRaw),
      quantity: _formatRawNumber(holding.quantityRaw),
      averagePrice: _formatRawNumber(holding.averagePriceRaw),
      date: _normalizeDate(holding.entryLabel) ?? '',
      observation: holding.observation,
      descriptor: _descriptorFromHolding(holding),
    );
  }

  final String type;
  final String code;
  final String platform;
  final String status;
  final String investedValue;
  final String currentValue;
  final String quantity;
  final String averagePrice;
  final String date;
  final String observation;
  final String descriptor;

  String get normalizedType => crudTypeFromCategory(type);

  String get keyFieldName {
    switch (normalizedType) {
      case 'fundos':
        return 'fundo';
      case 'previdencia':
        return 'plano';
      case 'acoes':
      default:
        return 'ativo';
    }
  }

  String? validate() {
    if (code.trim().isEmpty) {
      return 'Identificador obrigatorio.';
    }
    if (investedValue.trim().isNotEmpty &&
        _normalizeDecimal(investedValue) == null) {
      return 'Valor investido invalido.';
    }
    if (currentValue.trim().isNotEmpty &&
        _normalizeDecimal(currentValue) == null) {
      return 'Valor atual invalido.';
    }
    if (quantity.trim().isNotEmpty && _normalizeDecimal(quantity) == null) {
      return 'Quantidade invalida.';
    }
    if (averagePrice.trim().isNotEmpty &&
        _normalizeDecimal(averagePrice) == null) {
      return 'Preco medio invalido.';
    }
    if (date.trim().isNotEmpty && _normalizeDate(date) == null) {
      return 'Use data no formato YYYY-MM-DD ou DD/MM/YYYY.';
    }
    return null;
  }

  Map<String, String> toCreatePayload() {
    return <String, String>{
      keyFieldName: code.trim(),
      ..._sharedPayload(includeTypeDetails: true),
    };
  }

  Map<String, String> toUpdatePayload() {
    return _sharedPayload(includeTypeDetails: true);
  }

  Map<String, String> _sharedPayload({required bool includeTypeDetails}) {
    final payload = <String, String>{};

    _putIfPresent(payload, 'plataforma', platform);
    _putIfPresent(payload, 'status', status);
    _putIfPresent(payload, 'valor_investido', _normalizeDecimal(investedValue));
    _putIfPresent(payload, 'valor_atual', _normalizeDecimal(currentValue));
    _putIfPresent(payload, 'observacao', observation);

    switch (normalizedType) {
      case 'acoes':
        if (includeTypeDetails) {
          _putIfPresent(
            payload,
            'tipo',
            descriptor.isEmpty ? 'Acao' : descriptor,
          );
        }
        _putIfPresent(payload, 'quantidade', _normalizeDecimal(quantity));
        _putIfPresent(payload, 'preco_medio', _normalizeDecimal(averagePrice));
        _putIfPresent(payload, 'data_entrada', _normalizeDate(date));
        break;
      case 'fundos':
        if (includeTypeDetails) {
          _putIfPresent(payload, 'categoria', descriptor);
        }
        _putIfPresent(payload, 'data_inicio', _normalizeDate(date));
        break;
      case 'previdencia':
        if (includeTypeDetails) {
          _putIfPresent(payload, 'tipo', descriptor);
        }
        _putIfPresent(payload, 'data_inicio', _normalizeDate(date));
        break;
    }

    return payload;
  }

  static void _putIfPresent(
    Map<String, String> payload,
    String key,
    String? value,
  ) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return;
    }
    payload[key] = trimmed;
  }

  static String crudTypeFromCategory(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'fundos' || normalized == 'fundo') {
      return 'fundos';
    }
    if (normalized == 'previdencia' || normalized == 'previdencias') {
      return 'previdencia';
    }
    return 'acoes';
  }

  static String _descriptorFromHolding(PortfolioHolding holding) {
    if (holding.categoryKey == 'acoes') {
      return holding.subtitle.isNotEmpty ? holding.subtitle : 'Acao';
    }
    return holding.subtitle;
  }

  static String _formatRawNumber(double value) {
    if (value <= 0) return '';
    final hasDecimals = value % 1 != 0;
    return hasDecimals ? value.toStringAsFixed(2) : value.toStringAsFixed(0);
  }

  static String? _normalizeDecimal(String value) {
    var normalized = value.trim();
    if (normalized.isEmpty) return null;

    normalized = normalized
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('%', '');

    if (normalized.contains(',') && normalized.contains('.')) {
      normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
    } else if (normalized.contains(',')) {
      normalized = normalized.replaceAll(',', '.');
    }

    final parsed = double.tryParse(normalized);
    if (parsed == null) return null;

    final hasDecimals = parsed % 1 != 0;
    return hasDecimals ? parsed.toStringAsFixed(2) : parsed.toStringAsFixed(0);
  }

  static String? _normalizeDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final isoMatch = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (isoMatch.hasMatch(trimmed)) {
      return trimmed;
    }

    final brMatch = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(trimmed);
    if (brMatch != null) {
      return '${brMatch.group(3)}-${brMatch.group(2)}-${brMatch.group(1)}';
    }

    return null;
  }
}
