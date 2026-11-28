import 'package:flutter/material.dart';

import '../../../../core/utils/safe_zone_calculator.dart';

class SafeZoneSetupOverlay extends StatefulWidget {
  static const double circleDiameter = 240.0;
  static const double circleRadius = circleDiameter / 2.0;
  static const List<String> _quickNames = [
    'Ev',
    'Park',
    'Yakın Evi',
    'Hastane',
  ];

  final String patientName;
  final String? initialName;
  final double currentRadiusInMeters;
  final bool hasExistingSafeZone;
  final ValueChanged<String> onSave;
  final VoidCallback onCancel;
  final VoidCallback onRemove;

  const SafeZoneSetupOverlay({
    super.key,
    required this.patientName,
    this.initialName,
    required this.currentRadiusInMeters,
    required this.hasExistingSafeZone,
    required this.onSave,
    required this.onCancel,
    required this.onRemove,
  });

  @override
  State<SafeZoneSetupOverlay> createState() => _SafeZoneSetupOverlayState();
}

class _SafeZoneSetupOverlayState extends State<SafeZoneSetupOverlay> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void didUpdateWidget(covariant SafeZoneSetupOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialName != oldWidget.initialName &&
        widget.initialName != null &&
        widget.initialName != _nameController.text) {
      _nameController.text = widget.initialName!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _openNameSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                20 + MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    widget.hasExistingSafeZone
                        ? 'Bölgeyi Güncelle'
                        : 'Güvenli Bölgeyi Adlandır',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.patientName} • Yarıçap: ${SafeZoneCalculator.formatRadius(widget.currentRadiusInMeters)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _nameController,
                    autofocus: !widget.hasExistingSafeZone,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => setSheetState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Bölge adı (örn. Ev, Park)',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      prefixIcon: const Icon(
                        Icons.label_outline,
                        size: 18,
                        color: Colors.deepPurple,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: SafeZoneSetupOverlay._quickNames.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final suggestion =
                            SafeZoneSetupOverlay._quickNames[index];
                        final isSelected =
                            _nameController.text.trim() == suggestion;
                        return InkWell(
                          onTap: () {
                            _nameController.text = suggestion;
                            _nameController.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: suggestion.length),
                            );
                            setSheetState(() {});
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.deepPurple
                                  : Colors.deepPurple.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              suggestion,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.deepPurple,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: const Text('Geri'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            final trimmed = _nameController.text.trim();
                            Navigator.of(sheetContext).pop();
                            widget.onSave(
                              trimmed.isEmpty ? 'Güvenli Bölge' : trimmed,
                            );
                          },
                          child: Text(
                            widget.hasExistingSafeZone ? 'Güncelle' : 'Kaydet',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Üstte ince canlı yarıçap ve yönlendirme hapı
        Positioned(
          top: 12,
          left: 16,
          right: 16,
          child: IgnorePointer(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.radar,
                      size: 16,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      SafeZoneCalculator.formatRadius(
                        widget.currentRadiusInMeters,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '• Haritayı kaydırıp yakınlaştırın',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 2. Ekranın tam merkezindeki sabit çember (Harita etkileşimini engellemez)
        Center(
          child: IgnorePointer(
            child: Container(
              width: SafeZoneSetupOverlay.circleDiameter,
              height: SafeZoneSetupOverlay.circleDiameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.withValues(alpha: 0.18),
                border: Border.all(color: Colors.deepPurple, width: 2.5),
              ),
              child: const Center(
                child: Icon(
                  Icons.add,
                  color: Colors.deepPurple,
                  size: 28,
                ),
              ),
            ),
          ),
        ),

        // 3. Altta sade tek satırlı aksiyon çubuğu
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  if (widget.hasExistingSafeZone) ...[
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(
                          color: Colors.red.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onPressed: widget.onRemove,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Sil'),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('İptal'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _openNameSheet(context),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Onayla'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
