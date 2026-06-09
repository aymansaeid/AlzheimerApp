import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/followed_patient.dart';
import '../../domain/usecases/get_dashboard_summary.dart';
import '../../domain/usecases/get_followed_patients.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

export 'dashboard_event.dart';
export 'dashboard_state.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetFollowedPatients getFollowedPatients;
  final GetDashboardSummary getDashboardSummary;

  // Track the target patient ID currently being loaded
  String? _currentlyLoadingPatientId;

  DashboardBloc({
    required this.getFollowedPatients,
    required this.getDashboardSummary,
  }) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<SelectPatient>(_onSelectPatient);
    on<ResetDashboard>(_onResetDashboard);
  }

  void _onResetDashboard(ResetDashboard event, Emitter<DashboardState> emit) {
    emit(DashboardInitial());
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
          emit(DashboardEmptyPatients());
          return;
        }

        // 3. Select the patient ID dynamically: use selected patient or default to the first one in the list
        final String targetPatientId =
            localPatientId ?? patients.first.patientId;

        // Update class level loader ID to reflect targetPatientId if it was resolved from default first index
        _currentlyLoadingPatientId = targetPatientId;

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

    // Toggling selected patient reloads dashboard data
    add(LoadDashboard(event.patientId));
  }
}
