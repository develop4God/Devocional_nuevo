import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devocional_nuevo/providers/onboarding/onboarding_state.dart';
import 'package:devocional_nuevo/providers/theme/theme_providers.dart';
import 'package:devocional_nuevo/providers/backup/backup_providers.dart';
import 'package:devocional_nuevo/services/onboarding_service.dart';
import 'package:devocional_nuevo/models/onboarding_models.dart';

/// StateNotifier for managing onboarding flow with Riverpod
class OnboardingNotifier extends StateNotifier<OnboardingRiverpodState> {
  final OnboardingService _onboardingService;
  final Ref _ref;

  // Configuration persistence keys
  static const String _configurationKey = 'onboarding_configuration';
  static const String _progressKey = 'onboarding_progress';
  
  // Total steps in onboarding flow
  static const int _totalSteps = 4;

  // Race condition protection
  bool _isProcessingStep = false;
  bool _isCompletingOnboarding = false;
  bool _isSavingConfiguration = false;

  OnboardingNotifier({
    required OnboardingService onboardingService,
    required Ref ref,
  })  : _onboardingService = onboardingService,
        _ref = ref,
        super(const OnboardingRiverpodState.initial());

  /// Initialize onboarding flow and determine starting point
  Future<void> initialize() async {
    debugPrint('🔄 [ONBOARDING_NOTIFIER] === INICIANDO InitializeOnboarding ===');

    state = const OnboardingRiverpodState.loading();

    try {
      // Check if onboarding has been completed
      final isCompleted = await _onboardingService.isOnboardingComplete();
      debugPrint('📊 [ONBOARDING_NOTIFIER] Onboarding completado: $isCompleted');

      if (isCompleted) {
        state = OnboardingRiverpodState.completed(
          appliedConfigurations: {},
          completionTimestamp: DateTime.now(),
        );
        return;
      }

      // Load saved configuration and progress
      final savedConfiguration = await _loadSavedConfiguration();
      final savedProgress = await _loadSavedProgress();

      debugPrint('📊 [ONBOARDING_NOTIFIER] Configuración guardada: $savedConfiguration');
      debugPrint('📊 [ONBOARDING_NOTIFIER] Progreso guardado: $savedProgress');

      // Determine starting step based on progress
      final currentStepIndex = _determineCurrentStep(savedProgress);
      debugPrint('📊 [ONBOARDING_NOTIFIER] Iniciando en paso: $currentStepIndex');

      final stepInfo = _getStepInfo(currentStepIndex);
      final completedStepsList = _getCompletedStepsList(savedConfiguration);
      final progress = OnboardingProgress(
        totalSteps: _totalSteps,
        completedSteps: completedStepsList.where((completed) => completed).length,
        stepCompletionStatus: completedStepsList,
        progressPercentage: (completedStepsList.where((completed) => completed).length / _totalSteps) * 100,
      );

      // Emit initial step active state
      state = OnboardingRiverpodState.stepActive(
        currentStepIndex: currentStepIndex,
        currentStep: stepInfo,
        userSelections: savedConfiguration,
        stepConfiguration: _getStepConfiguration(stepInfo),
        canProgress: _canProgressFromStep(currentStepIndex, savedConfiguration),
        canGoBack: currentStepIndex > 0,
        progress: progress,
      );

      debugPrint('✅ [ONBOARDING_NOTIFIER] OnboardingStepActive emitido exitosamente');
    } catch (e, stackTrace) {
      debugPrint('❌ [ONBOARDING_NOTIFIER] Error en inicialización: $e');
      debugPrint('🔍 [ONBOARDING_NOTIFIER] StackTrace: $stackTrace');

      state = OnboardingRiverpodState.error(
        message: 'Error al inicializar onboarding: ${e.toString()}',
        category: OnboardingErrorCategory.unknown,
        errorContext: {'exception': e.toString()},
      );
    }

    debugPrint('🏁 [ONBOARDING_NOTIFIER] === FIN InitializeOnboarding ===');
  }

