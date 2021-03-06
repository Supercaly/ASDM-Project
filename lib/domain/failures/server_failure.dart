import 'package:tasky/domain/failures/failures.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_failure.freezed.dart';

/// Represent that a [Failure] with the server happened.
@freezed
abstract class ServerFailure extends Failure with _$ServerFailure {
  /// Creates a [ServerFailure] with unexpected error.
  const factory ServerFailure.unexpectedError(@nullable dynamic message) =
      ServerFailureUnexpectedError;

  /// Creates a [ServerFailure] with no internet error.
  const factory ServerFailure.noInternet() = ServerFailureNoInternet;

  /// Creates a [ServerFailure] with bad data error.
  const factory ServerFailure.badRequest(@nullable dynamic data) =
      ServerFailureBadRequest;

  /// Creates a [ServerFailure] with internal error.
  const factory ServerFailure.internalError(@nullable dynamic data) =
      ServerFailureInternalError;

  /// Creates a [ServerFailure] with format error.
  const factory ServerFailure.formatError(@nullable String message) =
      ServerFailureFormatError;

  /// Creates a [ServerFailure] with invalid arguments error.
  const factory ServerFailure.invalidArgument(@nullable String arg,
      {dynamic received}) = ServerFailureInvalidArgument;

  /// Creates a [ServerFailure] with upload error.
  const factory ServerFailure.uploadError() = ServerFailureUploadError;
}
