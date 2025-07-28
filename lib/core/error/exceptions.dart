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

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

class RateLimitException implements Exception {
  final String message;
  final int retryAfterSeconds;

  const RateLimitException(this.message, this.retryAfterSeconds);
}
