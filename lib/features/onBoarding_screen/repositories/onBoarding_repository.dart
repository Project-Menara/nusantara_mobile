import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OnboardingRepository {
  static const _hasSeenOnBoardingValue = "hasSeenOnBoarding";
  static const _onBoardingKey = "onBoarding";

  static const _storage = FlutterSecureStorage();

  Future<void> setSession() async {
    await _storage.write(key: _onBoardingKey, value: _hasSeenOnBoardingValue);
  }

  Future<bool> get hasSeenOnBoarding async {
    final value = await _storage.read(key: _onBoardingKey);
    return value == _hasSeenOnBoardingValue;
  }
}
