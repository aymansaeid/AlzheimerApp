import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../network/dio_client.dart';

import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() {
  getIt.init();
  // Eagerly resolve DioClient to trigger options and interceptors setup on the singleton Dio instance
  getIt<DioClient>();
}
