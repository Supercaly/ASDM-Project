import 'package:aspdm_project/domain/entities/task.dart';
import 'package:aspdm_project/domain/repositories/archive_repository.dart';
import 'package:aspdm_project/data/datasources/remote_data_source.dart';

import '../../locator.dart';

class ArchiveRepositoryImpl extends ArchiveRepository {
  final RemoteDataSource _dataSource = locator<RemoteDataSource>();

  @override
  Future<List<Task>> getArchivedTasks() {
    return _dataSource.getArchivedTasks();
  }
}