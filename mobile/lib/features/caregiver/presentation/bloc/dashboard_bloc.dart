import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/followed_patient.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/get_dashboard_summary.dart';
import '../../domain/usecases/get_followed_patients.dart';
import '../../../care_network/domain/repositories/care_network_repository.dart';
import '../../../medication/domain/repositories/medicine_repository.dart';
import '../../../notifications/service/notification_service.dart';
import '../../../onboarding/domain/repositories/follower_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

export 'dashboard_event.dart';
export 'dashboard_state.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetFollowedPatients getFollowedPatients;
  final GetDashboardSummary getDashboardSummary;
  final DashboardRepository dashboardRepository;
  final CareNetworkRepository careNetworkRepository;
  final FollowerRepository followerRepository;
  final MedicineRepository medicineRepository;
  final NotificationService notificationService;

  // Track the target patient ID currently being loaded
  String? _currentlyLoadingPatientId;
  StreamSubscription? _networkSubscription;
  StreamSubscription? _adminTransferredSubscription;
  StreamSubscription? _inviteSubscription;
  StreamSubscription? _medicineSubscription;
  StreamSubscription? _careTeamNotificationSubscription;

  DashboardBloc({
    required this.getFollowedPatients,
    required this.getDashboardSummary,
    required this.dashboardRepository,
    required this.careNetworkRepository,
    required this.followerRepository,
    required this.medicineRepository,
    required this.notificationService,
  }) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<SelectPatient>(_onSelectPatient);
    on<ResetDashboard>(_onResetDashboard);
    on<RefreshFollowedPatients>(_onRefreshFollowedPatients);
    on<UpdateLocalPatientAdminStatus>(_onUpdateLocalPatientAdminStatus);

    _networkSubscription = careNetworkRepository.onNetworkChanged.listen((_) {
      add(const LoadDashboard(null));
    });

    _adminTransferredSubscription =
        careNetworkRepository.onAdminTransferred.listen((patientId) {
      add(
        UpdateLocalPatientAdminStatus(
          patientId: patientId,
          isPrimaryAdmin: false,
        ),
      );
    });

    _inviteSubscription = followerRepository.onInviteAccepted.listen((_) {
      add(const RefreshFollowedPatients());
    });

    _medicineSubscription = medicineRepository.onMedicinesChanged.listen((_) {
      final activeId = state is DashboardLoaded
          ? (state as DashboardLoaded).summary.patientId
          : _currentlyLoadingPatientId;
      add(LoadDashboard(activeId));
    });

    _careTeamNotificationSubscription =
        notificationService.onCareTeamUpdated.listen((_) {
      add(const RefreshFollowedPatients());
    });
  }

  @override
  Future<void> close() {
    _networkSubscription?.cancel();
    _adminTransferredSubscription?.cancel();
    _inviteSubscription?.cancel();
    _medicineSubscription?.cancel();
    _careTeamNotificationSubscription?.cancel();
    return super.close();
  }

  void _onResetDashboard(ResetDashboard event, Emitter<DashboardState> emit) {
    _currentlyLoadingPatientId = null;
    emit(DashboardInitial());
  }

  Future<void> _onRefreshFollowedPatients(
    RefreshFollowedPatients event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is! DashboardLoaded) {
      add(const LoadDashboard(null));
      return;
    }

    final currentState = state as DashboardLoaded;
    final patientsResult = await getFollowedPatients();

    patientsResult.fold(
      (_) {
        // Keep current state if background my-patients refresh fails.
      },
      (patients) {
        if (patients.isEmpty) {
          unawaited(dashboardRepository.clearLastSelectedPatientId());
          emit(DashboardEmptyPatients());
          return;
        }

        final activePatientId = currentState.summary.patientId;
        final currentPatient = patients.cast<FollowedPatient?>().firstWhere(
          (p) => p?.patientId == activePatientId,
          orElse: () => null,
        );

        // If the active patient was removed (e.g., CARE_TEAM_REMOVED), switch to the first available.
        if (currentPatient == null) {
          add(LoadDashboard(patients.first.patientId));
          return;
        }

        emit(
          DashboardLoaded(
            summary: currentState.summary,
            patients: patients,
            isCurrentPatientAdmin: currentPatient.isPrimaryAdmin,
          ),
        );
      },
    );
  }

  void _onUpdateLocalPatientAdminStatus(
    UpdateLocalPatientAdminStatus event,
    Emitter<DashboardState> emit,
  ) {
    if (state is! DashboardLoaded) return;

    final currentState = state as DashboardLoaded;
    final updatedPatients = currentState.patients.map((patient) {
      if (patient.patientId == event.patientId) {
        return patient.copyWith(isPrimaryAdmin: event.isPrimaryAdmin);
      }
      return patient;
    }).toList();

    final isCurrentAdmin = currentState.summary.patientId == event.patientId
        ? event.isPrimaryAdmin
        : currentState.isCurrentPatientAdmin;

    emit(
      DashboardLoaded(
        summary: currentState.summary,
        patients: updatedPatients,
        isCurrentPatientAdmin: isCurrentAdmin,
      ),
    );
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    // Keep a local copy of the target ID that triggered this handler
    final String? localPatientId = event.patientId;
    _currentlyLoadingPatientId = localPatientId;

    // Dynamically extract already loaded patients list from the current state
    List<FollowedPatient>? existingPatients;
    if (state is DashboardLoaded) {
      existingPatients = (state as DashboardLoaded).patients;
    } else if (state is DashboardLoading) {
      existingPatients = (state as DashboardLoading).patients;
    } else if (state is DashboardError) {
      existingPatients = (state as DashboardError).patients;
    }

    emit(
      DashboardLoading(
        patients: existingPatients,
        loadingPatientId: localPatientId,
      ),
    );

    // 1. Fetch followed patients list dynamically
    final patientsResult = await getFollowedPatients();

    // RACE CONDITION CHECK: If local ID doesn't match the active ID anymore, exit immediately!
    if (localPatientId != _currentlyLoadingPatientId) return;

    await patientsResult.fold(
      (failure) async {
        emit(DashboardError(failure.message, patients: existingPatients));
      },
      (patients) async {
        // 2. If caregiver has no followed patients, yield fallback state
        if (patients.isEmpty) {
          unawaited(dashboardRepository.clearLastSelectedPatientId());
          emit(DashboardEmptyPatients());
          return;
        }

        // 3. Determine preferred patient ID (explicit event param or stored last selection)
        final String? preferredPatientId =
            (localPatientId != null && localPatientId.isNotEmpty)
            ? localPatientId
            : await dashboardRepository.getLastSelectedPatientId();

        // RACE CONDITION CHECK after awaiting storage
        if (localPatientId != _currentlyLoadingPatientId) return;

        // Validate against fetched followed patients list; fallback to the first patient
        final bool isStillFollowed =
            preferredPatientId != null &&
            patients.any((p) => p.patientId == preferredPatientId);
        final String targetPatientId =
            isStillFollowed ? preferredPatientId : patients.first.patientId;

        // Update class level loader ID to reflect targetPatientId and persist choice
        _currentlyLoadingPatientId = targetPatientId;
        unawaited(dashboardRepository.saveLastSelectedPatientId(targetPatientId));

        // 4. Fetch the selected patient's dashboard summary details
        final summaryResult = await getDashboardSummary(targetPatientId);

        // RACE CONDITION CHECK: If target ID doesn't match the active ID anymore, exit immediately!
        if (targetPatientId != _currentlyLoadingPatientId) return;

        summaryResult.fold(
          (failure) =>
              emit(DashboardError(failure.message, patients: patients)),
          (summary) {
            final currentPatient = patients.cast<FollowedPatient?>().firstWhere(
              (p) => p?.patientId == targetPatientId,
              orElse: () => null,
            );

            final isAdmin = currentPatient?.isPrimaryAdmin ?? false;

            // Hesaplanan değer, temiz bir şekilde paketlenip State'e verilir.
            emit(
              DashboardLoaded(
                summary: summary,
                patients: patients,
                isCurrentPatientAdmin: isAdmin,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onSelectPatient(
    SelectPatient event,
    Emitter<DashboardState> emit,
  ) async {
    // If we are already loading or loaded this patient, ignore the click!
    if (_currentlyLoadingPatientId == event.patientId) return;

    _currentlyLoadingPatientId = event.patientId;
    unawaited(dashboardRepository.saveLastSelectedPatientId(event.patientId));

    // Extract already loaded patients list from the current state
    List<FollowedPatient>? existingPatients;
    if (state is DashboardLoaded) {
      existingPatients = (state as DashboardLoaded).patients;
    } else if (state is DashboardLoading) {
      existingPatients = (state as DashboardLoading).patients;
    } else if (state is DashboardError) {
      existingPatients = (state as DashboardError).patients;
    }

    // If patients list is null or empty, fallback to LoadDashboard
    if (existingPatients == null || existingPatients.isEmpty) {
      add(LoadDashboard(event.patientId));
      return;
    }

    emit(
      DashboardLoading(
        patients: existingPatients,
        loadingPatientId: event.patientId,
      ),
    );

    // Fetch the selected patient's dashboard summary details directly
    final summaryResult = await getDashboardSummary(event.patientId);

    // RACE CONDITION CHECK: If target ID doesn't match the active ID anymore, exit immediately!
    if (event.patientId != _currentlyLoadingPatientId) return;

    summaryResult.fold(
      (failure) =>
          emit(DashboardError(failure.message, patients: existingPatients)),
      (summary) {
        final patients = existingPatients!;
        final currentPatient = patients.cast<FollowedPatient?>().firstWhere(
          (p) => p?.patientId == event.patientId,
          orElse: () => null,
        );

        final isAdmin = currentPatient?.isPrimaryAdmin ?? false;

        emit(
          DashboardLoaded(
            summary: summary,
            patients: patients,
            isCurrentPatientAdmin: isAdmin,
          ),
        );
      },
    );
  }
}
