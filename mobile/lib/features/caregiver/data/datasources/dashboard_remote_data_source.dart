import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/features/medication/domain/entities/medication.dart';
import '../../../care_network/domain/entities/network_user.dart';
import '../models/dashboard_summary_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardSummaryModel> getPatientDashboardSummary(String patientId);
  Future<List<NetworkUser>> getFollowedPatients();
}

@LazySingleton(as: DashboardRemoteDataSource)
class MockDashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  MockDashboardRemoteDataSourceImpl(this.dio, this.secureStorage);

  @override
  Future<DashboardSummaryModel> getPatientDashboardSummary(
    String patientId,
  ) async {
    // -------------------------------------------------------------
    // GERÇEK API BAĞLANTISI İÇİN ÖRNEK KOD (YORUM SATIRINDA)
    // -------------------------------------------------------------
    // try {
    //   final response = await dio.get('/api/dashboard/$patientId');
    //   return DashboardSummaryModel.fromJson(response.data);
    // } on DioException catch (e) {
    //   throw ServerException();
    // }
    // -------------------------------------------------------------

    return DashboardSummaryModel(
      patientId: patientId,
      isPatientSafe: true,
      todayMedications: [],
    );
  }

  @override
  Future<List<NetworkUser>> getFollowedPatients() async {
    // -------------------------------------------------------------
    // GERÇEK API BAĞLANTISI İÇİN ÖRNEK KOD (YORUM SATIRINDA)
    // -------------------------------------------------------------
    // try {
    //   final response = await dio.get('/api/caregiver/patients');
    //   return (response.data as List).map((p) => NetworkUserModel.fromJson(p)).toList();
    // } on DioException catch (e) {
    //   throw ServerException();
    // }
    // -------------------------------------------------------------

    // Backend'i simüle etmek için 1 saniye bekle
    await Future.delayed(const Duration(seconds: 1));

    // Check if the caregiver has accepted an invite using local secure storage key
    final hasInvite = await secureStorage.read(key: 'has_accepted_invite');
    if (hasInvite != 'true') {
      return const []; // Return empty so caregiver setup onboarding triggers
    }

    // Takipçinin takip ettiği hastalar listesi (Test amaçlı burası boşaltılabilir)
    return const [
      NetworkUser(
        id: '019e64f5-4474-7170-b7eb-08e7ec670197',
        fullName: 'Hasta 1',
        role: 'patient',
        avatarUrl: 'https://api.dicebear.com/7.x/adventurer/svg?seed=Ahmet',
        email: 'hasta1@gmail.com',
        phoneNumber: '+905551234567',
      ),
    ];
  }
}
