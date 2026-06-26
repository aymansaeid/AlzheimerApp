import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/features/location_tracking/domain/usecases/log_location_usecase.dart';

// background service için ayrı bir GetIt örneği oluşturuyoruz
final bgGetIt = GetIt.asNewInstance();

class LocationBgService {
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart, // Aşağıdaki giriş noktasını bağlıyoruz
        autoStart: true,
        isForegroundMode: true, // Android için zorunlu bildirim
        notificationChannelId: 'location_channel',
        initialNotificationTitle: 'Hasta Takibi Aktif',
        initialNotificationContent:
            'Konumunuz güvenliğiniz için arka planda takip ediliyor.',
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }
}

// İŞLETİM SİSTEMİN RETİKLEYECEĞİ GİRİŞ NOKTASI (ENTRY POINT)
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Arka plan izole alanı için .env dosyasını tekrar yüklüyoruz
  // (DioClient içindeki dotenv.env['BASE_URL'] hata vermemesi için)
  await dotenv.load(fileName: ".env");

  // 2. Injectable kullanarak arka plan için bgGetIt havuzunu otomatik kuruyoruz
  // Bu fonksiyon içeride DioClient'ı da eagerly resolve edecektir.
  configureBackgroundDependencies();

  // 3. UseCase'i artık enjeksiyon dosyanızda tanımladığımız bgGetIt havuzundan çekiyoruz
  final logLocationUseCase = bgGetIt<LogLocationUseCase>();

  // Konum akışını dinlemeye başlıyoruz
  Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 20, // 20 metrede bir backend'e gönderir
    ),
  ).listen((Position position) async {
    // NOT: Gerçek projede bu ID'yi yerel hafızadan (SharedPreferences/Hive) çekmelisiniz
    const String currentPatientId = "3fa85f64-5717-4562-b3fc-2c963f66afa6";

    // UseCase tetikleniyor
    final result = await logLocationUseCase(
      LogLocationParams(
        patientId: currentPatientId,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      ),
    );

    result.fold(
      (failure) =>
          debugPrint("Arka plan konum gönderim hatası: ${failure.message}"),
      (success) => debugPrint("Konum başarıyla .NET API'ye post edildi."),
    );
  });
}

// iOS için arka plan uyku modu tetikleyicisi
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}
