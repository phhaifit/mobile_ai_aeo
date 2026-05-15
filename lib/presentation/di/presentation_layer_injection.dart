import 'package:boilerplate/presentation/di/module/store_module.dart';
import 'package:boilerplate/presentation/brand_setup/di/brand_setup_presentation_module.dart';

class PresentationLayerInjection {
  static Future<void> configurePresentationLayerInjection() async {
    await StoreModule.configureStoreModuleInjection();
    await BrandSetupPresentationModule
        .configureBrandSetupPresentationModuleInjection();
  }
}
