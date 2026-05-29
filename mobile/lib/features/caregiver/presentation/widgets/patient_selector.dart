import 'package:flutter/material.dart';
import '../../../care_network/domain/entities/network_user.dart';

class PatientSelector extends StatelessWidget {
  final List<NetworkUser> patients;
  final String selectedPatientId;
  final ValueChanged<String> onPatientSelected;

  const PatientSelector({
    super.key,
    required this.patients,
    required this.selectedPatientId,
    required this.onPatientSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 76,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          final isSelected = patient.id == selectedPatientId;

          // HASTA SEÇİLDİĞİNDE YEŞİL YAPMA KURALI
          final cardColor = isSelected
              ? Colors.green.shade600
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                );
          final textColor = isSelected
              ? Colors.white
              : theme.colorScheme.onSurface;
          final borderSide = isSelected
              ? BorderSide.none
              : BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                );

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Material(
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: borderSide,
              ),
              child: InkWell(
                onTap: () => onPatientSelected(patient.id),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.2)
                              : theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            patient.id == '1' || patient.id == 'patient_1'
                                ? '👴'
                                : '👵',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            patient.fullName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Hasta',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