  /// Progress to specific step in onboarding
  Future<void> progressToStep(int stepIndex) async {
    if (_isProcessingStep) {
      debugPrint('⚠️ [ONBOARDING_NOTIFIER] Ya procesando paso, ignorando solicitud');
      return;
    }

    _isProcessingStep = true;

    try {
      debugPrint('🔄 [ONBOARDING_NOTIFIER] === INICIANDO ProgressToStep: $stepIndex ===');

      final currentState = state;
      if (currentState is! OnboardingStepActiveState) {
        debugPrint('❌ [ONBOARDING_NOTIFIER] Estado no válido para progreso');
        return;
      }

      if (stepIndex < 0 || stepIndex >= _totalSteps) {
        debugPrint('❌ [ONBOARDING_NOTIFIER] Índice de paso inválido: $stepIndex');
        return;
      }

      // Save current progress
      await _saveProgress(stepIndex + 1, _totalSteps);
      debugPrint('💾 [ONBOARDING_NOTIFIER] Progreso guardado: ${stepIndex + 1}/$_totalSteps');

      final stepInfo = _getStepInfo(stepIndex);
      final completedStepsList = _getCompletedStepsList(currentState.userSelections);
      final progress = OnboardingProgress(
        totalSteps: _totalSteps,
        completedSteps: completedStepsList.where((completed) => completed).length,
        stepCompletionStatus: completedStepsList,
        progressPercentage: (completedStepsList.where((completed) => completed).length / _totalSteps) * 100,
      );

      // Update state
      state = OnboardingRiverpodState.stepActive(
        currentStepIndex: stepIndex,
        currentStep: stepInfo,
        userSelections: currentState.userSelections,
        stepConfiguration: _getStepConfiguration(stepInfo),
        canProgress: _canProgressFromStep(stepIndex, currentState.userSelections),
        canGoBack: stepIndex > 0,
        progress: progress,
      );

      debugPrint('✅ [ONBOARDING_NOTIFIER] Progreso a paso $stepIndex exitoso');
    } catch (e) {
      debugPrint('❌ [ONBOARDING_NOTIFIER] Error en ProgressToStep: $e');
      state = OnboardingRiverpodState.error(
        message: 'Error al progresar al paso $stepIndex: ${e.toString()}',
        category: OnboardingErrorCategory.unknown,
      );
    } finally {
      _isProcessingStep = false;
    }

    debugPrint('🏁 [ONBOARDING_NOTIFIER] === FIN ProgressToStep ===');
  }

  /// Select theme during onboarding
  Future<void> selectTheme(String themeFamily) async {
    debugPrint('🔄 [ONBOARDING_NOTIFIER] === INICIANDO SelectTheme: $themeFamily ===');

    try {
      final currentState = state;
      if (currentState is! OnboardingStepActiveState) {
        debugPrint('❌ [ONBOARDING_NOTIFIER] Estado no válido para selección de tema');
        return;
      }

      // Emit configuring state for theme selection
      state = const OnboardingRiverpodState.configuring(
        configurationType: OnboardingConfigurationType.themeSelection,
        configurationData: {},
      );

      // Apply theme immediately for preview using Riverpod
      await _ref.read(themeProvider.notifier).setThemeFamily(themeFamily);
      debugPrint('🎨 [ONBOARDING_NOTIFIER] Tema aplicado para preview: $themeFamily');

      final updatedSelections = Map<String, dynamic>.from(currentState.userSelections);
      updatedSelections['selectedThemeFamily'] = themeFamily;

      // Validate configuration before saving
      if (!_validateConfiguration(updatedSelections)) {
        state = const OnboardingRiverpodState.error(
          message: 'Configuración de tema inválida',
          category: OnboardingErrorCategory.invalidConfiguration,
        );
        return;
      }

      debugPrint('✅ [ONBOARDING_NOTIFIER] Configuration validation passed');

      // Save configuration
      await _saveConfiguration(updatedSelections);
      debugPrint('💾 [ONBOARDING_NOTIFIER] Configuración guardada: (selectedThemeFamily)');

      // Return to step active state with updated selections
      final completedStepsList = _getCompletedStepsList(updatedSelections);
      final progress = OnboardingProgress(
        totalSteps: _totalSteps,
        completedSteps: completedStepsList.where((completed) => completed).length,
        stepCompletionStatus: completedStepsList,
        progressPercentage: (completedStepsList.where((completed) => completed).length / _totalSteps) * 100,
      );

      state = OnboardingRiverpodState.stepActive(
        currentStepIndex: currentState.currentStepIndex,
        currentStep: currentState.currentStep,
        userSelections: updatedSelections,
        stepConfiguration: currentState.stepConfiguration,
        canProgress: _canProgressFromStep(currentState.currentStepIndex, updatedSelections),
        canGoBack: currentState.canGoBack,
        progress: progress,
      );

      debugPrint('✅ [ONBOARDING_NOTIFIER] Selección de tema exitosa');
    } catch (e) {
      debugPrint('❌ [ONBOARDING_NOTIFIER] Error en SelectTheme: $e');
      state = OnboardingRiverpodState.error(
        message: 'Error al seleccionar tema: ${e.toString()}',
        category: OnboardingErrorCategory.unknown,
      );
    }

    debugPrint('🏁 [ONBOARDING_NOTIFIER] === FIN SelectTheme ===');
  }

