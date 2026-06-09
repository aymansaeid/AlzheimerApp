import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/medicine_log.dart';

class MedicineStatusInfoCard extends StatelessWidget {
  final MedicineLog medication;
  final bool isFuture;

  const MedicineStatusInfoCard({
    super.key,
    required this.medication,
    required this.isFuture,
  });

  @override
  Widget build(BuildContext context) {
    // Role check to customize status text
    final authState = getIt<AuthBloc>().state;
    final isPatient = authState is AuthAuthenticated && authState.user.role == 'patient';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              const Text(
                'Durum Bilgisi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            medication.status == 0
                ? (isFuture
                    ? (isPatient
                        ? 'İlaç saati henüz gelmemiştir. İlaç saati geldiğinde bu butonu kullanabilirsiniz.'
                        : 'İlaç saati henüz gelmemiştir.')
                    : (isPatient
                        ? 'İlaç henüz alınmadı. Alındı olarak işaretlemek için aşağıdaki butonu kullanabilirsiniz.'
                        : 'İlaç henüz alınmadı.'))
                : medication.status == 1
                ? 'İlaç alındı. Alınma zamanı: ${medication.takenAt != null ? DateFormat('HH:mm').format(medication.takenAt!.toLocal()) : '-'}'
                : 'İlaç saati geçirildi (Kaçırıldı).',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
