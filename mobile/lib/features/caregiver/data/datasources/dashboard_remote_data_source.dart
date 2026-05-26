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

    // Backend'i simüle etmek için 2 saniye bekle
    await Future.delayed(const Duration(seconds: 2));

    // ID '1' veya 'patient_1' ise safe (güvenli), '2' veya 'patient_2' ise unsafe (güvenli değil)
    final bool isSafe = patientId == '1' || patientId == 'patient_1';

    // Mock medications returned per patient
    final List<Medication> mockMeds = isSafe
        ? [
            Medication(
              id: 'med_1',
              patientId: patientId,
              createdBy: 'caregiver_1',
              name: 'Donepezil',
              dosage: '10 mg',
              instructions: 'Tok karnına, akşam yatmadan önce.',
              scheduleTime: '22:00',
              daysOfWeek: const [1, 2, 3, 4, 5, 6, 7],
              startDate: DateTime.now(),
              isActive: true,
              isTaken: true,
            ),
            Medication(
              id: 'med_2',
              patientId: patientId,
              createdBy: 'caregiver_1',
              name: 'Memantin',
              dosage: '20 mg',
              instructions: 'Sabah tok karnına yarım bardak su ile.',
              scheduleTime: '09:00',
              daysOfWeek: const [1, 2, 3, 4, 5, 6, 7],
              startDate: DateTime.now(),
              isActive: true,
              isTaken: false,
            ),
            Medication(
              id: 'med_3',
              patientId: patientId,
              createdBy: 'caregiver_1',
              name: 'B12 Vitamini',
              dosage: '1000 mcg',
              instructions: 'Öğle yemeğinden sonra dil altı.',
              scheduleTime: '13:00',
              daysOfWeek: const [1, 2, 3, 4, 5, 6, 7],
              startDate: DateTime.now(),
              isActive: true,
              isTaken: true,
            ),
          ]
        : [
            Medication(
              id: 'med_4',
              patientId: patientId,
              createdBy: 'caregiver_1',
              name: 'Aspirin',
              dosage: '100 mg',
              instructions: 'Öğle yemeğiyle birlikte.',
              scheduleTime: '12:30',
              daysOfWeek: const [1, 2, 3, 4, 5, 6, 7],
              startDate: DateTime.now(),
              isActive: true,
              isTaken: false,
            ),
            Medication(
              id: 'med_5',
              patientId: patientId,
              createdBy: 'caregiver_1',
              name: 'Coraspin',
              dosage: '300 mg',
              instructions: 'Akşam yemeğinden hemen sonra.',
              scheduleTime: '19:00',
              daysOfWeek: const [1, 2, 3, 4, 5, 6, 7],
              startDate: DateTime.now(),
              isActive: true,
              isTaken: true,
            ),
          ];

    return DashboardSummaryModel(
      patientId: patientId,
      isPatientSafe: isSafe,
      todayMedications: mockMeds,
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
