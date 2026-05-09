import 'dart:async';

import 'package:boilerplate/data/local/datasource/cronjob_datasource_impl.dart';
import 'package:boilerplate/data/local/datasources/post/post_datasource.dart';
import 'package:boilerplate/data/local/datasources/seo/seo_audit_datasource.dart';
import 'package:boilerplate/data/network/apis/analytics/analytics_api.dart';
import 'package:boilerplate/data/network/apis/auth/auth_api.dart';
import 'package:boilerplate/data/network/apis/content/content_api.dart';
import 'package:boilerplate/data/network/apis/content/content_profile_api.dart';
import 'package:boilerplate/data/network/apis/prompt/prompt_api.dart';
import 'package:boilerplate/data/network/apis/overview/overview_api.dart';
import 'package:boilerplate/data/network/apis/posts/post_api.dart';
import 'package:boilerplate/data/network/apis/seo/seo_api.dart';
import 'package:boilerplate/data/repository/analytics/analytics_repository_impl.dart';
import 'package:boilerplate/data/network/apis/performance/performance_api.dart';
import 'package:boilerplate/data/service/google_auth_service.dart';
import 'package:boilerplate/data/repository/content/content_repository_impl.dart';
import 'package:boilerplate/data/repository/content/content_profile_repository_impl.dart';
import 'package:boilerplate/data/repository/prompt/prompt_repository_impl.dart';
import 'package:boilerplate/data/repository/cronjob_repository_impl.dart';
import 'package:boilerplate/data/repository/overview/overview_repository_impl.dart';
import 'package:boilerplate/data/repository/post/post_repository_impl.dart';
import 'package:boilerplate/data/repository/seo/seo_repository_impl.dart';
import 'package:boilerplate/data/repository/setting/setting_repository_impl.dart';
import 'package:boilerplate/data/repository/user/user_repository_impl.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/domain/repository/analytics/analytics_repository.dart';
import 'package:boilerplate/domain/repository/content/content_repository.dart';
import 'package:boilerplate/domain/repository/content/content_profile_repository.dart';
import 'package:boilerplate/domain/repository/prompt/prompt_repository.dart';
import 'package:boilerplate/domain/repository/cronjob_repository.dart';
import 'package:boilerplate/domain/repository/overview/overview_repository.dart';
import 'package:boilerplate/domain/repository/post/post_repository.dart';
import 'package:boilerplate/domain/repository/seo/seo_repository.dart';
import 'package:boilerplate/domain/repository/setting/setting_repository.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/domain/repository/seo_repository.dart' as seo_opt;
import 'package:boilerplate/data/repository/seo_repository_impl.dart'
    as seo_opt;
import 'package:boilerplate/domain/repository/trend/trend_repository.dart';
import 'package:boilerplate/data/repository/trend/trend_repository_impl.dart';
import 'package:boilerplate/domain/repository/chat/chat-repository.dart';
import 'package:boilerplate/data/repository/chat/chat-repository-impl.dart';
import 'package:boilerplate/data/datasource/remote/chat/chat-mock-datasource.dart';

import '../../../di/service_locator.dart';

class RepositoryModule {
  static Future<void> configureRepositoryModuleInjection() async {
    // repository:--------------------------------------------------------------
    getIt.registerSingleton<SettingRepository>(SettingRepositoryImpl(
      getIt<SharedPreferenceHelper>(),
    ));

    getIt.registerSingleton<UserRepository>(UserRepositoryImpl(
      getIt<SharedPreferenceHelper>(),
      getIt<AuthApi>(),
      getIt<GoogleAuthService>(),
    ));

    getIt.registerSingleton<PostRepository>(PostRepositoryImpl(
      getIt<PostApi>(),
      getIt<PostDataSource>(),
    ));

    getIt.registerSingleton<ContentRepository>(
      ContentRepositoryImpl(getIt<ContentApi>()),
    );

    getIt.registerSingleton<ContentProfileRepository>(
      ContentProfileRepositoryImpl(getIt<ContentProfileApi>()),
    );

    getIt.registerSingleton<PromptRepository>(
      PromptRepositoryImpl(getIt<PromptApi>()),
    );

    getIt.registerSingleton<OverviewRepository>(
      OverviewRepositoryImpl(getIt<OverviewApi>()),
    );

    getIt.registerSingleton<AnalyticsRepository>(
      AnalyticsRepositoryImpl(getIt<AnalyticsApi>()),
    );

    getIt.registerSingleton<SeoRepository>(
      SeoRepositoryImpl(getIt<SeoApi>(), getIt<SeoAuditDataSource>()),
    );

    getIt.registerSingleton<seo_opt.SeoRepository>(
      seo_opt.SeoRepositoryImpl(getIt<SeoApi>()),
    );
    // cronjob repository:------------------------------------------------------
    getIt.registerSingleton<CronjobRepository>(CronjobRepositoryImpl(
      localDataSource: getIt<CronjobDataSourceImpl>(),
    ));

    // trend repository:---------------------------------------------------------
    getIt.registerSingleton<TrendRepository>(
      TrendRepositoryImpl(getIt<PerformanceApi>()),
    );

    // chat repository:---------------------------------------------------------
    getIt.registerSingleton<ChatMockDataSource>(
      ChatMockDataSource(),
    );
    getIt.registerSingleton<ChatRepository>(
      ChatRepositoryImpl(getIt<ChatMockDataSource>()),
    );
  }
}
