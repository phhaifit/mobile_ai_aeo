import 'dart:async';

import 'package:boilerplate/domain/repository/content/content_repository.dart';
import 'package:boilerplate/domain/repository/post/post_repository.dart';
import 'package:boilerplate/domain/repository/seo/seo_repository.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/domain/usecase/content/enhance_content_usecase.dart';
import 'package:boilerplate/domain/usecase/content/humanize_content_usecase.dart';
import 'package:boilerplate/domain/usecase/content/rewrite_content_usecase.dart';
import 'package:boilerplate/domain/usecase/content/summarize_content_usecase.dart';
import 'package:boilerplate/domain/usecase/seo/get_audit_history_usecase.dart';
import 'package:boilerplate/domain/usecase/seo/get_audit_status_usecase.dart';
import 'package:boilerplate/domain/usecase/seo/get_crawler_events_usecase.dart';
import 'package:boilerplate/domain/usecase/seo/run_seo_audit_usecase.dart';
import 'package:boilerplate/domain/usecase/post/delete_post_usecase.dart';
import 'package:boilerplate/domain/usecase/post/find_post_by_id_usecase.dart';
import 'package:boilerplate/domain/usecase/post/get_post_usecase.dart';
import 'package:boilerplate/domain/usecase/post/insert_post_usecase.dart';
import 'package:boilerplate/domain/usecase/post/udpate_post_usecase.dart';
import 'package:boilerplate/domain/usecase/user/is_logged_in_usecase.dart';
import 'package:boilerplate/domain/usecase/user/login_usecase.dart';
import 'package:boilerplate/domain/usecase/user/save_login_in_status_usecase.dart';

import '../../../di/service_locator.dart';

class UseCaseModule {
  static Future<void> configureUseCaseModuleInjection() async {
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
  }
}
