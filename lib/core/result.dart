/// Monadic Result type for explicit error handling.
/// Either [Result.success] with a value or [Result.failure] with an [AppException].
sealed class Result<T> {
  const Result();

  factory Result.success(T value) = Success<T>;
  factory Result.failure(AppException error) = Failure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T get orThrow => switch (this) {
        Success<T>(:final value) => value,
        Failure<T>(:final error) => throw error,
      };

  T? get orNull => switch (this) {
        Success<T>(:final value) => value,
        Failure<T>() => null,
      };

  R fold<R>(R Function(T) onSuccess, R Function(AppException) onFailure) =>
      switch (this) {
        Success<T>(:final value) => onSuccess(value),
        Failure<T>(:final error) => onFailure(error),
      };
}

final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

final class Failure<T> extends Result<T> {
  final AppException error;
  const Failure(this.error);
}

/// Base exception for all application errors.
sealed class AppException implements Exception {
  final String message;
  final String? code;
  final StackTrace? stackTrace;
  const AppException(this.message, {this.code, this.stackTrace});

  @override
  String toString() => '[$code] $message';
}

final class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.stackTrace});
}

final class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.stackTrace});
}

final class ValidationException extends AppException {
  final Map<String, String> fieldErrors;
  const ValidationException(super.message,
      {this.fieldErrors = const {}, super.code, super.stackTrace});
}

final class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code, super.stackTrace});
}

final class ServerException extends AppException {
  const ServerException(super.message, {super.code, super.stackTrace});
}

final class CacheException extends AppException {
  const CacheException(super.message, {super.code, super.stackTrace});
}

/// Wraps async operations into [Result].
Future<Result<T>> asyncGuard<T>(Future<T> Function() fn) async {
  try {
    return Result.success(await fn());
  } on AppException catch (e) {
    return Result.failure(e);
  } catch (e, s) {
    return Result.failure(
      ServerException(e.toString(), stackTrace: s),
    );
  }
}

/// Wraps sync operations into [Result].
Result<T> guard<T>(T Function() fn) {
  try {
    return Result.success(fn());
  } on AppException catch (e) {
    return Result.failure(e);
  } catch (e, s) {
    return Result.failure(
      ServerException(e.toString(), stackTrace: s),
    );
  }
}