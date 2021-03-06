import 'package:tasky/core/maybe.dart';
import 'package:tasky/domain/entities/task.dart';
import 'package:tasky/domain/values/unique_id.dart';
import 'package:tasky/presentation/pages/login/login_page.dart';
import 'package:tasky/presentation/pages/main/main_page.dart';
import 'package:tasky/presentation/pages/splash/splash_page.dart';
import 'package:tasky/presentation/pages/task_form/task_form_page.dart';
import 'package:tasky/presentation/pages/task_list/archive_page.dart';
import 'package:tasky/presentation/pages/task_info/task_info_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Static class containing all the route related logic.
class Routes {
  Routes._();

  /// Route names.
  static const String splash = "/";
  static const String main = "/main";
  static const String login = "/login";
  static const String archive = "/archive";
  static const String task = "/task";
  static const String taskForm = "/task-form";

  /// Route generator callback used to build the app's named routes.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(
          builder: (context) => SplashPage(),
          settings: settings,
        );
      case Routes.main:
        return MaterialPageRoute(
          builder: (context) => MainPage(),
          settings: settings,
        );
      case Routes.login:
        return MaterialPageRoute(
          builder: (context) => LoginPage(),
          settings: settings,
        );
      case Routes.archive:
        return MaterialPageRoute(
          builder: (context) => ArchivePage(),
          settings: settings,
        );
      case Routes.task:
        return MaterialPageRoute(
          builder: (context) => TaskInfoPage(
            taskId: extractArguments<UniqueId>(settings),
          ),
          settings: settings,
        );
      case Routes.taskForm:
        return MaterialPageRoute(
          builder: (context) => TaskFormPage(
            task: extractArguments<Task>(settings),
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      default:
        return MaterialPageRoute(
          builder: (context) => InvalidPageRoute(),
          settings: settings,
        );
    }
  }

  /// Extract the arguments form the [RouteSettings] and returns them.
  /// Returns a [Maybe] with the argument type [T]; if there is no arguments
  /// or are of a different type [Nothing] will be returned.
  @visibleForTesting
  static Maybe<T> extractArguments<T>(RouteSettings settings) {
    try {
      if (settings.arguments == null) return Maybe<T>.nothing();
      return Maybe<T>.just(settings.arguments as T);
    } catch (_) {
      return Maybe<T>.nothing();
    }
  }
}

/// Widget that is displayed if we are trying to navigate to
/// an invalid named route.
class InvalidPageRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(
          'invalid_route_msg',
          style: Theme.of(context).textTheme.headline6,
        ).tr(),
      ),
    );
  }
}
