import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/medicine.dart';
import '../bloc/medicine_bloc.dart';
import '../bloc/medicine_event.dart';
import '../bloc/medicine_state.dart';
import '../widgets/days_selector.dart';
import '../widgets/date_picker_group.dart';
import '../widgets/times_selector.dart';

class MedicineFormScreen extends StatefulWidget {
  final String? medicationId;
  final String? patientId;

  const MedicineFormScreen({
    super.key,
    this.medicationId,
    this.patientId,
  });

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

    if (widget.medicationId != null && widget.medicationId!.isNotEmpty) {
      context.read<MedicineBloc>().add(
        LoadMedicineDetailsEvent(medicineId: widget.medicationId!),
      );
    }
  }

  void _populateFromMedicine(Medicine medicine) {
    _existingMedication = medicine;
    _nameController.text = medicine.name;
    _dosageController.text = medicine.dosage;
    _instructionsController.text = medicine.instructions ?? '';
    _selectedDays = List<int>.from(medicine.daysOfWeek);
    _startDate = medicine.startDate;
    _endDate = medicine.endDate;

    final parsedTimes = <TimeOfDay>[];
    for (final rawTime in medicine.scheduleTimes) {
      final parts = rawTime.trim().split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null &&
            minute != null &&
            hour >= 0 &&
            hour <= 23 &&
            minute >= 0 &&
            minute <= 59) {
          parsedTimes.add(TimeOfDay(hour: hour, minute: minute));
        }
      }
    }
    _selectedTimes = parsedTimes.isNotEmpty
        ? parsedTimes
        : [const TimeOfDay(hour: 8, minute: 0)];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  String _toApiTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen en az bir gün seçin')),
        );
        return;
      }

      if (_selectedTimes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen en az bir saat ekleyin')),
        );
        return;
      }

      if (_selectedTimes.length > 12) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Günde en fazla 12 saat eklenebilir')),
        );
        return;
      }

      if (_endDate != null) {
        final startOnly = DateTime(
          _startDate.year,
          _startDate.month,
          _startDate.day,
        );
        final endOnly = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
        );
        if (endOnly.isBefore(startOnly)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bitiş tarihi başlangıç tarihinden önce olamaz'),
            ),
          );
          return;
        }
      }

      final formattedTimes = _selectedTimes.map(_toApiTime).toSet().toList()
        ..sort();
      final trimmedName = _nameController.text.trim();
      final trimmedDosage = _dosageController.text.trim();
      final rawInstructions = _instructionsController.text.trim();
      final String? trimmedInstructions = rawInstructions.isEmpty
          ? null
          : rawInstructions;

      if (_existingMedication != null) {
        final updated = _existingMedication!.copyWith(
          name: trimmedName,
          dosage: trimmedDosage,
          instructions: trimmedInstructions,
          clearInstructions: trimmedInstructions == null,
          scheduleTimes: formattedTimes,
          daysOfWeek: _selectedDays,
          startDate: _startDate,
          endDate: _endDate,
          clearEndDate: _endDate == null,
        );
        context.read<MedicineBloc>().add(UpdateMedicineEvent(updated));
      } else {
        final newMed = Medicine(
          id: '',
          patientId: widget.patientId ?? '',
          name: trimmedName,
          dosage: trimmedDosage,
          instructions: trimmedInstructions,
          scheduleTimes: formattedTimes,
          daysOfWeek: _selectedDays,
          startDate: _startDate,
          endDate: _endDate,
          isActive: true,
        );
        context.read<MedicineBloc>().add(AddMedicineEvent(newMed));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.medicationId != null;

    return BlocConsumer<MedicineBloc, MedicineState>(
      listener: (context, state) {
        if (state is MedicineDetailsLoaded) {
          setState(() {
            _populateFromMedicine(state.medicine);
          });
        } else if (state is MedicineError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is MedicineOperationSuccess) {
          if (context.mounted && context.canPop()) {
            context.pop(true);
          }
        }
      },
      builder: (context, state) {
        final isLoadingDetails =
            isEditing &&
            _existingMedication == null &&
            state is MedicineLoading;
        final isSaving = state is MedicineLoading && !isLoadingDetails;

        return Scaffold(
          appBar: AppBar(
            title: Text(isEditing ? 'İlacı Düzenle' : 'Yeni İlaç Ekle'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SafeArea(
            child: isLoadingDetails
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
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
                              onPressed: isSaving ? null : _saveForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 2,
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
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
      },
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
