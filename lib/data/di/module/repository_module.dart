import 'dart:async';

import 'package:boilerplate/data/local/datasource/cronjob_datasource_impl.dart';
import 'package:boilerplate/data/local/datasources/post/post_datasource.dart';
import 'package:boilerplate/data/local/datasources/seo/seo_audit_datasource.dart';
import 'package:boilerplate/data/network/apis/content/content_api.dart';
import 'package:boilerplate/data/network/apis/posts/post_api.dart';
import 'package:boilerplate/data/network/apis/seo/seo_api.dart';
import 'package:boilerplate/data/repository/content/content_repository_impl.dart';
import 'package:boilerplate/data/repository/cronjob_repository_impl.dart';
import 'package:boilerplate/data/repository/post/post_repository_impl.dart';
import 'package:boilerplate/data/repository/seo/seo_repository_impl.dart';
import 'package:boilerplate/data/repository/setting/setting_repository_impl.dart';
import 'package:boilerplate/data/repository/user/user_repository_impl.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/domain/repository/content/content_repository.dart';
import 'package:boilerplate/domain/repository/cronjob_repository.dart';
import 'package:boilerplate/domain/repository/post/post_repository.dart';
import 'package:boilerplate/domain/repository/seo/seo_repository.dart';
import 'package:boilerplate/domain/repository/setting/setting_repository.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/domain/repository/seo_repository.dart';
import 'package:boilerplate/data/repository/seo_repository_impl.dart';

import '../../../di/service_locator.dart';

class RepositoryModule {
  static Future<void> configureRepositoryModuleInjection() async {
    // repository:--------------------------------------------------------------
    getIt.registerSingleton<SettingRepository>(SettingRepositoryImpl(
      getIt<SharedPreferenceHelper>(),
    ));

    getIt.registerSingleton<UserRepository>(UserRepositoryImpl(
      getIt<SharedPreferenceHelper>(),
    ));

    getIt.registerSingleton<PostRepository>(PostRepositoryImpl(
      getIt<PostApi>(),
      getIt<PostDataSource>(),
    ));

    getIt.registerSingleton<ContentRepository>(
      ContentRepositoryImpl(getIt<ContentApi>()),
    );

    getIt.registerSingleton<SeoRepository>(
      SeoRepositoryImpl(getIt<SeoApi>(), getIt<SeoAuditDataSource>()),
    );

    // cronjob repository:------------------------------------------------------
    getIt.registerSingleton<CronjobRepository>(CronjobRepositoryImpl(
      localDataSource: getIt<CronjobDataSourceImpl>(),
    ));
  }
}
