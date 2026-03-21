import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/seo/crawler_event.dart';
import 'package:boilerplate/domain/repository/seo/seo_repository.dart';

class GetCrawlerEventsUseCase extends UseCase<List<CrawlerEvent>, String> {
  final SeoRepository _seoRepository;

  GetCrawlerEventsUseCase(this._seoRepository);

  @override
  Future<List<CrawlerEvent>> call({required String params}) {
    return _seoRepository.getCrawlerEvents(params);
  }
}
