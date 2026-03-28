import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:mobx/mobx.dart';

part 'auto_generation_store.g.dart';

class AutoGenerationStore = _AutoGenerationStore with _$AutoGenerationStore;

abstract class _AutoGenerationStore with Store {
  // constructor:---------------------------------------------------------------
  _AutoGenerationStore(this.errorStore);

  // store variables:-----------------------------------------------------------
  final ErrorStore errorStore;

  @observable
  bool loading = false;

  // actions:-------------------------------------------------------------------
  @action
  Future<void> startAutoGeneration() async {
    loading = true;
    try {
      // TODO: Implement auto generation logic
      await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      errorStore.errorMessage = e.toString();
    } finally {
      loading = false;
    }
  }

  // disposers:-----------------------------------------------------------------
  void dispose() {}
}
