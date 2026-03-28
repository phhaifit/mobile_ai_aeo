import 'package:mobx/mobx.dart';

part 'planning_and_recommendations_store.g.dart';

class PlanningAndRecommendationsStore = _PlanningAndRecommendationsStore
    with _$PlanningAndRecommendationsStore;

abstract class _PlanningAndRecommendationsStore with Store {
  @observable
  bool isLoading = false;
}
