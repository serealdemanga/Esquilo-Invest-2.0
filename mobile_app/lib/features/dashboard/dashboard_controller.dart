import 'package:flutter/foundation.dart';

import '../../models/dashboard_payload.dart';
import '../../services/app_script_dashboard_service.dart';

class DashboardController extends ChangeNotifier {
  DashboardController(this._service);

  final AppScriptDashboardService _service;

  DashboardPayload? _dashboard;
  String? _errorMessage;
  String? _aiAnalysis;
  bool _isLoading = false;
  bool _isAiLoading = false;

  DashboardPayload? get dashboard => _dashboard;
  String? get errorMessage => _errorMessage;
  String? get aiAnalysis => _aiAnalysis;
  bool get isLoading => _isLoading;
  bool get isAiLoading => _isAiLoading;
  bool get isConfigured => _service.isConfigured;

  Future<void> loadDashboard() async {
    if (!isConfigured) {
      _errorMessage =
          'Defina APP_SCRIPT_BASE_URL e, se necessario, APP_SCRIPT_API_TOKEN.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboard = await _service.fetchDashboard();
    } on AppScriptApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Falha inesperada ao carregar a carteira.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAiAnalysis() async {
    if (!isConfigured) {
      _errorMessage =
          'Defina APP_SCRIPT_BASE_URL e, se necessario, APP_SCRIPT_API_TOKEN.';
      notifyListeners();
      return;
    }

    _isAiLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _aiAnalysis = await _service.fetchAiAnalysis();
    } on AppScriptApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Falha inesperada ao carregar a Esquilo IA.';
    } finally {
      _isAiLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
