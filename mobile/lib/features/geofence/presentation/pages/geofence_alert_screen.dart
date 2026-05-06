import 'package:flutter/material.dart';
import '../../../../core/widgets/app_card.dart';

class GeofenceAlertScreen extends StatefulWidget {
  final String patientName;
  final String locationAddress;
  final double distanceMeters;
  final String timeOutside;
  final VoidCallback onCallPatient;
  final VoidCallback onOpenLiveMap;
  final VoidCallback onDismissAlert;

  const GeofenceAlertScreen({
    super.key,
    required this.patientName,
    required this.locationAddress,
    required this.distanceMeters,
    required this.timeOutside,
    required this.onCallPatient,
    required this.onOpenLiveMap,
    required this.onDismissAlert,
  });

  @override
  State<GeofenceAlertScreen> createState() => _GeofenceAlertScreenState();
}

class _GeofenceAlertScreenState extends State<GeofenceAlertScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _entranceCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _pulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.12,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _slideAnim = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic),
    );
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.errorContainer,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _entranceCtrl,
          builder: (_, child) => Opacity(
            opacity: _fadeAnim.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnim.value),
              child: child,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  _buildTopBar(theme),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildAlertHero(theme),
                          const SizedBox(height: 24),
                          _buildLocationCard(theme),
                          const SizedBox(height: 16),
                          _buildAlertMapMock(theme),
                          const SizedBox(height: 32),
                          _buildActionButtons(theme),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: theme.colorScheme.error,
            ),
          ),
          Expanded(
            child: Text(
              'Güvenli Alan Uyarısı',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Balance icon button
        ],
      ),
    );
  }

  Widget _buildAlertHero(ThemeData theme) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (_, child) =>
              Transform.scale(scale: _pulseAnim.value, child: child),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.error, width: 3),
            ),
            child: const Center(
              child: Text('📍', style: TextStyle(fontSize: 36)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Uyarı!',
          style: theme.textTheme.displayMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.patientName} güvenli alan dışına çıktı',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLocationCard(ThemeData theme) {
    return AppCard(
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 8),
              Text(
                'KONUM BİLGİSİ',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.location_on_rounded, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.locationAddress,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.social_distance_rounded,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Güvenli alandan ${widget.distanceMeters.toInt()}m uzakta',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time_rounded, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.timeOutside,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertMapMock(ThemeData theme) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(
          Icons.map_outlined,
          size: 48,
          color: theme.colorScheme.error.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.onCallPatient,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            icon: const Icon(Icons.phone_rounded),
            label: const Text('Hemen Ara'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: widget.onOpenLiveMap,
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
            icon: const Icon(Icons.map_rounded),
            label: const Text('Canlı Haritada Takip Et'),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: widget.onDismissAlert,
          child: Text(
            'Uyarıyı Kapat',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
