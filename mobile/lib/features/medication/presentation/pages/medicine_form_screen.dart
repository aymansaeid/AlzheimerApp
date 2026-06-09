import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/medicine.dart';
import '../bloc/medicine_bloc.dart';
import '../bloc/medicine_event.dart';
import '../bloc/medicine_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/days_selector.dart';
import '../widgets/date_picker_group.dart';
import '../widgets/times_selector.dart';

class MedicineFormScreen extends StatefulWidget {
  final String? medicationId;
  final String? patientId;

  const MedicineFormScreen({super.key, this.medicationId, this.patientId});

  @override
  State<MedicineFormScreen> createState() => _MedicineFormScreenState();
}

class _MedicineFormScreenState extends State<MedicineFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _instructionsController;

  List<TimeOfDay> _selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];
  List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  Medicine? _existingMedication;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _dosageController = TextEditingController();
    _instructionsController = TextEditingController();

    if (widget.medicationId != null) {
      final state = context.read<MedicineBloc>().state;
      if (state is MedicineLoaded) {
        try {
          final existingLog = state.medicines.firstWhere(
            (m) => m.medicineId == widget.medicationId || m.id == widget.medicationId,
          );
          _nameController.text = existingLog.medicineName;
          _dosageController.text = existingLog.dosage;
          _instructionsController.text = ''; // Instructions are not in JIT log
          _selectedDays = [1, 2, 3, 4, 5, 6, 7];
          _startDate = DateTime.now();

          // Format time from scheduledAt
          final hour = existingLog.scheduledAt.hour.toString().padLeft(2, '0');
          final minute = existingLog.scheduledAt.minute.toString().padLeft(2, '0');
          final timeStr = '$hour:$minute';
          
          _selectedTimes = [
            TimeOfDay(hour: existingLog.scheduledAt.hour, minute: existingLog.scheduledAt.minute),
          ];

          _existingMedication = Medicine(
            id: existingLog.medicineId.isNotEmpty ? existingLog.medicineId : existingLog.id,
            patientId: widget.patientId ?? '',
            creatorId: '',
            name: existingLog.medicineName,
            dosage: existingLog.dosage,
            instructions: '',
            scheduleTime: timeStr,
            daysOfWeek: const [1, 2, 3, 4, 5, 6, 7],
            startDate: DateTime.now(),
            isActive: true,
            isTaken: existingLog.status == 1,
          );
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen en az bir gün seçin')),
        );
        return;
      }

      if (_existingMedication != null) {
        // Update
        final time = _selectedTimes.first;
        final formattedTime =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

        final updated = _existingMedication!.copyWith(
          name: _nameController.text,
          dosage: _dosageController.text,
          instructions: _instructionsController.text,
          scheduleTime: formattedTime,
          daysOfWeek: _selectedDays,
          startDate: _startDate,
          endDate: _endDate,
        );
        context.read<MedicineBloc>().add(UpdateMedicineEvent(updated));
      } else {
        // Resolve patientId and createdBy dynamically
        String creatorId = '';
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          creatorId = authState.user.id;
        }

        // Add multiple medications if multiple times selected
        for (var time in _selectedTimes) {
          final formattedTime =
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

          final newMed = Medicine(
            id: '',
            patientId: widget.patientId!,
            creatorId: creatorId,
            name: _nameController.text,
            dosage: _dosageController.text,
            instructions: _instructionsController.text,
            scheduleTime: formattedTime,
            daysOfWeek: _selectedDays,
            startDate: _startDate,
            endDate: _endDate,
            isActive: true,
            isTaken: false,
          );
          context.read<MedicineBloc>().add(AddMedicineEvent(newMed));
        }
      }

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.medicationId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'İlacı Düzenle' : 'Yeni İlaç Ekle'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'İlaç Adı',
                  icon: Icons.medication,
                  validator: (value) => value == null || value.isEmpty
                      ? 'İlaç adı boş olamaz'
                      : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _dosageController,
                  label: 'Dozaj (Örn: 10 mg, 1 Hap)',
                  icon: Icons.science,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Dozaj boş olamaz'
                      : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _instructionsController,
                  label: 'Talimatlar (Örn: Tok karnına)',
                  icon: Icons.info,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Days Picker
                const Text(
                  'Hangi Günler?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                DaysSelector(
                  selectedDays: _selectedDays,
                  onChanged: (days) {
                    setState(() {
                      _selectedDays = days;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Date Picker
                DatePickerGroup(
                  startDate: _startDate,
                  endDate: _endDate,
                  onStartDateChanged: (date) {
                    setState(() {
                      _startDate = date;
                    });
                  },
                  onEndDateChanged: (date) {
                    setState(() {
                      _endDate = date;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Time Picker
                const Text(
                  'İlaç Saati',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TimesSelector(
                  selectedTimes: _selectedTimes,
                  isEditing: isEditing,
                  onChanged: (times) {
                    setState(() {
                      _selectedTimes = times;
                    });
                  },
                ),
                const SizedBox(height: 40),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _saveForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      isEditing ? 'Güncelle' : 'Kaydet',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
