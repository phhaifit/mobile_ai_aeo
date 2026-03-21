import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/seo/seo_audit_result.dart';
import 'package:boilerplate/domain/repository/seo/seo_repository.dart';

class GetAuditHistoryUseCase extends UseCase<List<SeoAuditResult>, void> {
  final SeoRepository _seoRepository;

  GetAuditHistoryUseCase(this._seoRepository);

  @override
  Future<List<SeoAuditResult>> call({required void params}) {
    return _seoRepository.getAuditHistory();
  }
}
