// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i48;
import '../../features/auth/domain/usecases/register_usecase.dart' as _i941;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/care_network/data/datasources/care_network_remote_data_source.dart'
    as _i485;
import '../../features/care_network/data/repositories/care_network_repository_impl.dart'
    as _i517;
import '../../features/care_network/domain/repositories/care_network_repository.dart'
    as _i83;
import '../../features/care_network/presentation/bloc/care_network_bloc.dart'
    as _i100;
import '../../features/caregiver/data/datasources/dashboard_remote_data_source.dart'
    as _i368;
import '../../features/caregiver/data/repositories/dashboard_repository_impl.dart'
    as _i598;
import '../../features/caregiver/domain/repositories/dashboard_repository.dart'
    as _i445;
import '../../features/caregiver/domain/usecases/get_dashboard_summary.dart'
    as _i1051;
import '../../features/caregiver/domain/usecases/get_followed_patients.dart'
    as _i1031;
import '../../features/caregiver/presentation/bloc/dashboard_bloc.dart'
    as _i844;
import '../../features/medication/data/datasources/medication_remote_data_source.dart'
    as _i484;
import '../../features/medication/data/datasources/medicine_log_remote_data_source.dart'
    as _i640;
import '../../features/medication/data/repositories/medication_repository_impl.dart'
    as _i598;
import '../../features/medication/data/repositories/medicine_log_repository_impl.dart'
    as _i370;
import '../../features/medication/domain/repositories/medication_repository.dart'
    as _i1036;
import '../../features/medication/domain/repositories/medicine_log_repository.dart'
    as _i1048;
import '../../features/medication/domain/usecases/add_medication.dart' as _i107;
import '../../features/medication/domain/usecases/delete_medication.dart'
    as _i329;
import '../../features/medication/domain/usecases/get_daily_logs_usecase.dart'
    as _i787;
import '../../features/medication/domain/usecases/get_medications_by_date.dart'
    as _i429;
import '../../features/medication/domain/usecases/mark_medication_as_taken.dart'
    as _i929;
import '../../features/medication/domain/usecases/update_medication.dart'
    as _i397;
import '../../features/medication/presentation/bloc/medication_bloc.dart'
    as _i501;
import '../../features/onboarding/data/datasources/follower_remote_data_source.dart'
    as _i237;
import '../../features/onboarding/data/repositories/follower_repository_impl.dart'
    as _i813;
import '../../features/onboarding/domain/repositories/follower_repository.dart'
    as _i1019;
import '../../features/onboarding/domain/usecases/accept_invite_usecase.dart'
    as _i702;
import '../../features/onboarding/domain/usecases/check_has_admin_usecase.dart'
    as _i411;
import '../../features/onboarding/domain/usecases/generate_invite_usecase.dart'
    as _i470;
import '../../features/onboarding/presentation/bloc/caregiver_setup/caregiver_setup_bloc.dart'
    as _i454;
import '../../features/onboarding/presentation/bloc/patient_setup/patient_setup_bloc.dart'
    as _i1068;
