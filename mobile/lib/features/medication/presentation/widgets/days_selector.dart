import 'package:flutter/material.dart';

class DaysSelector extends StatelessWidget {
  final List<int> selectedDays;
  final ValueChanged<List<int>> onChanged;

  const DaysSelector({
    super.key,
    required this.selectedDays,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return Wrap(
      spacing: 8,
      children: List.generate(7, (index) {
        final dayValue = index + 1;
        final isSelected = selectedDays.contains(dayValue);
        return FilterChip(
          label: Text(days[index]),
          selected: isSelected,
          onSelected: (selected) {
            final newList = List<int>.from(selectedDays);
            if (selected) {
              newList.add(dayValue);
            } else {
              newList.remove(dayValue);
            }
            onChanged(newList);
          },
          selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          checkmarkColor: Theme.of(context).colorScheme.primary,
        );
      }),
    );
  }
}
