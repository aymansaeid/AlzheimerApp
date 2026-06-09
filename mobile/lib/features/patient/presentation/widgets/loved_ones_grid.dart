import 'package:flutter/material.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/loved_one.dart';

class LovedOnesGrid extends StatelessWidget {
  final List<LovedOne> lovedOnes;
  final BoxConstraints constraints;
  final ValueChanged<String> onMemoryPersonTapped;

  const LovedOnesGrid({
    super.key,
    required this.lovedOnes,
    required this.constraints,
    required this.onMemoryPersonTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: lovedOnes.length,
      itemBuilder: (context, i) {
        final p = lovedOnes[i];
        return AppCard(
          padding: EdgeInsets.zero,
          onTap: () => onMemoryPersonTapped(p.fullName),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: _getColor(i),
                  child: Center(
                    child: Text(
                      _getEmoji(p.relationshipType),
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        p.fullName,
                        style: theme.textTheme.labelLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(p.relationshipType, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getEmoji(String relationshipType) {
    final rel = relationshipType.toLowerCase();
    if (rel.contains('eş') || rel.contains('wife') || rel.contains('spouse')) {
      return '👩';
    } else if (rel.contains('oğul') || rel.contains('son')) {
      return '👦';
    } else if (rel.contains('kız') || rel.contains('daughter')) {
      return '👧';
    } else if (rel.contains('kardeş') || rel.contains('brother') || rel.contains('sister')) {
      return '👨';
    } else if (rel.contains('torun') || rel.contains('grand')) {
      return '👶';
    } else if (rel.contains('bakıcı') || rel.contains('caregiver') || rel.contains('nurse') || rel.contains('hemşire')) {
      return '🧑‍⚕️';
    } else if (rel.contains('doktor') || rel.contains('doctor')) {
      return '👨‍⚕️';
    }
    return '👤';
  }

  Color _getColor(int index) {
    final colors = [
      const Color(0xFFE1F5EE),
      const Color(0xFFE6F1FB),
      const Color(0xFFFAECE7),
      const Color(0xFFFAEEDA),
    ];
    return colors[index % colors.length];
  }
}
