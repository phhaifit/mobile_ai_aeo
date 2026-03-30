import 'dart:async';

import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/seo/seo_audit_request.dart';
import 'package:boilerplate/domain/repository/seo/seo_repository.dart';

class RunSeoAuditUseCase extends UseCase<String, SeoAuditRequest> {
  final SeoRepository _seoRepository;

  RunSeoAuditUseCase(this._seoRepository);

  @override
  Future<String> call({required SeoAuditRequest params}) {
    return _seoRepository.startAudit(params);
  }
}
