import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/seo/seo_audit_result.dart';
import 'package:boilerplate/domain/repository/seo/seo_repository.dart';

class GetAuditStatusUseCase extends UseCase<SeoAuditResult, String> {
  final SeoRepository _seoRepository;

  GetAuditStatusUseCase(this._seoRepository);

  @override
  Future<SeoAuditResult> call({required String params}) {
    return _seoRepository.getAuditResult(params);
  }
}
