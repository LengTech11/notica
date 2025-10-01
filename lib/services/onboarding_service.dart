import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage onboarding state
class OnboardingService {
  static const String _onboardingCompleteKey = 'onboarding_complete';

  static final OnboardingService _instance = OnboardingService._internal();
  factory OnboardingService() => _instance;
  OnboardingService._internal();

  SharedPreferences? _prefs;

  /// Initialize the onboarding service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Check if onboarding has been completed
  Future<bool> isOnboardingComplete() async {
    await _ensureInitialized();
    return _prefs!.getBool(_onboardingCompleteKey) ?? false;
  }

  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    await _ensureInitialized();
    await _prefs!.setBool(_onboardingCompleteKey, true);
  }

  /// Reset onboarding (for testing purposes)
  Future<void> resetOnboarding() async {
    await _ensureInitialized();
    await _prefs!.setBool(_onboardingCompleteKey, false);
  }

  /// Ensure service is initialized
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await initialize();
    }
  }
}
