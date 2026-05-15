import 'package:boilerplate/data/repository/brand_setup/brand_profile_repository_impl.dart';
import 'package:boilerplate/data/repository/brand_setup/brand_positioning_repository_impl.dart';
import 'package:boilerplate/data/repository/brand_setup/knowledge_base_repository_impl.dart';
import 'package:boilerplate/data/repository/brand_setup/llm_monitoring_repository_impl.dart';
import 'package:boilerplate/data/repository/brand_setup/llm_polling_frequency_repository_impl.dart';
import 'package:boilerplate/data/repository/brand_setup/project_repository_impl.dart';
import 'package:boilerplate/data/repository/brand_setup/url_link_repository_impl.dart';
import 'package:boilerplate/data/repository/brand_setup/url_rewrite_repository_impl.dart';
import 'package:boilerplate/data/network/apis/brand_setup/brand_profile_api.dart';
import 'package:boilerplate/data/network/apis/brand_setup/brand_positioning_api.dart';
import 'package:boilerplate/data/network/apis/brand_setup/knowledge_base_api.dart';
import 'package:boilerplate/data/network/apis/brand_setup/llm_monitoring_api.dart';
import 'package:boilerplate/data/network/apis/brand_setup/llm_polling_frequency_api.dart';
import 'package:boilerplate/data/network/apis/brand_setup/project_api.dart';
import 'package:boilerplate/data/network/apis/brand_setup/url_link_api.dart';
import 'package:boilerplate/data/network/apis/brand_setup/url_rewrite_api.dart';
import 'package:boilerplate/domain/repository/brand_setup/brand_profile_repository.dart';
import 'package:boilerplate/domain/repository/brand_setup/brand_positioning_repository.dart';
import 'package:boilerplate/domain/repository/brand_setup/knowledge_base_repository.dart';
import 'package:boilerplate/domain/repository/brand_setup/llm_monitoring_repository.dart';
import 'package:boilerplate/domain/repository/brand_setup/llm_polling_frequency_repository.dart';
import 'package:boilerplate/domain/repository/brand_setup/project_repository.dart';
import 'package:boilerplate/domain/repository/brand_setup/url_link_repository.dart';
import 'package:boilerplate/domain/repository/brand_setup/url_rewrite_repository.dart';
import 'package:boilerplate/domain/usecase/brand_setup/brand_positioning_usecase.dart';
import 'package:boilerplate/domain/usecase/brand_setup/brand_profile_usecase.dart';
import 'package:boilerplate/domain/usecase/brand_setup/knowledge_base_usecase.dart';
import 'package:boilerplate/domain/usecase/brand_setup/llm_monitoring_usecase.dart';
import 'package:boilerplate/domain/usecase/brand_setup/llm_polling_frequency_usecase.dart';
import 'package:boilerplate/domain/usecase/brand_setup/project_usecase.dart';
import 'package:boilerplate/domain/usecase/brand_setup/url_link_usecase.dart';
import 'package:boilerplate/domain/usecase/brand_setup/url_rewrite_usecase.dart';

import '../../../di/service_locator.dart';

class BrandSetupModule {
  static Future<void> configureBrandSetupModuleInjection() async {
    // Repositories:----------------------------------------------------------
    getIt.registerSingleton<BrandProfileRepository>(
      BrandProfileRepositoryImpl(getIt<BrandProfileApi>()),
    );
    getIt.registerSingleton<KnowledgeBaseRepository>(
      KnowledgeBaseRepositoryImpl(getIt<KnowledgeBaseApi>()),
    );
    getIt.registerSingleton<UrlLinkRepository>(
      UrlLinkRepositoryImpl(getIt<UrlLinkApi>()),
    );
    getIt.registerSingleton<UrlRewriteRepository>(
      UrlRewriteRepositoryImpl(getIt<UrlRewriteApi>()),
    );
    getIt.registerSingleton<LlmMonitoringRepository>(
      LlmMonitoringRepositoryImpl(getIt<LlmMonitoringApi>()),
    );
    getIt.registerSingleton<LlmPollingFrequencyRepository>(
      LlmPollingFrequencyRepositoryImpl(getIt<LlmPollingFrequencyApi>()),
    );
    getIt.registerSingleton<BrandPositioningRepository>(
      BrandPositioningRepositoryImpl(getIt<BrandPositioningApi>()),
    );
    getIt.registerSingleton<ProjectRepository>(
      ProjectRepositoryImpl(getIt<ProjectApi>()),
    );

    // Use Cases:-------------------------------------------------------------
    getIt.registerSingleton(GetBrandProfileUseCase(getIt()));
    getIt.registerSingleton(SaveBrandProfileUseCase(getIt()));
    getIt.registerSingleton(UpdateBrandProfileUseCase(getIt()));

    getIt.registerSingleton(GetKnowledgeBaseEntriesUseCase(getIt()));
    getIt.registerSingleton(AddKnowledgeBaseEntryUseCase(getIt()));
    getIt.registerSingleton(UpdateKnowledgeBaseEntryUseCase(getIt()));
    getIt.registerSingleton(DeleteKnowledgeBaseEntryUseCase(getIt()));

    getIt.registerSingleton(GetUrlLinksUseCase(getIt()));
    getIt.registerSingleton(AddUrlLinkUseCase(getIt()));
    getIt.registerSingleton(UpdateUrlLinkUseCase(getIt()));
    getIt.registerSingleton(DeleteUrlLinkUseCase(getIt()));

    getIt.registerSingleton(GetUrlRewritesUseCase(getIt()));
    getIt.registerSingleton(AddUrlRewriteUseCase(getIt()));
    getIt.registerSingleton(UpdateUrlRewriteUseCase(getIt()));
    getIt.registerSingleton(DeleteUrlRewriteUseCase(getIt()));

    getIt.registerSingleton(GetLlmMonitoringConfigUseCase(getIt()));
    getIt.registerSingleton(ToggleLlmMonitoringUseCase(getIt()));

    getIt.registerSingleton(GetLlmPollingFrequencyUseCase(getIt()));
    getIt.registerSingleton(UpdateLlmPollingFrequencyUseCase(getIt()));

    getIt.registerSingleton(GetBrandPositioningUseCase(getIt()));
    getIt.registerSingleton(SaveBrandPositioningUseCase(getIt()));
    getIt.registerSingleton(UpdateBrandPositioningUseCase(getIt()));

    getIt.registerSingleton(GetProjectsUseCase(getIt()));
    getIt.registerSingleton(GetProjectUseCase(getIt()));
    getIt.registerSingleton(CreateProjectUseCase(getIt()));
    getIt.registerSingleton(SwitchProjectUseCase(getIt()));
    getIt.registerSingleton(UpdateProjectUseCase(getIt()));
    getIt.registerSingleton(DeleteProjectUseCase(getIt()));
  }
}
