import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tasky/domain/failures/failures.dart';
import 'package:tasky/domain/values/unique_id.dart';

part 'task_failure.freezed.dart';

/// Represent that a [Failure] with the task has happened.
@freezed
abstract class TaskFailure extends Failure with _$TaskFailure {
  /// Creates a [TaskFailure] with invalid id error.
  const factory TaskFailure.invalidId() = TaskFailureInvalidId;

  /// Creates a [TaskFailure] with new comment error.
  const factory TaskFailure.newCommentFailure() = TaskFailureNewCommentFailure;

  /// Creates a [TaskFailure] with edit comment error.
  const factory TaskFailure.editCommentFailure(@nullable UniqueId commentId) =
      TaskFailureEditCommentFailure;

  /// Creates a [TaskFailure] with delete comment error.
  const factory TaskFailure.deleteCommentFailure(@nullable UniqueId commentId) =
      TaskFailureDeleteCommentFailure;

  /// Creates a [TaskFailure] with like comment error.
  const factory TaskFailure.likeFailure(@nullable UniqueId commentId) =
      TaskFailureLikeFailure;

  /// Creates a [TaskFailure] with dislike comment error.
  const factory TaskFailure.dislikeFailure(@nullable UniqueId commentId) =
      TaskFailureDislikeFailure;

  /// Creates a [TaskFailure] with archive error.
  const factory TaskFailure.archiveFailure(@nullable UniqueId taskId) =
      TaskFailureArchiveFailure;

  /// Creates a [TaskFailure] with unarchive error.
  const factory TaskFailure.unarchiveFailure(@nullable UniqueId taskId) =
      TaskFailureUnarchiveFailure;

  /// Creates a [TaskFailure] with complete item error.
  const factory TaskFailure.itemCompleteFailure(@nullable UniqueId itemId) =
      TaskFailureItemCompleteFailure;
}
