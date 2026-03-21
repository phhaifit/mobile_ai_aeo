// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overview_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$OverviewStore on _OverviewStore, Store {
  late final _$brandVisibilityScoreAtom =
      Atom(name: '_OverviewStore.brandVisibilityScore', context: context);

  @override
  double get brandVisibilityScore {
    _$brandVisibilityScoreAtom.reportRead();
    return super.brandVisibilityScore;
  }

  @override
  set brandVisibilityScore(double value) {
    _$brandVisibilityScoreAtom.reportWrite(value, super.brandVisibilityScore,
        () {
      super.brandVisibilityScore = value;
    });
  }

  late final _$brandVisibilityPercentAtom =
      Atom(name: '_OverviewStore.brandVisibilityPercent', context: context);

  @override
  double get brandVisibilityPercent {
    _$brandVisibilityPercentAtom.reportRead();
    return super.brandVisibilityPercent;
  }

  @override
  set brandVisibilityPercent(double value) {
    _$brandVisibilityPercentAtom
        .reportWrite(value, super.brandVisibilityPercent, () {
      super.brandVisibilityPercent = value;
    });
  }

  late final _$brandMentionsAtom =
      Atom(name: '_OverviewStore.brandMentions', context: context);

  @override
  int get brandMentions {
    _$brandMentionsAtom.reportRead();
    return super.brandMentions;
  }

  @override
  set brandMentions(int value) {
    _$brandMentionsAtom.reportWrite(value, super.brandMentions, () {
      super.brandMentions = value;
    });
  }

  late final _$linkVisibilityPercentAtom =
      Atom(name: '_OverviewStore.linkVisibilityPercent', context: context);

  @override
  double get linkVisibilityPercent {
    _$linkVisibilityPercentAtom.reportRead();
    return super.linkVisibilityPercent;
  }

  @override
  set linkVisibilityPercent(double value) {
    _$linkVisibilityPercentAtom.reportWrite(value, super.linkVisibilityPercent,
        () {
      super.linkVisibilityPercent = value;
    });
  }

  late final _$linkReferencesAtom =
      Atom(name: '_OverviewStore.linkReferences', context: context);

  @override
  int get linkReferences {
    _$linkReferencesAtom.reportRead();
    return super.linkReferences;
  }

  @override
  set linkReferences(int value) {
    _$linkReferencesAtom.reportWrite(value, super.linkReferences, () {
      super.linkReferences = value;
    });
  }

  late final _$suggestedBenchmarkAtom =
      Atom(name: '_OverviewStore.suggestedBenchmark', context: context);

  @override
  double get suggestedBenchmark {
    _$suggestedBenchmarkAtom.reportRead();
    return super.suggestedBenchmark;
  }

  @override
  set suggestedBenchmark(double value) {
    _$suggestedBenchmarkAtom.reportWrite(value, super.suggestedBenchmark, () {
      super.suggestedBenchmark = value;
    });
  }

  late final _$topReferencedDomainsAtom =
      Atom(name: '_OverviewStore.topReferencedDomains', context: context);

  @override
  List<ReferencedDomain> get topReferencedDomains {
    _$topReferencedDomainsAtom.reportRead();
    return super.topReferencedDomains;
  }

  @override
  set topReferencedDomains(List<ReferencedDomain> value) {
    _$topReferencedDomainsAtom.reportWrite(value, super.topReferencedDomains,
        () {
      super.topReferencedDomains = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_OverviewStore.isLoading', context: context);

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

  late final _$fetchMockDataAsyncAction =
      AsyncAction('_OverviewStore.fetchMockData', context: context);

  @override
  Future<void> fetchMockData() {
    return _$fetchMockDataAsyncAction.run(() => super.fetchMockData());
  }

  @override
  String toString() {
    return '''
brandVisibilityScore: ${brandVisibilityScore},
brandVisibilityPercent: ${brandVisibilityPercent},
brandMentions: ${brandMentions},
linkVisibilityPercent: ${linkVisibilityPercent},
linkReferences: ${linkReferences},
suggestedBenchmark: ${suggestedBenchmark},
topReferencedDomains: ${topReferencedDomains},
isLoading: ${isLoading}
    ''';
  }
}
