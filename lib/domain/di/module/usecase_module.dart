import 'dart:async';

import 'package:boilerplate/domain/repository/analytics/analytics_repository.dart';
import 'package:boilerplate/domain/repository/content/content_repository.dart';
import 'package:boilerplate/domain/repository/content/content_profile_repository.dart';
import 'package:boilerplate/domain/repository/prompt/prompt_repository.dart';
import 'package:boilerplate/domain/repository/overview/overview_repository.dart';
import 'package:boilerplate/domain/repository/post/post_repository.dart';
import 'package:boilerplate/domain/repository/seo/seo_repository.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/domain/usecase/analytics/get_analytics_metrics_usecase.dart';
import 'package:boilerplate/domain/usecase/overview/get_overview_metrics_usecase.dart';
import 'package:boilerplate/domain/usecase/seo/get_audit_history_usecase.dart';
import 'package:boilerplate/domain/usecase/seo/get_audit_status_usecase.dart';
import 'package:boilerplate/domain/usecase/seo/get_crawler_events_usecase.dart';
import 'package:boilerplate/domain/usecase/seo/run_seo_audit_usecase.dart';
import 'package:boilerplate/domain/usecase/content/enhance_content_usecase.dart';
import 'package:boilerplate/domain/usecase/content/humanize_content_usecase.dart';
import 'package:boilerplate/domain/usecase/content/rewrite_content_usecase.dart';
import 'package:boilerplate/domain/usecase/content/summarize_content_usecase.dart';
import 'package:boilerplate/domain/usecase/content/get_content_profiles_usecase.dart';
import 'package:boilerplate/domain/usecase/content/create_content_profile_usecase.dart';
import 'package:boilerplate/domain/usecase/content/update_content_profile_usecase.dart';
import 'package:boilerplate/domain/usecase/content/delete_content_profile_usecase.dart';
import 'package:boilerplate/domain/usecase/prompt/create_content_generation_usecase.dart';
import 'package:boilerplate/domain/usecase/prompt/get_prompts_by_project_usecase.dart';
import 'package:boilerplate/domain/usecase/post/delete_post_usecase.dart';
import 'package:boilerplate/domain/usecase/post/find_post_by_id_usecase.dart';
import 'package:boilerplate/domain/usecase/post/get_post_usecase.dart';
import 'package:boilerplate/domain/usecase/post/insert_post_usecase.dart';
import 'package:boilerplate/domain/usecase/post/udpate_post_usecase.dart';
import 'package:boilerplate/domain/usecase/user/is_logged_in_usecase.dart';
import 'package:boilerplate/domain/usecase/user/login_usecase.dart';
import 'package:boilerplate/domain/usecase/user/save_login_in_status_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/get_all_cronjobs_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/get_cronjob_by_id_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/create_cronjob_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/update_cronjob_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/delete_cronjob_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/get_cronjob_executions_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/create_execution_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/get_execution_by_id_usecase.dart';
import 'package:boilerplate/domain/repository/cronjob_repository.dart';
import 'package:boilerplate/domain/repository/seo_repository.dart' as seo_opt;
import 'package:boilerplate/domain/usecase/seo/get_seo_data_usecase.dart';
import 'package:boilerplate/domain/repository/trend/trend_repository.dart';
import 'package:boilerplate/domain/usecase/trend/get_weekly_report_usecase.dart';
import 'package:boilerplate/domain/usecase/trend/get_trend_data_usecase.dart';
import 'package:boilerplate/domain/usecase/trend/get_performance_comparisons_usecase.dart';
import 'package:boilerplate/domain/usecase/trend/get_improvement_suggestions_usecase.dart';

import '../../../di/service_locator.dart';

