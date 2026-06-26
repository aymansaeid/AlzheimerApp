import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../network/dio_client.dart';

import 'injection.config.dart';

// 1. Ön plan (Main App) için standart GetIt instance'ınız
final GetIt getIt = GetIt.instance;

// 2. Arka plan (Background Isolate) için tamamen izole yepyeni GetIt instance'ı
final GetIt bgGetIt = GetIt.asNewInstance();

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
// Ön plan için başlatıcı (main.dart içinden çağrılacak)
void configureDependencies() {
  getIt.init();
  // Ön planda DioClient'ı eagerly resolve ediyoruz
  getIt<DioClient>();
}

// ARKA PLAN İÇİN BAŞLATICI (location_bg_service.dart içinden çağrılacak)
void configureBackgroundDependencies() {
  // injectabe'ın ürettiği .init() uzantısını bgGetIt üzerinde çalıştırıyoruz
  bgGetIt.init();

  // Arka plandaki izole alanda da DioClient'ın interceptor ve ayarlarının
  // yüklenmesi için eagerly resolve işlemini yapıyoruz
  bgGetIt<DioClient>();
}