import '../network/dio_client.dart' as _i667;
import '../network/interceptors/auth_interceptor.dart' as _i745;
import '../network/interceptors/logging_interceptor.dart' as _i344;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.factory<_i344.LoggingInterceptor>(() => _i344.LoggingInterceptor());
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.lazySingleton<_i368.DashboardRemoteDataSource>(
      () => _i368.DashboardRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i485.CareNetworkRemoteDataSource>(
      () => _i485.CareNetworkRemoteDataSourceImpl(),
    );
    gh.lazySingleton<_i237.FollowerRemoteDataSource>(
      () => _i237.FollowerRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i484.MedicationRemoteDataSource>(
      () => _i484.MedicationRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i107.AuthRemoteDataSource>(
      () => _i107.AuthRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i640.MedicineLogRemoteDataSource>(
      () => _i640.MedicineLogRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.factory<_i745.AuthInterceptor>(
      () => _i745.AuthInterceptor(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i107.AuthRemoteDataSource>(),
        gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.lazySingleton<_i445.DashboardRepository>(
      () =>
          _i598.DashboardRepositoryImpl(gh<_i368.DashboardRemoteDataSource>()),
    );
    gh.lazySingleton<_i1051.GetDashboardSummary>(
      () => _i1051.GetDashboardSummary(gh<_i445.DashboardRepository>()),
    );
    gh.lazySingleton<_i1031.GetFollowedPatients>(
      () => _i1031.GetFollowedPatients(gh<_i445.DashboardRepository>()),
    );
    gh.lazySingleton<_i83.CareNetworkRepository>(
      () => _i517.CareNetworkRepositoryImpl(
        gh<_i485.CareNetworkRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i1048.MedicineLogRepository>(
      () => _i370.MedicineLogRepositoryImpl(
        gh<_i640.MedicineLogRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i1019.FollowerRepository>(
      () => _i813.FollowerRepositoryImpl(
        gh<_i237.FollowerRemoteDataSource>(),
        gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.factory<_i100.CareNetworkBloc>(
      () => _i100.CareNetworkBloc(gh<_i83.CareNetworkRepository>()),
    );
    gh.factory<_i844.DashboardBloc>(
      () => _i844.DashboardBloc(
        getFollowedPatients: gh<_i1031.GetFollowedPatients>(),
        getDashboardSummary: gh<_i1051.GetDashboardSummary>(),
      ),
    );
    gh.lazySingleton<_i188.LoginUseCase>(
      () => _i188.LoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i48.LogoutUseCase>(
      () => _i48.LogoutUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i941.RegisterUseCase>(
      () => _i941.RegisterUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i1036.MedicationRepository>(
      () => _i598.MedicationRepositoryImpl(
        gh<_i484.MedicationRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i107.AddMedication>(
      () => _i107.AddMedication(gh<_i1036.MedicationRepository>()),
    );
    gh.lazySingleton<_i329.DeleteMedication>(
      () => _i329.DeleteMedication(gh<_i1036.MedicationRepository>()),
    );
    gh.lazySingleton<_i429.GetMedicationsByDate>(
      () => _i429.GetMedicationsByDate(gh<_i1036.MedicationRepository>()),
    );
    gh.lazySingleton<_i929.MarkMedicationAsTaken>(
      () => _i929.MarkMedicationAsTaken(gh<_i1036.MedicationRepository>()),
    );
    gh.lazySingleton<_i397.UpdateMedication>(
      () => _i397.UpdateMedication(gh<_i1036.MedicationRepository>()),
    );
    gh.lazySingleton<_i702.AcceptInviteUseCase>(
      () => _i702.AcceptInviteUseCase(gh<_i1019.FollowerRepository>()),
    );
    gh.lazySingleton<_i411.CheckHasAdminUseCase>(
      () => _i411.CheckHasAdminUseCase(gh<_i1019.FollowerRepository>()),
    );
    gh.lazySingleton<_i470.GenerateInviteUseCase>(
      () => _i470.GenerateInviteUseCase(gh<_i1019.FollowerRepository>()),
    );
    gh.lazySingleton<_i667.DioClient>(
      () => _i667.DioClient(
        gh<_i361.Dio>(),
        gh<_i745.AuthInterceptor>(),
        gh<_i344.LoggingInterceptor>(),
      ),
    );
    gh.factory<_i454.CaregiverSetupBloc>(
      () => _i454.CaregiverSetupBloc(
        gh<_i702.AcceptInviteUseCase>(),
        gh<_i1031.GetFollowedPatients>(),
      ),
    );
    gh.lazySingleton<_i787.GetDailyLogsUseCase>(
      () => _i787.GetDailyLogsUseCase(gh<_i1048.MedicineLogRepository>()),
    );
    gh.lazySingleton<_i797.AuthBloc>(
      () => _i797.AuthBloc(
        gh<_i188.LoginUseCase>(),
        gh<_i941.RegisterUseCase>(),
        gh<_i48.LogoutUseCase>(),
        gh<_i787.AuthRepository>(),
        gh<_i1031.GetFollowedPatients>(),
        gh<_i411.CheckHasAdminUseCase>(),
      ),
    );
    gh.factory<_i501.MedicationBloc>(
      () => _i501.MedicationBloc(
        getDailyLogsUseCase: gh<_i787.GetDailyLogsUseCase>(),
        addMedication: gh<_i107.AddMedication>(),
        updateMedication: gh<_i397.UpdateMedication>(),
        deleteMedication: gh<_i329.DeleteMedication>(),
        markMedicationAsTaken: gh<_i929.MarkMedicationAsTaken>(),
      ),
    );
    gh.factory<_i1068.PatientSetupBloc>(
      () => _i1068.PatientSetupBloc(
        gh<_i411.CheckHasAdminUseCase>(),
        gh<_i470.GenerateInviteUseCase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
