import 'package:tasky/application/bloc/auth_bloc.dart';
import 'package:tasky/application/bloc/home_bloc.dart';
import 'package:tasky/locator.dart';
import 'package:tasky/presentation/pages/main/widgets/main_page_content_desktop.dart';
import 'package:tasky/presentation/pages/main/widgets/main_page_content_mobile.dart';
import 'package:tasky/presentation/pages/settings/settings_page.dart';
import 'package:tasky/presentation/pages/task_list/tasks_page.dart';
import 'package:tasky/domain/repositories/home_repository.dart';
import 'package:tasky/presentation/routes.dart';
import 'package:tasky/presentation/widgets/connection_state_listener.dart';
import 'package:tasky/services/connectivity_service.dart';
import 'package:tasky/services/log_service.dart';
import 'package:tasky/services/navigation_service.dart';
import 'package:tasky/presentation/widgets/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIdx;
  List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIdx = 0;
    _pages = [
      TasksPage(),
      Container(),
      SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ConnectionStateListener(
      connectivityService: locator<ConnectivityService>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) => state.maybeMap(
          unauthenticated: (_) =>
              locator<NavigationService>().replaceWith(Routes.login),
          orElse: () => null,
        ),
        child: BlocProvider(
          create: (context) => HomeBloc(
            repository: locator<HomeRepository>(),
          )..fetch(),
          child: Builder(
            builder: (context) {
              locator<LogService>()
                  .logBuild("Main Page - open page at index $_currentIdx");
              return Responsive(
                small: MainPageContentMobile(
                  currentIndex: _currentIdx,
                  pages: _pages,
                  navigateTo: _navigateTo,
                ),
                large: MainPageContentDesktop(
                  currentIndex: _currentIdx,
                  pages: _pages,
                  navigateTo: _navigateTo,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _navigateTo(int newIdx) {
    // Navigate to NewTaskPage
    if (newIdx == 1) {
      locator<NavigationService>().navigateTo(Routes.taskForm);
    } else
      setState(() => _currentIdx = newIdx);
  }
}
