// domain/core/failures.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
abstract class Failure with _$Failure {
  const factory Failure.serverFailure({
    required String message,
    int? statusCode,
  }) = ServerFailure;

  const factory Failure.networkFailure({
    required String message,
  }) = NetworkFailure;

  const factory Failure.unauthorizedFailure({
    required String message,
  }) = UnauthorizedFailure;

  const factory Failure.notFoundFailure({
    required String message,
  }) = NotFoundFailure;

  const factory Failure.validationFailure({
    required String message,
  }) = ValidationFailure;

  const factory Failure.unexpectedFailure({
    required String message,
  }) = UnexpectedFailure;
}