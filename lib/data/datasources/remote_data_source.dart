import 'dart:io';
import 'package:aspdm_project/locator.dart';
import 'package:aspdm_project/domain/entities/label.dart';
import 'package:aspdm_project/domain/entities/user.dart';
import 'package:aspdm_project/domain/entities/task.dart';
import 'package:aspdm_project/services/log_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Class representing the data source of the entire application.
/// This class has the purpose to receive data from the remote server
/// and send to him the one that the app generates.
class RemoteDataSource {
  /// Base url of the API endpoint.
  static const String _baseUrl = "aspdm-project-server.glitch.me";

  Dio _dio;
  LogService _logService;

  RemoteDataSource()
      : _dio = Dio(BaseOptions(baseUrl: Uri.https(_baseUrl, "api").toString())),
        _logService = locator<LogService>();

  @visibleForTesting
  RemoteDataSource.test(this._dio, this._logService);

  /// Close the connection to the data source.
  void close() {
    _dio.close(force: true);
  }

  /*
   * ----------------------------------------
   *            User API
   * ----------------------------------------
   */

  /// Returns a list of all [User]s.
  /// This method throw [DioError] if some connection error happens.
  Future<List<User>> getUsers() async {
    final res = await get("/users");
    if (res.data != null)
      return (res.data as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();
    else
      return null;
  }

  /// Returns a [User] with given [userId].
  /// This method throw [DioError] if some connection error happens.
  Future<User> getUser(String userId) async {
    assert(userId != null);

    final res = await get("/user/$userId");
    if (res.data != null)
      return User.fromJson(res.data);
    else
      return null;
  }

  /// Authenticate a user with given [email] and [password].
  /// If the credentials are valid the corresponding [User] is returned,
  /// otherwise null is returned.
  /// This method throw [DioError] if some connection error happens.
  Future<User> authenticate(String email, String password) async {
    final res = await post("/authenticate", {
      "email": email,
      "password": password,
    });
    if (res.data != null) return User.fromJson(res.data);
    return null;
  }

  /*
   * ----------------------------------------
   *            Label API
   * ----------------------------------------
   */

  /// Returns a list of all [Label]s.
  /// This method throw [DioError] if some connection error happens.
  Future<List<Label>> getLabels() async {
    final res = await get("/labels");
    if (res.data != null)
      return (res.data as List<dynamic>)
          .map((e) => Label.fromJson(e as Map<String, dynamic>))
          .toList();
    else
      return null;
  }

  /*
   * ----------------------------------------
   *            Task API
   * ----------------------------------------
   */

  /// Returns a list of all [Task]s that are not archived.
  /// This method throw [DioError] if some connection error happens.
  Future<List<Task>> getUnarchivedTasks() async {
    final res = await get("/list");
    if (res.data != null)
      return (res.data as List<dynamic>)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
    else
      return null;
  }

  /// Returns a list of all [Task]s that are archived.
  /// This method throw [DioError] if some connection error happens.
  Future<List<Task>> getArchivedTasks() async {
    final res = await get("/list/archived");
    if (res.data != null)
      return (res.data as List<dynamic>)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
    else
      return null;
  }

  /// Returns a [Task] with given [taskId].
  /// This method throw [DioError] if some connection error happens.
  Future<Task> getTask(String taskId) async {
    assert(taskId != null);

    final res = await get("/task/$taskId");
    if (res.data != null)
      return Task.fromJson(res.data as Map<String, dynamic>);
    else
      return null;
  }

  /// Archive/Unarchive a [Task] with given [taskId].
  /// This method will return the updated [Task].
  /// This method throw [DioError] if some connection error happens.
  Future<Task> archive(String taskId, String userId, bool archive) async {
    assert(taskId != null);
    assert(userId != null);
    assert(archive != null);

    final res = await post("/task/archive", {
      "task": taskId,
      "user": userId,
      "archive": archive,
    });
    if (res.data != null)
      return Task.fromJson(res.data as Map<String, dynamic>);
    else
      return null;
  }

  /// Creates a new task from a given [Task].
  /// This method throw [DioError] if some connection error happens.
  Future<Task> postTask(Task newTask) async {
    assert(newTask != null);

    final jsonTask = newTask.toJson();
    final res = await post("/task", {
      "title": jsonTask['title'],
      "description": jsonTask['description'],
      "author": jsonTask['author'],
      "members": jsonTask['members'],
      "labels": jsonTask['labels'],
      "expire_date": jsonTask['expire_date'],
      "checklists": newTask.checklists?.map((e) => {
            "title": e.title,
            "items": e.items?.map((i) => i.item),
          }),
    });
    if (res.data != null)
      return Task.fromJson(res.data as Map<String, dynamic>);
    else
      return null;
  }

  /// Updates an existing task from a given [Task].
  /// This method throw [DioError] if some connection error happens.
  Future<Task> patchTask(Task newTask) async {
    assert(newTask != null);

    final res = await patch("/task", newTask.toJson());
    if (res.data != null)
      return Task.fromJson(res.data as Map<String, dynamic>);
    else
      return null;
  }

  /*
   * ----------------------------------------
   *            Comment API
   * ----------------------------------------
   */

  /// Adds a new comment under a [Task] with given [taskId].
  /// This method will return the updated [Task].
  /// This method throw [DioError] if some connection error happens.
  Future<Task> postComment(String taskId, String userId, String content) async {
    assert(taskId != null);
    assert(userId != null);
    assert(content != null);

    final res = await post("/comment", {
      "task": taskId,
      "comment": {
        "author": userId,
        "content": content,
      },
    });
    if (res.data != null)
      return Task.fromJson(res.data as Map<String, dynamic>);
    else
      return null;
  }

  /// Deletes a comment under a [Task] with given [taskId].
  /// This method will return the updated [Task].
  /// This method throw [DioError] if some connection error happens.
  Future<Task> deleteComment(
    String taskId,
    String commentId,
    String userId,
  ) async {
    assert(taskId != null);
    assert(commentId != null);
    assert(userId != null);

    final res = await delete("/comment", {
      "task": taskId,
      "user": userId,
      "comment": commentId,
    });
    if (res.data != null)
      return Task.fromJson(res.data as Map<String, dynamic>);
    else
      return null;
  }

  /// Updates a comment under a [Task] with given [taskId].
  /// This method will return the updated [Task].
  /// This method throw [DioError] if some connection error happens.
  Future<Task> patchComment(
    String taskId,
    String commentId,
    String userId,
    String newContent,
  ) async {
    assert(taskId != null);
    assert(commentId != null);
    assert(userId != null);
    assert(newContent != null);

    final res = await patch("/comment", {
      "task": taskId,
      "user": userId,
      "comment": commentId,
      "content": newContent,
    });
    if (res.data != null)
      return Task.fromJson(res.data as Map<String, dynamic>);
    else
      return null;
  }

  /// Likes a comment under a [Task] with given [taskId].
  /// This method will return the updated [Task].
  /// This method throw [DioError] if some connection error happens.
  Future<Task> likeComment(
    String taskId,
    String commentId,
    String userId,
  ) async {
    assert(taskId != null);
    assert(commentId != null);
    assert(userId != null);

    final res = await post("/comment/like", {
      "task": taskId,
      "user": userId,
      "comment": commentId,
    });
    if (res.data != null)
      return Task.fromJson(res.data as Map<String, dynamic>);
    else
      return null;
  }

  /// Dislikes a comment under a [Task] with given [taskId].
  /// This method will return the updated [Task].
  /// This method throw [DioError] if some connection error happens.
  Future<Task> dislikeComment(
    String taskId,
    String commentId,
    String userId,
  ) async {
    assert(taskId != null);
    assert(commentId != null);
    assert(userId != null);

    final res = await post("/comment/dislike", {
      "task": taskId,
      "user": userId,
      "comment": commentId,
    });
    if (res.data != null)
      return Task.fromJson(res.data as Map<String, dynamic>);
    else
      return null;
  }

  /// Mark a checklist's item of a [Task] with given [taskId] as complete.
  /// This method will return the updated [Task].
  /// This method throw [DioError] if some connection error happens.
  Future<Task> check(
    String taskId,
    String userId,
    String checklistId,
    String itemId,
    bool checked,
  ) async {
    assert(taskId != null);
    assert(userId != null);
    assert(checklistId != null);
    assert(itemId != null);
    assert(checked != null);

    final res = await post("/task/check", {
      "task": taskId,
      "user": userId,
      "checklist": checklistId,
      "item": itemId,
      "checked": checked,
    });
    if (res.data != null)
      return Task.fromJson(res.data as Map<String, dynamic>);
    else
      return null;
  }

  /*
   * ----------------------------------------
   *            Internal HTTP methods
   * ----------------------------------------
   */

  /// Run a HTTP request with method GET to the given [url].
  /// Returns the JSON response or throws a [DioError].
  @visibleForTesting
  Future<Response<dynamic>> get(String url) async {
    try {
      return await _dio.get(url);
    } on DioError catch (e) {
      if (e.response != null && e.response.statusCode == 400)
        _logService.error("DataSource get: Bad request: ${e.response.data}");
      else if (e.error is SocketException)
        _logService.error("DataSource get: No internet connection!");
      rethrow;
    }
  }

  /// Run a HTTP request with method POST to the given [url] with
  /// given [body] parameters.
  /// Returns the JSON response or throws a [DioError].
  @visibleForTesting
  Future<Response<dynamic>> post(String url, Map<String, dynamic> body) async {
    try {
      return await _dio.post(url, data: body);
    } on DioError catch (e) {
      if (e.response != null && e.response.statusCode == 400)
        _logService.error("DataSource post: Bad request: ${e.response.data}");
      else if (e.error is SocketException)
        _logService.error("DataSource post: No internet connection!");
      rethrow;
    }
  }

  /// Run a HTTP request with method PATCH to the given [url] with
  /// given [body] parameters.
  /// Returns the JSON response or throws a [DioError].
  @visibleForTesting
  Future<Response<dynamic>> patch(String url, Map<String, dynamic> body) async {
    try {
      return await _dio.patch(url, data: body);
    } on DioError catch (e) {
      if (e.response != null && e.response.statusCode == 400)
        _logService.error("DataSource patch: Bad request: ${e.response.data}");
      else if (e.error is SocketException)
        _logService.error("DataSource patch: No internet connection!");
      rethrow;
    }
  }

  /// Run a HTTP request with method DELETE to the given [url] with
  /// given [body] parameters.
  /// Returns the JSON response or throws a [DioError].
  @visibleForTesting
  Future<Response<dynamic>> delete(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      return await _dio.delete(url, data: body);
    } on DioError catch (e) {
      if (e.response != null && e.response.statusCode == 400)
        _logService.error("DataSource delete: Bad request: ${e.response.data}");
      else if (e.error is SocketException)
        _logService.error("DataSource delete: No internet connection!");
      rethrow;
    }
  }
}