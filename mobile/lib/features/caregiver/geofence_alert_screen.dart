import 'package:flutter/material.dart';
import '/core/app_theme.dart';
import '/core/shared_widgets.dart';

class GeofenceAlertScreen extends StatefulWidget {
  final String patientName;
  final String locationAddress;
  final double distanceMeters;
  final String timeOutside;

  const GeofenceAlertScreen({
    super.key,
    this.patientName = 'Ahmet Bey',
    this.locationAddress = 'Kadıköy, Moda Caddesi',
    this.distanceMeters = 340,
    this.timeOutside = '09:38\'den beri',
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
    return Scaffold(
      backgroundColor: AppColors.coral50,
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
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      _buildAlertHero(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildLocationCard(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildAlertMapMock(),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildActionButtons(),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.coral50,
        border: Border(bottom: BorderSide(color: AppColors.coral100)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.coral600,
            ),
          ),
          const Expanded(
            child: Text(
              'Güvenli Alan Uyarısı',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.coral600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert_rounded,
              size: 20,
              color: AppColors.coral600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertHero() {
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
              color: AppColors.coral50,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.coral400, width: 3),
            ),
            child: const Center(
              child: Text('📍', style: TextStyle(fontSize: 36)),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'Uyarı!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.coral600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${widget.patientName} güvenli alan dışına çıktı',
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.coral400,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return AppCard(
      color: AppColors.coral50,
      borderColor: AppColors.coral100,
      child: Column(
        children: [
          Row(
            children: const [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: AppColors.coral600,
              ),
              SizedBox(width: 6),
              Text(
                'KONUM BİLGİSİ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.coral600,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _LocationRow(
            icon: Icons.location_on_rounded,
            iconColor: AppColors.coral400,
            label: widget.locationAddress,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _LocationRow(
            icon: Icons.social_distance_rounded,
            iconColor: AppColors.coral400,
            label: 'Güvenli alandan ${widget.distanceMeters.toInt()}m uzakta',
            labelStyle: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _LocationRow(
            icon: Icons.access_time_rounded,
            iconColor: AppColors.coral400,
            label: widget.timeOutside,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.coral400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertMapMock() {
    return SizedBox(
      height: 140,
      child: AppCard(
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: AppRadius.lg,
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFfcd5c0),
                      Color(0xFFf0b89a),
                      Color(0xFFfde8d8),
                    ],
                  ),
                ),
              ),
              CustomPaint(size: Size.infinite, painter: _AlertMapPainter()),
              // Geofence zone
              Positioned(
                top: 20,
                left: 40,
                child: Container(
                  width: 70,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.coral600,
                      width: 1.5,
                      strokeAlign: BorderSide.strokeAlignCenter,
                    ),
                    color: AppColors.coral400.withOpacity(0.08),
                  ),
                ),
              ),
              // Patient pin (outside zone)
              Positioned(
                top: 24,
                left: 140,
                child: AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, child) => Transform.scale(
                    scale: 0.9 + (_pulseCtrl.value * 0.1),
                    child: child,
                  ),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.coral400,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(13),
                        topRight: Radius.circular(13),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(13),
                      ),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Center(
                      child: Text('👴', style: TextStyle(fontSize: 10)),
                    ),
                  ),
                ),
              ),
              // Distance line
              Positioned(
                top: 35,
                left: 78,
                child: Container(
                  width: 62,
                  height: 1.5,
                  color: AppColors.coral600.withOpacity(0.6),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: AppRadius.sm,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, size: 6, color: AppColors.coral400),
                      SizedBox(width: 5),
                      Text(
                        'Canlı takip',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.coral600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _callPatient,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coral400,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
            ),
            icon: const Icon(Icons.phone_rounded, size: 20),
            label: const Text(
              'Hemen Ara',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _openLiveMap,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.coral400,
              side: const BorderSide(color: AppColors.coral100, width: 1.5),
              backgroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
            ),
            icon: const Icon(Icons.map_rounded, size: 20),
            label: const Text(
              'Canlı Haritada Takip Et',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: _dismissAlert,
          child: const Text(
            'Uyarıyı Kapat',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Actions ─────────────────────────────────────────────────────────────
  void _callPatient() {
    // launch('tel:+905XXXXXXXXX')
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.patientName} aranıyor...'),
        backgroundColor: AppColors.coral400,
      ),
    );
  }

  void _openLiveMap() {
    // Navigate to live map screen
  }

  void _dismissAlert() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: AppRadius.full,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'Uyarıyı kapatmak istediğinden emin misin?',
              style: AppTextStyles.headingSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Hasta hâlâ güvenli alan dışında olabilir.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Vazgeç'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.coral400,
                    ),
                    child: const Text('Kapat'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

// ─── Supporting Widgets ───────────────────────────────────────────────────────
class _LocationRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final TextStyle labelStyle;

  const _LocationRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: labelStyle)),
      ],
    );
  }
}

// ─── Alert Map Painter ────────────────────────────────────────────────────────
class _AlertMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height * 0.6),
      Offset(size.width, size.height * 0.48),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.25, 0),
      Offset(size.width * 0.3, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
