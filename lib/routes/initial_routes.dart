// lib/routes/initial_routes.dart

class InitialRoutes {
  InitialRoutes._();

  // Rute Awal
  static const splashScreen = '/';

  // Rute Onboarding
  static const onboarding1 = '/onboarding1';
  static const onboarding2 = '/onboarding2';
  static const onboarding3 = '/onboarding3';

  //Rute Verifikasi PIN
  static const verifyNumber = '/verify-number';
  static const createPin = '/create-pin';
  static const confirmPin = '/confirm-pin';
  static const pinLogin = '/pin-login';

  // Rute Lupa PIN
  static const forgotPin = '/forgot-pin';
  static const forgotPinNew = '/forgot-pin-new';
  static const confirmPinForgot = '/confirm-pin-forgot';
  static const resetPin = '/reset-pin';

  // Rute Ubah Nomor Telepon
  static const changePhone = '/change-phone';
  static const confirmChangePhone = '/confirm-change-phone';

  //Verify Pin
  static const verifyPinForChangePhone = '/verify-pin-change-phone';
  static const verifyPinForChangePin = '/verify-pin-change-pin';

  //Rute New PIN
  static const newPin = '/new-pin';
  static const confirmNewPin = '/confirm-new-pin';

  // Rute Detail Banner821817475
  static const bannerDetail = '/banner-detail';

  // Rute My vouchers
  static const myVouchers = '/my-vouchers';

  //Rute Profile
  static const personalData = '/personal-data';

  // Rute Autentikasi
  static const loginScreen = '/login';
  static const registerScreen = '/register';

  // Rute Utama di dalam MainScreen (Shell)
  static const home = '/home';
  static const orders = '/orders';
  static const favorites = '/favorites';
  static const vouchers = '/vouchers';
  static const profile = '/profile';
}
