import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../bloc/notification_permission_cubit.dart';
import '../bloc/notification_permission_state.dart';
import 'notification_permission_modal.dart';

/// Tüm uygulamayı veya belirli ekranları saran, bildirim izni verilmeden
/// uygulamanın kullanılmasına izin vermeyen koruyucu widget (Hard-Block Guard).
class NotificationPermissionGuard extends StatefulWidget {
  final Widget child;

  const NotificationPermissionGuard({
    super.key,
    required this.child,
  });

  @override
  State<NotificationPermissionGuard> createState() =>
      _NotificationPermissionGuardState();
}

class _NotificationPermissionGuardState
    extends State<NotificationPermissionGuard>
    with WidgetsBindingObserver {
  late final NotificationPermissionCubit _cubit;
  bool _isModalOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cubit = getIt<NotificationPermissionCubit>();

    // Router değişimlerini dinle (Splash ekranından çıkıldığında izin kontrolü yapmak için)
    appRouter.routerDelegate.addListener(_onRouteChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _evaluatePermission();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    appRouter.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Kullanıcı telefonun ayarlar ekranından uygulamaya geri döndüğünde (resumed)
    if (state == AppLifecycleState.resumed) {
      debugPrint(
        '📱 [NotificationPermissionGuard] Uygulama ön plana geldi (resumed). İzin yeniden kontrol ediliyor...',
      );
      _evaluatePermission();
    }
  }

  void _onRouteChanged() {
    // Rota değiştiğinde (örneğin /splash -> /login veya /splash -> /patient/home)
    _evaluatePermission();
  }

  bool _isAtSplashScreen() {
    try {
      final location = appRouter.routerDelegate.currentConfiguration.uri.toString();
      return location.isEmpty || location == '/splash';
    } catch (_) {
      return false;
    }
  }

  Future<void> _evaluatePermission() async {
    // 1. KURAL: Splash ekranındayken kesinlikle modal açma ve takılma yaratma
    if (_isAtSplashScreen()) {
      return;
    }

    await _cubit.checkPermission();
  }

  void _showModal(BuildContext context) {
    if (_isModalOpen || !mounted) return;
    _isModalOpen = true;

    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (modalContext) {
        return BlocProvider.value(
          value: _cubit,
          child: const NotificationPermissionModal(),
        );
      },
    ).then((_) {
      _isModalOpen = false;
    });
  }

  void _closeModal(BuildContext context) {
    if (_isModalOpen && mounted) {
      _isModalOpen = false;
      final nav = Navigator.of(context, rootNavigator: true);
      if (nav.canPop()) {
        nav.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<NotificationPermissionCubit, NotificationPermissionState>(
        listener: (context, state) {
          // Splash ekranındaysak hiçbir işlem yapma
          if (_isAtSplashScreen()) {
            return;
          }

          if (state is NotificationPermissionDenied) {
            _showModal(context);
          } else if (state is NotificationPermissionGranted) {
            _closeModal(context);
          }
        },
        child: widget.child,
      ),
    );
  }
}
