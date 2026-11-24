// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:dio/dio.dart' as _i361;
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:image_cropper/image_cropper.dart' as _i184;
import 'package:image_picker/image_picker.dart' as _i183;
import 'package:injectable/injectable.dart' as _i526;
import 'package:just_audio/just_audio.dart' as _i501;

import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i48;
import '../../features/auth/domain/usecases/register_usecase.dart' as _i941;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/auth/presentation/cubit/register_cubit.dart' as _i759;
import '../../features/care_network/data/datasources/care_network_remote_data_source.dart'
    as _i485;
import '../../features/care_network/data/repositories/care_network_repository_impl.dart'
    as _i517;
import '../../features/care_network/domain/repositories/care_network_repository.dart'
    as _i83;
import '../../features/care_network/domain/usecases/generate_invite_usecase.dart'
    as _i417;
import '../../features/care_network/domain/usecases/get_care_team_usecase.dart'
    as _i240;
import '../../features/care_network/domain/usecases/leave_team_usecase.dart'
    as _i1027;
import '../../features/care_network/domain/usecases/remove_team_member_usecase.dart'
    as _i477;
import '../../features/care_network/domain/usecases/transfer_admin_usecase.dart'
    as _i754;
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
import '../../features/location_tracking/data/datasources/location_remote_datasource.dart'
    as _i60;
import '../../features/location_tracking/data/repositories/location_repository.dart'
    as _i856;
import '../../features/location_tracking/domain/repositories/location_repository.dart'
    as _i326;
import '../../features/location_tracking/domain/usecases/log_location_usecase.dart'
    as _i902;
import '../../features/medication/data/datasources/medicine_log_remote_data_source.dart'
    as _i640;
import '../../features/medication/data/datasources/medicine_remote_data_source.dart'
    as _i964;
import '../../features/medication/data/repositories/medicine_log_repository_impl.dart'
    as _i370;
import '../../features/medication/data/repositories/medicine_repository_impl.dart'
    as _i600;
import '../../features/medication/domain/repositories/medicine_log_repository.dart'
    as _i1048;
import '../../features/medication/domain/repositories/medicine_repository.dart'
    as _i185;
import '../../features/medication/domain/usecases/add_medicine_usecase.dart'
    as _i670;
import '../../features/medication/domain/usecases/delete_medicine_usecase.dart'
    as _i886;
import '../../features/medication/domain/usecases/get_daily_logs_usecase.dart'
    as _i788;
import '../../features/medication/domain/usecases/mark_medicine_as_taken_usecase.dart'
    as _i669;
import '../../features/medication/domain/usecases/update_medicine_usecase.dart'
    as _i310;
import '../../features/medication/presentation/bloc/medicine_bloc.dart'
    as _i1015;
import '../../features/memory_content/features/create_audio_post/presentation/cubit/record_audio_cubit.dart'
    as _i784;
import '../../features/memory_content/features/create_text_post/presentation/cubit/create_post_cubit.dart'
    as _i410;
import '../../features/memory_content/features/feed/data/datasources/feed_local_data_source.dart'
    as _i171;
import '../../features/memory_content/features/feed/data/datasources/memory_remote_data_source.dart'
    as _i399;
import '../../features/memory_content/features/feed/data/repositories/feed_repository_impl.dart'
    as _i177;
import '../../features/memory_content/features/feed/data/repositories/firebase_storage_repository_impl.dart'
    as _i331;
import '../../features/memory_content/features/feed/data/repositories/memory_repository_impl.dart'
    as _i405;
import '../../features/memory_content/features/feed/domain/repositories/feed_repository.dart'
    as _i315;
import '../../features/memory_content/features/feed/domain/repositories/file_storage_repository.dart'
    as _i314;
import '../../features/memory_content/features/feed/domain/repositories/memory_repository.dart'
    as _i472;
import '../../features/memory_content/features/feed/domain/usecases/add_post_usecase.dart'
    as _i400;
import '../../features/memory_content/features/feed/domain/usecases/create_memory_usecase.dart'
    as _i506;
import '../../features/memory_content/features/feed/domain/usecases/delete_memory_usecase.dart'
    as _i308;
import '../../features/memory_content/features/feed/domain/usecases/get_feed_usecase.dart'
    as _i320;
import '../../features/memory_content/features/feed/domain/usecases/get_patient_memories_usecase.dart'
    as _i748;
import '../../features/memory_content/features/feed/domain/usecases/update_memory_usecase.dart'
    as _i418;
import '../../features/memory_content/features/feed/presentation/bloc/feed_bloc.dart'
    as _i86;
import '../../features/memory_content/features/feed/presentation/bloc/memory_bloc.dart'
    as _i426;
import '../../features/notifications/data/datasources/notification_local_data_source.dart'
    as _i481;
