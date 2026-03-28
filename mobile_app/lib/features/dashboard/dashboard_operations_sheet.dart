import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../models/holding_operation_request.dart';

enum HoldingFormMode { create, update }

class HoldingFormSheet extends StatefulWidget {
  const HoldingFormSheet({super.key, required this.mode, this.initialRequest});

  final HoldingFormMode mode;
  final HoldingOperationRequest? initialRequest;

  @override
  State<HoldingFormSheet> createState() => _HoldingFormSheetState();
}

class _HoldingFormSheetState extends State<HoldingFormSheet> {
  late String _selectedType;
  late final TextEditingController _codeController;
  late final TextEditingController _platformController;
  late final TextEditingController _statusController;
  late final TextEditingController _investedValueController;
  late final TextEditingController _currentValueController;
  late final TextEditingController _quantityController;
  late final TextEditingController _averagePriceController;
  late final TextEditingController _dateController;
  late final TextEditingController _descriptorController;
  late final TextEditingController _observationController;

  @override
  void initState() {
    super.initState();
    final request = widget.initialRequest;
    _selectedType = request?.normalizedType ?? 'acoes';
    _codeController = TextEditingController(text: request?.code ?? '');
    _platformController = TextEditingController(text: request?.platform ?? '');
    _statusController = TextEditingController(text: request?.status ?? '');
    _investedValueController = TextEditingController(
      text: request?.investedValue ?? '',
    );
    _currentValueController = TextEditingController(
      text: request?.currentValue ?? '',
    );
    _quantityController = TextEditingController(text: request?.quantity ?? '');
    _averagePriceController = TextEditingController(
      text: request?.averagePrice ?? '',
    );
    _dateController = TextEditingController(text: request?.date ?? '');
    _descriptorController = TextEditingController(
      text: request?.descriptor ?? '',
    );
    _observationController = TextEditingController(
      text: request?.observation ?? '',
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _platformController.dispose();
    _statusController.dispose();
    _investedValueController.dispose();
    _currentValueController.dispose();
    _quantityController.dispose();
    _averagePriceController.dispose();
    _dateController.dispose();
    _descriptorController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCreate = widget.mode == HoldingFormMode.create;
    final title = isCreate ? 'Novo item operacional' : 'Atualizar item';

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppPalette.panel,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppPalette.border),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: AppTheme.hudStyle(size: 18)),
                const SizedBox(height: 6),
                Text(
                  'CRUD controlado na base, sem execucao financeira real.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppPalette.textMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                if (isCreate) ...<Widget>[
                  DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: _decoration('Categoria'),
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem(value: 'acoes', child: Text('Acoes')),
                      DropdownMenuItem(value: 'fundos', child: Text('Fundos')),
                      DropdownMenuItem(
                        value: 'previdencia',
                        child: Text('Previdencia'),
                      ),
                    ],
                    onChanged: (String? value) {
                      if (value == null) return;
                      setState(() {
                        _selectedType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: _codeController,
                  readOnly: !isCreate,
                  decoration: _decoration(_identifierLabel(_selectedType)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _platformController,
                  decoration: _decoration('Plataforma'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _statusController,
                  decoration: _decoration('Status operacional'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptorController,
                  decoration: _decoration(_descriptorLabel(_selectedType)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _investedValueController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _decoration('Valor investido'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _currentValueController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _decoration('Valor atual'),
                      ),
                    ),
                  ],
                ),
                if (_selectedType == 'acoes') ...<Widget>[
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _quantityController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _decoration('Quantidade'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _averagePriceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _decoration('Preco medio'),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: _dateController,
                  decoration: _decoration(
                    _selectedType == 'acoes'
                        ? 'Data de entrada'
                        : 'Data de inicio',
                    hint: 'YYYY-MM-DD ou DD/MM/YYYY',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _observationController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: _decoration('Observacao'),
                ),
                const SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _submit,
                        child: Text(isCreate ? 'Criar' : 'Salvar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppPalette.panelSoft,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppPalette.border),
      ),
    );
  }

  String _identifierLabel(String type) {
    switch (type) {
      case 'fundos':
        return 'Nome do fundo';
      case 'previdencia':
        return 'Nome do plano';
      case 'acoes':
      default:
        return 'Ticker / ativo';
    }
  }

  String _descriptorLabel(String type) {
    switch (type) {
      case 'fundos':
        return 'Categoria / estrategia';
      case 'previdencia':
        return 'Tipo / perfil';
      case 'acoes':
      default:
        return 'Tipo / contexto';
    }
  }

  void _submit() {
    final request = HoldingOperationRequest(
      type: _selectedType,
      code: _codeController.text,
      platform: _platformController.text,
      status: _statusController.text,
      investedValue: _investedValueController.text,
      currentValue: _currentValueController.text,
      quantity: _quantityController.text,
      averagePrice: _averagePriceController.text,
      date: _dateController.text,
      observation: _observationController.text,
      descriptor: _descriptorController.text,
    );
    final validationError = request.validate();
    if (validationError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationError)));
      return;
    }
    Navigator.of(context).pop(request);
  }
}

class HoldingStatusSheet extends StatefulWidget {
  const HoldingStatusSheet({
    super.key,
    required this.type,
    required this.currentStatus,
  });

  final String type;
  final String currentStatus;

  @override
  State<HoldingStatusSheet> createState() => _HoldingStatusSheetState();
}

class _HoldingStatusSheetState extends State<HoldingStatusSheet> {
  late final TextEditingController _statusController;

  @override
  void initState() {
    super.initState();
    _statusController = TextEditingController(text: widget.currentStatus);
  }

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _suggestedStatuses(widget.type);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppPalette.panel,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppPalette.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Atualizar status', style: AppTheme.hudStyle(size: 18)),
              const SizedBox(height: 6),
              Text(
                'Altera apenas a base operacional.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppPalette.textMuted),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _statusController,
                decoration: InputDecoration(
                  labelText: 'Novo status',
                  filled: true,
                  fillColor: AppPalette.panelSoft,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppPalette.border),
                  ),
                ),
              ),
              if (suggestions.isNotEmpty) ...<Widget>[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: suggestions
                      .map(
                        (String item) => ActionChip(
                          label: Text(item),
                          onPressed: () => _statusController.text = item,
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _submit,
                      child: const Text('Salvar status'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _suggestedStatuses(String type) {
    switch (HoldingOperationRequest.crudTypeFromCategory(type)) {
      case 'fundos':
      case 'previdencia':
        return const <String>['Ativo', 'Pausado', 'Inativo'];
      case 'acoes':
      default:
        return const <String>['Comprado', 'Venda', 'Vendido'];
    }
  }

  void _submit() {
    final value = _statusController.text.trim();
    if (value.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Status obrigatorio.')));
      return;
    }
    Navigator.of(context).pop(value);
  }
}
