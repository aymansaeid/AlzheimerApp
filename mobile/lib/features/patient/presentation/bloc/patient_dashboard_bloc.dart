import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_patient_dashboard_usecase.dart';
import 'patient_dashboard_event.dart';
import 'patient_dashboard_state.dart';

export 'patient_dashboard_event.dart';
export 'patient_dashboard_state.dart';

@injectable
class PatientDashboardBloc extends Bloc<PatientDashboardEvent, PatientDashboardState> {
  final GetPatientDashboardUseCase getPatientDashboardUseCase;

  PatientDashboardBloc(this.getPatientDashboardUseCase) : super(const PatientDashboardInitial()) {
    on<LoadPatientDashboardEvent>(_onLoadPatientDashboard);
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
}
