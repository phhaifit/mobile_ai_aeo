import 'package:boilerplate/domain/usecase/brand_setup/brand_positioning_usecase.dart';
import 'package:boilerplate/domain/usecase/brand_setup/brand_profile_usecase.dart';
import 'package:boilerplate/domain/usecase/brand_setup/knowledge_base_usecase.dart';
import 'package:boilerplate/domain/usecase/brand_setup/llm_monitoring_usecase.dart';
import 'package:boilerplate/domain/usecase/brand_setup/llm_polling_frequency_usecase.dart';
import 'package:boilerplate/domain/usecase/brand_setup/project_usecase.dart';
import 'package:boilerplate/domain/usecase/brand_setup/url_link_usecase.dart';
import 'package:boilerplate/domain/usecase/brand_setup/url_rewrite_usecase.dart';
import 'package:boilerplate/presentation/brand_setup/store/brand_positioning_store.dart';
import 'package:boilerplate/presentation/brand_setup/store/brand_profile_store.dart';
import 'package:boilerplate/presentation/brand_setup/store/knowledge_base_store.dart';
import 'package:boilerplate/presentation/brand_setup/store/llm_monitoring_store.dart';
import 'package:boilerplate/presentation/brand_setup/store/llm_polling_frequency_store.dart';
import 'package:boilerplate/presentation/brand_setup/store/project_store.dart';
import 'package:boilerplate/presentation/brand_setup/store/url_link_store.dart';
import 'package:boilerplate/presentation/brand_setup/store/url_rewrite_store.dart';

import '../../../di/service_locator.dart';

class BrandSetupPresentationModule {
  static Future<void> configureBrandSetupPresentationModuleInjection() async {
    // Stores:----------------------------------------------------------------
    getIt.registerSingleton<BrandProfileStore>(
      BrandProfileStore(
        getIt<GetBrandProfileUseCase>(),
        getIt<SaveBrandProfileUseCase>(),
        getIt<UpdateBrandProfileUseCase>(),
      ),
    );

    getIt.registerSingleton<KnowledgeBaseStore>(
      KnowledgeBaseStore(
        getIt<GetKnowledgeBaseEntriesUseCase>(),
        getIt<AddKnowledgeBaseEntryUseCase>(),
        getIt<UpdateKnowledgeBaseEntryUseCase>(),
        getIt<DeleteKnowledgeBaseEntryUseCase>(),
      ),
    );

    getIt.registerSingleton<UrlLinkStore>(
      UrlLinkStore(
        getIt<GetUrlLinksUseCase>(),
        getIt<AddUrlLinkUseCase>(),
        getIt<UpdateUrlLinkUseCase>(),
        getIt<DeleteUrlLinkUseCase>(),
      ),
    );

    getIt.registerSingleton<UrlRewriteStore>(
      UrlRewriteStore(
        getIt<GetUrlRewritesUseCase>(),
        getIt<AddUrlRewriteUseCase>(),
        getIt<UpdateUrlRewriteUseCase>(),
        getIt<DeleteUrlRewriteUseCase>(),
      ),
    );

    getIt.registerSingleton<LlmMonitoringStore>(
      LlmMonitoringStore(
        getIt<GetLlmMonitoringConfigUseCase>(),
        getIt<ToggleLlmMonitoringUseCase>(),
      ),
    );

    getIt.registerSingleton<LlmPollingFrequencyStore>(
      LlmPollingFrequencyStore(
        getIt<GetLlmPollingFrequencyUseCase>(),
        getIt<UpdateLlmPollingFrequencyUseCase>(),
      ),
    );

    getIt.registerSingleton<BrandPositioningStore>(
      BrandPositioningStore(
        getIt<GetBrandPositioningUseCase>(),
        getIt<SaveBrandPositioningUseCase>(),
        getIt<UpdateBrandPositioningUseCase>(),
      ),
    );

    getIt.registerSingleton<ProjectStore>(
      ProjectStore(
        getIt<GetProjectsUseCase>(),
        getIt<GetProjectUseCase>(),
        getIt<CreateProjectUseCase>(),
        getIt<SwitchProjectUseCase>(),
        getIt<UpdateProjectUseCase>(),
        getIt<DeleteProjectUseCase>(),
      ),
    );
  }
}
