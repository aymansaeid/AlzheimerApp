import 'package:flutter/material.dart';
import '/core/app_theme.dart';
import '/core/shared_widgets.dart';

// ─── Data Models ─────────────────────────────────────────────────────────────
class PatientStatus {
  final String name;
  final bool isSafe;
  final String lastSeen;
  final String location;
  final int medicationCompliance; // out of 7
  final int alertsToday;

  const PatientStatus({
    required this.name,
    required this.isSafe,
    required this.lastSeen,
    required this.location,
    required this.medicationCompliance,
    required this.alertsToday,
  });
}

// ─── Screen ──────────────────────────────────────────────────────────────────
class CaregiverDashboardScreen extends StatefulWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  State<CaregiverDashboardScreen> createState() =>
      _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen> {
  int _currentIndex = 0;

  final PatientStatus _patient = const PatientStatus(
    name: 'Ahmet Bey',
    isSafe: true,
    lastSeen: '2 dakika önce',
    location: 'Kadıköy, İstanbul',
    medicationCompliance: 5,
    alertsToday: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.teal400,
                onRefresh: () async =>
                    await Future.delayed(const Duration(seconds: 1)),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      _buildHeader(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildPatientStatusCard(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildStatsRow(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildAlertBanner(),
                      const SizedBox(height: AppSpacing.xl),
                      const SectionTitle(text: 'Hızlı Erişim'),
                      _buildQuickActions(),
                      const SizedBox(height: AppSpacing.xl),
                      const SectionTitle(
                        text: 'Son Aktiviteler',
                        trailing: TextButton(
                          onPressed: null,
                          child: Text(
                            'Tümü',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.teal400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      _buildActivityFeed(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        items: const [
          AppNavItem(icon: Icons.dashboard_rounded, label: 'Panel'),
          AppNavItem(icon: Icons.location_on_rounded, label: 'Konum'),
          AppNavItem(icon: Icons.medication_rounded, label: 'İlaçlar'),
          AppNavItem(icon: Icons.folder_rounded, label: 'İçerik'),
        ],
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Merhaba,', style: AppTextStyles.bodyMedium),
              Text('Fatma Hanım 👋', style: AppTextStyles.headingLarge),
            ],
          ),
        ),
        Stack(
          children: [
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.coral50,
                  borderRadius: AppRadius.md,
                  border: Border.all(color: AppColors.coral100),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.coral400,
                  size: 22,
                ),
              ),
            ),
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: AppColors.coral400,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '2',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPatientStatusCard() {
    return AppCard(
      color: AppColors.teal50,
      borderColor: AppColors.teal100,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.teal200,
                  borderRadius: AppRadius.md,
                ),
                child: const Center(
                  child: Text('👴', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _patient.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.teal800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    StatusBadge.safe(),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.open_in_new_rounded,
                  size: 18,
                  color: AppColors.teal600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildMapMock(),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: AppColors.teal600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _patient.lastSeen,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.teal600,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.teal400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.map_rounded, size: 14),
                label: const Text(
                  'Haritayı Aç',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapMock() {
    return Container(
      width: double.infinity,
      height: 110,
      decoration: BoxDecoration(
        borderRadius: AppRadius.md,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD4E8C0), Color(0xFFB8D4A8), Color(0xFFE8F0D8)],
        ),
      ),
      child: Stack(
        children: [
          // Roads
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(painter: _MapPainter()),
          ),
          // Geofence circle
          Positioned(
            top: 15,
            left: 60,
            child: Container(
              width: 65,
              height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.teal600,
                  width: 1.5,
                  strokeAlign: BorderSide.strokeAlignCenter,
                ),
                color: AppColors.teal400.withOpacity(0.12),
              ),
            ),
          ),
          // Map pin
          Positioned(
            top: 28,
            left: 100,
            child: Transform.rotate(
              angle: -0.8,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.teal400,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(12),
                  ),
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
          // Label
          Positioned(
            bottom: 8,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: AppRadius.sm,
              ),
              child: const Text(
                'Ev — 150m yarıçap',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.teal800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            value: '${_patient.medicationCompliance}/7',
            label: 'İlaç Uyumu',
            backgroundColor: AppColors.gray50,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: StatCard(
            value: _patient.alertsToday.toString(),
            label: 'Bugün Uyarı',
            valueColor: _patient.alertsToday == 0
                ? AppColors.teal400
                : AppColors.coral400,
            backgroundColor: _patient.alertsToday == 0
                ? AppColors.teal50
                : AppColors.coral50,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: StatCard(
            value: '73%',
            label: 'Rutin Uyumu',
            valueColor: AppColors.amber400,
            backgroundColor: AppColors.amber50,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertBanner() {
    return AppCard(
      color: AppColors.amber50,
      borderColor: AppColors.amber100,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Text('⚠', style: TextStyle(fontSize: 18)),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(
            child: Text(
              'Dün akşam ilaç alınmadı',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.amber400,
              ),
            ),
          ),
          const Text('Dün', style: AppTextStyles.caption),
          const SizedBox(width: AppSpacing.xs),
          const Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: AppColors.amber400,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'emoji': '🗓',
        'label': 'İlaç\nTakvimi',
        'color': AppColors.blue50,
        'textColor': AppColors.blue400,
      },
      {
        'emoji': '📊',
        'label': 'Haftalık\nRapor',
        'color': AppColors.teal50,
        'textColor': AppColors.teal400,
      },
      {
        'emoji': '📍',
        'label': 'Güvenli\nAlan',
        'color': AppColors.coral50,
        'textColor': AppColors.coral400,
      },
      {
        'emoji': '💝',
        'label': 'İçerik\nEkle',
        'color': AppColors.amber50,
        'textColor': AppColors.amber400,
      },
    ];

    return Row(
      children: actions.map((a) {
        return Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: EdgeInsets.only(
                right: actions.indexOf(a) < actions.length - 1
                    ? AppSpacing.sm
                    : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: a['color'] as Color,
                borderRadius: AppRadius.md,
              ),
              child: Column(
                children: [
                  Text(
                    a['emoji'] as String,
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    a['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: a['textColor'] as Color,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivityFeed() {
    final activities = [
      {
        'icon': '📍',
        'text': 'Konum güncellendi — Kadıköy',
        'time': '5 dk önce',
        'color': AppColors.teal50,
      },
      {
        'icon': '💊',
        'text': 'Sabah ilacı alındı — Donepezil',
        'time': '2 saat önce',
        'color': AppColors.blue50,
      },
      {
        'icon': '⚠',
        'text': 'Akşam ilacı atlandı — Memantin',
        'time': 'Dün 20:15',
        'color': AppColors.amber50,
      },
    ];

    return Column(
      children: activities.map((a) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: a['color'] as Color,
            borderRadius: AppRadius.md,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Text(a['icon'] as String, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  a['text'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Text(a['time'] as String, style: AppTextStyles.caption),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Map Painter ──────────────────────────────────────────────────────────────
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height * 0.55),
      Offset(size.width, size.height * 0.45),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, 0),
      Offset(size.width * 0.42, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