class UseCaseModule {
  static Future<void> configureUseCaseModuleInjection() async {
    // analytics:---------------------------------------------------------------
    getIt.registerSingleton<GetAnalyticsMetricsUseCase>(
      GetAnalyticsMetricsUseCase(getIt<AnalyticsRepository>()),
    );

    // overview:----------------------------------------------------------------
    getIt.registerSingleton<GetOverviewMetricsUseCase>(
      GetOverviewMetricsUseCase(getIt<OverviewRepository>()),
    );

    // user:--------------------------------------------------------------------
    getIt.registerSingleton<IsLoggedInUseCase>(
      IsLoggedInUseCase(getIt<UserRepository>()),
    );
    getIt.registerSingleton<SaveLoginStatusUseCase>(
      SaveLoginStatusUseCase(getIt<UserRepository>()),
    );
    getIt.registerSingleton<LoginUseCase>(
      LoginUseCase(getIt<UserRepository>()),
    );

    // post:--------------------------------------------------------------------
    getIt.registerSingleton<GetPostUseCase>(
      GetPostUseCase(getIt<PostRepository>()),
    );
    getIt.registerSingleton<FindPostByIdUseCase>(
      FindPostByIdUseCase(getIt<PostRepository>()),
    );
    getIt.registerSingleton<InsertPostUseCase>(
      InsertPostUseCase(getIt<PostRepository>()),
    );
    getIt.registerSingleton<UpdatePostUseCase>(
      UpdatePostUseCase(getIt<PostRepository>()),
    );
    getIt.registerSingleton<DeletePostUseCase>(
      DeletePostUseCase(getIt<PostRepository>()),
    );

    // content:-----------------------------------------------------------------
    getIt.registerSingleton<EnhanceContentUseCase>(
      EnhanceContentUseCase(getIt<ContentRepository>()),
    );
    getIt.registerSingleton<RewriteContentUseCase>(
      RewriteContentUseCase(getIt<ContentRepository>()),
    );
    getIt.registerSingleton<HumanizeContentUseCase>(
      HumanizeContentUseCase(getIt<ContentRepository>()),
    );
    getIt.registerSingleton<SummarizeContentUseCase>(
      SummarizeContentUseCase(getIt<ContentRepository>()),
    );
    getIt.registerSingleton<GetContentProfilesUseCase>(
      GetContentProfilesUseCase(getIt<ContentProfileRepository>()),
    );
    getIt.registerSingleton<CreateContentProfileUseCase>(
      CreateContentProfileUseCase(getIt<ContentProfileRepository>()),
    );
    getIt.registerSingleton<UpdateContentProfileUseCase>(
      UpdateContentProfileUseCase(getIt<ContentProfileRepository>()),
    );
    getIt.registerSingleton<DeleteContentProfileUseCase>(
      DeleteContentProfileUseCase(getIt<ContentProfileRepository>()),
    );

    getIt.registerSingleton<GetPromptsByProjectUseCase>(
      GetPromptsByProjectUseCase(getIt<PromptRepository>()),
    );
    getIt.registerSingleton<CreateContentGenerationUseCase>(
      CreateContentGenerationUseCase(getIt<PromptRepository>()),
    );

    // seo:--------------------------------------------------------------------
    getIt.registerSingleton<RunSeoAuditUseCase>(
      RunSeoAuditUseCase(getIt<SeoRepository>()),
    );
    getIt.registerSingleton<GetAuditStatusUseCase>(
      GetAuditStatusUseCase(getIt<SeoRepository>()),
    );
    getIt.registerSingleton<GetAuditHistoryUseCase>(
      GetAuditHistoryUseCase(getIt<SeoRepository>()),
    );
    getIt.registerSingleton<GetCrawlerEventsUseCase>(
      GetCrawlerEventsUseCase(getIt<SeoRepository>()),
    );
    // cronjob:-----------------------------------------------------------------
    getIt.registerSingleton<GetAllCronjobsUseCase>(
      GetAllCronjobsUseCase(repository: getIt<CronjobRepository>()),
    );
    getIt.registerSingleton<GetCronjobByIdUseCase>(
      GetCronjobByIdUseCase(repository: getIt<CronjobRepository>()),
    );
    getIt.registerSingleton<CreateCronjobUseCase>(
      CreateCronjobUseCase(repository: getIt<CronjobRepository>()),
    );
    getIt.registerSingleton<UpdateCronjobUseCase>(
      UpdateCronjobUseCase(repository: getIt<CronjobRepository>()),
    );
    getIt.registerSingleton<DeleteCronjobUseCase>(
      DeleteCronjobUseCase(repository: getIt<CronjobRepository>()),
    );
    getIt.registerSingleton<GetCronjobExecutionsUseCase>(
      GetCronjobExecutionsUseCase(repository: getIt<CronjobRepository>()),
    );
    getIt.registerSingleton<CreateExecutionUseCase>(
      CreateExecutionUseCase(repository: getIt<CronjobRepository>()),
    );
    getIt.registerSingleton<GetExecutionByIdUseCase>(
      GetExecutionByIdUseCase(repository: getIt<CronjobRepository>()),
    );

    // seo optimization:--------------------------------------------------------
    getIt.registerSingleton<GetSeoDataUseCase>(
      GetSeoDataUseCase(repository: getIt<seo_opt.SeoRepository>()),
    );

    // trend:-------------------------------------------------------------------
    getIt.registerSingleton<GetWeeklyReportUseCase>(
      GetWeeklyReportUseCase(repository: getIt<TrendRepository>()),
    );
    getIt.registerSingleton<GetTrendDataUseCase>(
      GetTrendDataUseCase(repository: getIt<TrendRepository>()),
    );
    getIt.registerSingleton<GetPerformanceComparisonsUseCase>(
      GetPerformanceComparisonsUseCase(repository: getIt<TrendRepository>()),
    );
    getIt.registerSingleton<GetImprovementSuggestionsUseCase>(
      GetImprovementSuggestionsUseCase(repository: getIt<TrendRepository>()),
    );
  }
}