import '../../features/notifications/data/datasources/notification_remote_data_source.dart'
    as _i757;
import '../../features/notifications/data/repositories/notification_repository_impl.dart'
    as _i362;
import '../../features/notifications/domain/repository/notification_repository.dart'
    as _i1068;
import '../../features/notifications/presentation/bloc/notification_permission_cubit.dart'
    as _i1030;
import '../../features/notifications/service/notification_service.dart'
    as _i105;
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
    as _i1069;
import '../../features/patient/data/datasources/patient_remote_data_source.dart'
    as _i1012;
import '../../features/patient/data/repositories/patient_repository_impl.dart'
    as _i814;
import '../../features/patient/domain/repositories/patient_repository.dart'
    as _i233;
import '../../features/patient/domain/usecases/get_patient_dashboard_usecase.dart'
    as _i647;
import '../../features/patient/presentation/bloc/patient_dashboard_bloc.dart'
    as _i490;
import '../../features/profile/data/datasources/profile_remote_data_source.dart'
    as _i847;
import '../../features/profile/data/repositories/profile_repository_impl.dart'
    as _i334;
import '../../features/profile/domain/repositories/profile_repository.dart'
    as _i894;
import '../../features/profile/domain/usecases/add_profile_picture_usecase.dart'
    as _i55;
import '../../features/profile/domain/usecases/remove_profile_picture_usecase.dart'
    as _i514;
import '../../features/profile/domain/usecases/update_profile_usecase.dart'
    as _i478;
