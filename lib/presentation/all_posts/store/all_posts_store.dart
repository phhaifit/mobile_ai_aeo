import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:mobx/mobx.dart';

part 'all_posts_store.g.dart';

class AllPostsStore = _AllPostsStore with _$AllPostsStore;

abstract class _AllPostsStore with Store {
  // constructor:---------------------------------------------------------------
  _AllPostsStore(this.errorStore);

  // store variables:-----------------------------------------------------------
  final ErrorStore errorStore;

  @observable
  bool loading = false;

  // actions:-------------------------------------------------------------------
  @action
  Future<void> getPosts() async {
    loading = true;
    try {
      // TODO: Implement get posts logic
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