  /// Configure backup option during onboarding
  Future<void> configureBackupOption(bool enableBackup) async {
    debugPrint('🔄 [ONBOARDING_NOTIFIER] === INICIANDO ConfigureBackupOption: $enableBackup ===');

    try {
      final currentState = state;
      if (currentState is! OnboardingStepActiveState) {
        debugPrint('❌ [ONBOARDING_NOTIFIER] Estado no válido para configuración de backup');
        return;
      }

      // Emit configuring state
      state = const OnboardingRiverpodState.configuring(
        configurationType: OnboardingConfigurationType.backupConfiguration,
        configurationData: {},
      );

      final updatedSelections = Map<String, dynamic>.from(currentState.userSelections);
      updatedSelections['backupEnabled'] = enableBackup;

      // If backup is enabled and BackupBloc is available, trigger setup
      if (enableBackup && _backupBloc != null) {
        _backupBloc!.add(const SignInToGoogleDrive());
        debugPrint('🔧 [ONBOARDING_NOTIFIER] Google Drive Auth setup iniciado');
      }

      // Save configuration
      await _saveConfiguration(updatedSelections);
      debugPrint('💾 [ONBOARDING_NOTIFIER] Configuración de backup guardada: $enableBackup');

      // Return to step active state
      final completedStepsList = _getCompletedStepsList(updatedSelections);
      final progress = OnboardingProgress(
        totalSteps: _totalSteps,
        completedSteps: completedStepsList.where((completed) => completed).length,
        stepCompletionStatus: completedStepsList,
        progressPercentage: (completedStepsList.where((completed) => completed).length / _totalSteps) * 100,
      );

      state = OnboardingRiverpodState.stepActive(
        currentStepIndex: currentState.currentStepIndex,
        currentStep: currentState.currentStep,
        userSelections: updatedSelections,
        stepConfiguration: currentState.stepConfiguration,
        canProgress: _canProgressFromStep(currentState.currentStepIndex, updatedSelections),
        canGoBack: currentState.canGoBack,
        progress: progress,
      );

      debugPrint('✅ [ONBOARDING_NOTIFIER] Configuración de backup exitosa');
    } catch (e) {
      debugPrint('❌ [ONBOARDING_NOTIFIER] Error en ConfigureBackupOption: $e');
      state = OnboardingRiverpodState.error(
        message: 'Error al configurar backup: ${e.toString()}',
        category: OnboardingErrorCategory.unknown,
      );
    }

    debugPrint('🏁 [ONBOARDING_NOTIFIER] === FIN ConfigureBackupOption ===');
  }

  /// Complete onboarding flow
  Future<void> complete() async {
    if (_isCompletingOnboarding) {
      debugPrint('⚠️ [ONBOARDING_NOTIFIER] Ya completando onboarding, ignorando solicitud');
      return;
    }

    _isCompletingOnboarding = true;

    try {
      debugPrint('🔄 [ONBOARDING_NOTIFIER] === INICIANDO CompleteOnboarding ===');

      final currentState = state;
      if (currentState is! OnboardingStepActiveState) {
        debugPrint('❌ [ONBOARDING_NOTIFIER] Estado no válido para completar');
        return;
      }

      // Mark onboarding as completed
      await _onboardingService.setOnboardingComplete();
      debugPrint('✅ [ONBOARDING_NOTIFIER] Onboarding marcado como completado');

      // Apply final configurations
      await _applyFinalConfigurations(currentState.userSelections);
      debugPrint('✅ [ONBOARDING_NOTIFIER] Configuraciones finales aplicadas');

      // Clean up temporary data
      await _cleanupTemporaryData();
      debugPrint('🧹 [ONBOARDING_NOTIFIER] Datos temporales limpiados');

      state = OnboardingRiverpodState.completed(
        appliedConfigurations: currentState.userSelections,
        completionTimestamp: DateTime.now(),
      );

      debugPrint('✅ [ONBOARDING_NOTIFIER] CompleteOnboarding exitoso');
    } catch (e) {
      debugPrint('❌ [ONBOARDING_NOTIFIER] Error en CompleteOnboarding: $e');
      state = OnboardingRiverpodState.error(
        message: 'Error al completar onboarding: ${e.toString()}',
        category: OnboardingErrorCategory.unknown,
      );
    } finally {
      _isCompletingOnboarding = false;
    }

    debugPrint('🏁 [ONBOARDING_NOTIFIER] === FIN CompleteOnboarding ===');
  }