import '../../features/profile/presentation/bloc/profile_bloc.dart' as _i469;
import '../network/dio_client.dart' as _i667;
import '../network/interceptors/auth_interceptor.dart' as _i745;
import '../network/interceptors/logging_interceptor.dart' as _i344;
import '../services/audio_record_service.dart' as _i492;
import '../services/feed_audio_coordinator.dart' as _i750;
import '../services/media_service.dart' as _i586;
import '../services/permission_service.dart' as _i165;
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
    gh.lazySingleton<_i457.FirebaseStorage>(
      () => registerModule.firebaseStorage,
    );
    gh.lazySingleton<_i501.AudioPlayer>(() => registerModule.audioPlayer);
    gh.lazySingleton<_i183.ImagePicker>(() => registerModule.imagePicker);
    gh.lazySingleton<_i184.ImageCropper>(() => registerModule.imageCropper);
    gh.lazySingleton<_i750.FeedAudioCoordinator>(
      () => _i750.FeedAudioCoordinator(),
    );
    gh.lazySingleton<_i847.ProfileRemoteDataSource>(
      () => _i847.ProfileRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i757.NotificationRemoteDataSource>(
      () => _i757.NotificationRemoteDataSourceImpl(),
    );
    gh.lazySingleton<_i368.DashboardRemoteDataSource>(
      () => _i368.DashboardRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i481.NotificationLocalDataSource>(
      () => _i481.NotificationLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i237.FollowerRemoteDataSource>(
      () => _i237.FollowerRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i60.LocationRemoteDataSource>(
      () => _i60.LocationRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i171.FeedLocalDataSource>(
      () => _i171.FeedLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i964.MedicineRemoteDataSource>(
      () => _i964.MedicineRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i492.AudioRecordService>(
      () => _i492.AudioRecordServiceImpl(),
    );
    gh.lazySingleton<_i485.CareNetworkRemoteDataSource>(
      () => _i485.CareNetworkRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i107.AuthRemoteDataSource>(
      () => _i107.AuthRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i1012.PatientRemoteDataSource>(
      () => _i1012.PatientRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i399.MemoryRemoteDataSource>(
      () => _i399.MemoryRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i640.MedicineLogRemoteDataSource>(
      () => _i640.MedicineLogRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i165.PermissionService>(
      () => _i165.PermissionServiceImpl(),
    );
    gh.lazySingleton<_i315.FeedRepository>(
      () => _i177.FeedRepositoryImpl(gh<_i171.FeedLocalDataSource>()),
    );
    gh.lazySingleton<_i472.MemoryRepository>(
      () => _i405.MemoryRepositoryImpl(gh<_i399.MemoryRemoteDataSource>()),
    );
    gh.lazySingleton<_i308.DeleteMemoryUseCase>(
      () => _i308.DeleteMemoryUseCase(gh<_i472.MemoryRepository>()),
    );
    gh.lazySingleton<_i748.GetPatientMemoriesUseCase>(
      () => _i748.GetPatientMemoriesUseCase(gh<_i472.MemoryRepository>()),
    );
    gh.lazySingleton<_i418.UpdateMemoryUseCase>(
      () => _i418.UpdateMemoryUseCase(gh<_i472.MemoryRepository>()),
    );
    gh.lazySingleton<_i1068.NotificationRepository>(
      () => _i362.NotificationRepositoryImpl(
        gh<_i757.NotificationRemoteDataSource>(),
        gh<_i481.NotificationLocalDataSource>(),
      ),
    );
    gh.factory<_i745.AuthInterceptor>(
      () => _i745.AuthInterceptor(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i326.LocationRepository>(
      () => _i856.LocationRepositoryImpl(
        remoteDataSource: gh<_i60.LocationRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i445.DashboardRepository>(
      () =>
          _i598.DashboardRepositoryImpl(gh<_i368.DashboardRemoteDataSource>()),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i107.AuthRemoteDataSource>(),
        gh<_i558.FlutterSecureStorage>(),
        gh<_i757.NotificationRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i314.FileStorageRepository>(
      () => _i331.FirebaseStorageRepositoryImpl(gh<_i457.FirebaseStorage>()),
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
    gh.lazySingleton<_i902.LogLocationUseCase>(
      () => _i902.LogLocationUseCase(gh<_i326.LocationRepository>()),
    );
    gh.lazySingleton<_i320.GetFeedUseCase>(
      () => _i320.GetFeedUseCase(gh<_i315.FeedRepository>()),
    );
    gh.lazySingleton<_i1048.MedicineLogRepository>(
      () => _i370.MedicineLogRepositoryImpl(
        gh<_i640.MedicineLogRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i586.MediaService>(
      () => _i586.MediaServiceImpl(
        gh<_i183.ImagePicker>(),
        gh<_i184.ImageCropper>(),
      ),
    );
    gh.lazySingleton<_i506.CreateMemoryUseCase>(
      () => _i506.CreateMemoryUseCase(
        gh<_i314.FileStorageRepository>(),
        gh<_i472.MemoryRepository>(),
      ),
    );
    gh.lazySingleton<_i400.AddPostUseCase>(
      () => _i400.AddPostUseCase(gh<_i315.FeedRepository>()),
    );
    gh.lazySingleton<_i185.MedicineRepository>(
      () => _i600.MedicineRepositoryImpl(
        gh<_i964.MedicineRemoteDataSource>(),
        gh<_i1068.NotificationRepository>(),
      ),
    );
    gh.lazySingleton<_i1019.FollowerRepository>(
      () => _i813.FollowerRepositoryImpl(
        gh<_i237.FollowerRemoteDataSource>(),
        gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.lazySingleton<_i417.GenerateInviteUseCase>(
      () => _i417.GenerateInviteUseCase(gh<_i83.CareNetworkRepository>()),
    );
    gh.lazySingleton<_i240.GetCareTeamUseCase>(
      () => _i240.GetCareTeamUseCase(gh<_i83.CareNetworkRepository>()),
    );
    gh.lazySingleton<_i1027.LeaveTeamUseCase>(
      () => _i1027.LeaveTeamUseCase(gh<_i83.CareNetworkRepository>()),
    );
    gh.lazySingleton<_i477.RemoveTeamMemberUseCase>(
      () => _i477.RemoveTeamMemberUseCase(gh<_i83.CareNetworkRepository>()),
    );
    gh.lazySingleton<_i754.TransferAdminUseCase>(
      () => _i754.TransferAdminUseCase(gh<_i83.CareNetworkRepository>()),
    );
    gh.factory<_i410.CreatePostCubit>(
      () => _i410.CreatePostCubit(
        gh<_i165.PermissionService>(),
        gh<_i586.MediaService>(),
        gh<_i400.AddPostUseCase>(),
      ),
    );
    gh.lazySingleton<_i105.NotificationService>(
      () => _i105.NotificationService(
        gh<_i1068.NotificationRepository>(),
        gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.lazySingleton<_i894.ProfileRepository>(
      () => _i334.ProfileRepositoryImpl(
        gh<_i847.ProfileRemoteDataSource>(),
        gh<_i314.FileStorageRepository>(),
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
    gh.factory<_i1030.NotificationPermissionCubit>(
      () => _i1030.NotificationPermissionCubit(
        gh<_i1068.NotificationRepository>(),
      ),
    );
    gh.lazySingleton<_i233.PatientRepository>(
      () => _i814.PatientRepositoryImpl(gh<_i1012.PatientRemoteDataSource>()),
    );
    gh.factory<_i426.MemoryBloc>(
      () => _i426.MemoryBloc(
        gh<_i748.GetPatientMemoriesUseCase>(),
        gh<_i308.DeleteMemoryUseCase>(),
        gh<_i506.CreateMemoryUseCase>(),
      ),
    );
    gh.lazySingleton<_i647.GetPatientDashboardUseCase>(
      () => _i647.GetPatientDashboardUseCase(gh<_i233.PatientRepository>()),
    );
    gh.factory<_i844.DashboardBloc>(
      () => _i844.DashboardBloc(
        getFollowedPatients: gh<_i1031.GetFollowedPatients>(),
        getDashboardSummary: gh<_i1051.GetDashboardSummary>(),
        careNetworkRepository: gh<_i83.CareNetworkRepository>(),
        followerRepository: gh<_i1019.FollowerRepository>(),
      ),
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
    gh.lazySingleton<_i788.GetDailyLogsUseCase>(
      () => _i788.GetDailyLogsUseCase(gh<_i1048.MedicineLogRepository>()),
    );
    gh.lazySingleton<_i669.MarkMedicineAsTakenUseCase>(
      () =>
          _i669.MarkMedicineAsTakenUseCase(gh<_i1048.MedicineLogRepository>()),
    );
    gh.factory<_i86.FeedBloc>(
      () =>
          _i86.FeedBloc(gh<_i320.GetFeedUseCase>(), gh<_i400.AddPostUseCase>()),
    );
    gh.lazySingleton<_i55.AddProfilePictureUseCase>(
      () => _i55.AddProfilePictureUseCase(gh<_i894.ProfileRepository>()),
    );
    gh.lazySingleton<_i514.RemoveProfilePictureUseCase>(
      () => _i514.RemoveProfilePictureUseCase(gh<_i894.ProfileRepository>()),
    );
    gh.lazySingleton<_i478.UpdateProfileUseCase>(
      () => _i478.UpdateProfileUseCase(gh<_i894.ProfileRepository>()),
    );
    gh.factory<_i759.RegisterCubit>(
      () => _i759.RegisterCubit(
        gh<_i586.MediaService>(),
        gh<_i165.PermissionService>(),
        gh<_i314.FileStorageRepository>(),
      ),
    );
    gh.factory<_i784.RecordAudioCubit>(
      () => _i784.RecordAudioCubit(
        gh<_i492.AudioRecordService>(),
        gh<_i165.PermissionService>(),
        gh<_i400.AddPostUseCase>(),
      ),
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
    gh.lazySingleton<_i670.AddMedicineUseCase>(
      () => _i670.AddMedicineUseCase(gh<_i185.MedicineRepository>()),
    );
    gh.lazySingleton<_i886.DeleteMedicineUseCase>(
      () => _i886.DeleteMedicineUseCase(gh<_i185.MedicineRepository>()),
    );
    gh.lazySingleton<_i310.UpdateMedicineUseCase>(
      () => _i310.UpdateMedicineUseCase(gh<_i185.MedicineRepository>()),
    );
    gh.factory<_i490.PatientDashboardBloc>(
      () => _i490.PatientDashboardBloc(
        gh<_i647.GetPatientDashboardUseCase>(),
        gh<_i669.MarkMedicineAsTakenUseCase>(),
      ),
    );
    gh.factory<_i1069.PatientSetupBloc>(
      () => _i1069.PatientSetupBloc(
        gh<_i411.CheckHasAdminUseCase>(),
        gh<_i470.GenerateInviteUseCase>(),
      ),
    );
    gh.factory<_i1015.MedicineBloc>(
      () => _i1015.MedicineBloc(
        getDailyLogsUseCase: gh<_i788.GetDailyLogsUseCase>(),
        addMedicine: gh<_i670.AddMedicineUseCase>(),
        updateMedicine: gh<_i310.UpdateMedicineUseCase>(),
        deleteMedicine: gh<_i886.DeleteMedicineUseCase>(),
        markMedicineAsTaken: gh<_i669.MarkMedicineAsTakenUseCase>(),
        medicineRepository: gh<_i185.MedicineRepository>(),
        medicineLogRepository: gh<_i1048.MedicineLogRepository>(),
      ),
    );
    gh.factory<_i100.CareNetworkBloc>(
      () => _i100.CareNetworkBloc(
        getCareTeamUseCase: gh<_i240.GetCareTeamUseCase>(),
        generateInviteUseCase: gh<_i417.GenerateInviteUseCase>(),
        removeTeamMemberUseCase: gh<_i477.RemoveTeamMemberUseCase>(),
        leaveTeamUseCase: gh<_i1027.LeaveTeamUseCase>(),
        acceptInviteUseCase: gh<_i702.AcceptInviteUseCase>(),
        transferAdminUseCase: gh<_i754.TransferAdminUseCase>(),
      ),
    );
    gh.factory<_i469.ProfileBloc>(
      () => _i469.ProfileBloc(
        gh<_i55.AddProfilePictureUseCase>(),
        gh<_i514.RemoveProfilePictureUseCase>(),
        gh<_i478.UpdateProfileUseCase>(),
        gh<_i586.MediaService>(),
        gh<_i165.PermissionService>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
