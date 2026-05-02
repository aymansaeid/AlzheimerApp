import 'package:flutter/material.dart';
import '/core/app_theme.dart';
import '/core/shared_widgets.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;

  final List<AppNavItem> _navItems = const [
    AppNavItem(icon: Icons.home_rounded, label: 'Ana Sayfa'),
    AppNavItem(icon: Icons.medication_rounded, label: 'İlaçlar'),
    AppNavItem(icon: Icons.photo_album_rounded, label: 'Anılar'),
    AppNavItem(icon: Icons.call_rounded, label: 'Ara'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    _buildHeader(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildSOSButton(),
                    const SizedBox(height: AppSpacing.xl),
                    const SectionTitle(text: 'Bugünkü İlaçlar'),
                    _buildMedicationCard(
                      name: 'Donepezil 10mg',
                      time: 'Sabah 08:00',
                      isTaken: true,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildMedicationCard(
                      name: 'Memantin 20mg',
                      time: 'Akşam 20:00',
                      isTaken: false,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const SectionTitle(text: 'Sevdiklerin'),
                    _buildMemoryGrid(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildDailyStatus(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_getGreeting(), style: AppTextStyles.bodyMedium),
              const Text('Ahmet Bey', style: AppTextStyles.headingLarge),
              const SizedBox(height: 4),
              Text(_getFormattedDate(), style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.teal50,
            borderRadius: AppRadius.lg,
            border: Border.all(color: AppColors.teal100, width: 2),
          ),
          child: const Center(
            child: Text('👴', style: TextStyle(fontSize: 28)),
          ),
        ),
      ],
    );
  }

  Widget _buildSOSButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _onSOSPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.coral400,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
          elevation: 0,
        ),
        icon: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white70, width: 2),
          ),
          child: const Center(
            child: Text(
              '!',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        label: const Text(
          'Acil Durum',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildMedicationCard({
    required String name,
    required String time,
    required bool isTaken,
  }) {
    return AppCard(
      color: AppColors.teal50,
      borderColor: AppColors.teal100,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.teal400,
              borderRadius: AppRadius.md,
            ),
            child: const Center(
              child: Text('💊', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.teal800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.teal600,
                  ),
                ),
              ],
            ),
          ),
          isTaken
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.teal400,
                    borderRadius: AppRadius.full,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Alındı',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : ElevatedButton(
                  onPressed: () => _onMedicationTaken(name),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Aldım'),
                ),
        ],
      ),
    );
  }

  Widget _buildMemoryGrid() {
    final people = [
      {
        'emoji': '👩',
        'name': 'Fatma',
        'relation': 'Eşi',
        'color': AppColors.teal50,
      },
      {
        'emoji': '👦',
        'name': 'Mehmet',
        'relation': 'Oğlu',
        'color': AppColors.blue50,
      },
      {
        'emoji': '👧',
        'name': 'Zeynep',
        'relation': 'Kızı',
        'color': AppColors.coral50,
      },
      {
        'emoji': '👨',
        'name': 'Ali',
        'relation': 'Kardeşi',
        'color': AppColors.amber50,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.4,
      ),
      itemCount: people.length,
      itemBuilder: (context, i) {
        final p = people[i];
        return GestureDetector(
          onTap: () => _onMemoryPersonTapped(p['name'] as String),
          child: AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: p['color'] as Color,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        p['emoji'] as String,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        p['name'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        p['relation'] as String,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyStatus() {
    return AppCard(
      color: AppColors.blue50,
      borderColor: AppColors.blue100,
      child: Row(
        children: [
          const Text('☀', style: TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bugün nasılsın?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0C447C),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Günlük ruh halini takipçilerinle paylaş',
                  style: TextStyle(fontSize: 12, color: Color(0xFF185FA5)),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.blue400),
        ],
      ),
    );
  }

  // ─── Actions ─────────────────────────────────────────────────────────────
  void _onSOSPressed() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
        title: const Text('Acil Durum', style: AppTextStyles.headingMedium),
        content: const Text(
          'Tüm takipçilerinize acil durum bildirimi gönderilecek. Devam etmek istiyor musunuz?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'İptal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Acil durum bildirimi gönderildi'),
                  backgroundColor: AppColors.coral400,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coral400,
            ),
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  void _onMedicationTaken(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name alındı olarak işaretlendi'),
        backgroundColor: AppColors.teal400,
      ),
    );
  }

  void _onMemoryPersonTapped(String name) {
    // Navigate to memory detail screen
    // Navigator.push(context, MaterialPageRoute(builder: (_) => MemoryDetailScreen(name: name)));
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Günaydın,';
    if (hour < 17) return 'İyi günler,';
    return 'İyi akşamlar,';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const days = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }
}
