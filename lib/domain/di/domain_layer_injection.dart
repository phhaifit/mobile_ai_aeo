import 'package:boilerplate/domain/di/module/usecase_module.dart';
import 'package:boilerplate/domain/di/module/brand_setup_module.dart';

class DomainLayerInjection {
  static Future<void> configureDomainLayerInjection() async {
    await UseCaseModule.configureUseCaseModuleInjection();
    await BrandSetupModule.configureBrandSetupModuleInjection();
  }
}
