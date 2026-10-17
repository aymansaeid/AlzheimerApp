import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';

abstract class FcmRemoteDataSource {
  Future<String?> getDeviceToken();
  Stream<String> get onTokenRefresh;
}

@LazySingleton(as: FcmRemoteDataSource)
class FcmRemoteDataSourceImpl implements FcmRemoteDataSource {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  Future<String?> getDeviceToken() async {
    // İzin verilmemişse isteyebilir veya doğrudan token dönebilirsiniz
    return await _messaging.getToken();
  }

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;
}
