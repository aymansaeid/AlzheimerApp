import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../location_tracking/data/services/location_bg_service.dart';
import '../../../location_tracking/data/services/location_permission_service.dart';

class LocationPermissionRequiredPage extends StatefulWidget {
  final VoidCallback? onPermissionGranted;

  const LocationPermissionRequiredPage({
    super.key,
    this.onPermissionGranted,
  });

  @override
  State<LocationPermissionRequiredPage> createState() =>
      _LocationPermissionRequiredPageState();
}

class _LocationPermissionRequiredPageState
    extends State<LocationPermissionRequiredPage>
    with WidgetsBindingObserver {
  final LocationPermissionService _permissionService =
      getIt<LocationPermissionService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Kullanıcı telefon ayarlarından uygulamaya geri döndüğünde otomatik kontrol et
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndRedirectIfGranted();
    }
  }

  Future<void> _checkAndRedirectIfGranted() async {
    final status = await _permissionService.checkStatus(requireAlways: true);
    if (status == LocationAccessStatus.granted && mounted) {
      await LocationBgService.startTrackingIfNeeded();
      if (!mounted) return;
      if (widget.onPermissionGranted != null) {
        widget.onPermissionGranted!();
      } else {
        context.go('/patient/home');
      }
    }
  }

  Future<void> _handlePermissionAction() async {
    final status = await _permissionService.requestPermission(
      requireAlways: true,
    );
    if (!mounted) return;

    if (status == LocationAccessStatus.granted) {
      await LocationBgService.startTrackingIfNeeded();
      if (!mounted) return;
      if (widget.onPermissionGranted != null) {
        widget.onPermissionGranted!();
      } else {
        context.go('/patient/home');
      }
    } else {
      // İzin kalıcı reddedildiyse veya GPS kapalıysa doğrudan Ayarları aç
      await _permissionService.openSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Geri tuşuyla hasta ekranına kaçmasını engelliyoruz
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Konum İzni Zorunlu'),
          automaticallyImplyLeading: false,
          actions: [
            TextButton.icon(
              onPressed: () =>
                  context.read<AuthBloc>().add(AuthLogoutRequested()),
              icon: const Icon(Icons.logout),
              label: const Text('Çıkış Yap'),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_off_rounded,
                  size: 80,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Konum İzni Olmadan Devam Edilemez',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              const Text(
                'Bu uygulama güvenliğiniz için konumunuzu belirli aralıklarla yakınlarınıza iletir. '
                'Uygulamayı hasta modunda kullanabilmek için konum servislerini açmanız ve '
                '"Her Zaman İzin Ver" seçeneğini aktif etmeniz gerekmektedir.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _handlePermissionAction,
                icon: const Icon(Icons.settings),
                label: const Text(
                  'İzin Ver / Ayarlara Git',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _checkAndRedirectIfGranted,
                icon: const Icon(Icons.refresh),
                label: const Text('İzni Açtım, Tekrar Kontrol Et'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