  /// Go back to previous step
  Future<void> goBack() async {
    final currentState = state;
    if (currentState is OnboardingStepActiveState && currentState.canGoBack) {
      await progressToStep(currentState.currentStepIndex - 1);
    }
  }

  /// Skip current step
  Future<void> skipCurrentStep() async {
    final currentState = state;
    if (currentState is OnboardingStepActiveState) {
      await progressToStep(currentState.currentStepIndex + 1);
    }
  }

  // Private helper methods
  
  int _determineCurrentStep(int? savedProgress) {
    if (savedProgress == null) return 0;
    return (savedProgress - 1).clamp(0, _totalSteps - 1);
  }

  OnboardingStepInfo _getStepInfo(int stepIndex) {
    switch (stepIndex) {
      case 0:
        return const OnboardingStepInfo(
          type: OnboardingStepType.welcome,
          title: 'Bienvenido',
          subtitle: 'Configuremos tu experiencia',
          isRequired: true,
          isSkippable: false,
        );
      case 1:
        return const OnboardingStepInfo(
          type: OnboardingStepType.themeSelection,
          title: 'Elige tu tema',
          subtitle: 'Personaliza el aspecto de la aplicación',
          isRequired: true,
          isSkippable: false,
        );
      case 2:
        return const OnboardingStepInfo(
          type: OnboardingStepType.backupConfiguration,
          title: 'Configurar respaldo',
          subtitle: 'Mantén tus datos seguros',
          isRequired: false,
          isSkippable: true,
        );
      case 3:
        return const OnboardingStepInfo(
          type: OnboardingStepType.completion,
          title: 'Listo',
          subtitle: '¡Todo configurado correctamente!',
          isRequired: true,
          isSkippable: false,
        );
      default:
        return const OnboardingStepInfo(
          type: OnboardingStepType.welcome,
          title: 'Bienvenido',
          subtitle: 'Configuremos tu experiencia',
          isRequired: true,
          isSkippable: false,
        );
    }
  }

  Map<String, dynamic> _getStepConfiguration(OnboardingStepInfo stepInfo) {
    return {}; // Can be extended with step-specific configuration
  }

  bool _canProgressFromStep(int stepIndex, Map<String, dynamic> userSelections) {
    switch (stepIndex) {
      case 1: // Theme selection step
        return userSelections.containsKey('selectedThemeFamily');
      case 2: // Backup configuration step
        return userSelections.containsKey('backupEnabled');
      default:
        return true;
    }
  }

  List<bool> _getCompletedStepsList(Map<String, dynamic> userSelections) {
    return [
      true, // Welcome step is always completed when reached
      userSelections.containsKey('selectedThemeFamily'),
      userSelections.containsKey('backupEnabled'),
      false, // Completion step is only completed when onboarding finishes
    ];
  }

  bool _validateConfiguration(Map<String, dynamic> config) {
    return true; // Basic validation - can be extended
  }

  Future<void> _applyFinalConfigurations(Map<String, dynamic> configurations) async {
    // Apply theme configuration
    if (configurations.containsKey('selectedThemeFamily')) {
      await _ref.read(themeProvider.notifier).setThemeFamily(
        configurations['selectedThemeFamily'] as String,
      );
    }
    
    // Other configurations can be applied here
  }

  Future<void> _cleanupTemporaryData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_progressKey);
    } catch (e) {
      debugPrint('⚠️ [ONBOARDING_NOTIFIER] Error limpiando datos temporales: $e');
    }
  }

  // SharedPreferences operations
  Future<Map<String, dynamic>> _loadSavedConfiguration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configString = prefs.getString(_configurationKey);
      if (configString != null) {
        return Map<String, dynamic>.from(jsonDecode(configString));
      }
    } catch (e) {
      debugPrint('⚠️ [ONBOARDING_NOTIFIER] Error cargando configuración: $e');
    }
    return {};
  }

  Future<int?> _loadSavedProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_progressKey);
    } catch (e) {
      debugPrint('⚠️ [ONBOARDING_NOTIFIER] Error cargando progreso: $e');
    }
    return null;
  }

  Future<void> _saveConfiguration(Map<String, dynamic> config) async {
    if (_isSavingConfiguration) return;
    
    _isSavingConfiguration = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_configurationKey, jsonEncode(config));
    } catch (e) {
      debugPrint('❌ [ONBOARDING_NOTIFIER] Error guardando configuración: $e');
    } finally {
      _isSavingConfiguration = false;
    }
  }

  Future<void> _saveProgress(int currentStep, int totalSteps) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_progressKey, currentStep);
    } catch (e) {
      debugPrint('❌ [ONBOARDING_NOTIFIER] Error guardando progreso: $e');
    }
  }
}