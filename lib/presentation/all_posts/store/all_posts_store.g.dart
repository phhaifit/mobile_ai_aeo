// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_posts_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AllPostsStore on _AllPostsStore, Store {
  late final _$loadingAtom =
      Atom(name: '_AllPostsStore.loading', context: context);

  @override
  bool get loading {
    _$loadingAtom.reportRead();
    return super.loading;
  }

  @override
  set loading(bool value) {
    _$loadingAtom.reportWrite(value, super.loading, () {
      super.loading = value;
    });
  }

  late final _$getPostsAsyncAction =
      AsyncAction('_AllPostsStore.getPosts', context: context);

  @override
  Future<void> getPosts() {
    return _$getPostsAsyncAction.run(() => super.getPosts());
  }

  @override
  String toString() {
    return '''
loading: ${loading}
    ''';
  }
}
