import 'package:flutter/material.dart';

class TimesSelector extends StatelessWidget {
  final List<TimeOfDay> selectedTimes;
  final ValueChanged<List<TimeOfDay>> onChanged;
  final bool isEditing;

  const TimesSelector({
    super.key,
    required this.selectedTimes,
    required this.onChanged,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...selectedTimes.asMap().entries.map((entry) {
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
                        final newList = List<TimeOfDay>.from(selectedTimes);
                        newList[index] = picked;
                        onChanged(newList);
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
                if (!isEditing && selectedTimes.length > 1) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      final newList = List<TimeOfDay>.from(selectedTimes);
                      newList.removeAt(index);
                      onChanged(newList);
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
              final newList = List<TimeOfDay>.from(selectedTimes);
              newList.add(const TimeOfDay(hour: 8, minute: 0));
              onChanged(newList);
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
}
