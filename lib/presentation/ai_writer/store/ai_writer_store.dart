import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:mobx/mobx.dart';

part 'ai_writer_store.g.dart';

class AiWriterStore = _AiWriterStore with _$AiWriterStore;

abstract class _AiWriterStore with Store {
  // constructor:---------------------------------------------------------------
  _AiWriterStore(this.errorStore);

  // store variables:-----------------------------------------------------------
  final ErrorStore errorStore;

  @observable
  bool loading = false;

  // actions:-------------------------------------------------------------------
  @action
  Future<void> generateContent() async {
    loading = true;
    try {
      // TODO: Implement generate content logic
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
