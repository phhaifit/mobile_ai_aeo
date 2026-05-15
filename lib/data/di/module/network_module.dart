import 'package:boilerplate/core/config/environment_config.dart';
import 'package:boilerplate/core/data/network/dio/configs/dio_configs.dart';
import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/core/data/network/dio/interceptors/auth_interceptor.dart';
import 'package:boilerplate/core/data/network/dio/interceptors/logging_interceptor.dart';
import 'package:boilerplate/data/network/apis/auth/auth_api.dart';
import 'package:boilerplate/data/network/apis/analytics/analytics_api.dart';
import 'package:boilerplate/data/network/apis/content/content_api.dart';
import 'package:boilerplate/data/network/apis/content/content_profile_api.dart';
import 'package:boilerplate/data/network/apis/prompt/prompt_api.dart';
import 'package:boilerplate/data/network/apis/overview/overview_api.dart';
import 'package:boilerplate/data/network/apis/posts/post_api.dart';
import 'package:boilerplate/data/network/apis/seo/seo_api.dart';
import 'package:boilerplate/data/network/apis/brand_setup/brand_profile_api.dart';
import 'package:boilerplate/data/network/apis/brand_setup/knowledge_base_api.dart';
import 'package:boilerplate/data/network/apis/brand_setup/url_link_api.dart';
import 'package:boilerplate/data/network/apis/brand_setup/url_rewrite_api.dart';
import 'package:boilerplate/data/network/apis/brand_setup/llm_monitoring_api.dart';
import 'package:boilerplate/data/network/apis/brand_setup/llm_polling_frequency_api.dart';
import 'package:boilerplate/data/network/apis/brand_setup/brand_positioning_api.dart';
import 'package:boilerplate/data/network/apis/brand_setup/project_api.dart';
import 'package:boilerplate/data/service/google_auth_service.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/data/network/interceptors/error_interceptor.dart';
import 'package:boilerplate/data/service/mock_execution_service.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:event_bus/event_bus.dart';
import 'package:sentry_dio/sentry_dio.dart';

import '../../../di/service_locator.dart';

class NetworkModule {
  static Future<void> configureNetworkModuleInjection() async {
    final config = getIt<EnvironmentConfig>();

    // event bus:---------------------------------------------------------------
    getIt.registerSingleton<EventBus>(EventBus());

    // interceptors:------------------------------------------------------------
    getIt.registerSingleton<LoggingInterceptor>(LoggingInterceptor());
    getIt.registerSingleton<ErrorInterceptor>(ErrorInterceptor(getIt()));
    getIt.registerSingleton<AuthInterceptor>(
      AuthInterceptor(
        accessToken: () async =>
            await getIt<SharedPreferenceHelper>().authToken,
      ),
    );

    // rest client:-------------------------------------------------------------
    // getIt.registerSingleton(RestClient());

    // mock execution service:--------------------------------------------------
    getIt.registerSingleton<MockExecutionService>(
      MockExecutionService(),
    );

    // main dio client:---------------------------------------------------------
    getIt.registerSingleton<DioConfigs>(
      DioConfigs(
        baseUrl: config.apiBaseUrl,
        connectionTimeout: Endpoints.connectionTimeout,
        receiveTimeout: Endpoints.receiveTimeout,
      ),
    );
    final mainClient = DioClient(dioConfigs: getIt())
      ..addInterceptors([
        getIt<AuthInterceptor>(),
        getIt<ErrorInterceptor>(),
        getIt<LoggingInterceptor>(),
      ]);
    if (config.isSentryEnabled) {
      mainClient.dio.addSentry();
    }
    getIt.registerSingleton<DioClient>(mainClient);

    // AI service dio client (longer timeout for AI processing):----------------
    final aiClient = DioClient(
      dioConfigs: DioConfigs(
        baseUrl: config.aiApiBaseUrl,
        connectionTimeout: Endpoints.connectionTimeout,
        receiveTimeout: Endpoints.aiReceiveTimeout,
      ),
    )..addInterceptors([
        getIt<AuthInterceptor>(),
        getIt<ErrorInterceptor>(),
        getIt<LoggingInterceptor>(),
      ]);
    if (config.isSentryEnabled) {
      aiClient.dio.addSentry();
    }
    getIt.registerSingleton<DioClient>(aiClient, instanceName: 'aiDioClient');

    // api's:-------------------------------------------------------------------
    getIt.registerSingleton(AuthApi(getIt<DioClient>()));
    getIt.registerSingleton(PostApi(getIt<DioClient>()));
    getIt.registerSingleton(OverviewApi(getIt<DioClient>()));
    getIt.registerSingleton(AnalyticsApi(getIt<DioClient>()));
    getIt.registerSingleton(ContentProfileApi(getIt<DioClient>()));
    getIt.registerSingleton(PromptApi(getIt<DioClient>()));
    getIt.registerSingleton(
        ContentApi(getIt<DioClient>(instanceName: 'aiDioClient')));
    getIt.registerSingleton(
        SeoApi(getIt<DioClient>(instanceName: 'aiDioClient')));

    // Brand Setup APIs:--------------------------------------------------------
    getIt.registerSingleton(BrandProfileApi(getIt<DioClient>()));
    getIt.registerSingleton(KnowledgeBaseApi(getIt<DioClient>()));
    getIt.registerSingleton(UrlLinkApi(getIt<DioClient>()));
    getIt.registerSingleton(UrlRewriteApi(getIt<DioClient>()));
    getIt.registerSingleton(LlmMonitoringApi(getIt<DioClient>()));
    getIt.registerSingleton(LlmPollingFrequencyApi(getIt<DioClient>()));
    getIt.registerSingleton(BrandPositioningApi(getIt<DioClient>()));
    getIt.registerSingleton(ProjectApi(getIt<DioClient>()));

    // services:----------------------------------------------------------------
    getIt.registerSingleton(GoogleAuthService());
  }
}
