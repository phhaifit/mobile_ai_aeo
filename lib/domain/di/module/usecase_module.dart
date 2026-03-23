import 'dart:async';

import 'package:boilerplate/domain/repository/post/post_repository.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
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
  }
}
