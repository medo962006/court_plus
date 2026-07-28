import 'package:flutter_test/flutter_test.dart';
import 'package:court_plus/core/result.dart';

void main() {
  group('Result<T>', () {
    group('Result.success', () {
      test('isSuccess returns true', () {
        final result = Result.success(42);
        expect(result.isSuccess, isTrue);
      });

      test('isFailure returns false', () {
        final result = Result.success('hello');
        expect(result.isFailure, isFalse);
      });

      test('orThrow returns the value', () {
        final result = Result.success([1, 2, 3]);
        expect(result.orThrow, [1, 2, 3]);
      });

      test('orNull returns the value', () {
        final result = Result.success('value');
        expect(result.orNull, 'value');
      });

      test('fold calls onSuccess with the value', () {
        final result = Result.success(10);
        final output = result.fold(
          (v) => 'Got $v',
          (e) => 'Error: ${e.message}',
        );
        expect(output, 'Got 10');
      });
    });

    group('Result.failure', () {
      test('isFailure returns true', () {
        final result = Result.failure(ValidationException('bad'));
        expect(result.isFailure, isTrue);
      });

      test('isSuccess returns false', () {
        final result = Result.failure(NetworkException('fail'));
        expect(result.isSuccess, isFalse);
      });

      test('orThrow throws the exception', () {
        final error = AuthException('not allowed');
        final result = Result.failure(error);
        expect(() => result.orThrow, throwsA(error));
      });

      test('orNull returns null', () {
        final result = Result.failure(NotFoundException('missing'));
        expect(result.orNull, isNull);
      });

      test('fold calls onFailure with the error', () {
        final error = AuthException('denied');
        final result = Result.failure(error);
        final output = result.fold(
          (v) => 'Got $v',
          (e) => 'Error: ${e.message}',
        );
        expect(output, 'Error: denied');
      });
    });

    group('Type safety', () {
      test('Success<T> preserves value type', () {
        final result = Result.success('text');
        expect(result.orThrow, isA<String>());
      });

      test('Failure<T> preserves error type', () {
              final Result<int> result = Result.failure(NetworkException('nope'));
              expect(result.fold((v) => v, (e) => -1), -1);
            });
    });
  });

  group('AppException subclasses', () {
    test('NetworkException has correct message and code', () {
      final e = NetworkException('timeout', code: 'NET_ERR');
      expect(e.message, 'timeout');
      expect(e.code, 'NET_ERR');
      expect(e.toString(), '[NET_ERR] timeout');
    });

    test('AuthException has correct message', () {
      final e = AuthException('unauthorized');
      expect(e.message, 'unauthorized');
      expect(e.code, isNull);
      expect(e.toString(), '[null] unauthorized');
    });

    test('ValidationException has fieldErrors', () {
      final e = ValidationException('invalid',
          fieldErrors: {'email': 'bad format'});
      expect(e.message, 'invalid');
      expect(e.fieldErrors, {'email': 'bad format'});
    });

    test('NotFoundException has correct message', () {
      final e = NotFoundException('user not found', code: '404');
      expect(e.message, 'user not found');
      expect(e.code, '404');
    });

    test('ServerException has correct message', () {
      final e = ServerException('internal error');
      expect(e.message, 'internal error');
    });

    test('CacheException has correct message', () {
      final e = CacheException('stale data');
      expect(e.message, 'stale data');
    });

    test('stackTrace is null when not provided', () {
      final e = ServerException('fail');
      expect(e.stackTrace, isNull);
    });
  });

  group('asyncGuard', () {
    test('returns Success when future completes', () async {
      final result = await asyncGuard(() async => 42);
      expect(result.isSuccess, isTrue);
      expect(result.orThrow, 42);
    });

    test('returns Failure with AppException when future throws AppException',
        () async {
      final result = await asyncGuard<int>(
        () async => throw AuthException('token expired'),
      );
      expect(result.isFailure, isTrue);
      expect(result.fold((v) => '', (e) => e.message), 'token expired');
    });

    test('returns Failure with ServerException for non-AppException errors',
        () async {
      final result = await asyncGuard<int>(
        () async => throw StateError('unexpected'),
      );
      expect(result.isFailure, isTrue);
      expect(result.fold((v) => '', (e) => e), isA<ServerException>());
    });

    test('wraps synchronous exceptions thrown inside Future', () async {
      final result = await asyncGuard<int>(() async {
        throw ArgumentError('bad arg');
      });
      expect(result.isFailure, isTrue);
      expect(
        result.fold((v) => '', (e) => e),
        isA<ServerException>(),
      );
    });
  });

  group('guard', () {
    test('returns Success when function returns', () {
      final result = guard(() => 'ok');
      expect(result.isSuccess, isTrue);
      expect(result.orThrow, 'ok');
    });

    test('returns Failure with AppException when function throws AppException',
        () {
      final result = guard<int>(
        () => throw ValidationException('bad input'),
      );
      expect(result.isFailure, isTrue);
      expect(
        result.fold((v) => '', (e) => e.message),
        'bad input',
      );
    });

    test('returns Failure with ServerException for non-AppException errors',
        () {
      final result = guard<int>(
        () => throw FormatException('bad format'),
      );
      expect(result.isFailure, isTrue);
      expect(result.fold((v) => '', (e) => e), isA<ServerException>());
    });
  });
}