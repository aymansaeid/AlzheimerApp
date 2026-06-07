import 'package:flutter/material.dart';
import '../../../../core/widgets/app_card.dart';

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

class MemoryModuleScreen extends StatefulWidget {
  final List<MemoryPerson> people;
  final VoidCallback onAddMemory;

  const MemoryModuleScreen({
    super.key,
    required this.onAddMemory,
    this.people = const [
      MemoryPerson(
        name: 'Fatma Hanım',
        relationship: 'Eşiniz • 42 yıldır birliktesiniz',
        emoji: '👩',
        voiceMessage: '"Seni çok seviyorum Ahmet. Her zaman yanındayım."',
        cardColor: Color(0xFFE1F5EE),
        photoEmojis: ['📷', '🏡', '💒'],
      ),
      MemoryPerson(
        name: 'Mehmet',
        relationship: 'Oğlunuz • İstanbul\'da yaşıyor',
        emoji: '👦',
        voiceMessage: '"Babacığım, seni çok özledim. Yarın geliyorum."',
        cardColor: Color(0xFFE6F1FB),
        photoEmojis: ['📷', '⚽', '🎓'],
      ),
    ],
  });

  @override
  State<MemoryModuleScreen> createState() => _MemoryModuleScreenState();
}

class _MemoryModuleScreenState extends State<MemoryModuleScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sevdiklerin 💝'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: theme.colorScheme.outlineVariant),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                itemCount: widget.people.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (ctx, i) => _PersonCard(person: widget.people[i]),
              ),
            ),
            _buildPageIndicator(theme),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.people.length,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == _currentIndex ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == _currentIndex
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

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
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        children: [
          Expanded(
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildPhotoArea(theme),
                  Expanded(child: _buildInfoArea(theme)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoArea(ThemeData theme) {
    return Container(
      height: 220,
      decoration: BoxDecoration(color: widget.person.cardColor),
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
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
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

  Widget _buildInfoArea(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.person.name, style: theme.textTheme.headlineLarge),
          const SizedBox(height: 4),
          Text(widget.person.relationship, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          _buildVoiceMessageCard(theme),
          const Spacer(),
          _buildActionButtons(theme),
        ],
      ),
    );
  }

  Widget _buildVoiceMessageCard(ThemeData theme) {
    return GestureDetector(
      onTap: _toggleVoice,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isPlayingVoice
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isPlayingVoice
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: _isPlayingVoice
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.person.voiceMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (_isPlayingVoice)
                    _VoiceWaveform()
                  else
                    Text(
                      'Sesli mesajı oynat',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _toggleVoice,
            icon: Icon(
              _isPlayingVoice ? Icons.pause_rounded : Icons.volume_up_rounded,
              size: 20,
            ),
            label: Text(
              _isPlayingVoice ? 'Durdur' : 'Sesli Mesaj',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.photo_library_outlined, size: 20),
            label: const Text('Fotoğraflar', style: TextStyle(fontSize: 16)),
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
    final theme = Theme.of(context);
    return SizedBox(
      height: 18,
      child: Row(
        children: List.generate(
          _heights.length,
          (i) => AnimatedBuilder(
            animation: _controllers[i],
            builder: (_, _) => Container(
              width: 3,
              height: 4 + (_heights[i] * _controllers[i].value),
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
