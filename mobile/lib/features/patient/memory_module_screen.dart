import 'package:flutter/material.dart';
import '/core/app_theme.dart';
import '/core/shared_widgets.dart';

// ─── Data Model ──────────────────────────────────────────────────────────────
class MemoryPerson {
  final String name;
  final String relationship;
  final String emoji;
  final String voiceMessage;
  final Color cardColor;
  final List<String> photoEmojis;

  const MemoryPerson({
    required this.name,
    required this.relationship,
    required this.emoji,
    required this.voiceMessage,
    required this.cardColor,
    required this.photoEmojis,
  });
}

// ─── Screen ──────────────────────────────────────────────────────────────────
class MemoryModuleScreen extends StatefulWidget {
  const MemoryModuleScreen({super.key});

  @override
  State<MemoryModuleScreen> createState() => _MemoryModuleScreenState();
}

class _MemoryModuleScreenState extends State<MemoryModuleScreen> {
  int _currentIndex = 0;

  final List<MemoryPerson> _people = const [
    MemoryPerson(
      name: 'Fatma Hanım',
      relationship: 'Eşiniz • 42 yıldır birliktesiniz',
      emoji: '👩',
      voiceMessage: '"Seni çok seviyorum Ahmet. Her zaman yanındayım."',
      cardColor: AppColors.teal50,
      photoEmojis: ['📷', '🏡', '💒'],
    ),
    MemoryPerson(
      name: 'Mehmet',
      relationship: 'Oğlunuz • İstanbul\'da yaşıyor',
      emoji: '👦',
      voiceMessage: '"Babacığım, seni çok özledim. Yarın geliyorum."',
      cardColor: AppColors.blue50,
      photoEmojis: ['📷', '⚽', '🎓'],
    ),
    MemoryPerson(
      name: 'Zeynep',
      relationship: 'Kızınız • Ankara\'da yaşıyor',
      emoji: '👧',
      voiceMessage:
          '"Baba, seni çok seviyoruz. Geçen hafta ki piknik harikaydı!"',
      cardColor: AppColors.coral50,
      photoEmojis: ['📷', '🎨', '🌸'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sevdiklerin 💝'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                itemCount: _people.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (ctx, i) => _PersonCard(person: _people[i]),
              ),
            ),
            _buildPageIndicator(),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 2,
        items: const [
          AppNavItem(icon: Icons.home_rounded, label: 'Ana Sayfa'),
          AppNavItem(icon: Icons.medication_rounded, label: 'İlaçlar'),
          AppNavItem(icon: Icons.photo_album_rounded, label: 'Anılar'),
          AppNavItem(icon: Icons.call_rounded, label: 'Ara'),
        ],
        onTap: (_) {},
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _people.length,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == _currentIndex ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == _currentIndex ? AppColors.teal400 : AppColors.border,
            borderRadius: AppRadius.full,
          ),
        ),
      ),
    );
  }
}

// ─── Person Card ─────────────────────────────────────────────────────────────
class _PersonCard extends StatefulWidget {
  final MemoryPerson person;
  const _PersonCard({required this.person});

  @override
  State<_PersonCard> createState() => _PersonCardState();
}

class _PersonCardState extends State<_PersonCard>
    with SingleTickerProviderStateMixin {
  bool _isPlayingVoice = false;
  late AnimationController _voiceAnimCtrl;

  @override
  void initState() {
    super.initState();
    _voiceAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _voiceAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        children: [
          Expanded(
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildPhotoArea(),
                  Expanded(child: _buildInfoArea()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoArea() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: widget.person.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              widget.person.emoji,
              style: const TextStyle(fontSize: 80),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Row(
              children: widget.person.photoEmojis
                  .map(
                    (e) => Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.only(left: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: AppRadius.sm,
                      ),
                      child: Center(
                        child: Text(e, style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoArea() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.person.name, style: AppTextStyles.headingLarge),
          const SizedBox(height: 4),
          Text(widget.person.relationship, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.lg),
          _buildVoiceMessageCard(),
          const Spacer(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildVoiceMessageCard() {
    return GestureDetector(
      onTap: _toggleVoice,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: AppRadius.md,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isPlayingVoice ? AppColors.teal400 : AppColors.teal50,
                borderRadius: AppRadius.sm,
              ),
              child: Icon(
                _isPlayingVoice
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: _isPlayingVoice ? Colors.white : AppColors.teal400,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.person.voiceMessage,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (_isPlayingVoice)
                    _VoiceWaveform()
                  else
                    const Text(
                      'Sesli mesajı oynat',
                      style: TextStyle(fontSize: 11, color: AppColors.teal600),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _toggleVoice,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal400,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
            ),
            icon: Icon(
              _isPlayingVoice ? Icons.pause_rounded : Icons.volume_up_rounded,
              size: 18,
            ),
            label: Text(
              _isPlayingVoice ? 'Durdur' : 'Sesli Mesaj',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.teal400,
              side: const BorderSide(color: AppColors.teal200, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
            ),
            icon: const Icon(Icons.photo_library_outlined, size: 18),
            label: const Text(
              'Fotoğraflar',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleVoice() {
    setState(() {
      _isPlayingVoice = !_isPlayingVoice;
      if (_isPlayingVoice) {
        _voiceAnimCtrl.repeat(reverse: true);
      } else {
        _voiceAnimCtrl.stop();
      }
    });
  }
}

// ─── Voice Waveform ───────────────────────────────────────────────────────────
class _VoiceWaveform extends StatefulWidget {
  @override
  State<_VoiceWaveform> createState() => _VoiceWaveformState();
}

class _VoiceWaveformState extends State<_VoiceWaveform>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  final List<double> _heights = [6, 10, 14, 10, 8, 14, 6, 10, 12, 8];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _heights.length,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300 + (i * 50)),
      )..repeat(reverse: true),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: Row(
        children: List.generate(
          _heights.length,
          (i) => AnimatedBuilder(
            animation: _controllers[i],
            builder: (_, __) => Container(
              width: 3,
              height: 4 + (_heights[i] * _controllers[i].value),
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: AppColors.teal400,
                borderRadius: AppRadius.full,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
