import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'care_network_event.dart';
import 'care_network_state.dart';
import '../../domain/repositories/care_network_repository.dart';

@injectable
class CareNetworkBloc extends Bloc<CareNetworkEvent, CareNetworkState> {
  final CareNetworkRepository repository;

  CareNetworkBloc(this.repository) : super(CareNetworkInitial()) {
    on<FetchNetworkUsers>(_onFetchNetworkUsers);
  }

  Future<void> _onFetchNetworkUsers(
    FetchNetworkUsers event,
    Emitter<CareNetworkState> emit,
  ) async {
    emit(CareNetworkLoading());

    final result = await repository.getNetworkUsers();

    result.fold(
      (failure) => emit(CareNetworkError(failure.message)),
      (users) {
        final patients = users.where((u) => u.role == 'patient').toList();
        final caregivers = users.where((u) => u.role == 'caregiver').toList();
        
        emit(CareNetworkLoaded(
          patients: patients,
          caregivers: caregivers,
        ));
      },
    );
  }
}
