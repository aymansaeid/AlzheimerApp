import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notification_permission_cubit.dart';
import '../bloc/notification_permission_state.dart';

class NotificationPermissionModal extends StatelessWidget {
  const NotificationPermissionModal({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Üst çekme çubuğu göstergesi (Tıklanamaz/Sürüklense de kapanmaz)
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),

              // Uyarı Rozeti
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.red.shade200,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.red.shade700,
                  size: 38,
                ),
              ),
              const SizedBox(height: 20),

              // Başlık
              Text(
                'Bildirim İzni Zorunludur',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Açıklama Metni
              Text(
                'Alzheimer hasta güvenliği ve acil durum müdahaleleri için bildirim izni hayati önem taşır. Bildirimler olmadan acil uyarılar ve ilaç alarmları iletilemez.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Hayati Nedenler Kartı
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    _buildReasonRow(
                      icon: Icons.shield_outlined,
                      iconColor: Colors.blue.shade700,
                      title: 'Güvenli Bölge İhlalleri',
                      subtitle: 'Hasta güvenli alanın dışına çıktığında acil bildirim.',
                    ),
                    const Divider(height: 20),
                    _buildReasonRow(
                      icon: Icons.medication_outlined,
                      iconColor: Colors.teal.shade700,
                      title: 'Zamanında İlaç Hatırlatıcıları',
                      subtitle: 'Uygulama kapalı olsa dahi tam saatinde sesli alarmlar.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // İzin İste / Ayarları Aç Butonu
              BlocBuilder<NotificationPermissionCubit, NotificationPermissionState>(
                builder: (context, state) {
                  final isChecking = state is NotificationPermissionChecking;

                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isChecking
                          ? null
                          : () {
                              context
                                  .read<NotificationPermissionCubit>()
                                  .requestPermission();
                            },
                      icon: isChecking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.settings_outlined, size: 22),
                      label: Text(
                        isChecking
                            ? 'İzin Kontrol Ediliyor...'
                            : 'Bildirimlere İzin Ver / Ayarları Aç',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              // Alt Bilgilendirme İpucu
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'İzin verildiğinde bu ekran otomatik kapanacaktır.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReasonRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
