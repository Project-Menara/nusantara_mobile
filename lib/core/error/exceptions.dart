class ServerException implements Exception {
  final String message;
  const ServerException(this.message);

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}

// 2. MODIFIKASI AUTHEXCEPTION
class AuthException implements Exception {
  final String message;
  final AuthErrorType type; // Tambahkan properti type

  // Modifikasi constructor untuk bisa menerima 'type'
  AuthException(this.message, {this.type = AuthErrorType.unknown});
}
class RateLimitException implements Exception {
  final String message;
  final int retryAfterSeconds;

  const RateLimitException(this.message, this.retryAfterSeconds);
}
enum AuthErrorType {
  invalidCredentials,
  tokenExpired, // Tipe error yang kita butuhkan
  userNotFound,
  tooManyRequests,
  unknown,
}