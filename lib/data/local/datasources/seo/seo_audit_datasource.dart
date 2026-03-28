import 'package:boilerplate/core/data/local/sembast/sembast_client.dart';
import 'package:boilerplate/data/local/constants/db_constants.dart';
import 'package:boilerplate/domain/entity/seo/seo_audit_result.dart';
import 'package:sembast/sembast.dart';

class SeoAuditDataSource {
  static const int _maxRecords = 10;

  final _store = intMapStoreFactory.store(DBConstants.SEO_STORE_NAME);
  final SembastClient _sembastClient;

  SeoAuditDataSource(this._sembastClient);

  Future<void> insert(SeoAuditResult result) async {
    await _store.add(_sembastClient.database, result.toMap());
    await _trimToMax();
  }

  Future<List<SeoAuditResult>> getAll() async {
    final finder = Finder(sortOrders: [SortOrder(Field.key, false)]);
    final snapshots = await _store.find(_sembastClient.database, finder: finder);
    return snapshots
        .map((s) => SeoAuditResult.fromMap(s.value))
        .toList();
  }

  Future<void> _trimToMax() async {
    final count = await _store.count(_sembastClient.database);
    if (count <= _maxRecords) return;

    final finder = Finder(
      sortOrders: [SortOrder(Field.key)],
      limit: count - _maxRecords,
    );
    final oldest = await _store.find(_sembastClient.database, finder: finder);
    for (final record in oldest) {
      await _store.record(record.key).delete(_sembastClient.database);
    }
  }

  Future<void> deleteAll() async {
    await _store.drop(_sembastClient.database);
  }
}
