import 'package:sembast/sembast.dart';

import '../../../domain/entity/cronjob/cronjob.dart';
import '../../../domain/entity/cronjob/cronjob_execution.dart';
import 'cronjob_datasource.dart';

class CronjobDataSourceImpl implements CronjobDataSource {
  final Database database;

  static const String _cronjobsStoreName = 'cronjobs';
  static const String _executionsStoreName = 'cronjob_executions';

  late final StoreRef<String, Map<String, dynamic>> _cronjobsStore =
      stringMapStoreFactory.store(_cronjobsStoreName);
  late final StoreRef<String, Map<String, dynamic>> _executionsStore =
      stringMapStoreFactory.store(_executionsStoreName);

  CronjobDataSourceImpl({required this.database});

  @override
  Future<List<Cronjob>> getAllCronjobs() async {
    final records = await _cronjobsStore.find(database);
    return records
        .map((record) => Cronjob.fromMap(record.value))
        .toList();
  }

  @override
  Future<Cronjob?> getCronjobById(String id) async {
    final record = await _cronjobsStore.record(id).get(database);
    if (record != null) {
      return Cronjob.fromMap(record);
    }
    return null;
  }

  @override
  Future<void> saveCronjob(Cronjob cronjob) async {
    await _cronjobsStore.record(cronjob.id).put(database, cronjob.toMap());
  }

  @override
  Future<void> deleteCronjob(String id) async {
    await _cronjobsStore.record(id).delete(database);
  }

  @override
  Future<List<CronjobExecution>> getCronjobExecutions(String cronjobId) async {
    final allExecutions = await _executionsStore.find(database);
    return allExecutions
        .where((record) {
          final execution = CronjobExecution.fromMap(record.value);
          return execution.cronjobId == cronjobId;
        })
        .map((record) => CronjobExecution.fromMap(record.value))
        .toList();
  }

  @override
  Future<void> saveExecution(CronjobExecution execution) async {
    await _executionsStore.record(execution.id).put(database, execution.toMap());
  }

  @override
  Future<CronjobExecution?> getExecutionById(String executionId) async {
    final record = await _executionsStore.record(executionId).get(database);
    if (record != null) {
      return CronjobExecution.fromMap(record);
    }
    return null;
  }

  @override
  Future<void> deleteExecution(String executionId) async {
    await _executionsStore.record(executionId).delete(database);
  }
}
