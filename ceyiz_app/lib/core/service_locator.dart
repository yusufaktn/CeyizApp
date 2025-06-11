import 'package:get_it/get_it.dart';

import '../services/bohca_service.dart';
import '../services/ceyiz_service.dart';
import '../services/local_storage_service.dart';
import '../services/photo_service.dart';
import '../viewmodels/bohca_view_model.dart';
import '../viewmodels/ceyiz_view_model.dart';
import '../viewmodels/home_view_model.dart';

final GetIt locator = GetIt.instance;

void setupServiceLocator() {
  // Services
  locator.registerLazySingleton<LocalStorageService>(() => LocalStorageService());

  locator.registerLazySingleton<CeyizService>(() => CeyizService(
        storage: locator<LocalStorageService>(),
      ));

  locator.registerLazySingleton<BohcaService>(() => BohcaService(
        storage: locator<LocalStorageService>(),
      ));

  locator.registerLazySingleton<PhotoService>(() => PhotoService());

  // ViewModels
  locator.registerFactory<HomeViewModel>(() => HomeViewModel(
        ceyizService: locator<CeyizService>(),
        bohcaService: locator<BohcaService>(),
        photoService: locator<PhotoService>(),
      ));

  locator.registerFactory<CeyizViewModel>(() => CeyizViewModel(
        ceyizService: locator<CeyizService>(),
        photoService: locator<PhotoService>(),
      ));

  locator.registerFactory<BohcaViewModel>(() => BohcaViewModel(
        bohcaService: locator<BohcaService>(),
        photoService: locator<PhotoService>(),
      ));
}
