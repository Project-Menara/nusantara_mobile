import 'dart:convert';

class JwtHelper {
  /// Decode JWT token tanpa verifikasi signature
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      final payload = parts[1];

      // Tambahkan padding jika diperlukan
      String normalizedPayload = payload;
      while (normalizedPayload.length % 4 != 0) {
        normalizedPayload += '=';
      }

      final decoded = utf8.decode(base64Url.decode(normalizedPayload));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Cek apakah token sudah expired
  static bool isTokenExpired(String token) {
    try {
      final payload = decodeToken(token);
      if (payload == null) {
        return true;
      }

      final exp = payload['exp'];
      if (exp == null) {
        return true;
      }

      final expirationTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();

      return now.isAfter(expirationTime);
    } catch (e) {
      return true;
    }
  }

  /// Mendapatkan waktu remaining dari token (dalam detik)
  static int getTokenRemainingTime(String token) {
    try {
      final payload = decodeToken(token);
      if (payload == null) return 0;

      final exp = payload['exp'];
      if (exp == null) return 0;

      final expirationTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();

      final remaining = expirationTime.difference(now).inSeconds;
      return remaining > 0 ? remaining : 0;
    } catch (e) {
      return 0;
    }
  }

  /// Format waktu remaining ke string yang readable
  static String formatRemainingTime(int seconds) {
    if (seconds <= 0) return 'Expired';

    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  /// Set token expiry check to be more aggressive (untuk testing)
  /// Jika remaining time < threshold, anggap expired
  static bool isTokenNearExpiry(String token, {int thresholdMinutes = 5}) {
    try {
      final remainingSeconds = getTokenRemainingTime(token);
      final thresholdSeconds = thresholdMinutes * 60;
      return remainingSeconds <= thresholdSeconds;
    } catch (e) {
      return true;
    }
  }
}
