import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/medicine.dart';
import '../bloc/medicine_bloc.dart';
import '../bloc/medicine_event.dart';
import '../bloc/medicine_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

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
                _buildDaysSelector(),
                const SizedBox(height: 24),

                // Date Picker
                _buildDateSelector(),
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
                _buildTimesSelector(isEditing),
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

  Widget _buildDaysSelector() {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return Wrap(
      spacing: 8,
      children: List.generate(7, (index) {
        final dayValue = index + 1;
        final isSelected = _selectedDays.contains(dayValue);
        return FilterChip(
          label: Text(days[index]),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedDays.add(dayValue);
              } else {
                _selectedDays.remove(dayValue);
              }
            });
          },
          selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          checkmarkColor: Theme.of(context).colorScheme.primary,
        );
      }),
    );
  }

  Widget _buildDateSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildDatePicker(
            label: 'Başlangıç',
            date: _startDate,
            onChanged: (date) {
              if (date != null) {
                setState(() => _startDate = date);
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDatePicker(
            label: 'Bitiş (Opsiyonel)',
            date: _endDate,
            onChanged: (date) {
              setState(() => _endDate = date);
            },
            isOptional: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime?> onChanged,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (isOptional && date != null)
              GestureDetector(
                onTap: () => onChanged(null),
                child: const Icon(Icons.close, size: 16, color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}'
                      : 'Seçiniz',
                  style: TextStyle(
                    fontSize: 16,
                    color: date != null ? Colors.black87 : Colors.grey.shade600,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimesSelector(bool isEditing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._selectedTimes.asMap().entries.map((entry) {
          final index = entry.key;
          final time = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: time,
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedTimes[index] = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            time.format(context),
                            style: const TextStyle(fontSize: 18),
                          ),
                          Icon(
                            Icons.access_time,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!isEditing && _selectedTimes.length > 1) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedTimes.removeAt(index);
                      });
                    },
                  ),
                ],
              ],
            ),
          );
        }),
        if (!isEditing)
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedTimes.add(const TimeOfDay(hour: 8, minute: 0));
              });
            },
            icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
            label: Text(
              'Saat Ekle',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
      ],
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
