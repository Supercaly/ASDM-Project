import 'package:aspdm_project/core/either.dart';
import 'package:aspdm_project/domain/failures/failures.dart';
import 'package:aspdm_project/core/monad_task.dart';
import 'package:aspdm_project/domain/entities/user.dart';
import 'package:aspdm_project/domain/failures/server_failure.dart';
import 'package:aspdm_project/domain/repositories/auth_repository.dart';
import 'package:aspdm_project/infrastructure/datasources/remote_data_source.dart';
import 'package:aspdm_project/domain/values/user_values.dart';
import 'package:aspdm_project/services/preference_service.dart';

class AuthRepositoryImpl extends AuthRepository {
  RemoteDataSource _dataSource;
  PreferenceService _preferenceService;

  AuthRepositoryImpl(this._dataSource, this._preferenceService);

  @override
  Either<Failure, User> get lastSignedInUser =>
      Either.right(_preferenceService.getLastSignedInUser());

  @override
  Future<Either<Failure, User>> login(
      EmailAddress email, Password password) async {
    return MonadTask(
      () => _dataSource
          .authenticate(email.value.getOrCrash(), password.value.getOrCrash())
          .then((userModel) {
        if (userModel == null)
          throw InvalidUserFailure(
            email: email,
            password: password,
          );
        final user = userModel.toUser();
        _preferenceService.storeSignedInUser(user);
        return user;
      }),
    ).attempt<Failure>((e) => ServerFailure.unexpectedError(e)).run();
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    await _preferenceService.storeSignedInUser(null);
    return Either.right(const Unit());
  }
}