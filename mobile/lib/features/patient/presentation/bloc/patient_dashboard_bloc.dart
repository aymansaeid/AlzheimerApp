import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/features/medication/domain/usecases/mark_medicine_as_taken_usecase.dart';
import '../../domain/usecases/get_patient_dashboard_usecase.dart';
import 'patient_dashboard_event.dart';
import 'patient_dashboard_state.dart';
export 'patient_dashboard_event.dart';
export 'patient_dashboard_state.dart';

@injectable
class PatientDashboardBloc extends Bloc<PatientDashboardEvent, PatientDashboardState> {
  final GetPatientDashboardUseCase getPatientDashboardUseCase;
  final MarkMedicineAsTakenUseCase markMedicineAsTakenUseCase;

  PatientDashboardBloc(
    this.getPatientDashboardUseCase,
    this.markMedicineAsTakenUseCase,
  ) : super(const PatientDashboardInitial()) {
    on<LoadPatientDashboardEvent>(_onLoadPatientDashboard);
    on<DashboardMedicineTakenEvent>(_onDashboardMedicineTaken);
  }

  Future<void> _onLoadPatientDashboard(
    LoadPatientDashboardEvent event,
    Emitter<PatientDashboardState> emit,
  ) async {
    emit(const PatientDashboardLoading());
    final result = await getPatientDashboardUseCase();
    result.fold(
      (failure) => emit(PatientDashboardError(failure.message)),
      (dashboardData) => emit(PatientDashboardLoaded(dashboardData)),
    );
  }

  Future<void> _onDashboardMedicineTaken(
    DashboardMedicineTakenEvent event,
    Emitter<PatientDashboardState> emit,
  ) async {
    final result = await markMedicineAsTakenUseCase(event.logId, event.status);
    await result.fold(
      (failure) async => emit(PatientDashboardError(failure.message)),
      (_) async {
        final dashboardResult = await getPatientDashboardUseCase();
        dashboardResult.fold(
          (failure) => emit(PatientDashboardError(failure.message)),
          (dashboardData) => emit(PatientDashboardLoaded(dashboardData)),
        );
      },
    );
  }
}
