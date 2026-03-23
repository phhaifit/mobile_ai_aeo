// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_generation_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AutoGenerationStore on _AutoGenerationStore, Store {
  late final _$loadingAtom =
      Atom(name: '_AutoGenerationStore.loading', context: context);

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

  late final _$startAutoGenerationAsyncAction =
      AsyncAction('_AutoGenerationStore.startAutoGeneration', context: context);

  @override
  Future<void> startAutoGeneration() {
    return _$startAutoGenerationAsyncAction
        .run(() => super.startAutoGeneration());
  }

  @override
  String toString() {
    return '''
loading: ${loading}
    ''';
  }
}
