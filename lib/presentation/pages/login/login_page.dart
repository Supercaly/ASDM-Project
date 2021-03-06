import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasky/application/bloc/auth_bloc.dart';
import 'package:tasky/application/bloc/login_bloc.dart';
import 'package:tasky/domain/repositories/auth_repository.dart';
import 'package:tasky/presentation/pages/login/widgets/login_page_content_desktop.dart';
import 'package:tasky/presentation/pages/login/widgets/login_page_content_mobile.dart';
import 'package:tasky/presentation/widgets/connection_state_listener.dart';
import 'package:tasky/presentation/widgets/responsive.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tasky/services/connectivity_service.dart';
import 'package:tasky/services/navigation_service.dart';

import '../../../locator.dart';
import '../../routes.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<LoginBloc>(
        create: (context) => LoginBloc(repository: locator<AuthRepository>()),
        child: ConnectionStateListener(
          connectivityService: locator<ConnectivityService>(),
          child: BlocConsumer<LoginBloc, LoginState>(
            listener: (context, state) => state.authFailureOrSuccessOption.fold(
              () {},
              (value) => value.fold(
                (failure) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('login_error_msg').tr())),
                (_) {
                  locator<NavigationService>().replaceWith(Routes.main);
                  context.read<AuthBloc>().checkAuth();
                },
              ),
            ),
            buildWhen: (p, c) => p.isLoading != c.isLoading,
            builder: (context, state) => LoadingOverlay(
              isLoading: state.isLoading,
              color: Colors.black45,
              child: Responsive(
                small: LoginPageContentMobile(),
                large: LoginPageContentDesktop(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
