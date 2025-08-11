import 'package:equatable/equatable.dart';

abstract class Failures extends Equatable {
  final String message;

  const Failures(this.message);

  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failures {
  const ServerFailure(String message) : super(message);
}

class AuthFailure extends Failures {
  const AuthFailure(String message) : super(message);
}

class CacheFailure extends Failures {
  const CacheFailure(String message) : super(message);
}

class NetworkFailure extends Failures {
  const NetworkFailure(String message) : super(message);
}

class RateLimitFailure extends Failures {
  final int retryAfterSeconds;

  const RateLimitFailure(super.message, this.retryAfterSeconds);

  @override
  List<Object> get props => [message, retryAfterSeconds];
}
class TokenExpiredFailure extends Failures {
  const TokenExpiredFailure(String message) : super(message);
}

class SessionExpiredFailure extends Failures {
  const SessionExpiredFailure(String message) : super(message);
}
