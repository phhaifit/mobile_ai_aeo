import '../../entity/trend/improvement_suggestion.dart';
import '../../repository/trend/trend_repository.dart';

class GetImprovementSuggestionsUseCase {
  final TrendRepository repository;

  GetImprovementSuggestionsUseCase({required this.repository});

  Future<List<ImprovementSuggestion>> call() async {
    return await repository.getImprovementSuggestions();
  }
}
