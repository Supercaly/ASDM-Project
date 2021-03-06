import 'package:tasky/core/either.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'value_object.freezed.dart';

/// Class representing a value that can be used by an entity.
abstract class ValueObject<T> {
  /// Returns [Either] the value [T] or a [ValueFailure].
  Either<ValueFailure<T>, T> get value;

  const ValueObject();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValueObject<T> && other.value == this.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => "Value{$value}";
}

/// Class representing the invalid state of a ValueObject.
@freezed
abstract class ValueFailure<T> with _$ValueFailure<T> {
  const factory ValueFailure.empty(@nullable T value) = ValueFailureEmpty<T>;

  const factory ValueFailure.tooLong(@nullable T value) =
      ValueFailureTooLong<T>;

  const factory ValueFailure.invalidEmail(@nullable T value) =
      ValueFailureInvalidEmail<T>;

  const factory ValueFailure.invalidPassword(@nullable T value) =
      ValueFailureInvalidPassword<T>;

  const factory ValueFailure.invalidId(@nullable T value) =
      ValueFailureInvalidId<T>;

  const factory ValueFailure.unknown(@nullable T value) =
      ValueFailureUnknown<T>;
}
