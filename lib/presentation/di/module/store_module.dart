import 'dart:async';

import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:boilerplate/domain/repository/setting/setting_repository.dart';
import 'package:boilerplate/domain/usecase/post/get_post_usecase.dart';
import 'package:boilerplate/domain/usecase/user/is_logged_in_usecase.dart';
import 'package:boilerplate/domain/usecase/user/login_usecase.dart';
import 'package:boilerplate/domain/usecase/user/save_login_in_status_usecase.dart';
import 'package:boilerplate/domain/usecase/content/enhance_content_usecase.dart';
import 'package:boilerplate/domain/usecase/content/humanize_content_usecase.dart';
import 'package:boilerplate/domain/usecase/content/rewrite_content_usecase.dart';
import 'package:boilerplate/domain/usecase/content/summarize_content_usecase.dart';
import 'package:boilerplate/domain/usecase/seo/get_audit_history_usecase.dart';
import 'package:boilerplate/domain/usecase/seo/get_audit_status_usecase.dart';
import 'package:boilerplate/domain/usecase/seo/get_crawler_events_usecase.dart';
import 'package:boilerplate/domain/usecase/seo/run_seo_audit_usecase.dart';
import 'package:boilerplate/presentation/content_enhancement/store/content_enhancement_store.dart';
import 'package:boilerplate/presentation/forgot_password/store/forgot_password_store.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/cronjob/store/cronjob_store.dart';
import 'package:boilerplate/presentation/cronjob/store/cronjob_execution_store.dart';
import 'package:boilerplate/domain/usecase/cronjob/get_all_cronjobs_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/get_cronjob_by_id_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/create_cronjob_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/update_cronjob_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/delete_cronjob_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/get_cronjob_executions_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/create_execution_usecase.dart';
import 'package:boilerplate/data/service/mock_execution_service.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/post/store/post_store.dart';
import 'package:boilerplate/presentation/technical_seo/store/technical_seo_store.dart';
import 'package:boilerplate/presentation/register/store/register_store.dart';
import 'package:boilerplate/presentation/overview/store/overview_store.dart';
import 'package:boilerplate/presentation/template_library/store/template_library_store.dart';
import 'package:boilerplate/presentation/all_posts/store/all_posts_store.dart';
import 'package:boilerplate/presentation/ai_writer/store/ai_writer_store.dart';
import 'package:boilerplate/presentation/auto_generation/store/auto_generation_store.dart';
import 'package:boilerplate/presentation/seo_optimization/store/seo_store.dart';
import 'package:boilerplate/domain/usecase/seo/get_seo_data_usecase.dart';
import 'package:boilerplate/presentation/performance_monitoring/store/performance_monitoring_store.dart';
import 'package:boilerplate/domain/usecase/trend/get_weekly_report_usecase.dart';
import 'package:boilerplate/domain/usecase/trend/get_trend_data_usecase.dart';
import 'package:boilerplate/domain/usecase/trend/get_performance_comparisons_usecase.dart';
import 'package:boilerplate/domain/usecase/trend/get_improvement_suggestions_usecase.dart';

import '../../../di/service_locator.dart';

class StoreModule {
  static Future<void> configureStoreModuleInjection() async {
    // factories:---------------------------------------------------------------
    getIt.registerFactory(() => ErrorStore());
    getIt.registerFactory(() => FormErrorStore());
    getIt.registerFactory(
      () => FormStore(getIt<FormErrorStore>(), getIt<ErrorStore>()),
    );

    // stores:------------------------------------------------------------------
    getIt.registerSingleton<UserStore>(
      UserStore(
        getIt<IsLoggedInUseCase>(),
        getIt<SaveLoginStatusUseCase>(),
        getIt<LoginUseCase>(),
        getIt<FormErrorStore>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<PostStore>(
      PostStore(
        getIt<GetPostUseCase>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<ThemeStore>(
      ThemeStore(
        getIt<SettingRepository>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<LanguageStore>(
      LanguageStore(
        getIt<SettingRepository>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<ContentEnhancementStore>(
      ContentEnhancementStore(
        getIt<EnhanceContentUseCase>(),
        getIt<RewriteContentUseCase>(),
        getIt<HumanizeContentUseCase>(),
        getIt<SummarizeContentUseCase>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<TechnicalSeoStore>(
      TechnicalSeoStore(
        getIt<RunSeoAuditUseCase>(),
        getIt<GetAuditStatusUseCase>(),
        getIt<GetAuditHistoryUseCase>(),
        getIt<GetCrawlerEventsUseCase>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<RegisterStore>(
      RegisterStore(
        getIt<FormErrorStore>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<ForgotPasswordStore>(
      ForgotPasswordStore(
        //getIt<FormErrorStore>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<OverviewStore>(
      OverviewStore(
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<SeoStore>(
      SeoStore(
        getIt<ErrorStore>(),
        getIt<GetSeoDataUseCase>(),
      ),
    );

    getIt.registerSingleton<AllPostsStore>(
      AllPostsStore(getIt<ErrorStore>()),
    );
    getIt.registerSingleton<AiWriterStore>(
      AiWriterStore(getIt<ErrorStore>()),
    );
    getIt.registerSingleton<AutoGenerationStore>(
      AutoGenerationStore(getIt<ErrorStore>()),
    );
    getIt.registerSingleton<TemplateLibraryStore>(
      TemplateLibraryStore(
        getIt<ErrorStore>(),
      ),
    );

    // Register CronjobStore as singleton
    getIt.registerSingleton<CronjobStore>(
      CronjobStore(
        getAllCronjobsUseCase: getIt<GetAllCronjobsUseCase>(),
        getCronjobByIdUseCase: getIt<GetCronjobByIdUseCase>(),
        createCronjobUseCase: getIt<CreateCronjobUseCase>(),
        updateCronjobUseCase: getIt<UpdateCronjobUseCase>(),
        deleteCronjobUseCase: getIt<DeleteCronjobUseCase>(),
      ),
    );

    // Register CronjobExecutionStore as singleton
    getIt.registerSingleton<CronjobExecutionStore>(
      CronjobExecutionStore(
        getCronjobExecutionsUseCase: getIt<GetCronjobExecutionsUseCase>(),
        createExecutionUseCase: getIt<CreateExecutionUseCase>(),
        getCronjobByIdUseCase: getIt<GetCronjobByIdUseCase>(),
        mockExecutionService: getIt<MockExecutionService>(),
      ),
    );

    // Register PerformanceMonitoringStore as singleton
    getIt.registerSingleton<PerformanceMonitoringStore>(
      PerformanceMonitoringStore(
        getIt<ErrorStore>(),
        getIt<GetWeeklyReportUseCase>(),
        getIt<GetTrendDataUseCase>(),
        getIt<GetPerformanceComparisonsUseCase>(),
        getIt<GetImprovementSuggestionsUseCase>(),
      ),
    );
  }
}
