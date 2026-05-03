// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytic_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AnalyticStore on _AnalyticStore, Store {
  late final _$sentimentPositiveCountAtom =
      Atom(name: '_AnalyticStore.sentimentPositiveCount', context: context);

  @override
  int get sentimentPositiveCount {
    _$sentimentPositiveCountAtom.reportRead();
    return super.sentimentPositiveCount;
  }

  @override
  set sentimentPositiveCount(int value) {
    _$sentimentPositiveCountAtom
        .reportWrite(value, super.sentimentPositiveCount, () {
      super.sentimentPositiveCount = value;
    });
  }

  late final _$sentimentPositivePercentAtom =
      Atom(name: '_AnalyticStore.sentimentPositivePercent', context: context);

  @override
  double get sentimentPositivePercent {
    _$sentimentPositivePercentAtom.reportRead();
    return super.sentimentPositivePercent;
  }

  @override
  set sentimentPositivePercent(double value) {
    _$sentimentPositivePercentAtom
        .reportWrite(value, super.sentimentPositivePercent, () {
      super.sentimentPositivePercent = value;
    });
  }

  late final _$sentimentNeutralCountAtom =
      Atom(name: '_AnalyticStore.sentimentNeutralCount', context: context);

  @override
  int get sentimentNeutralCount {
    _$sentimentNeutralCountAtom.reportRead();
    return super.sentimentNeutralCount;
  }

  @override
  set sentimentNeutralCount(int value) {
    _$sentimentNeutralCountAtom.reportWrite(value, super.sentimentNeutralCount,
        () {
      super.sentimentNeutralCount = value;
    });
  }

  late final _$sentimentNeutralPercentAtom =
      Atom(name: '_AnalyticStore.sentimentNeutralPercent', context: context);

  @override
  double get sentimentNeutralPercent {
    _$sentimentNeutralPercentAtom.reportRead();
    return super.sentimentNeutralPercent;
  }

  @override
  set sentimentNeutralPercent(double value) {
    _$sentimentNeutralPercentAtom
        .reportWrite(value, super.sentimentNeutralPercent, () {
      super.sentimentNeutralPercent = value;
    });
  }

  late final _$sentimentNegativeCountAtom =
      Atom(name: '_AnalyticStore.sentimentNegativeCount', context: context);

  @override
  int get sentimentNegativeCount {
    _$sentimentNegativeCountAtom.reportRead();
    return super.sentimentNegativeCount;
  }

  @override
  set sentimentNegativeCount(int value) {
    _$sentimentNegativeCountAtom
        .reportWrite(value, super.sentimentNegativeCount, () {
      super.sentimentNegativeCount = value;
    });
  }

  late final _$sentimentNegativePercentAtom =
      Atom(name: '_AnalyticStore.sentimentNegativePercent', context: context);

  @override
  double get sentimentNegativePercent {
    _$sentimentNegativePercentAtom.reportRead();
    return super.sentimentNegativePercent;
  }

  @override
  set sentimentNegativePercent(double value) {
    _$sentimentNegativePercentAtom
        .reportWrite(value, super.sentimentNegativePercent, () {
      super.sentimentNegativePercent = value;
    });
  }

  late final _$llmShareDataAtom =
      Atom(name: '_AnalyticStore.llmShareData', context: context);

  @override
  List<LLMShareData> get llmShareData {
    _$llmShareDataAtom.reportRead();
    return super.llmShareData;
  }

  @override
  set llmShareData(List<LLMShareData> value) {
    _$llmShareDataAtom.reportWrite(value, super.llmShareData, () {
      super.llmShareData = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_AnalyticStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$fetchAnalyticsMetricsAsyncAction =
      AsyncAction('_AnalyticStore.fetchAnalyticsMetrics', context: context);

  @override
  Future<void> fetchAnalyticsMetrics(String projectId) {
    return _$fetchAnalyticsMetricsAsyncAction
        .run(() => super.fetchAnalyticsMetrics(projectId));
  }

  late final _$_AnalyticStoreActionController =
      ActionController(name: '_AnalyticStore', context: context);

  @override
  void _loadMockData() {
    final _$actionInfo = _$_AnalyticStoreActionController.startAction(
        name: '_AnalyticStore._loadMockData');
    try {
      return super._loadMockData();
    } finally {
      _$_AnalyticStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
sentimentPositiveCount: ${sentimentPositiveCount},
sentimentPositivePercent: ${sentimentPositivePercent},
sentimentNeutralCount: ${sentimentNeutralCount},
sentimentNeutralPercent: ${sentimentNeutralPercent},
sentimentNegativeCount: ${sentimentNegativeCount},
sentimentNegativePercent: ${sentimentNegativePercent},
llmShareData: ${llmShareData},
isLoading: ${isLoading}
    ''';
  }
}
